Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id F04476B40ED
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 10:28:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h5-v6so8687260itb.3
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:28:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10-v6sor5375730iob.204.2018.08.27.07.28.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 07:28:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180827103353.GB13848@rapoport-lnx>
References: <20180827082101.5036-1-brgl@bgdev.pl> <20180827103353.GB13848@rapoport-lnx>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Mon, 27 Aug 2018 16:28:55 +0200
Message-ID: <CAMRc=MdZ_1Vk2c19L-spzOm=7UaDpaACriq4gzMxAvQz=noNgQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] devres: provide devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2018-08-27 12:33 GMT+02:00 Mike Rapoport <rppt@linux.vnet.ibm.com>:
> On Mon, Aug 27, 2018 at 10:21:00AM +0200, Bartosz Golaszewski wrote:
>> Provide a resource managed version of kstrdup_const(). This variant
>> internally calls devm_kstrdup() on pointers that are outside of
>> .rodata section. Also provide a corresponding version of devm_kfree().
>>
>> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
>> ---
>>  include/linux/device.h |  2 ++
>>  mm/util.c              | 35 +++++++++++++++++++++++++++++++++++
>>  2 files changed, 37 insertions(+)
>>
>> diff --git a/include/linux/device.h b/include/linux/device.h
>> index 8f882549edee..f8f5982d26b2 100644
>> --- a/include/linux/device.h
>> +++ b/include/linux/device.h
>> @@ -693,7 +693,9 @@ static inline void *devm_kcalloc(struct device *dev,
>>       return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
>>  }
>>  extern void devm_kfree(struct device *dev, void *p);
>> +extern void devm_kfree_const(struct device *dev, void *p);
>>  extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
>> +extern char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp);
>>  extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
>>                         gfp_t gfp);
>>
>> diff --git a/mm/util.c b/mm/util.c
>> index d2890a407332..6d1f41b5775e 100644
>> --- a/mm/util.c
>> +++ b/mm/util.c
>> @@ -39,6 +39,20 @@ void kfree_const(const void *x)
>>  }
>>  EXPORT_SYMBOL(kfree_const);
>>
>> +/**
>> + * devm_kfree_const - Resource managed conditional kfree
>> + * @dev: device this memory belongs to
>> + * @p: memory to free
>> + *
>> + * Function calls devm_kfree only if @p is not in .rodata section.
>> + */
>> +void devm_kfree_const(struct device *dev, void *p)
>> +{
>> +     if (!is_kernel_rodata((unsigned long)p))
>> +             devm_kfree(dev, p);
>> +}
>> +EXPORT_SYMBOL(devm_kfree_const);
>> +
>>  /**
>>   * kstrdup - allocate space for and copy an existing string
>>   * @s: the string to duplicate
>> @@ -78,6 +92,27 @@ const char *kstrdup_const(const char *s, gfp_t gfp)
>>  }
>>  EXPORT_SYMBOL(kstrdup_const);
>>
>> +/**
>> + * devm_kstrdup_const - resource managed conditional string duplication
>> + * @dev: device for which to duplicate the string
>> + * @s: the string to duplicate
>> + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
>> + *
>> + * Function returns source string if it is in .rodata section otherwise it
>> + * fallbacks to devm_kstrdup.
>
> Please make it proper "Returns:" description and move to the end of the
> comment. See Documentation/doc-guide/kernel-doc.rst.
>

Sure.

>> + * Strings allocated by devm_kstrdup_const will be automatically freed when
>> + * the associated device is detached.
>> + */
>> +char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp)
>> +{
>> +     if (is_kernel_rodata((unsigned long)s))
>> +             return s;
>> +
>> +     return devm_kstrdup(dev, s, gfp);
>> +}
>> +EXPORT_SYMBOL(devm_kstrdup_const);
>> +
>
> The devm_ variants seem to belong to drivers/base/devres.c rather than
> mm/util.c
>

Not all devm_ variants live in drivers/base/devres.c, many subsystems
implement them locally. In this case we need to choose between
exporting is_kernel_rodata() and putting devm_kstrdup_const() in
mm/util.c. I chose the latter, since it's cleaner.

Bart

>>  /**
>>   * kstrndup - allocate space for and copy an existing string
>>   * @s: the string to duplicate
>> --
>> 2.18.0
>>
>
> --
> Sincerely yours,
> Mike.
>
