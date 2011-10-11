Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 494256B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 03:51:09 -0400 (EDT)
Message-ID: <4E93F55E.6030800@parallels.com>
Date: Tue, 11 Oct 2011 11:50:54 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Slab objects identifiers
References: <4E8DD5B9.4060905@parallels.com> <20111010185909.GD16723@count0.beaverton.ibm.com>
In-Reply-To: <20111010185909.GD16723@count0.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/10/2011 10:59 PM, Matt Helsley wrote:
> On Thu, Oct 06, 2011 at 08:22:17PM +0400, Pavel Emelyanov wrote:

Matt, thanks for the reply! Please, see my comments below.

>> Hi.
>>
>>
>> While doing the checkpoint-restore in the userspace we need to determine
>> whether various kernel objects (like mm_struct-s of file_struct-s) are shared
>> between tasks and restore this state.
>> The 2nd step can for now be solved by using respective CLONE_XXX flags and
>> the unshare syscall, while there's currently no ways for solving the 1st one.
>>
>> One of the ways for checking whether two tasks share e.g. an mm_struct is to
>> provide some mm_struct ID of a task to its proc file. The best from the
>> performance point of view ID is the object address in the kernel, but showing
>> them to the userspace is not good for performance reasons. Thus the ID should
>> not be calculated based on the object address.
>>
>> The proposal is to have the ID for slab objects as the mixture of two things -
>> the number of an object on the slub and the ID of a slab, which is calculated
>> simply by getting a monotonic 64 bit number at the slab allocation time which
>> gives us 200+ years of stable work (see comment in the patch #2) :)
> 
> This just strikes me as the wrong approach. Userspace should not need to know
> the structures the kernel is using to implement the sharing that's possible
> with the clone flags. The userspace interface should be framed such that the
> kernel is not exporting the relationship between these structures so much as
> the relationship between the tasks which those structures reflect.
> Perhaps you could write the interface so that it shows the clone flags
> one would use to re-create the child task from the parent instead of
> trying to output these ids.

Well, another API would also work for us, I just propose this one as one of the 
approaches.

Your proposal with showing CLONE flags sounds very promising, but how can it handle
the case when a task shares it's e.g. mm_struct with some other task which is not his
parent? Like if we create the chain of 3 tasks all with the shared mm_struct and then
the middle one calls execve unsharing one (I saw MySQL doing this). Besides "reparenting
to init" and the unshare syscall may create more interesting objects sharing mosaic and 
thus we need the API which is as generic as "do these two tasks share an mm?".

Looking a little bit forward, if the same API can answer a question "does this *group*
of tasks sharing one mm_struct share it with someone else?" this would also be very
helpful.

> Also, putting this in slab seems like a poor choice -- isn't instrumenting
> the allocator rather invasive? 

Well, the payload in my patches is not intrusive - it just adds the code, not tosses
the existing one.

> Especialy when we're talking about a handful of structs in comparison to everything
> else the allocators handle?

I did this functionality so that it doesn't affect those kmem caches that we don't need
to provide us the IDs at all.

> Cheers,
> 	-Matt Helsley
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
