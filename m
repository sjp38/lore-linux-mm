Date: Thu, 8 May 2008 04:56:52 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508025652.GW8276@duo.random>
References: <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org> <20080507233953.GM8276@duo.random> <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 06:12:32PM -0700, Christoph Lameter wrote:
> Andrea's mm_lock could have wider impact. It is the first effective 
> way that I have seen of temporarily holding off reclaim from an address 
> space. It sure is a brute force approach.

The only improvement I can imagine on mm_lock, is after changing the
name to global_mm_lock() to reestablish the signal_pending check in
the loop that takes the spinlock and to backoff and put the cap to 512
vmas so the ram wasted on anon-vmas wouldn't save more than 10-100usec
at most (plus the vfree that may be a bigger cost but we're ok to pay
it and it surely isn't security related).

Then on the long term we need to talk to Matt on returning a parameter
to the sort function to break the loop. After that we remove the 512
vma cap and mm_lock is free to run as long as it wants like
/dev/urandom, nobody can care less how long it will run before
returning as long as it reacts to signals.

This is the right way if we want to support XPMEM/GRU efficiently and
without introducing unnecessary regressions in the VM fastpaths and VM
footprint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
