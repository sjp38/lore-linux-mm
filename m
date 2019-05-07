Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800BDC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2262120825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:17:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="P0ZMkXR8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2262120825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A74F36B026B; Tue,  7 May 2019 17:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A26A56B026C; Tue,  7 May 2019 17:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EE976B026D; Tue,  7 May 2019 17:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 643766B026B
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:17:29 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id i21so9916726otf.4
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yac5Q1Bb3Ab84Ay+I6HErMslUzRcn/poLQApwzJN+zw=;
        b=IQvYx16gZOOgY4tI8oUesgJDOZc5bGlpITJC86pulXEaTvTZSFNZj2i10n9zjlM/YC
         EXRAZfAYhdxZArzYoCDsXbBoy6FqXPZOGjG1mUq70FnR1b6BVIqCue7wdPA3lBdJ1v9y
         ZslC27hI8SHlU2ElkvmvB4Ao778O9PdJD+soQYLjD5ZlZ5RaY4Dp6Pcr683HFVQCloJL
         cTY/Xve4YcjxrYAZgsJ8bi2p5iT+ioQi0BUAhBcTZp9uad/AjkUg+L73jmpVi3esJoDL
         +KIgu/JuZ9enqi0ZeDed3dtjdLhHe1zH6A/MGGk27Fh0cNk7KYcxb9qDaJd7uP0Q/fj7
         NIeQ==
X-Gm-Message-State: APjAAAXavSD6zLXcpnbeFSOjL7EGP/Q/fuc2TmRJp/uWRGTOwHWp8MHx
	81s8yMT7oMd04yZlzCUV88aqZkZFj5/pY6l+9cRYNcttUhW9iPN+6/JfwYcdfEYem5W+rlghI8f
	BF8p1qhxqgfByZIGpII7FdfOVr0BcJ4jQPX4iKC3HeCMslbK4Y3pUyHAXpQP9/OPGXw==
X-Received: by 2002:aca:3784:: with SMTP id e126mr342076oia.85.1557263849095;
        Tue, 07 May 2019 14:17:29 -0700 (PDT)
X-Received: by 2002:aca:3784:: with SMTP id e126mr342024oia.85.1557263848181;
        Tue, 07 May 2019 14:17:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557263848; cv=none;
        d=google.com; s=arc-20160816;
        b=rbPdqsRDByi6XhUKsc/DQ43z4K/gzWV1iW/QsQtIUpFOeJhGHmZDW5vWut+Slemp3w
         YTQrtIKF3hjlWQ/tuuRkmyf+seYw3bcBbVRAG32T+kA0i2I//jpHeHY1LAeEPGOjr41G
         2Qdp7FWb2ahbx2jRceryjbMb3WA4nLnCE1jbUkyz9Z1jmpN3LA1antOnPju/g+/52Gyv
         3Xx1v1smES2wOXDjJQgGtHGSs3okMiQuW5HDUFZpRYcw6luSHofr1R1Kj9Pte5rxlRVk
         PqaRGW/qZtFgWOXlugckIUcgQLbE5xjQdLx1bfwpHveHaF4ixo1Q6gUfYqOdOED4biyj
         9N2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yac5Q1Bb3Ab84Ay+I6HErMslUzRcn/poLQApwzJN+zw=;
        b=GlCKCpGBTSs2kr3apI0LgyQYqFTZ97cU1i8hqOm7+qWV5Y7oZkc9lKov9drdblw6hf
         mkoq66LVab2KK3cL3eUObWZMX6xtfOTGGKTIxqC8iphpsYzvHjKJwaGZuJ4d79xgKBte
         3l2lduaMsdjfZrPIFFo/YH3uDm4xujCpNcZAXyGxhIYl9V45SkPBeJz2VRainf98rYMw
         NIC5F9tWKt0RUfTWuXY0C/t/QEqKz9uSTwvhpfOm5gF8zzA9g2xv/OYyp32LmeUdc/aT
         8U9FSyoYYSZwauYf3zht97ZMa5MfMjHeW/DWX6RyRQ8UE52A0hP3sxE0UZwLWN+EdqfG
         jV9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=P0ZMkXR8;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k25sor5985598otr.49.2019.05.07.14.17.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 14:17:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=P0ZMkXR8;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yac5Q1Bb3Ab84Ay+I6HErMslUzRcn/poLQApwzJN+zw=;
        b=P0ZMkXR8O3azRABsQBk3fAiZsBICKK6woNtr3VYs0ZFJm/DvszyJEJqsbJAYawfB3a
         Xvj8D6rghVEK2rY82za7fMdhDibQLUABrUCxHI4BB/pqKz7rx/MfmvzKuJRw6pNa3A7D
         KBnOyc0YAs8D8BY3PQjaND30uCMwr6w4OFscsNLSS5FBZcdOXzXgkp45cYemuprD/paT
         W3n4UWSpfXuwgpr1d0iusWBxC1GncaYHffTd7h/+nSY4ucDurChHbhQI31DqauRT+2RE
         mzhzzx/ALUPMvLbdU0ufPMuQncfKhkb36/xh1vYx/tA8qS8tdHHzNZkhvU452Sw89KKb
         HYhg==
X-Google-Smtp-Source: APXvYqwpTU7vZoZskSKJhr6wZc5gbJ6Tsf40ceB5At3BV8uMhV+H1AUAbI+Q9cyXIDuDMu06rBaOcSwIZ2goRxtCNJA=
X-Received: by 2002:a9d:222c:: with SMTP id o41mr23279424ota.353.1557263847435;
 Tue, 07 May 2019 14:17:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-5-david@redhat.com>
In-Reply-To: <20190507183804.5512-5-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 14:17:16 -0700
Message-ID: <CAPcyv4jiVyaPbUrQwSiy65xk=EegJwuGSDKkVYWkGiTJz847gg@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	"mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, 
	Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, 
	Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, 
	Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> Only memory to be added to the buddy and to be onlined/offlined by
> user space using memory block devices needs (and should have!) memory
> block devices.
>
> Factor out creation of memory block devices Create all devices after
> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
> because it is now effectively stale.
>
> Only after memory block devices have been added, memory can be onlined
> by user space. This implies, that memory is not visible to user space at
> all before arch_add_memory() succeeded.

Nice!

>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    | 15 ++++-----
>  3 files changed, 53 insertions(+), 34 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 6e0cb4fda179..862c202a18ca 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
>         return 0;
>  }
>
> +static void unregister_memory(struct memory_block *memory)
> +{
> +       BUG_ON(memory->dev.bus != &memory_subsys);

Given this should never happen and only a future kernel developer
might trip over it, do we really need to kill that developer's
machine? I.e. s/BUG/WARN/? I guess an argument can be made to move
such a change that to a follow-on patch since you're just preserving
existing behavior, but I figure might as well address these as the
code is refactored.

> +
> +       /* drop the ref. we got via find_memory_block() */
> +       put_device(&memory->dev);
> +       device_unregister(&memory->dev);
> +}
> +
>  /*
> - * need an interface for the VM to add new memory regions,
> - * but without onlining it.
> + * Create memory block devices for the given memory area. Start and size
> + * have to be aligned to memory block granularity. Memory block devices
> + * will be initialized as offline.
>   */
> -int hotplug_memory_register(int nid, struct mem_section *section)
> +int hotplug_memory_register(unsigned long start, unsigned long size)
>  {
> -       int ret = 0;
> +       unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
> +       unsigned long start_pfn = PFN_DOWN(start);
> +       unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +       unsigned long pfn;
>         struct memory_block *mem;
> +       int ret = 0;
>
> -       mutex_lock(&mem_sysfs_mutex);
> +       BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
> +       BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));

Perhaps:

    if (WARN_ON(...))
        return -EINVAL;

>
> -       mem = find_memory_block(section);
> -       if (mem) {
> -               mem->section_count++;
> -               put_device(&mem->dev);
> -       } else {
> -               ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +       mutex_lock(&mem_sysfs_mutex);
> +       for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +               mem = find_memory_block(__pfn_to_section(pfn));
> +               if (mem) {
> +                       WARN_ON_ONCE(false);

?? Isn't that a nop?

> +                       put_device(&mem->dev);
> +                       continue;
> +               }
> +               ret = init_memory_block(&mem, __pfn_to_section(pfn),
> +                                       MEM_OFFLINE);
>                 if (ret)
> -                       goto out;
> -               mem->section_count++;
> +                       break;
> +               mem->section_count = memory_block_size_bytes() /
> +                                    MIN_MEMORY_BLOCK_SIZE;
> +       }
> +       if (ret) {
> +               end_pfn = pfn;
> +               for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +                       mem = find_memory_block(__pfn_to_section(pfn));
> +                       if (!mem)
> +                               continue;
> +                       mem->section_count = 0;
> +                       unregister_memory(mem);
> +               }
>         }
> -
> -out:
>         mutex_unlock(&mem_sysfs_mutex);
>         return ret;
>  }
>
> -static void
> -unregister_memory(struct memory_block *memory)
> -{
> -       BUG_ON(memory->dev.bus != &memory_subsys);
> -
> -       /* drop the ref. we got via find_memory_block() */
> -       put_device(&memory->dev);
> -       device_unregister(&memory->dev);
> -}
> -
> -void unregister_memory_section(struct mem_section *section)
> +static int remove_memory_section(struct mem_section *section)
>  {
>         struct memory_block *mem;
>
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 474c7c60c8f2..95505fbb5f85 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> -int hotplug_memory_register(int nid, struct mem_section *section);
> +int hotplug_memory_register(unsigned long start, unsigned long size);
>  extern void unregister_memory_section(struct mem_section *);
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 7b5439839d67..e1637c8a0723 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -258,13 +258,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>                 return -EEXIST;
>
>         ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
> -       if (ret < 0)
> -               return ret;
> -
> -       if (!want_memblock)
> -               return 0;
> -
> -       return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
> +       return ret < 0 ? ret : 0;
>  }
>
>  /*
> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>         if (ret < 0)
>                 goto error;
>
> +       /* create memory block devices after memory was added */
> +       ret = hotplug_memory_register(start, size);
> +       if (ret) {
> +               arch_remove_memory(nid, start, size, NULL);
> +               goto error;
> +       }
> +
>         if (new_node) {
>                 /* If sysfs file of new node can't be created, cpu on the node
>                  * can't be hot-added. There is no rollback way now.
> --
> 2.20.1
>

