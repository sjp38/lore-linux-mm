Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2854E6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:45:27 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id p65so22460516wmp.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:45:27 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m205si26725464wma.5.2016.03.23.05.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:45:25 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r129so3976923wmr.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:45:25 -0700 (PDT)
Date: Wed, 23 Mar 2016 13:45:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Message-ID: <20160323124523.GF7059@dhcp22.suse.cz>
References: <1458497259-12753-1-git-send-email-ebru.akagunduz@gmail.com>
 <1458497259-12753-3-git-send-email-ebru.akagunduz@gmail.com>
 <20160321153637.GE21248@dhcp22.suse.cz>
 <1458674476.24206.5.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1458674476.24206.5.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Tue 22-03-16 15:21:16, Rik van Riel wrote:
> On Mon, 2016-03-21 at 16:36 +0100, Michal Hocko wrote:
> > On Sun 20-03-16 20:07:39, Ebru Akagunduz wrote:
> > > 
> > > Currently khugepaged makes swapin readahead to improve
> > > THP collapse rate. This patch checks vm statistics
> > > to avoid workload of swapin, if unnecessary. So that
> > > when system under pressure, khugepaged won't consume
> > > resources to swapin.
> > OK, so you want to disable the optimization when under the memory
> > pressure. That sounds like a good idea in general.
> > 
> > > @@ -2493,7 +2494,14 @@ static void collapse_huge_page(struct
> > > mm_struct *mm,
> > >  		goto out;
> > >  	}
> > >  
> > > -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > +	swap = get_mm_counter(mm, MM_SWAPENTS);
> > > +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> > > +	/*
> > > +	 * When system under pressure, don't swapin readahead.
> > > +	 * So that avoid unnecessary resource consuming.
> > > +	 */
> > > +	if (allocstall == curr_allocstall && swap != 0)
> > > +		__collapse_huge_page_swapin(mm, vma, address,
> > > pmd);
> > this criteria doesn't really make much sense to me. So we are
> > checking
> > whether there was the direct reclaim invoked since some point in time
> > (more on that below) and we take that as a signal of a strong memory
> > pressure, right? What if that was quite some time ago? What if we
> > didn't
> > have a single direct reclaim but the kswapd was busy the whole time.
> > Or
> > what if the allocstall was from a different numa node?
> 
> Do you have a measure in mind that the code should test
> against, instead?

vmpressure provides a reclaim pressure feedback. I am not sure it could
be used here, though.

> I don't think we want page cache turnover to prevent
> khugepaged collapsing THPs, but if the system gets
> to the point where kswapd is doing pageout IO, or
> swapout IO, or kswapd cannot keep up, we should
> probably slow down khugepaged.

I agree. Would using gfp_mask & ~___GFP_DIRECT_RECLAIM allocation
requests for the opportunistic swapin be something to try out? If the
kswapd doesn't keep up with the load to the point when we have to enter
the direct reclaim then it doesn't really make sense to increase the
memory pressure but additional direct reclaim.

> If another NUMA node is under significant memory
> pressure, we probably want the programs from that
> node to be able to do some allocations from this
> node, rather than have khugepaged consume the memory.

This is hard to tell because those tasks might be bound to that node
and won't leave it. Anyway I just wanted to point out that relying to
a global counter is rather dubious.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
