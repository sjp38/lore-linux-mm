Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02311280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:38:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b14so4682631wrd.11
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 23:38:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18si2381725wrc.496.2017.08.20.23.38.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Aug 2017 23:38:20 -0700 (PDT)
Date: Mon, 21 Aug 2017 08:38:18 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:since-4.12 539/540] mm/compaction.c:469:8: error:
 implicit declaration of function 'pageblock_skip_persistent'
Message-ID: <20170821063818.GD13724@dhcp22.suse.cz>
References: <201708190034.TmrRSDV7%fengguang.wu@intel.com>
 <fac0ae1a-7de3-bb98-53c8-f63f205f5c04@redhat.com>
 <20170818140300.d97c99cc5bd60c0f924a6e9a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170818140300.d97c99cc5bd60c0f924a6e9a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri 18-08-17 14:03:00, Andrew Morton wrote:
> On Fri, 18 Aug 2017 12:57:48 -0400 Waiman Long <longman@redhat.com> wrote:
> 
> > On 08/18/2017 12:42 PM, kbuild test robot wrote:
> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.12
> > > head:   ba5e8c23db5729ebdbafad983b07434c829cf5b6
> > > commit: 500539d3686a835f6a9740ffc38bed5d74951a64 [539/540] debugobjects: make kmemleak ignore debug objects
> > > config: i386-randconfig-s0-08141822 (attached as .config)
> > > compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> > > reproduce:
> > >         git checkout 500539d3686a835f6a9740ffc38bed5d74951a64
> > >         # save the attached .config to linux build tree
> > >         make ARCH=i386 
> > >
> > > All errors (new ones prefixed by >>):
> > >
> > >    mm/compaction.c: In function 'isolate_freepages_block':
> > >>> mm/compaction.c:469:8: error: implicit declaration of function 'pageblock_skip_persistent' [-Werror=implicit-function-declaration]
> > >        if (pageblock_skip_persistent(page, order)) {
> > >            ^~~~~~~~~~~~~~~~~~~~~~~~~
> > >>> mm/compaction.c:470:5: error: implicit declaration of function 'set_pageblock_skip' [-Werror=implicit-function-declaration]
> > >         set_pageblock_skip(page);
> > >         ^~~~~~~~~~~~~~~~~~
> > >    cc1: some warnings being treated as errors
> > >
> > > vim +/pageblock_skip_persistent +469 mm/compaction.c
> > 
> > It is not me. My patch doesn't touch any header file and
> > mm/compaction.c. So it can't cause this kind of errors.
> > 
> 
> Yes, that's wrong.  It's David's "mm, compaction: persistently skip
> hugetlbfs pageblocks".  I'll do this:

David has already posted the fix
http://lkml.kernel.org/r/alpine.DEB.2.10.1708201734390.117182@chino.kir.corp.google.com
 
> --- a/mm/compaction.c~mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix
> +++ a/mm/compaction.c
> @@ -327,6 +327,11 @@ static void update_pageblock_skip(struct
>  			bool migrate_scanner)
>  {
>  }
> +
> +static bool pageblock_skip_persistent(struct page *page, unsigned int order)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_COMPACTION */
>  
>  /*
> --- a/include/linux/pageblock-flags.h~mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix
> +++ a/include/linux/pageblock-flags.h
> @@ -96,6 +96,8 @@ void set_pfnblock_flags_mask(struct page
>  #define set_pageblock_skip(page) \
>  			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
>  							PB_migrate_skip)
> +#else
> +#define set_pageblock_skip(page) do { } while (0)
>  #endif /* CONFIG_COMPACTION */
>  
>  #endif	/* PAGEBLOCK_FLAGS_H */
> 
> Those macros in pageblock-flags.h are obnoxious and reference their
> args multiple times.  I'll see what happens if they're turned into C
> functions...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
