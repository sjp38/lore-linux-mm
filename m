Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC946B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:02:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so37836951wms.7
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:02:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lh9si24765669wjc.83.2016.12.07.07.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 07:02:42 -0800 (PST)
Date: Wed, 7 Dec 2016 16:02:38 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161207150237.GC31797@dhcp22.suse.cz>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
 <20161205093100.GF30758@dhcp22.suse.cz>
 <20161206100358.GA4619@sha-win-210.asiapac.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161206100358.GA4619@sha-win-210.asiapac.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "vbabka@suze.cz" <vbabka@suze.cz>

On Tue 06-12-16 18:03:59, Huang Shijie wrote:
> On Mon, Dec 05, 2016 at 05:31:01PM +0800, Michal Hocko wrote:
> > On Mon 05-12-16 17:17:07, Huang Shijie wrote:
> > [...]
> > >    The failure is caused by:
> > >     1) kernel fails to allocate a gigantic page for the surplus case.
> > >        And the gather_surplus_pages() will return NULL in the end.
> > > 
> > >     2) The condition checks for some functions are wrong:
> > >         return_unused_surplus_pages()
> > >         nr_overcommit_hugepages_store()
> > >         hugetlb_overcommit_handler()
> > 
> > OK, so how is this any different from gigantic (1G) hugetlb pages on
> I think there is no different from gigantic (1G) hugetlb pages on
> x86_64. Do anyone ever tested the 1G hugetlb pages in x86_64 with the "counter.sh"
> before? 

I suspect nobody has because the gigantic page support is still somehow
coarse and from a quick look into the code we only support pre-allocated
giga pages. In other words surplus pages and their accounting is not
supported at all.

I haven't yet checked your patchset but I can tell you one thing.
Surplus and subpool pages code is tricky as hell. And it is not just a
matter of teaching the huge page allocation code to do the right thing.
There are subtle details all over the place. E.g. we currently
do not free giga pages AFAICS. In fact I believe that the giga pages are
kind of implanted to the existing code without any higher level
consistency. This should change long term. But I am worried it is much
more work.

Now I might be wrong because I might misremember things which might have
been changed recently but please make sure you describe the current
state and changes of giga pages when touching this area much better if
you want to pursue this route...

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
