Message-ID: <48D1625C.7000309@redhat.com>
Date: Wed, 17 Sep 2008 16:02:36 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org>
In-Reply-To: <48D142B2.3040607@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Avi and I were discussing whether we should populate multiple ptes at
> pagefault time, rather than one at at time as we do now.
> 
> When Linux is operating as a virtual guest, pte population will
> generally involve some kind of trap to the hypervisor, either to
> validate the pte contents (in Xen's case) or to update the shadow
> pagetable (kvm).  This is relatively expensive, and it would be good to
> amortise the cost by populating multiple ptes at once.

Is it still expensive when you're using nested page tables?

> Xen and kvm already batch pte updates where multiple ptes are explicitly
> updated at once (mprotect and unmap, mostly), but in practise that's
> relatively rare.  Most pages are demand faulted into a process one at a
> time.
> 
> It seems to me there are two cases: major faults, and minor faults:
> 
> Major faults: the page in question is physically missing, and so the
> fault invokes IO.  If we blindly pull in a lot of extra pages that are
> never used, then we'll end up wasting a lot of memory.  However, page at
> a time IO is pretty bad performance-wise too, so I guess we do clustered
> fault-time IO?  If we can distinguish between random and linear fault
> patterns, then we can use that as a basis for deciding how much
> speculative mapping to do.  Certainly, we should create mappings for any
> nearby page which does become physically present.

We already have rather well-tested code in the VM to detect fault patterns, 
complete with userspace hints to set readahead policy.  It seems to me that if 
we're going to read nearby pages into pagecache, we might as well actually map 
them at the same time.  Duplicating the readahead code is probably a bad idea.

> Minor faults are easier; if the page already exists in memory, we should
> just create mappings to it.  If neighbouring pages are also already
> present, then we can can cheaply create mappings for them too.

If we're mapping pagecache, then sure, this is really cheap, but speculatively 
allocating anonymous pages will hurt, badly, on many workloads.

> This seems like an obvious idea, so I'm wondering if someone has
> prototyped it already to see what effects there are.  In the native
> case, pte updates are much cheaper, so perhaps it doesn't help much
> there, though it would potentially reduce the number of faults needed. 
> But I think there's scope for measurable benefits in the virtual case.

Sounds like something we might want to enable conditionally on the use of pv_ops 
features.

-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
