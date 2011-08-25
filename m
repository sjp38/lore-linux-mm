Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ECC406B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 09:41:50 -0400 (EDT)
Received: by qyk7 with SMTP id 7so1815955qyk.14
        for <linux-mm@kvack.org>; Thu, 25 Aug 2011 06:41:48 -0700 (PDT)
MIME-Version: 1.0
From: Prateek Sharma <prateek3.14@gmail.com>
Date: Thu, 25 Aug 2011 19:11:28 +0530
Message-ID: <CAKwxwqxxPRkTtHy4GvK8JFGV04FpJ5M39gTSwPDQAHxY=qJn8Q@mail.gmail.com>
Subject: KSM Unstable tree questiom
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello everyone .
I've been trying to understand how KSM works (i want to make some
modifications / implement some optimizations) .
One thing that struck me odd was the high number of calls to
remove_rmap_item_from_tree .
Particularly, this instance in cmp_and_merge_page :

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * As soon as we merge this page, we want to=
 remove the
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * rmap_item of the page we have merged with=
 from the unstable
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * tree, and insert it instead as new node i=
n the stable tree.
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (kpage) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remove_rmap_item_from_tree(
tree_rmap_item);

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lock_page(kpage);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stable_node =3D stable_tree_=
insert(kpage);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (stable_node) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stable_tree_=
append(tree_rmap_item, stable_node);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stable_tree_=
append(rmap_item, stable_node);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}

Here, from i understand, we've found a match in the unstable tree, and
are adding a stable node in the stable tree.
My question is: why do we need to remove the rmap_item from unstable
tree here? At the end of a scan we are erasing the unstable tree
anyway. Also, all searches first consider the stable tree , and then
the unstable tree.
What will happen if we find a match in the unstable tree, and simply
update tree_rmap_item to point to a stable_node ?

Thanks for reading. I'd love to share the ideas i have for (attempting
to) improve KSM, if anyone is=A0interested.

Prateek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
