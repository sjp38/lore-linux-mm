Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0879B6B0087
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 22:16:42 -0500 (EST)
Date: Wed, 22 Dec 2010 12:15:07 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC] radix_tree_destroy?
Message-ID: <20101222031507.GE30700@linux-sh.org>
References: <20101217032721.GD20847@linux-sh.org> <7fbf2264-04be-4899-9c1f-5c2e0942b158@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fbf2264-04be-4899-9c1f-5c2e0942b158@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2010 at 10:44:06AM -0800, Dan Magenheimer wrote:
> > > +void radix_tree_destroy(struct radix_tree_root *root, void
> > (*slot_free)(void *))
> > > +{
> > > +	if (root->rnode == NULL)
> > > +		return;
> > > +	if (root->height == 0)
> > > +		slot_free(root->rnode);
> > 
> > Don't you want indirect_to_ptr(root->rnode) here? You probably also
> > don't
> > want the callback in the !radix_tree_is_indirect_ptr() case.
> > 
> > > +	else {
> > > +		radix_tree_node_destroy(root->rnode, root->height,
> > slot_free);
> > > +		radix_tree_node_free(root->rnode);
> > > +		root->height = 0;
> > > +	}
> > > +	root->rnode = NULL;
> > > +}
> > 
> > The above will handle the nodes, but what about the root? It looks like
> > you're at least going to leak tags on the root, so at the very least
> > you'd still want a root_tag_clear_all() here.
> 
> Thanks for your help.  Will do both.  My use model doesn't require
> tags or rcu, so my hacked version of radix_tree_destroy missed those
> subtleties.
> 
> So my assumption was correct?  There is no way to efficiently
> destroy an entire radix tree without adding this new routine?
> 
Not that I'm specifically aware of, no. Most of the in-tree radix users
bury the tree pointer under some other data structure that is separately
accounted and then manually balanced with the insert/remove pair. I
suppose your use case is modular and you wish to tear down the root
completely on exit. In that case, if you have items you need to iterate
over to clean up after for a clean exit anyways then simply wrapping in
to radix_tree_delete() at that point for node-at-a-time freeing would be
consistent with in-tree usage today. It'd be interesting to know what
precisely your use case is and why the existing node-at-a-time delete
semantics are sub-optimal for you, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
