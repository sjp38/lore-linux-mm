Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFF0E6B0253
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 02:28:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e128so3513537wmg.1
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 23:28:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si825771wrh.60.2017.12.20.23.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 23:28:04 -0800 (PST)
Date: Thu, 21 Dec 2017 08:28:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
Message-ID: <20171221072802.GY4831@dhcp22.suse.cz>
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171215093309.GU16951@dhcp22.suse.cz>
 <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
 <20171220095328.GG4831@dhcp22.suse.cz>
 <233096d8-ecbc-353a-023a-4f6fa72ebb2f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <233096d8-ecbc-353a-023a-4f6fa72ebb2f@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-12-17 14:43:03, Mike Kravetz wrote:
> On 12/20/2017 01:53 AM, Michal Hocko wrote:
> > On Wed 20-12-17 05:33:36, Naoya Horiguchi wrote:
> >> I have one comment on the code path from mbind(2).
> >> The callback passed to migrate_pages() in do_mbind() (i.e. new_page())
> >> calls alloc_huge_page_noerr() which currently doesn't call SetPageHugeTemporary(),
> >> so hugetlb migration fails when h->surplus_huge_page >= h->nr_overcommit_huge_pages.
> > 
> > Yes, I am aware of that. I should have been more explicit in the
> > changelog. Sorry about that and thanks for pointing it out explicitly.
> > To be honest I wasn't really sure what to do about this. The code path
> > is really complex and it made my head spin. I fail to see why we have to
> > call alloc_huge_page and mess with reservations at all.
> 
> Oops!  I missed that in my review.
> 
> Since alloc_huge_page was called with avoid_reserve == 1, it should not
> do anything with reserve counts.  One potential issue with the existing
> code is cgroup accounting done by alloc_huge_page.  When the new target
> page is allocated, it is charged against the cgroup even though the original
> page is still accounted for.  If we are 'at the cgroup limit', the migration
> may fail because of this.

Yeah, the existing code seems just broken. I strongly suspect that the
allocation API for hugetlb was so complicated that this was just a
natural result of a confusion with some follow up changes on top.

> I like your new code below as it explicitly takes reserve and cgroup
> accounting out of the picture for migration.  Let me think about it
> for another day before providing a Reviewed-by.

Thanks a lot!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
