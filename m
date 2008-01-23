Date: Tue, 22 Jan 2008 19:21:48 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123012148.GF26420@sgi.com>
References: <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <1201044989.6807.46.camel@pasglop> <Pine.LNX.4.64.0801221640010.3329@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221640010.3329@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2008 at 04:40:50PM -0800, Christoph Lameter wrote:
> On Wed, 23 Jan 2008, Benjamin Herrenschmidt wrote:
> 
> > > - anon_vma/inode and pte locks are held during callbacks.
> > 
> > So how does that fix the problem of sleeping then ?
> 
> The locks are taken in the mmu_ops patch. This patch does not hold them 
> while performing the callbacks.

Let me start by clarifying, the page is referenced prior to exporting
and that reference is not removed until after recall is complete and
memory protections are back to normal.

As Christoph pointed out, the mmu_ops callouts do not allow sleeping.
This is a problem for us as our recall path includes a message to one or
more other hosts and a wait until we receive a response.  That message
sequence can take seconds or more to complete.  It includes an operation
to ensure the memory is in a cross-partition clean state and then changes
memory protection.  When that is complete we remove our page reference
and return.

Christoph's patch allows that long slow activity to happen prior to the
mmu_ops callout.  By the time the mmu_ops callout is made, we no longer
are exporting the page so the cleanup is equivalent to the cleanup of
a page we have never used.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
