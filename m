From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/10] emm: notifier logic
Date: Sun, 6 Apr 2008 23:20:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804062314080.18728@schroedinger.engr.sgi.com>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.469710551@sgi.com>
	<20080405005759.GH14784@duo.random>
	<Pine.LNX.4.64.0804062246030.18148@schroedinger.engr.sgi.com>
	<20080407060602.GE9309@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080407060602.GE9309@duo.random>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-Id: linux-mm.kvack.org

On Mon, 7 Apr 2008, Andrea Arcangeli wrote:

> > > My mm_lock solution makes all rcu serialization an unnecessary
> > > overhead so you should remove it like I already did in #v11. If it
> > > wasn't the case, then mm_lock wouldn't be a definitive fix for the
> > > race.
> > 
> > There still could be junk in the cache of one cpu. If you just read the 
> > new pointer but use the earlier content pointed to then you have a 
> > problem.
> 
> There can't be junk, spinlocks provides semantics of proper memory
> barriers, just like rcu, so it's entirely superflous.
> 
> There could be junk only if any of the mmu_notifier_* methods would be
> invoked _outside_ the i_mmap_lock and _outside_ the anon_vma and
> outside the mmap_sem, that is never the case of course.

So we use other locks to perform serialization on the list chains? 
Basically the list chains are protected by either mmap_sem or an rmap 
lock? We need to document that.

In that case we could also add an unregister function.


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
