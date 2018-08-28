Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC816B44B0
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:33:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c25-v6so356149edb.12
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 23:33:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b10-v6si584351edk.422.2018.08.27.23.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 23:33:04 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7S6SkkG067451
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:33:03 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m513y081k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:33:03 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 28 Aug 2018 07:33:00 +0100
Date: Tue, 28 Aug 2018 09:32:50 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] devres: provide devm_kstrdup_const()
References: <20180827082101.5036-1-brgl@bgdev.pl>
 <20180827103353.GB13848@rapoport-lnx>
 <CAMRc=MdZ_1Vk2c19L-spzOm=7UaDpaACriq4gzMxAvQz=noNgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMRc=MdZ_1Vk2c19L-spzOm=7UaDpaACriq4gzMxAvQz=noNgQ@mail.gmail.com>
Message-Id: <20180828063250.GB25317@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Aug 27, 2018 at 04:28:55PM +0200, Bartosz Golaszewski wrote:
> 2018-08-27 12:33 GMT+02:00 Mike Rapoport <rppt@linux.vnet.ibm.com>:
> > On Mon, Aug 27, 2018 at 10:21:00AM +0200, Bartosz Golaszewski wrote:
> >> Provide a resource managed version of kstrdup_const(). This variant
> >> internally calls devm_kstrdup() on pointers that are outside of
> >> .rodata section. Also provide a corresponding version of devm_kfree().
> >>
> >> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> >> ---
> >>  include/linux/device.h |  2 ++
> >>  mm/util.c              | 35 +++++++++++++++++++++++++++++++++++
> >>  2 files changed, 37 insertions(+)
> >>
> >> diff --git a/include/linux/device.h b/include/linux/device.h
> >> index 8f882549edee..f8f5982d26b2 100644
> >> --- a/include/linux/device.h
> >> +++ b/include/linux/device.h
> >> @@ -693,7 +693,9 @@ static inline void *devm_kcalloc(struct device *dev,
> >>       return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
> >>  }
> >>  extern void devm_kfree(struct device *dev, void *p);
> >> +extern void devm_kfree_const(struct device *dev, void *p);
> >>  extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
> >> +extern char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp);
> >>  extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
> >>                         gfp_t gfp);
> >>
> >> diff --git a/mm/util.c b/mm/util.c
> >> index d2890a407332..6d1f41b5775e 100644
> >> --- a/mm/util.c
> >> +++ b/mm/util.c

[ ... ]

> >> + * Strings allocated by devm_kstrdup_const will be automatically freed when
> >> + * the associated device is detached.
> >> + */
> >> +char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp)
> >> +{
> >> +     if (is_kernel_rodata((unsigned long)s))
> >> +             return s;
> >> +
> >> +     return devm_kstrdup(dev, s, gfp);
> >> +}
> >> +EXPORT_SYMBOL(devm_kstrdup_const);
> >> +
> >
> > The devm_ variants seem to belong to drivers/base/devres.c rather than
> > mm/util.c
> >
> 
> Not all devm_ variants live in drivers/base/devres.c, many subsystems
> implement them locally. In this case we need to choose between
> exporting is_kernel_rodata() and putting devm_kstrdup_const() in
> mm/util.c. I chose the latter, since it's cleaner.

I rather think that moving is_kernel_rodata() to
include/asm-generic/sections.h and having devm_kstrdup_const() next to
devm_kstrdup() would be cleaner.
 
> Bart
> 

-- 
Sincerely yours,
Mike.
