Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 278AF6B0033
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 04:32:10 -0400 (EDT)
Message-ID: <4E8EB8F7.4090208@parallels.com>
Date: Fri, 07 Oct 2011 12:31:51 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] slab_id: Generic slab ID infrastructure
References: <4E8DD5B9.4060905@parallels.com> <4E8DD600.7070700@parallels.com> <4E8EB802.8020201@parallels.com>
In-Reply-To: <4E8EB802.8020201@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, "devel@openvz.org" <devel@openvz.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>

On 10/07/2011 12:27 PM, Glauber Costa wrote:
> Hi Pavel,
> 
> On 10/06/2011 08:23 PM, Pavel Emelyanov wrote:
>> The idea of how to generate and ID for an arbitrary slab object is simple:
>>
>> - The ID is 128 bits
>> - The upper 64 bits are slab ID
>> - The lower 64 bits are object index withing a slab (yes, it's too many,
>>    but is done for simplicity - not to deal with 96-bit numbers)
>> - The slab ID is the 48-bit per-cpu monotonic counter mixed with 16-bit
>>    cpuid. Even if being incremented 1M times per second the first part
>>    will stay uniqe for 200+ years. The cpuid is required to make values
>>    picked on two cpus differ.
> 
> So why can't we just use tighter numbers, and leave some reserved fields 
> instead ?

Well, we have to save the ID on the slab and for 64-bit kernel we can already
use the 64-bit mapping field. For 32-bit kernels 32-bit value is not enough as
it can overlap in several days (like 32bit jiffies do) which is not enough.

> Having ids in the objects of the slab may prove useful in the future for
> other uses as well.
> 
> For instance, concurrent to that, we're trying to figure out ways to 
> have per-cgroup pages/objects accounted in the memory controller.
> 
> The most up2date proposals create an entire kmem cache for each cgroup,
> thus trivially guaranteeing uniqueness. It however, leads to fragmentation.
> Having the objects to be IDed and being cgroup part of this id, could
> help us achieve the same goal with less fragmentation.

That's good point! I can extend the patches to provide the space reservation
infrastructure for slabs.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
