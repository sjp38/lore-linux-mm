Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99C8160021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 06:20:25 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 27 Dec 2009 12:19:56 +0100
Message-ID: <1261912796.15854.25.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-12-25 at 10:51 +0900, KAMEZAWA Hiroyuki wrote:
> Index: linux-2.6.33-rc2/lib/rbtree.c
> ===================================================================
> --- linux-2.6.33-rc2.orig/lib/rbtree.c
> +++ linux-2.6.33-rc2/lib/rbtree.c
> @@ -30,19 +30,19 @@ static void __rb_rotate_left(struct rb_n
>  
>         if ((node->rb_right = right->rb_left))
>                 rb_set_parent(right->rb_left, node);
> -       right->rb_left = node;
> +       rcu_assign_pointer(right->rb_left, node);
>  
>         rb_set_parent(right, parent);
>  
>         if (parent)
>         {
>                 if (node == parent->rb_left)
> -                       parent->rb_left = right;
> +                       rcu_assign_pointer(parent->rb_left, right);
>                 else
> -                       parent->rb_right = right;
> +                       rcu_assign_pointer(parent->rb_right, right);
>         }
>         else
> -               root->rb_node = right;
> +               rcu_assign_pointer(root->rb_node, right);
>         rb_set_parent(node, right);
>  }
>  
> @@ -53,19 +53,19 @@ static void __rb_rotate_right(struct rb_
>  
>         if ((node->rb_left = left->rb_right))
>                 rb_set_parent(left->rb_right, node);
> -       left->rb_right = node;
> +       rcu_assign_pointer(left->rb_right, node);
>  
>         rb_set_parent(left, parent);
>  
>         if (parent)
>         {
>                 if (node == parent->rb_right)
> -                       parent->rb_right = left;
> +                       rcu_assign_pointer(parent->rb_right, left);
>                 else
> -                       parent->rb_left = left;
> +                       rcu_assign_pointer(parent->rb_left, left);
>         }
>         else
> -               root->rb_node = left;
> +               rcu_assign_pointer(root->rb_node, left);
>         rb_set_parent(node, left);
>  }


Consider the tree rotation:


           Q                        P
         /   \                    /   \
       P       C                A       Q
     /   \                            /   \
   A       B                        B       C


Since this comprises of 3 assignments (assuming right rotation):

  Q.left = B
  P.right = Q
  parent = P

it is non-atomic. This in turn means that any lock-less decent into the
tree will be able to miss a whole subtree or worse (imagine us being at
Q, needing to go to A, then the rotation happens, and all we can choose
from is B or C).

Your changelog states as much.

"Even if RB-tree rotation occurs while we walk tree for look-up, we just
miss vma without oops."

However, since this is the case, do we still need the
rcu_assign_pointer() conversion your patch does? All I can see it do is
slow down all RB-tree users, without any gain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
