Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA5956B0284
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:01:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c82so1610637wme.8
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:01:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si1945347edi.99.2017.11.22.05.01.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 05:01:25 -0800 (PST)
Date: Wed, 22 Nov 2017 14:01:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Message-ID: <20171122130121.ujp6qppa7nhahazh@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
 <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
 <20171122093510.baxsmzvvid7c7yrq@dhcp22.suse.cz>
 <20171122101422.ny5tyyyje5dhx343@dhcp22.suse.cz>
 <896594C0-D9CE-4E95-BCAF-45BAD3E3DA2C@cs.rutgers.edu>
 <59AE7B0B-9E1A-434D-89FF-E4A1ECEFF9A4@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <59AE7B0B-9E1A-434D-89FF-E4A1ECEFF9A4@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 22-11-17 07:29:38, Zi Yan wrote:
> On 22 Nov 2017, at 7:13, Zi Yan wrote:
> 
> > On 22 Nov 2017, at 5:14, Michal Hocko wrote:
> >
> >> On Wed 22-11-17 10:35:10, Michal Hocko wrote:
> >> [...]
> >>> Moreover I am not really sure this is really working properly. Just look
> >>> at the split_huge_page. It moves all the tail pages to the LRU list
> >>> while migrate_pages has a list of pages to migrate. So we will migrate
> >>> the head page and all the rest will get back to the LRU list. What
> >>> guarantees that they will get migrated as well.
> >>
> >> OK, so this is as I've expected. It doesn't work! Some pfn walker based
> >> migration will just skip tail pages see madvise_inject_error.
> >> __alloc_contig_migrate_range will simply fail on THP page see
> >> isolate_migratepages_block so we even do not try to migrate it.
> >> do_move_page_to_node_array will simply migrate head and do not care
> >> about tail pages. do_mbind splits the page and then fall back to pte
> >> walk when thp migration is not supported but it doesn't handle tail
> >> pages if the THP migration path is not able to allocate a fresh THP
> >> AFAICS. Memory hotplug should be safe because it doesn't skip the whole
> >> THP when doing pfn walk.
> >>
> >> Unless I am missing something here this looks like a huge mess to me.
> >
> > +Kirill
> >
> > First, I agree with you that splitting a THP and only migrating its head page
> > is a mess. But what you describe is also the behavior of migrate_page()
> > _before_ THP migration support is added. I thought that was intended.
> >
> > Look at http://elixir.free-electrons.com/linux/v4.13.15/source/mm/migrate.c#L1091,
> > unmap_and_move() splits THPs and only migrates the head page in v4.13 before THP
> > migration is added. I think the behavior was introduced since v4.5 (I just skimmed
> > v4.0 to v4.13 code and did not have time to use git blame), before that THPs are
> > not migrated but shown as successfully migrated (at least from v4.4a??s code).
> 
> Sorry, I misread v4.4a??s code, it also does a??splitting a THP and migrating its head pagea??.
> This behavior was there for a long time, at least since v3.0.
> 
> The code in unmap_and_move() is:
> 
> if (unlikely(PageTransHuge(page)))
> 		if (unlikely(split_huge_page(page)))
> 			goto out;

I _think_ that this all should be handled at migrate_pages layer. Try to
migrate THP and fallback to split_huge_page into to the list when it
fails. I haven't checked whether there is something which would prevent
that though. THP tricks in specific paths then should be removed.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
