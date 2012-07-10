Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id E87986B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 19:10:29 -0400 (EDT)
Received: by yenr5 with SMTP id r5so697150yen.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 16:10:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FFC0B0E.8070600@att.net>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	<1341876923-12469-3-git-send-email-walken@google.com>
	<4FFC0B0E.8070600@att.net>
Date: Tue, 10 Jul 2012 16:10:28 -0700
Message-ID: <CANN689HVQndmGaNm4n=dDB1YeTvDtQx9Vaq90XcEqM+kSNAN3Q@mail.gmail.com>
Subject: Re: [PATCH 02/13] rbtree: empty nodes have no color
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Santos <daniel.santos@pobox.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, Jul 10, 2012 at 3:59 AM, Daniel Santos <danielfsantos@att.net> wrote:
>> One final rb_init_node() caller was recently added in sysctl code
>> to implement faster sysctl name lookups. This code doesn't make use
>> of RB_EMPTY_NODE at all, and from what I could see it only called
>> rb_init_node() under the mistaken assumption that such initialization
>> was required before node insertion.
> That was one of the problems with rb_init_node().  Not being documented,
> one would assume it's needed unless you study the code more closely.

Agree, the name made it sound like it was required, while it wasn't.

Looking at the code history, it's pretty clear that the function was
introduced for the wrong reasons...

> BTW, the current revision of my patches adds some doc comments to struct
> rb_node since the actual function of rb_parent_color isn't very clear
> without a lot of study.
>
> /**
>  * struct rb_node
>  * @rb_parent_color: Contains the color in the lower 2 bits (although
> only bit
>  *              zero is currently used) and the address of the parent in
>  *              the rest (lower 2 bits of address should always be zero on
>  *              any arch supported).  If the node is initialized and not a
>  *              member of any tree, the parent point to its self.  If the
>  *              node belongs to a tree, but is the root element, the
>  *              parent will be NULL.  Otherwise, parent will always
>  *              point to the parent node in the tree.
>  * @rb_right:        Pointer to the right element.
>  * @rb_left:         Pointer to the left element.
>  */
>
> That said, there's an extra bit in the rb_parent_color that can be used
> for some future purpose.

My preference would be for such comments to go into lib/rbtree.c, NOT
include/lib/rbtree.h . The reason being that we really don't want
rbtree users to start depending on rbtree internals - it's best if
they just stick to using the documented APIs :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
