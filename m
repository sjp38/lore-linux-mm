Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 060926B0068
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:38:53 -0400 (EDT)
Date: Tue, 21 Aug 2012 15:38:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/5] mempolicy: fix refcount leak in
 mpol_set_shared_policy()
In-Reply-To: <20120821071532.GB1657@suse.de>
Message-ID: <0000013949d61abd-83aaf442-a4a1-4558-9045-ed91d77aae00-000000@email.amazonses.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-5-git-send-email-mgorman@suse.de> <00000139459223d7-93a9c53f-6724-4a4b-b675-cd25d8d53c71-000000@email.amazonses.com> <20120821071532.GB1657@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, 21 Aug 2012, Mel Gorman wrote:

> On Mon, Aug 20, 2012 at 07:46:09PM +0000, Christoph Lameter wrote:
> > On Mon, 20 Aug 2012, Mel Gorman wrote:
> >
> > > @@ -2318,9 +2323,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
> > >  	while (next) {
> > >  		n = rb_entry(next, struct sp_node, nd);
> > >  		next = rb_next(&n->nd);
> > > -		rb_erase(&n->nd, &p->root);
> >
> > Looks like we need to keep the above line? sp_delete does not remove the
> > tree entry.
> >
> > > -		mpol_put(n->policy);
> > > -		kmem_cache_free(sn_cache, n);
> > > +		sp_delete(p, n);
>
> Yes it does, could you have accidentally mixed up sp_free (which does not
> remove the tree entry) and sp_delete (which does)? The altered code ends
> up looking like this;

Yup I got that mixed up.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
