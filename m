Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BEAD26B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 03:21:28 -0400 (EDT)
Date: Tue, 21 Aug 2012 08:15:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/5] mempolicy: fix refcount leak in
 mpol_set_shared_policy()
Message-ID: <20120821071532.GB1657@suse.de>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
 <1345480594-27032-5-git-send-email-mgorman@suse.de>
 <00000139459223d7-93a9c53f-6724-4a4b-b675-cd25d8d53c71-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00000139459223d7-93a9c53f-6724-4a4b-b675-cd25d8d53c71-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Aug 20, 2012 at 07:46:09PM +0000, Christoph Lameter wrote:
> On Mon, 20 Aug 2012, Mel Gorman wrote:
> 
> > @@ -2318,9 +2323,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
> >  	while (next) {
> >  		n = rb_entry(next, struct sp_node, nd);
> >  		next = rb_next(&n->nd);
> > -		rb_erase(&n->nd, &p->root);
> 
> Looks like we need to keep the above line? sp_delete does not remove the
> tree entry.
> 
> > -		mpol_put(n->policy);
> > -		kmem_cache_free(sn_cache, n);
> > +		sp_delete(p, n);

Yes it does, could you have accidentally mixed up sp_free (which does not
remove the tree entry) and sp_delete (which does)? The altered code ends
up looking like this;

static void sp_delete(struct shared_policy *sp, struct sp_node *n)
{
        pr_debug("deleting %lx-l%lx\n", n->start, n->end);
        rb_erase(&n->nd, &sp->root);				<----- frees node here
        sp_free(n);
}

void mpol_free_shared_policy(struct shared_policy *p)
{
        struct sp_node *n;
        struct rb_node *next;

        if (!p->root.rb_node)
                return;
        mutex_lock(&p->mutex);
        next = rb_first(&p->root);
        while (next) {
                n = rb_entry(next, struct sp_node, nd);
                next = rb_next(&n->nd);
                sp_delete(p, n);				<---- equivalent to rb_erase(&n->nd, &p->root); sp_free(n);
        }
        mutex_unlock(&p->mutex);
}

Thanks Christoph for looking at this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
