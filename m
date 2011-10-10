Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0576B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 14:59:21 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9AIhHfb017921
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:43:17 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9AIxDPE168012
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:59:13 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9AIxDEN003205
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:59:13 -0600
Date: Mon, 10 Oct 2011 11:59:09 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 0/5] Slab objects identifiers
Message-ID: <20111010185909.GD16723@count0.beaverton.ibm.com>
References: <4E8DD5B9.4060905@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E8DD5B9.4060905@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 06, 2011 at 08:22:17PM +0400, Pavel Emelyanov wrote:
> Hi.
> 
> 
> While doing the checkpoint-restore in the userspace we need to determine
> whether various kernel objects (like mm_struct-s of file_struct-s) are shared
> between tasks and restore this state.
> The 2nd step can for now be solved by using respective CLONE_XXX flags and
> the unshare syscall, while there's currently no ways for solving the 1st one.
> 
> One of the ways for checking whether two tasks share e.g. an mm_struct is to
> provide some mm_struct ID of a task to its proc file. The best from the
> performance point of view ID is the object address in the kernel, but showing
> them to the userspace is not good for performance reasons. Thus the ID should
> not be calculated based on the object address.
> 
> The proposal is to have the ID for slab objects as the mixture of two things -
> the number of an object on the slub and the ID of a slab, which is calculated
> simply by getting a monotonic 64 bit number at the slab allocation time which
> gives us 200+ years of stable work (see comment in the patch #2) :)

This just strikes me as the wrong approach. Userspace should not need to know
the structures the kernel is using to implement the sharing that's possible
with the clone flags. The userspace interface should be framed such that the
kernel is not exporting the relationship between these structures so much as
the relationship between the tasks which those structures reflect.
Perhaps you could write the interface so that it shows the clone flags
one would use to re-create the child task from the parent instead of
trying to output these ids.

Also, putting this in slab seems like a poor choice -- isn't instrumenting
the allocator rather invasive? Especialy when we're talking about a
handful of structs in comparison to everything else the allocators
handle?

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
