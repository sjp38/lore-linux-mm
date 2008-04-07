From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: [patch 02/10] emm: notifier logic
Date: Sun, 6 Apr 2008 22:48:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804062246030.18148@schroedinger.engr.sgi.com>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.469710551@sgi.com>
	<20080405005759.GH14784@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080405005759.GH14784@duo.random>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-Id: linux-mm.kvack.org

On Sat, 5 Apr 2008, Andrea Arcangeli wrote:

> > +	rcu_assign_pointer(mm->emm_notifier, e);
> > +	mm_unlock(mm);
> 
> My mm_lock solution makes all rcu serialization an unnecessary
> overhead so you should remove it like I already did in #v11. If it
> wasn't the case, then mm_lock wouldn't be a definitive fix for the
> race.

There still could be junk in the cache of one cpu. If you just read the 
new pointer but use the earlier content pointed to then you have a 
problem.

So a memory fence / barrier is needed to guarantee that the contents 
pointed to are fetched after the pointer.
