Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C0E0C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:26:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF5F520989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:26:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cxtBXQjr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF5F520989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 934CC8E0002; Tue, 29 Jan 2019 14:26:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90B758E0001; Tue, 29 Jan 2019 14:26:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 821628E0002; Tue, 29 Jan 2019 14:26:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57C488E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:26:40 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id p131so11258741oia.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:26:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ouNDxW1aE5KIRmfvk+0q+ZC0t1e1u22BjhYLnvkJJdU=;
        b=IM1DnHdGbGM3/oy40We0Ajb2p8WluDXXRGwCOnqevDmIPrJYhIj2eqYPGf9QZ0SmZ+
         X5/t/rENY1E//PayKGhdHCtyRbvYO8DE+oHip6mPjKLVruT9EaFrkUZRXAfcuvJspAym
         Q9s9ODC299WWBcnwL/Xhx7nfKAxJkUIkyo8xmF1dcu/hqE74kghCYjR4XgJRcUrIYNSe
         Er/Pf4UC1xs3tn5AcPX3gLKladvSKTfHVMUymQh3iSTa959dvYtMOqIvIqsnPnfcj83D
         sIydaREM1vrL8JYXeXUBS+FQMHjWOe11eGkYKvm+MqVyk3SqJq6ILGM4rkGeU4ORh8/2
         Ej6Q==
X-Gm-Message-State: AHQUAuaZEqy+EYmnhvBV8EEZNzAqrfwmhroS1DURn6/L5KibzkDp/hi8
	02DrY9XcJQTEbt7/avFbqzkvOgjLlEhLhTPR+24mJLAVtK7Rw8CSkpA0wei/NRPoZZNHoSxDY4P
	diW225hjfiPx+ra4N+xME+TAjWLYl7jaVmkiu0kxo79bRYekpAL/IrRhWfYWOsPa+6uhWxscFgp
	KG4Wctt7aSYENH+Wbe0460l0I1Os041+jyUSB1L/1osxTpDhNbgfRB435A5Z21xbBptu6Ej0hn/
	8A0eTcvD3toO+K7v8G2lN9q7trecmuxlv4AXP2Kn9OKnhQjTTeIL9m9LX0n8dBpmmQmWXLfH7Om
	/vXEpSDL51BVmV1X3rKvdaDO1HH5TzMp7lbq7IdNwuhcJHgl3v3frbZfjkvHYgbP/jFNyYvxkzM
	9
X-Received: by 2002:aca:5987:: with SMTP id n129mr10579447oib.174.1548790000035;
        Tue, 29 Jan 2019 11:26:40 -0800 (PST)
X-Received: by 2002:aca:5987:: with SMTP id n129mr10579400oib.174.1548789998891;
        Tue, 29 Jan 2019 11:26:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548789998; cv=none;
        d=google.com; s=arc-20160816;
        b=Azzp4cuMu3+4b4CcAZyIW4zQaa0xFRaZ1lw/soUn0yD1zH3EXb6IjLXV2DvVsthQs2
         x752pua1iQMTK3G2yydifQZFwG/2PnB+HHN3aZEe3uSeSID04jKUl679d2hxBPj/KvPT
         n8vjXz9RdiP85EwflHQQdX8iK7QomDJDZwC3XRI+xiSjW5vjDpsFncUH5rgZTkSMyOfO
         OQGi4UEdDLhTyalElSZ3opyAaKAHmJE3EnyYfSuIw+r5HknYjL6Nv5vPhkrPoWBRe1Sk
         GnuRVrIhKjTeVKReoCGWbNS3i10lPbb8DrXyX0vlY9wGQTrXu+ME40hXfzaJks7GNfw9
         eL2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ouNDxW1aE5KIRmfvk+0q+ZC0t1e1u22BjhYLnvkJJdU=;
        b=TNznA4VrSO50OulbcW7ehfLeWclaR5pKI/v3npvuXF1rOW5TB7p4H8+fnBAaIFWQnK
         VNXome4PVDSaNYC4r0i3JmUhKnBMGyyBE/S/f4+O1I1+Mpff3dHcfPmcf6fQYFHHwRRb
         C73UaURoSEtdeXVR0x5j/3KHUBDXbfHfYl4EVSTQppHCp9nsvuJX3f3Go5hsE9k7ra+h
         Oe+PeMs9mDK1T08TUPJzqssEadB3Q/JUeJ9us+quVSL80GLWtTphN/d21IacmTTL2Flb
         dGBV7ujknPUqiV8H6r84FbdbbQndW/haKJKN70JZwPfUl7UB4OcaSmnXdC/S/SY46oBH
         NxhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cxtBXQjr;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y124sor8213585oig.122.2019.01.29.11.26.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 11:26:38 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cxtBXQjr;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ouNDxW1aE5KIRmfvk+0q+ZC0t1e1u22BjhYLnvkJJdU=;
        b=cxtBXQjrqJ48TYHrP4QX0HszczJDSA1FeFac4pad9Z/AzyAswcHDwp3N+rQVTLNDw3
         OJmMycmSB1P0vAwtHqNETe2WQRpsvdEBmsfToOPPZTGswjmLEE6bAd+MrZ7XLVVNGIQD
         7edINJVUg194vfTSGae3ptfCtZDR7kXsLbQIFTdId6Zlx9L+3ZsrFruaYSGlPNng97s2
         KHvKi7hKS1LAds/xMU4X6OYt1cUcFBoZHDxeCbbR8yp6wqkJ31sDcqY3lUb4pzEUu2eX
         RvmUeDGIyg04Z34+Etu0RHk0bEvAtjQnclEUIU1D77hJqwCpS9GUWxmMYT9jKfdEVO+f
         Eabw==
X-Google-Smtp-Source: AHgI3IZeiGPvKCZK+lP+xFNEpVWyu4iKS3H9G7ElJabMkjWS3VKAne12MOe3uNtiwnmUi0S3esBHM0xOwT68RpLhOao=
X-Received: by 2002:aca:b804:: with SMTP id i4mr9936891oif.280.1548789998456;
 Tue, 29 Jan 2019 11:26:38 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190125142039.GN3560@dhcp22.suse.cz>
In-Reply-To: <20190125142039.GN3560@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 29 Jan 2019 11:26:26 -0800
Message-ID: <CAPcyv4gLaOJTfNJVuSoJdB93e05hc-tUSdJ4u=gaedDqHTT5QQ@mail.gmail.com>
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

On Fri, Jan 25, 2019 at 6:21 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 07-01-19 15:21:10, Dan Williams wrote:
> [...]
>
> Thanks a lot for the additional information. And...

Hi Michal,

Thanks for the review!

> > Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> > perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> > when they are initially populated with free memory at boot and at
> > hotplug time. Do this based on either the presence of a
> > page_alloc.shuffle=Y command line parameter, or autodetection of a
> > memory-side-cache (to be added in a follow-on patch).
>
> ... to make it opt-in and also provide an opt-out to override for the
> auto-detected case.
>
> > The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> > pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> > 10, 4MB this trades off randomization granularity for time spent
> > shuffling.
>
> But I do not really think we want to make this a config option. Who do
> you expect will tune this? I would rather wait for those usecases to be
> called out and we can give them a command line parameter to do so rather
> than something hardcoded during compile time and as such really unusable
> for any consumer of the pre-built kernels.

True. I have no problem removing it. If people want to play with
randomizing different orders they can change the compile-time constant
manually. If it turns out that there is a use case for it to be
dynamically set from the command line that then that be added when
demand / user is clarified.

> I do not have a problem with the default section though.

Ok.

> > MAX_ORDER-1 was chosen to be minimally invasive to the page
> > allocator while still showing memory-side cache behavior improvements,
> > and the expectation that the security implications of finer granularity
> > randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.
> >
> > The performance impact of the shuffling appears to be in the noise
> > compared to other memory initialization work. Also the bulk of the work
> > is done in the background as a part of deferred_init_memmap().
> >
> > This initial randomization can be undone over time so a follow-on patch
> > is introduced to inject entropy on page free decisions. It is reasonable
> > to ask if the page free entropy is sufficient, but it is not enough due
> > to the in-order initial freeing of pages. At the start of that process
> > putting page1 in front or behind page0 still keeps them close together,
> > page2 is still near page1 and has a high chance of being adjacent. As
> > more pages are added ordering diversity improves, but there is still
> > high page locality for the low address pages and this leads to no
> > significant impact to the cache conflict rate.
> >
> > [1]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
> > [2]: https://lkml.org/lkml/2018/9/22/54
> > [3]: https://lkml.org/lkml/2018/10/12/309
>
> Please turn lkml.org links into http://lkml.kernel.org/r/$msg_id

Will do.


>
> [....]
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
>
> I haven't checked the actual shuffling algorithm, I will trust you on
> that part ;)
> --
> Michal Hocko
> SUSE Labs

