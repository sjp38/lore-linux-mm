Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC5F6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 04:52:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so4172504wmd.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 01:52:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n64si12485990wmn.101.2016.12.08.01.52.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 01:52:58 -0800 (PST)
Date: Thu, 8 Dec 2016 10:52:54 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161208095253.GB8330@dhcp22.suse.cz>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
 <20161205093100.GF30758@dhcp22.suse.cz>
 <20161206100358.GA4619@sha-win-210.asiapac.arm.com>
 <20161207150237.GC31797@dhcp22.suse.cz>
 <20161208093623.GA4551@sha-win-210.asiapac.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161208093623.GA4551@sha-win-210.asiapac.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "vbabka@suze.cz" <vbabka@suze.cz>

On Thu 08-12-16 17:36:24, Huang Shijie wrote:
> On Wed, Dec 07, 2016 at 11:02:38PM +0800, Michal Hocko wrote:
[...]
> > I haven't yet checked your patchset but I can tell you one thing.
>
> Could you please review the patch set when you have time? Thanks a lot.

>From a quick glance you do not handle the reservation code at all. You
just make sure that the allocation doesn't fail unconditionally. I might
be wrong here and Naoya resp. Mike will know much better but this seems
far from enough to me.

> 
> > Surplus and subpool pages code is tricky as hell. And it is not just a
> Agree. 
> 
> Do we really need so many accountings? such as reserve/ovorcommit/surplus.

If we want to make giga page the first class citizen then the whole
reservation/surplus code has to independent on the page size.

> > matter of teaching the huge page allocation code to do the right thing.
> > There are subtle details all over the place. E.g. we currently
> > do not free giga pages AFAICS. In fact I believe that the giga pages are
> Please correct me if I am wrong. :)
> 
> I think the free-giga-pages can work well.
> Please see the code in update_and_free_page(). 

Hmm, I have missed that part. I guess you are right but I would have to
look much closer. Hugetlb code tends to be full of surprises.

> Could you please list all the subtle details you think the code is wrong?
> I can check them one by one.

Well, this would take me quite some time and basically restudy the whole
hugetlb code again. What you are trying to achieve is not a simple "fix
a test case" thing. You are trying to implement full featured giga pages
suport. And as I've said this requires a deeper understanding of the
current code and clean it up considerably wrt. giga pages. This is
definitely desirable plan longterm and I would like to encourage you for
that but it is not a simple project at the same time. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
