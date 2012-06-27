Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E44496B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:28:36 -0400 (EDT)
Message-ID: <1340800064.10063.48.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 27 Jun 2012 14:27:44 +0200
In-Reply-To: <4FE9DA1C.1010305@redhat.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	       <1340315835-28571-2-git-send-email-riel@surriel.com>
	      <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com>
	     <1340374439.18025.75.camel@twins> <4FE48054.5090407@redhat.com>
	    <1340375872.18025.77.camel@twins> <4FE4922D.8070501@surriel.com>
	   <1340652578.21991.18.camel@twins> <4FE8DD80.9040108@redhat.com>
	  <1340699507.21991.32.camel@twins> <4FE9B3B4.1050305@redhat.com>
	 <1340718349.21991.81.camel@twins> <4FE9DA1C.1010305@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, danielfsantos@att.net

On Tue, 2012-06-26 at 11:49 -0400, Rik van Riel wrote:
>=20
> However, doing an insert or delete changes the
> gap size for the _next_ vma, and potentially a
> change in the maximum gap size for the parent
> node, so both insert and delete cause two tree
> walks :(=20

Right,.. don't have anything smart for that :/

I guess there's nothing to it but create a number of variants of
rb_insert/rb_erase, possibly using Daniel's 'template' stuff so we don't
actually have to maintain multiple copies of the code.

Maybe something simple like:

static void __always_inline
__rb_insert(struct rb_node *node, struct rb_root *root, rb_augment_f func, =
bool threaded)
{
	/* all the fancy code */
}

void rb_insert(struct rb_node *node, struct rb_root *root)
{
	__rb_insert(node, root, NULL, false);
}

void rb_insert_threaded(struct rb_node *node, struct rb_root *root)
{
	__rb_insert(node, root, NULL, true);
}

void rb_insert_augment(struct rb_node *node, struct rb_root *root, rb_augme=
nt_f func)
{
	__rb_insert(node, root, func, false);
}

void rb_insert_augment_threaded(struct rb_node *node, struct rb_root *root,=
 rb_augment_f func)
{
	__rb_insert(node, root, func, true);
}

Would do, except it wouldn't be able to inline the augment function. For
that to happen we'd need to move __rb_insert() and the
__rb_insert_augment*() variants into rbtree.h.

But it would create clean variants without augmentation/threading
without too much duplicate code.


BTW, is there a reason rb_link_node() and rb_insert_color() are separate
functions? They seem to always be used together in sequence.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
