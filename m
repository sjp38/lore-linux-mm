Date: Fri, 30 May 2003 18:00:27 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] Convert do_no_page() to a hook to avoid DFS race
Message-Id: <20030530180027.75680efd.akpm@digeo.com>
In-Reply-To: <20030530164150.A26766@us.ibm.com>
References: <20030530164150.A26766@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

"Paul E. McKenney" <paulmck@us.ibm.com> wrote:
>
> Rediffed to 2.5.70-mm2.
> 
> This patch allows a distributed filesystem to avoid the
> pagefault/cross-node-invalidate race described in:
> 
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=105286345316249&w=2
> 
> This patch converts the bulk of do_no_page() into a hook that may
> be called from the ->nopage vm_operations_struct callout.

Seems reasonable.

> There
> is still an inlined do_no_page() wrapper due to the fact that
> do_anonymous_page() requires that the mm->page_table_lock be
> held on entry, while the ->nopage callouts require that this
> lock be dropped.

I sugest you change the ->nopage definition so that page_table_lock is held
on entry to ->nopage, and ->nopage must drop it at some point.  This gives
the nopage implementations some more flexibility and may perhaps eliminate
that special case?

> This patch is untested.

I don't think there's a lot of point in making changes until the code which
requires those changes is accepted into the tree.  Otherwise it may be
pointless churn, and there's nothing in-tree to exercise the new features.

> An alternative to this patch includes the nopagedone() patch posted
> moments ago.  hch has also suggested that do_anonymous_page() be
> converted to a ->nopage callout, but this would require that all
> of the other ->nopage callouts drop mm->page_table_lock as their
> first action.  If people believe that this is the right thing to
> do, I will happily produce such a patch.

That sounds better to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
