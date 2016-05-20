Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75E4A6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 03:26:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so201806659pfz.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 00:26:27 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id re14si5006974pab.85.2016.05.20.00.26.25
        for <linux-mm@kvack.org>;
        Fri, 20 May 2016 00:26:26 -0700 (PDT)
Date: Fri, 20 May 2016 16:26:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160520072624.GD6808@bbox>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
 <20160428151921.GL31489@dhcp22.suse.cz>
 <20160517075815.GC14453@dhcp22.suse.cz>
 <20160517090254.GE14453@dhcp22.suse.cz>
 <20160519050038.GA16318@bbox>
 <20160519070357.GB26110@dhcp22.suse.cz>
 <20160519072751.GB16318@bbox>
 <20160519073957.GE26110@dhcp22.suse.cz>
 <20160520002155.GA2224@bbox>
 <20160520063917.GC19172@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520063917.GC19172@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri, May 20, 2016 at 08:39:17AM +0200, Michal Hocko wrote:
> On Fri 20-05-16 09:21:55, Minchan Kim wrote:
> [...]
> > I think other important thing we should consider is how the THP page is likely
> > to be hot without split in a short time like KSM is doing double checking to
> > merge stable page. Of course, it wouldn't be easyI to implement but I think
> > algorithm is based on such *hotness* basically and then consider the number
> > of max_swap_ptes. IOW, I think we should approach more conservative rather
> > than optimistic because a page I/O overhead by wrong choice could be bigger
> > than benefit of a few TLB hit.
> > If we approach that way, maybe we don't need to detect memory pressure.
> > 
> > For that way, how about raising bar for swapin allowance?
> > I mean now we allows swapin
> > 
> > from
> >         64 pages below swap ptes and 1 page young in 512 ptes 
> > to
> >         64 pages below swap ptes and 256 page young in 512 ptes 
> 
> I agree that the current 1 page threshold for collapsing is way too
> optimistic. Same as the defaults we had for the page fault THP faulting
> which has caused many issues. So I would be all for changing it. I do

I don't know we should change all but if we change it for THP faulting,
I believe THP swapin should be more conservative value rather than THP
faulting because cost of THP swapin collapsing would be heavier.

> not have good benchmarks to back any "good" number unfortunately. So
> such a change would be quite arbitrary based on feeling... If you have
> some workload where collapsing THP pages causes some real issues that
> would be great justification though.

Hope to have but our products never have turned on THP. :(
I just wanted to say current problem and suggestion so a THP guy
can have an interest on that.
If it's not worth to do, simple igonore.

> 
> That being said khugepaged_max_ptes_none = HPAGE_PMD_NR/2 sounds like a

max_ptes_none?
               
> good start to me. Whether all of the present pages have to be young I am
> not so sure.
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
