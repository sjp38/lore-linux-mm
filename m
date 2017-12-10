Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 986206B0069
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 04:55:19 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f2so2986129plj.15
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 01:55:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si8308879plb.79.2017.12.10.01.55.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 01:55:18 -0800 (PST)
Date: Sun, 10 Dec 2017 10:55:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm, thp: introduce generic transparent huge page
 allocation interfaces
Message-ID: <20171210095514.GX20234@dhcp22.suse.cz>
References: <1512708175-14089-1-git-send-email-changbin.du@intel.com>
 <20171208082737.GA15790@dhcp22.suse.cz>
 <20171209032658.koktsag3hqpm7psx@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171209032658.koktsag3hqpm7psx@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Du, Changbin" <changbin.du@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 09-12-17 11:26:58, Du, Changbin wrote:
> On Fri, Dec 08, 2017 at 09:27:37AM +0100, Michal Hocko wrote:
> > On Fri 08-12-17 12:42:55, changbin.du@intel.com wrote:
> > > From: Changbin Du <changbin.du@intel.com>
> > > 
> > > This patch introduced 4 new interfaces to allocate a prepared transparent
> > > huge page. These interfaces merge distributed two-step allocation as simple
> > > single step. And they can avoid issue like forget to call prep_transhuge_page()
> > > or call it on wrong page. A real fix:
> > > 40a899e ("mm: migrate: fix an incorrect call of prep_transhuge_page()")
> > > 
> > > Anyway, I just want to prove that expose direct allocation interfaces is
> > > better than a interface only do the second part of it.
> > > 
> > > These are similar to alloc_hugepage_xxx which are for hugetlbfs pages. New
> > > interfaces are:
> > >   - alloc_transhuge_page_vma
> > >   - alloc_transhuge_page_nodemask
> > >   - alloc_transhuge_page_node
> > >   - alloc_transhuge_page
> > > 
> > > These interfaces implicitly add __GFP_COMP gfp mask which is the minimum
> > > flags used for huge page allocation. More flags leave to the callers.
> > > 
> > > This patch does below changes:
> > >   - define alloc_transhuge_page_xxx interfaces
> > >   - apply them to all existing code
> > >   - declare prep_transhuge_page as static since no others use it
> > >   - remove alloc_hugepage_vma definition since it no longer has users
> > 
> > I am not really convinced this is a huge win, to be honest. Just look at
> > the diffstat. Very few callsites get marginally simpler while we add a
> > lot of stubs and the code churn.
> >
> I know we should write less code, but it is not the only rule. Sometimes we need
> add little more code since the compiler requires so, but it doesn't mean then
> the compiler will generate worse/more machine code. Besides this, I really want
> to know wethere any other considerations you have. Thanks.

Well, these allocation functions are pretty much internal MM thing. They
are not like regular alloc_pages variants which are used all over the
kernel. So while I understand your motivation to have them easy to use
as possible I am not sure this is really worth adding more code which we
will have to maintain. From my past experience many different variants
of helper functions tend to get out of sync over time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
