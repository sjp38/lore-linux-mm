Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 349356B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 21:12:13 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3457936pbb.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 18:12:12 -0700 (PDT)
Date: Wed, 11 Jul 2012 18:12:08 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 00/13] rbtree updates
Message-ID: <20120712011208.GA1152@google.com>
References: <1341876923-12469-1-git-send-email-walken@google.com>
 <1342012996.3462.154.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342012996.3462.154.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Wed, Jul 11, 2012 at 6:23 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> Looks nice.. How about something like the below on top.. I couldn't
> immediately find a sane reason for the grand-parent to always be red in
> the insertion case.

Do you mean the case you marked XXX ? it is actually parent that is
red, which we know because we tested that a few lines earlier.

> @@ -85,12 +104,27 @@ void rb_insert_color(struct rb_node *nod
>                 } else if (rb_is_black(parent))
>                         break;
>
> +               /*
> +                * XXX
> +                */
>                 gparent = rb_red_parent(parent);

See :)

>                 if (parent == gparent->rb_left) {
>                         tmp = gparent->rb_right;
>                         if (tmp && rb_is_red(tmp)) {
> -                               /* Case 1 - color flips */
> +                               /*
> +                                * Case 1 - color flips
> +                                *
> +                                *       G            g
> +                                *      / \          / \
> +                                *     p   u  -->   P   U
> +                                *    /            /
> +                                *   n            N
> +                                *
> +                                * However, since g's parent might be red, and
> +                                * 4) does not allow this, we need to recurse
> +                                * at g.
> +                                */

I like these diagrams - I initially didn't think they'd work well, given the need for colors etc, but I now see that it's workable.

In __rb_erase_color(), some of the cases are more complicated than you drew however, because some node colors aren't known.
This is what I ended up with:

  *  5), then the longest possible path due to 4 is 2B.
  *
  *  We shall indicate color with case, where black nodes are uppercase and red
- *  nodes will be lowercase.
+ *  nodes will be lowercase. Unknown color nodes shall be drawn as red with
+ *  some accompanying text comment.
  */

+                                       /*
+                                        * Case 2 - sibling color flip
+                                        * (p could be either color here)
+                                        *
+                                        *     p             p
+                                        *    / \           / \
+                                        *   N   S    -->  N   s
+                                        *      / \           / \
+                                        *     Sl  Sr        Sl  Sr
+                                        *
+                                        * This leaves us violating 5), so
+                                        * recurse at p. If p is red, the
+                                        * recursion will just flip it to black
+                                        * and exit. If coming from Case 1,
+                                        * p is known to be red.
+                                        */

+                               /*
+                                * Case 3 - right rotate at sibling
+                                * (p could be either color here)
+                                *
+                                *    p             p
+                                *   / \           / \
+                                *  N   S    -->  N   Sl
+                                *     / \             \
+                                *    sl  Sr            s
+                                *                       \
+                                *                        Sr
+                                */

+                       /*
+                        * Case 4 - left rotate at parent + color flips
+                        * (p and sl could be either color here.
+                        *  After rotation, p becomes black, s acquires
+                        *  p's color, and sl keeps its color)
+                        *
+                        *       p               s
+                        *      / \             / \
+                        *     N   S     -->   P   Sr
+                        *        / \         / \
+                        *       sl  sr      N   sl
+                        */

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
