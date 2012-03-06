Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 3FA3E6B00E8
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 18:31:25 -0500 (EST)
Received: by iajr24 with SMTP id r24so10076205iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 15:31:24 -0800 (PST)
Date: Tue, 6 Mar 2012 15:31:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
In-Reply-To: <20120305094411.GD3481@suse.de>
Message-ID: <alpine.DEB.2.00.1203061529480.18656@chino.kir.corp.google.com>
References: <20120302112358.GA3481@suse.de> <alpine.DEB.2.00.1203021018130.15125@router.home> <20120302174349.GB3481@suse.de> <1330723529.11248.237.camel@twins> <alpine.DEB.2.00.1203021540040.18377@chino.kir.corp.google.com> <20120305094411.GD3481@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 5 Mar 2012, Mel Gorman wrote:

> > It's very expensive even without memory barriers since the page allocator 
> > wraps itself in {get,put}_mems_allowed() until a page or NULL is returned 
> > and an update to current's set of allowed mems can stall indefinitely 
> > trying to change the nodemask during this time. 
> 
> Hmm, this sounds problematic. Are you seeing a problem with the behaviour
> with the patch applied or the existing behaviour?
> 

Sorry, yes, this is with the existing behavior prior to your patch.  We 
definitely need fixes for get_mems_allowed() because it's possible that a 
write to cpuset.mems will never return even when trying to add nodes to 
its nodemask in oom conditions if one of the cpuset's tasks is looping 
forever in the page allocator.

I'll review your updated version posted from today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
