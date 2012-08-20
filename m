Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3B2886B0070
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:28:04 -0400 (EDT)
Date: Mon, 20 Aug 2012 15:28:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/9] rbtree: place easiest case first in rb_erase()
Message-Id: <20120820152802.272ec736.akpm@linux-foundation.org>
In-Reply-To: <1345500331-10546-4-git-send-email-walken@google.com>
References: <1345500331-10546-1-git-send-email-walken@google.com>
	<1345500331-10546-4-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, 20 Aug 2012 15:05:25 -0700
Michel Lespinasse <walken@google.com> wrote:

> In rb_erase, move the easy case (node to erase has no more than
> 1 child) first. I feel the code reads easier that way.

Well.  For efficiency we should put the commonest case first.  Is that
the case here?

> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -368,17 +368,28 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
>  
>  void rb_erase(struct rb_node *node, struct rb_root *root)
>  {
> -	struct rb_node *child, *parent;
> +	struct rb_node *child = node->rb_right, *tmp = node->rb_left;

Coding style nit: multiple-definitions-per-line makes it harder to
locate a particular definition, and from long experience I can assure
you that it makes management of subsequent overlapping patches quite a
lot harder.  Also, one-definition-per-line gives room for a nice little
comment, and we all like nice little comments.

Also, "tmp" is a rotten name.  Your choice of an identifier is your
opportunity to communicate something to the reader.  When you choose
"tmp", you threw away that opportunity.  Should it be called "left"?


--- a/lib/rbtree.c~rbtree-place-easiest-case-first-in-rb_erase-fix
+++ a/lib/rbtree.c
@@ -368,12 +368,13 @@ static void __rb_erase_color(struct rb_n
 
 void rb_erase(struct rb_node *node, struct rb_root *root)
 {
-	struct rb_node *child = node->rb_right, *tmp = node->rb_left;
+	struct rb_node *child = node->rb_right
+	struct rb_node *tmp = node->rb_left;
 	struct rb_node *parent;
 	int color;
 
 	if (!tmp) {
-	case1:
+case1:
 		/* Case 1: node to erase has no more than 1 child (easy!) */
 
 		parent = rb_parent(node);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
