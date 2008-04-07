From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 02/10] emm: notifier logic
Date: Mon, 7 Apr 2008 08:06:02 +0200
Message-ID: <20080407060602.GE9309@duo.random>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.469710551@sgi.com>
	<20080405005759.GH14784@duo.random>
	<Pine.LNX.4.64.0804062246030.18148@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804062246030.18148@schroedinger.engr.sgi.com>
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
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-Id: linux-mm.kvack.org

On Sun, Apr 06, 2008 at 10:48:56PM -0700, Christoph Lameter wrote:
> On Sat, 5 Apr 2008, Andrea Arcangeli wrote:
> 
> > > +	rcu_assign_pointer(mm->emm_notifier, e);
> > > +	mm_unlock(mm);
> > 
> > My mm_lock solution makes all rcu serialization an unnecessary
> > overhead so you should remove it like I already did in #v11. If it
> > wasn't the case, then mm_lock wouldn't be a definitive fix for the
> > race.
> 
> There still could be junk in the cache of one cpu. If you just read the 
> new pointer but use the earlier content pointed to then you have a 
> problem.

There can't be junk, spinlocks provides semantics of proper memory
barriers, just like rcu, so it's entirely superflous.

There could be junk only if any of the mmu_notifier_* methods would be
invoked _outside_ the i_mmap_lock and _outside_ the anon_vma and
outside the mmap_sem, that is never the case of course.

> So a memory fence / barrier is needed to guarantee that the contents 
> pointed to are fetched after the pointer.

It's not needed... if you were right we could never possibly run a
list_for_each inside any spinlock protected critical section and we'd
always need to use the _rcu version instead. The _rcu version is
needed only when the list walk happens outside the spinlock critical
section of course (rcu = no spinlock cacheline exlusive write
operation in the read side, here the read side takes the spinlock big time).

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
