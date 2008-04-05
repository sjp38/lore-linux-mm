From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 02/10] emm: notifier logic
Date: Sat, 5 Apr 2008 02:57:59 +0200
Message-ID: <20080405005759.GH14784@duo.random>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.469710551@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20080404223131.469710551@sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-Id: linux-mm.kvack.org

On Fri, Apr 04, 2008 at 03:30:50PM -0700, Christoph Lameter wrote:
> +	mm_lock(mm);
> +	e->next = mm->emm_notifier;
> +	/*
> +	 * The update to emm_notifier (e->next) must be visible
> +	 * before the pointer becomes visible.
> +	 * rcu_assign_pointer() does exactly what we need.
> +	 */
> +	rcu_assign_pointer(mm->emm_notifier, e);
> +	mm_unlock(mm);

My mm_lock solution makes all rcu serialization an unnecessary
overhead so you should remove it like I already did in #v11. If it
wasn't the case, then mm_lock wouldn't be a definitive fix for the
race.

> +		e = rcu_dereference(e->next);

Same here.
