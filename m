Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7547D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 16:04:49 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b185so3262813qkc.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:04:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k34sor7986133qvf.44.2018.12.20.13.04.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 13:04:48 -0800 (PST)
Message-ID: <1545339886.18411.31.camel@lca.pw>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
From: Qian Cai <cai@lca.pw>
Date: Thu, 20 Dec 2018 16:04:46 -0500
In-Reply-To: <E084FF0A-88CD-4E61-88F2-7D542D67DDF1@oracle.com>
References: <20181220185031.43146-1-cai@lca.pw>
	 <20181220203156.43441-1-cai@lca.pw>
	 <E084FF0A-88CD-4E61-88F2-7D542D67DDF1@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2018-12-20 at 14:00 -0700, William Kucharski wrote:
> > On Dec 20, 2018, at 1:31 PM, Qian Cai <cai@lca.pw> wrote:
> > 
> > diff --git a/mm/page_ext.c b/mm/page_ext.c
> > index ae44f7adbe07..d76fd51e312a 100644
> > --- a/mm/page_ext.c
> > +++ b/mm/page_ext.c
> > @@ -399,9 +399,8 @@ void __init page_ext_init(void)
> > 			 * -------------pfn-------------->
> > 			 * N0 | N1 | N2 | N0 | N1 | N2|....
> > 			 *
> > -			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
> > 			 */
> > -			if (early_pfn_to_nid(pfn) != nid)
> > +			if (pfn_to_nid(pfn) != nid)
> > 				continue;
> > 			if (init_section_page_ext(pfn, nid))
> > 				goto oom;
> > -- 
> > 2.17.2 (Apple Git-113)
> > 
> 
> Is there any danger in the fact that in the CONFIG_NUMA case in mmzone.h
> (around line 1261), pfn_to_nid() calls page_to_nid(), possibly causing the
> same issue seen in v2?
> 

No. If CONFIG_DEFERRED_STRUCT_PAGE_INIT=y, page_ext_init() is called after
page_alloc_init_late() where all the memory has already been initialized,
so page_to_nid() will work then.
