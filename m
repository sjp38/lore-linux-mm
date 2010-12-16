Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE026B0095
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 11:28:37 -0500 (EST)
MIME-Version: 1.0
Message-ID: <62b1cf2f-17ec-45c9-a980-308d9b75cdc5@default>
Date: Thu, 16 Dec 2010 08:27:41 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC] radix_tree_destroy?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

I am in need of a radix-tree routine that will efficiently
"destroy" an entire radix tree, but make callbacks to free the
slots.  Is it possible to do that (efficiently) with existing
radix-tree code?  If so, I'd appreciate some guidance.

If not, I'm thinking about submitting a patch (as part of a
larger patchset) that would look something like the patch below.
I'm uncertain of the rcu implications however... because
of the mass destruction, perhaps there could just be a
requirement that the caller must lock the entire tree
prior to the call?

Another option would be for me to do this outside of
radix-tree.c, but then I would need to move some defines and
the definition of the struct radix_tree_node from
radix-tree.c to radix-tree.h

Thanks for any advice!
Dan

P.S. I will be offline for an extended period over the holidays,
so apologies in advance if I am unable to respond quickly.

--- radix-tree.c=092010-10-20 14:30:22.000000000 -0600
+++ radix-tree.patch.c=092010-12-16 16:13:32.672039108 -0700
@@ -1318,6 +1318,42 @@ out:
 }
 EXPORT_SYMBOL(radix_tree_delete);
=20
+static void
+radix_tree_node_destroy(struct radix_tree_node *node, unsigned int height,
+=09=09=09void (*slot_free)(void *))
+{
+=09int i;
+
+=09if (height =3D=3D 0)
+=09=09return;
+=09for (i =3D 0; i < RADIX_TREE_MAP_SIZE; i++) {
+=09=09if (node->slots[i]) {
+=09=09=09if (height > 1) {
+=09=09=09=09radix_tree_node_destroy(node->slots[i],
+=09=09=09=09=09height-1, slot_free);
+=09=09=09=09radix_tree_node_free(node->slots[i]);
+=09=09=09=09node->slots[i] =3D NULL;
+=09=09=09} else
+=09=09=09=09slot_free(node->slots[i]);
+=09=09}
+=09}
+}
+
+void radix_tree_destroy(struct radix_tree_root *root, void (*slot_free)(vo=
id *))
+{
+=09if (root->rnode =3D=3D NULL)
+=09=09return;
+=09if (root->height =3D=3D 0)
+=09=09slot_free(root->rnode);
+=09else {
+=09=09radix_tree_node_destroy(root->rnode, root->height, slot_free);
+=09=09radix_tree_node_free(root->rnode);
+=09=09root->height =3D 0;
+=09}
+=09root->rnode =3D NULL;
+}
+EXPORT_SYMBOL(radix_tree_destroy);
+
 /**
  *=09radix_tree_tagged - test whether any items in the tree are tagged
  *=09@root:=09=09radix tree root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
