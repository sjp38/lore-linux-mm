Date: Tue, 5 Feb 2008 16:12:22 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080205221221.GP17211@sgi.com>
References: <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com> <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com> <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com> <20080205180802.GE7441@v2.random> <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com> <20080205205519.GF7441@v2.random> <Pine.LNX.4.64.0802051400200.14665@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802051400200.14665@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2008 at 02:06:23PM -0800, Christoph Lameter wrote:
> On Tue, 5 Feb 2008, Andrea Arcangeli wrote:
> 
> > On Tue, Feb 05, 2008 at 10:17:41AM -0800, Christoph Lameter wrote:
> > > The other approach will not have any remote ptes at that point. Why would 
> > > there be a coherency issue?
> > 
> > It never happens that two threads writes to two different physical
> > pages by working on the same process virtual address. This is an issue
> > only for KVM which is probably ok with it but certainly you can't
> > consider the dependency on the page-pin less fragile or less complex
> > than my PT lock approach.
> 
> You can avoid the page-pin and the pt lock completely by zapping the 
> mappings at _start and then holding off new references until _end.

XPMEM is doing this by putting our equivalent structure of the mm into a
recalling state which will cause all future faulters to back off, it then
marks any currently active faults in the range as invalid (we have a very
small number of possible concurrent faulters for a different reason),
proceeds to start remote shoot-downs, waits for those shoot-downs to
complete, then returns from the _begin callout with the mm-equiv still in
the recalling state.  Additional recalls may occur, but no new faults can.
The _end callout reduces the number of active recalls until there are
none left at which point the faulters are allowed to proceed again.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
