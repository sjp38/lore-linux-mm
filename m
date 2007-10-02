Date: Tue, 02 Oct 2007 11:20:43 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch / 002](memory hotplug) Callback function to create kmem_cache_node.
In-Reply-To: <Pine.LNX.4.64.0710011334090.19779@schroedinger.engr.sgi.com>
References: <20071001183316.7A9B.Y-GOTO@jp.fujitsu.com> <Pine.LNX.4.64.0710011334090.19779@schroedinger.engr.sgi.com>
Message-Id: <20071002105422.2790.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 1 Oct 2007, Yasunori Goto wrote:
> 
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> > +static void __slab_callback_offline(int nid)
> > +{
> > +	struct kmem_cache_node *n;
> > +	struct kmem_cache *s;
> > +
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +		if (s->node[nid]) {
> > +			n = get_node(s, nid);
> > +			s->node[nid] = NULL;
> > +			kmem_cache_free(kmalloc_caches, n);
> > +		}
> > +	}
> > +}
> 
> I think we need to bug here if there are still objects on the node that 
> are in use. This will silently discard the objects.
> 
Here is just the rollback code for an allocation failure of
kmem_cache_node in halfway.
So, there is a case some of them are not allocated yet.
Any slabs don't use new kmem_cache_node before the new nodes page is
available --so far--.
But, in the future, here will be useful for node hot-unplug code,
and its check will be necessary.  Ok. I'll add its check.

Do you mean that just nr_slabs should be checked like followings?
I'm not sure this is enough.

    :
if (s->node[nid]) {
	n = get_node(s, nid);
	if (!atomic_read(&n->nr_slabs)) {
		s->node[nid] = NULL;
		kmem_cache_free(kmalloc_caches, n);
	}
}
    :
    :

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
