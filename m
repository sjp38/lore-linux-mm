Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 528CD6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 11:46:55 -0400 (EDT)
Message-ID: <4E931368.8080902@parallels.com>
Date: Mon, 10 Oct 2011 19:46:48 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Slab objects identifiers
References: <4E8DD5B9.4060905@parallels.com> <alpine.DEB.2.00.1110071159540.11042@router.home> <4E92C6FA.2050609@parallels.com> <alpine.DEB.2.00.1110101022220.16264@router.home>
In-Reply-To: <alpine.DEB.2.00.1110101022220.16264@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/10/2011 07:24 PM, Christoph Lameter wrote:
> On Mon, 10 Oct 2011, Pavel Emelyanov wrote:
> 
>>> If you store the physical address with the object content
>>> when transferring then you can verify that they share the mm_struct.
>>
>> ... are we all OK with showing kernel addresses to the userspace? I thought the %pK
>> format was invented specially to handle such leaks.
> 
> Not in general but I think for process migration we are fine with the
> handling of the addresses. Doesnt process migration require rooot anyways?

Well, currently the most strict requirement for checkpoint part is the
ptrace_may_access() one, which is not necessarily root. And I'd prefer not
restricting it further without need.

> Adding additional metadata to each slab or object is certainly not
> acceptable because it slows down operations for everyone.

Please note, that this ID generation thing is not required for EVERY kmem cache
in the system, only for a couple of them. For 64 bits kernel this ID is stored on
the struct page itself doesn't making object density worse, on 32 bits the caches
I require to mark with this flag already have gaps between objects and thus do not 
make density worse either.

Besides, the slab ID generation is a single percpu counter and is called in the 
places where percpu areas are already hot in caches, thus no noticeable penalty 
should be seen.


Besides, in OpenVZ we modify slub code to store on the page with objects an array 
of pointers (size == number of objects) and no performance tests show any degradation
due to this.

If I misunderstood your concern, please elaborate.

>> If we are, then (as I said in the first letter) we should just show them and forget
>> this set. If we're not - we should invent smth more straightforward and this set is
>> an attempt for doing this.
> 
> Well one solution is to show the addresses only to members of a specific
> group or only to root.

I agree with that. Need to sort out the issues above.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
