Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08A59C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:05:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A217D2087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:05:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="bkbfhBFn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A217D2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 410A88E0009; Tue, 29 Jan 2019 15:05:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BE668E0002; Tue, 29 Jan 2019 15:05:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2609F8E0009; Tue, 29 Jan 2019 15:05:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA9278E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:05:03 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id a3so8337858otl.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:05:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yrWDUDhoyYGIFap6yXSC0PKoELQ511iVKxMkPwh5BQs=;
        b=CQzYPD+H3c3cF8DlTMyypEwO3BU/yEJO8rbei5UlTTlYCeHMVkdRWB3lBc/cDK66xN
         XR4lzN/2BsDKhUnTSAxuPY+k7q49YNZYg+9qU1MkGSSpJt56827J4lqrJc9NpM/aLX4M
         IV+rLFAbYvX9cuic62xW5aLZJC34dxex5dmAHAZVdYKgRiat0qnZ2zmgTSAFXSJnvzAe
         DMnVUB2iYl36bqqoxlRMdtODdG7/J5paYh9EJlXfipFmpHGQkMLya70W4C5VYT634KO7
         tRw6jdSQ6+RVcY6CLcIYva9bhFfjrES8wuNjvW13y9jIkC0erKM235iKLa2yG5/33BkM
         VJLw==
X-Gm-Message-State: AJcUukdfo+wn2+HNC+nH/idCSv99SjFt3FpjWqAMduMSQEeLZFW1nUKs
	6uA/cUSXfVHIuoM/Dl3t2uBS2XF3MvczklhlJI5hBex9PNoeyjpwZj5nstvuZV6/NcrlgP68QFe
	xHPBNDCkDu5fbmagU4ocFX/Z6ACi1/R/LhoKKJo1bv8TueyUuj+bRMCzRXaTtGsXOXLhndIKktt
	L8GDnI/dBmaBw0hntQX3LOO4N06hhu0JqI27RyZP1/qKtjm3yVa+FY0AOlp5fU8KhOKShV9ickW
	jj/t/Dvo8EO1CS8ocoZ2uxxXoB4MUAqSJTfET9q4elmbpi4eJuhCw42WUeE/oiNPH0WDQO/Fhp5
	jJ32zQ62r5Xx063ovVTBpn19Jp7hefO49fEEl17QEgufx1r23j54QNBTIP7/d2E69gAMIysTvNG
	8
X-Received: by 2002:aca:a11:: with SMTP id 17mr10046147oik.15.1548792303680;
        Tue, 29 Jan 2019 12:05:03 -0800 (PST)
X-Received: by 2002:aca:a11:: with SMTP id 17mr10046100oik.15.1548792302756;
        Tue, 29 Jan 2019 12:05:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548792302; cv=none;
        d=google.com; s=arc-20160816;
        b=Lxf+oJvAijVXTekfSLdyWxoHhkJIVyEByc708KcE83HtdMDkrNQFeUnEv29Cf/lKWA
         K6XETmpuyT90n26pPaa8GshHvkD2CTvzzfKVi9pnqrCGmq7KEO6uRQusR2pa7m3Zotxd
         zurBj5Jzp2lI9uMj30QsHygbAhWKFuQdKHn3ehhxZ906qcsVn8sKVpA6wjeGDOUx/Pby
         vkxial5qXTClHK5zPVJ61TW909jYEcYJIrgPALhTwTxsPmh70vZQFkXKq4AJ6+IayokO
         ap77juyIc6OpW0tqrXQYzwY9G9euGYCIWF1JHM8Lzb7TQfUwzQqEUDpsKnCK+D7RZhEK
         Agig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yrWDUDhoyYGIFap6yXSC0PKoELQ511iVKxMkPwh5BQs=;
        b=dOBAXNKAOXokH2Q2mj4SIbGEfHyyP43nCUL+0d7RQ4oYl1up3IDdn5XLenqmmy5nmt
         aUgdoieLD03QdLDKsnvf8YAuNCrCNnG1Ayx/BT/wxumfgvxymkRtAaUFoDOw7SCXCXsF
         4seMrT8eXaAiyCe7F/cJzUcPF5hbYf5xIB7wieSa+am296GUm2rno4TI/Q7npVX3HhtF
         MMAvKURdM92w+qRhnW+a1AqDhqlNnk2ioc1fm43g7D92BF0OhwzsTKacU4z/1qUJRLeh
         pJnfsWUz9oZMR0PJr27ve7Rj9wY/u2JJ01DJbW4MdSXRfg7X7BTT3LazMBtUHihZ4AZh
         r8Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=bkbfhBFn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor7840827otf.124.2019.01.29.12.05.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 12:05:02 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=bkbfhBFn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yrWDUDhoyYGIFap6yXSC0PKoELQ511iVKxMkPwh5BQs=;
        b=bkbfhBFnweMgDSJIBVXJkp8NaQJKZ2j7s9SAip2zlBn9qIwrIzv9q+jmcCbYaDTNdj
         OF/ashyFT5RdHTousv84tq6TkEAwiJJaaF67/1UqF6R9DAhfm8sA9QUS+p2RImf3n873
         8EKm0PzBd0MPUYZ5v9EpPQ/NKqkW78ggwiTYj0phzsaWG7Fm+fdJe9g9dDFMsFMgjoQX
         mLVPucdf4WBI7tBgnePkE5tzFWksqBoyfaxBl4Sb9gM9JqXjmsEdoaPggC2wYQ21+tuT
         1wqVajtp5WQ/4QRPflJ/ykekjBjij8HfzLlNRFdILQQA0eFq1iux1Pux5WQictG9vyui
         joOQ==
X-Google-Smtp-Source: ALg8bN6Lo/HuIjb8whLk3ikPLOMecohVb2/LO+CsbKt0AskAyGaeacF1dESBod+UnOVnYRrk0yEA4Sv1SQGK4iNG6n8=
X-Received: by 2002:a9d:7dd5:: with SMTP id k21mr21206645otn.214.1548792302276;
 Tue, 29 Jan 2019 12:05:02 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190125142039.GN3560@dhcp22.suse.cz>
In-Reply-To: <20190125142039.GN3560@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 29 Jan 2019 12:04:50 -0800
Message-ID: <CAPcyv4hB0YPcuvMZSjbDXkhnvHnt49jzi-NvNnE-8--aFiZKwA@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Whoops, did not reply to all your feedback, see below:

On Fri, Jan 25, 2019 at 6:21 AM Michal Hocko <mhocko@kernel.org> wrote:
[..]
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index cc4a507d7ca4..8c37a023a790 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1272,6 +1272,10 @@ void sparse_init(void);
> >  #else
> >  #define sparse_init()        do {} while (0)
> >  #define sparse_index_init(_sec, _nid)  do {} while (0)
> > +static inline int pfn_present(unsigned long pfn)
> > +{
> > +     return 1;
> > +}
>
> Does this really make sense? Shouldn't this default to pfn_valid on
> !sparsemem?

Yes, I think it should be pfn_valid()

>
> [...]
> > +config SHUFFLE_PAGE_ALLOCATOR
> > +     bool "Page allocator randomization"
> > +     depends on ACPI_NUMA
> > +     default SLAB_FREELIST_RANDOM
> > +     help
> > +       Randomization of the page allocator improves the average
> > +       utilization of a direct-mapped memory-side-cache. See section
> > +       5.2.27 Heterogeneous Memory Attribute Table (HMAT) in the ACPI
> > +       6.2a specification for an example of how a platform advertises
> > +       the presence of a memory-side-cache. There are also incidental
> > +       security benefits as it reduces the predictability of page
> > +       allocations to compliment SLAB_FREELIST_RANDOM, but the
> > +       default granularity of shuffling on 4MB (MAX_ORDER) pages is
> > +       selected based on cache utilization benefits.
> > +
> > +       While the randomization improves cache utilization it may
> > +       negatively impact workloads on platforms without a cache. For
> > +       this reason, by default, the randomization is enabled only
> > +       after runtime detection of a direct-mapped memory-side-cache.
> > +       Otherwise, the randomization may be force enabled with the
> > +       'page_alloc.shuffle' kernel command line parameter.
> > +
> > +       Say Y if unsure.
>
> Do we really need to make this a choice? Are any of the tiny systems
> going to be NUMA? Why cannot we just make it depend on ACPI_NUMA?

Kees wants to use this on ARM and I removed the ACPI_NUMA dependency
in v8 (you happened to review v7).

Given the setting has performance impact I believe it should allow for
being hard disabled at compile time, but I'll update the default to:

    default SLAB_FREELIST_RANDOM && ACPI_NUMA

>
> > +config SHUFFLE_PAGE_ORDER
> > +     depends on SHUFFLE_PAGE_ALLOCATOR
> > +     int "Page allocator shuffle order"
> > +     range 0 10
> > +     default 10
> > +     help
> > +       Specify the granularity at which shuffling (randomization) is
> > +       performed. By default this is set to MAX_ORDER-1 to minimize
> > +       runtime impact of randomization and with the expectation that
> > +       SLAB_FREELIST_RANDOM mitigates heap attacks on smaller
> > +       object granularities.
> > +
>
> and no, do not make this configurable here as already mentioned.

Will remove.

> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 022d4cbb3618..3602f7a2eab4 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -17,6 +17,7 @@
> >  #include <linux/poison.h>
> >  #include <linux/pfn.h>
> >  #include <linux/debugfs.h>
> > +#include <linux/shuffle.h>
> >  #include <linux/kmemleak.h>
> >  #include <linux/seq_file.h>
> >  #include <linux/memblock.h>
> > @@ -1929,9 +1930,16 @@ static unsigned long __init free_low_memory_core_early(void)
> >        *  low ram will be on Node1
> >        */
> >       for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
> > -                             NULL)
> > +                             NULL) {
> > +             pg_data_t *pgdat;
> > +
> >               count += __free_memory_core(start, end);
> >
> > +             for_each_online_pgdat(pgdat)
> > +                     shuffle_free_memory(pgdat, PHYS_PFN(start),
> > +                                     PHYS_PFN(end));
> > +     }
> > +
> >       return count;
> >  }
> >
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index b9a667d36c55..7caffb9a91ab 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -23,6 +23,7 @@
> >  #include <linux/highmem.h>
> >  #include <linux/vmalloc.h>
> >  #include <linux/ioport.h>
> > +#include <linux/shuffle.h>
> >  #include <linux/delay.h>
> >  #include <linux/migrate.h>
> >  #include <linux/page-isolation.h>
> > @@ -895,6 +896,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> >       zone->zone_pgdat->node_present_pages += onlined_pages;
> >       pgdat_resize_unlock(zone->zone_pgdat, &flags);
> >
> > +     shuffle_zone(zone, pfn, zone_end_pfn(zone));
> > +
> >       if (onlined_pages) {
> >               node_states_set_node(nid, &arg);
> >               if (need_zonelists_rebuild)
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index cde5dac6229a..2adcd6da8a07 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -61,6 +61,7 @@
> >  #include <linux/sched/rt.h>
> >  #include <linux/sched/mm.h>
> >  #include <linux/page_owner.h>
> > +#include <linux/shuffle.h>
> >  #include <linux/kthread.h>
> >  #include <linux/memcontrol.h>
> >  #include <linux/ftrace.h>
> > @@ -1634,6 +1635,8 @@ static int __init deferred_init_memmap(void *data)
> >       }
> >       pgdat_resize_unlock(pgdat, &flags);
> >
> > +     shuffle_zone(zone, first_init_pfn, zone_end_pfn(zone));
> > +
> >       /* Sanity check that the next zone really is unpopulated */
> >       WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
>
> I would prefer if would have less placess to place the shuffling. Why
> cannot we have a single place for the bootup and one for onlining part?
> page_alloc_init_late sounds like a good place for the later. You can
> miss some early allocations but are those of a big interest?

Ok, so you mean reduce the 3 callsites to 2. Replace the
free_low_memory_core_early() and deferred_init_memmap() sites with a
single shuffle call in page_alloc_init_late() after waiting for
deferred_init_memmap() work to complete? I don't see any red flags
with that, I'll give it a try.

> I haven't checked the actual shuffling algorithm, I will trust you on
> that part ;)

The algorithm has proved reliable. The breakage has only arisen from
missing locations that free large amounts of memory to the allocator
and failing to re-randomize within a whole zone, i.e. not just the
pages that were currently being hot-added.

