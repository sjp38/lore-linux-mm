Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E28536B0095
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 13:44:49 -0500 (EST)
MIME-Version: 1.0
Message-ID: <7fbf2264-04be-4899-9c1f-5c2e0942b158@default>
Date: Fri, 17 Dec 2010 10:44:06 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] radix_tree_destroy?
References: <62b1cf2f-17ec-45c9-a980-308d9b75cdc5@default
 20101217032721.GD20847@linux-sh.org>
In-Reply-To: <20101217032721.GD20847@linux-sh.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > +void radix_tree_destroy(struct radix_tree_root *root, void
> (*slot_free)(void *))
> > +{
> > +=09if (root->rnode =3D=3D NULL)
> > +=09=09return;
> > +=09if (root->height =3D=3D 0)
> > +=09=09slot_free(root->rnode);
>=20
> Don't you want indirect_to_ptr(root->rnode) here? You probably also
> don't
> want the callback in the !radix_tree_is_indirect_ptr() case.
>=20
> > +=09else {
> > +=09=09radix_tree_node_destroy(root->rnode, root->height,
> slot_free);
> > +=09=09radix_tree_node_free(root->rnode);
> > +=09=09root->height =3D 0;
> > +=09}
> > +=09root->rnode =3D NULL;
> > +}
>=20
> The above will handle the nodes, but what about the root? It looks like
> you're at least going to leak tags on the root, so at the very least
> you'd still want a root_tag_clear_all() here.

Thanks for your help.  Will do both.  My use model doesn't require
tags or rcu, so my hacked version of radix_tree_destroy missed those
subtleties.

So my assumption was correct?  There is no way to efficiently
destroy an entire radix tree without adding this new routine?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
