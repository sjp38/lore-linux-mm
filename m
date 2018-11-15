Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2395E6B000A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 20:55:33 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t2so5871299pfj.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:55:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l4-v6si28547170plb.258.2018.11.14.17.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 17:55:32 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAF1rlDW069387
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 20:55:30 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nrv5uf7mv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 20:55:30 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 15 Nov 2018 01:55:28 -0000
Date: Wed, 14 Nov 2018 17:55:12 -0800
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <20181114150742.GZ23419@dhcp22.suse.cz>
 <9e8218eb-80bf-fc02-ae56-42ccfddb572e@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e8218eb-80bf-fc02-ae56-42ccfddb572e@linux.intel.com>
Message-Id: <20181115015511.GB2353@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Wed, Nov 14, 2018 at 04:50:23PM -0800, Alexander Duyck wrote:
> 
> 
> On 11/14/2018 7:07 AM, Michal Hocko wrote:
> >On Mon 05-11-18 13:19:25, Alexander Duyck wrote:
> >>This patchset is essentially a refactor of the page initialization logic
> >>that is meant to provide for better code reuse while providing a
> >>significant improvement in deferred page initialization performance.
> >>
> >>In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> >>memory per node I have seen the following. In the case of regular memory
> >>initialization the deferred init time was decreased from 3.75s to 1.06s on
> >>average. For the persistent memory the initialization time dropped from
> >>24.17s to 19.12s on average. This amounts to a 253% improvement for the
> >>deferred memory initialization performance, and a 26% improvement in the
> >>persistent memory initialization performance.
> >>
> >>I have called out the improvement observed with each patch.
> >
> >I have only glanced through the code (there is a lot of the code to look
> >at here). And I do not like the code duplication and the way how you
> >make the hotplug special. There shouldn't be any real reason for that
> >IMHO (e.g. why do we init pfn-at-a-time in early init while we do
> >pageblock-at-a-time for hotplug). I might be wrong here and the code
> >reuse might be really hard to achieve though.
> 
> Actually it isn't so much that hotplug is special. The issue is more that
> the non-hotplug case is special in that you have to perform a number of
> extra checks for things that just aren't necessary for the hotplug case.
> 
> If anything I would probably need a new iterator that would be able to take
> into account all the checks for the non-hotplug case and then provide ranges
> of PFNs to initialize.
> 
> >I am also not impressed by new iterators because this api is quite
> >complex already. But this is mostly a detail.
> 
> Yeah, the iterators were mostly an attempt at hiding some of the complexity.
> Being able to break a loop down to just an iterator provding the start of
> the range and the number of elements to initialize is pretty easy to
> visualize, or at least I thought so.

Just recently we had a discussion about overlapping for_each_mem_range()
and for_each_mem_pfn_range(), but unfortunately it appears that no mailing
list was cc'ed by the original patch author :(
In short, there was a spelling fix in one of them and Michal pointed out
that their functionality overlaps.

I have no objection for for_each_free_mem_pfn_range_in_zone() and
__next_mem_pfn_range_in_zone(), but probably we should consider unifying
the older iterators before we introduce a new one? 
 
> >Thing I do not like is that you keep microptimizing PageReserved part
> >while there shouldn't be anything fundamental about it. We should just
> >remove it rather than make the code more complex. I fell more and more
> >guilty to add there actually.
> 
> I plan to remove it, but don't think I can get to it in this patch set.
> 
> I was planning to submit one more iteration of this patch set early next
> week, and then start focusing more on the removal of the PageReserved bit
> for hotplug. I figure it is probably going to be a full patch set onto
> itself and as you pointed out at the start of this email there is already
> enough code to review without adding that.
> 
> 

-- 
Sincerely yours,
Mike.
