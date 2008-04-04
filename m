From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: EMM: disable other notifiers before register and
	unregister
Date: Fri, 4 Apr 2008 14:30:40 +0200
Message-ID: <20080404123040.GC10185@duo.random>
References: <20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
	<20080403151908.GB9603@duo.random>
	<Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 03, 2008 at 12:20:41PM -0700, Christoph Lameter wrote:
> On Thu, 3 Apr 2008, Andrea Arcangeli wrote:
> 
> > My attempt to fix this once and for all is to walk all vmas of the
> > "mm" inside mmu_notifier_register and take all anon_vma locks and
> > i_mmap_locks in virtual address order in a row. It's ok to take those
> > inside the mmap_sem. Supposedly if anybody will ever take a double
> > lock it'll do in order too. Then I can dump all the other locking and
> 
> What about concurrent mmu_notifier registrations from two mm_structs 
> that have shared mappings? Isnt there a potential deadlock situation?

No, the ordering of the lock avoids that. Here a snippnet.

/*
 * This operation locks against the VM for all pte/vma/mm related
 * operations that could ever happen on a certain mm. This includes
 * vmtruncate, try_to_unmap, and all page faults. The holder
 * must not hold any mm related lock. A single task can't take more
 * than one mm lock in a row or it would deadlock.
 */

So you can't do:

   mm_lock(mm1);
   mm_lock(mm2);

But if two different tasks run the mm_lock everything is ok. Each task
in the system can lock at most 1 mm at time.

> Well good luck. Hopefully we will get to something that works.

Looks good so far but I didn't finish it yet.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
