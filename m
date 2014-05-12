Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id BD00E6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 14:47:02 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 142so6275488ykq.18
        for <linux-mm@kvack.org>; Mon, 12 May 2014 11:47:02 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id g3si2415986yhd.113.2014.05.12.11.47.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 May 2014 11:47:02 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 12 May 2014 12:47:01 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DC3B23E40040
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:46:57 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4CIk75320971586
	for <linux-mm@kvack.org>; Mon, 12 May 2014 20:46:07 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4CIkvGv029877
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:46:57 -0600
Date: Mon, 12 May 2014 11:46:54 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
Message-ID: <20140512184654.GC8941@linux.vnet.ibm.com>
References: <20140324230550.GB18778@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251116490.16557@nuc>
 <20140325162303.GA29977@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251152250.16870@nuc>
 <20140325181010.GB29977@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251323030.26744@nuc>
 <20140327203354.GA16651@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403290038200.24286@nuc>
 <20140401013346.GD5144@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1404031139090.21739@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1404031139090.21739@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

Hi Christoph,

Sorry for the delay in my response!

On 03.04.2014 [11:41:37 -0500], Christoph Lameter wrote:
> On Mon, 31 Mar 2014, Nishanth Aravamudan wrote:
> 
> > Yep. The node exists, it's just fully exhausted at boot (due to the
> > presence of 16GB pages reserved at boot-time).
> 
> Well if you want us to support that then I guess you need to propose
> patches to address this issue.

Yep, that's my plan, I was hoping to get input from developers/experts
such as yourself first. Obviously, code speaks louder though...

> > I'd appreciate a bit more guidance? I'm suggesting that in this case
> > the node functionally has no memory. So the page allocator should
> > not allow allocations from it -- except (I need to investigate this
> > still) userspace accessing the 16GB pages on that node, but that, I
> > believe, doesn't go through the page allocator at all, it's all from
> > hugetlb interfaces. It seems to me there is a bug in SLUB that we
> > are noting that we have a useless per-node structure for a given
> > nid, but not actually preventing requests to that node or reclaim
> > because of those allocations.
> 
> Well if you can address that without impacting the fastpath then we
> could do this. Otherwise we would need a fake structure here to avoid
> adding checks to the fastpath

Ok, I'll keep thinking about what makes the most sense.

> > I think there is a logical bug (even if it only occurs in this
> > particular corner case) where if reclaim progresses for a THISNODE
> > allocation, we don't check *where* the reclaim is progressing, and thus
> > may falsely be indicating that we have done some progress when in fact
> > the allocation that is causing reclaim will not possibly make any more
> > progress.
> 
> Ok maybe we could address this corner case. How would you do this?

This is where I started to get stumped. It seems like did_some_progress
is only checking that any progress is made. It would be more expensive
in the reclaim path to check what nodes we made progress on and verify
it was on the intended one (if we are reclaiming due to THISNODE). I
will try and look at this case specifically more, I apologize it's
taking me quite a bit of time to get up-to-speed on the code and design.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
