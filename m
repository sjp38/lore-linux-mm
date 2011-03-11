Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD1DD8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:01:54 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p2BL1pUW021834
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:01:51 -0800
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz37.hot.corp.google.com with ESMTP id p2BL1ldB026521
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:01:50 -0800
Received: by pvh11 with SMTP id 11so836631pvh.22
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:01:50 -0800 (PST)
Date: Fri, 11 Mar 2011 13:01:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 00/25]: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com>
References: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

On Fri, 11 Mar 2011, Prasad Joshi wrote:

> A filesystem might run into a problem while calling
> __vmalloc(GFP_NOFS) inside a lock.
> 
> It is expected than __vmalloc when called with GFP_NOFS should not
> callback the filesystem code even incase of the increased memory
> pressure. But the problem is that even if we pass this flag, __vmalloc
> itself allocates memory with GFP_KERNEL.
> 
> Using GFP_KERNEL allocations may go into the memory reclaim path and
> try to free memory by calling file system clear_inode/evict_inode
> function. Which might lead into deadlock.
> 
> For further details
> https://bugzilla.kernel.org/show_bug.cgi?id=30702
> http://marc.info/?l=linux-mm&m=128942194520631&w=4
> 
> The patch passes the gfp allocation flag all the way down to those
> allocating functions.
> 

You're going to run into trouble by hard-wiring __GFP_REPEAT into all of 
the pte allocations because if GFP_NOFS is used then direct reclaim will 
usually fail (see the comment for do_try_to_free_pages(): If the caller is 
!__GFP_FS then the probability of a failure is reasonably high) and, if 
it does so continuously, then the page allocator will loop forever.  This 
bit should probably be moved a level higher in your architecture changes 
to the caller passing GFP_KERNEL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
