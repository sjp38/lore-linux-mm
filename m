Message-ID: <47974B54.30407@redhat.com>
Date: Wed, 23 Jan 2008 15:12:36 +0100
From: Gerd Hoffmann <kraxel@redhat.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [PATCH] export notifier #1
References: <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <4797384B.7080200@redhat.com> <20080123131939.GJ26420@sgi.com>
In-Reply-To: <20080123131939.GJ26420@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

>> That would render the notifies useless for Xen too.  Xen needs to
>> intercept the actual pte clear and instead of just zapping it use the
>> hypercall to do the unmap and release the grant.
> 
> We are tackling that by having our own page table hanging off the
> structure representing our seg (thing created when we do the equiv of
> your grant call).

--verbose please.  I don't understand that "own page table" trick.  Is
that page table actually used by the processor or is it just used to
maintain some sort of page list?

>> Current implementation uses a new vm_ops operation which is called if
>> present instead of doing a ptep_get_and_clear_full().  It is in the
>> XenSource tree only, mainline hasn't this yet due to implementing only
>> the DomU bits so far.  When adding Dom0 support to mainline we'll need
>> some way to handle it, and I'd like to see the notifies be designed in a
>> way that Xen can simply use them.
> 
> Would the callouts Christoph proposed work for you if you maintained
> your own page table and moved them after the callouts the mmu_notifiers
> are using.

I *think* it would.  I'm not that deep in the VM details to be sure
though.  One possible problem I see is that the hypercall does also tear
down the mapping, so this isn't just a notify but also changes the page
tables, which could confuse the VM later on when it comes to the actual
pte clearing.

cheers,
  Gerd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
