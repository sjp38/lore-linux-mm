Date: Fri, 1 Feb 2008 13:00:28 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080201120028.GW7185@v2.random>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random> <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com> <20080131232842.GQ7185@v2.random> <Pine.LNX.4.64.0801311733140.24297@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311733140.24297@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 05:37:21PM -0800, Christoph Lameter wrote:
> On Fri, 1 Feb 2008, Andrea Arcangeli wrote:
> 
> > I appreciate the review! I hope my entirely bug free and
> > strightforward #v5 will strongly increase the probability of getting
> > this in sooner than later. If something else it shows the approach I
> > prefer to cover GRU/KVM 100%, leaving the overkill mutex locking
> > requirements only to the mmu notifier users that can't deal with the
> > scalar and finegrined and already-taken/trashed PT lock.
> 
> Mutex locking? Could you be more specific?

Robin understanding was correct on this point. Also I think if you add
start,end to range_end (like suggested a few times by me and once
by Robin) I may get away without a lock thanks to the page pin. That's
one strong reason why start,end are needed in range_end.

The only one that will definitely be forced to add a new lock around
follow_page, in addition to the very _scalable_ PT lock, is GRU.

> I hope you will continue to do reviews of the other mmu notifier patchset?

Sure. I will also create a new KVM patch to plug on top of your
versions (I already did for V2/V3 even if it never worked, but that
might have a build problem, see kvm-devel for details). To be clear,
as long as anything is merged that avoids me to use kprobes to make
KVM swap work, I'm satisfied. I thought my approach had several
advantages in simplicity, and being more obviously safe (in not
relaying entirely on the page pin and creating a window of time where
the linux pte writes to a page and the sptes writes to another one,
remember populate_range), and it avoids introducing external locks in
the GRU follow_page path. My approach was supposed to be in addition
of the range_start/end needed by xpmem that can't possibly take
advanage of the scalar PT lock and it definitely requires external
lock to serialize xpmem fault against linux pagefault (not the case
for GRU/KVM).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
