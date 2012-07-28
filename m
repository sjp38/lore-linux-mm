Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 117C16B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 20:44:17 -0400 (EDT)
Received: by obhx4 with SMTP id x4so6302653obh.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 17:44:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343419375.32120.48.camel@twins>
References: <1342787467-5493-1-git-send-email-walken@google.com>
	<1342787467-5493-6-git-send-email-walken@google.com>
	<1343419375.32120.48.camel@twins>
Date: Fri, 27 Jul 2012 17:44:15 -0700
Message-ID: <CANN689Fn=DYR8eGKkBJPeQYMtOfP6tykzqLMBOdV0Yg8OdrVPQ@mail.gmail.com>
Subject: Re: [PATCH 5/6] rbtree: faster augmented erase
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 27, 2012 at 1:02 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>On Fri, 2012-07-20 at 05:31 -0700, Michel Lespinasse wrote:
>> --- a/lib/rbtree_test.c
>> +++ b/lib/rbtree_test.c
>> @@ -1,5 +1,6 @@
>>  #include <linux/module.h>
>>  #include <linux/rbtree.h>
>> +#include <linux/rbtree_internal.h>
>This confuses me.. either its internal to the rb-tree implementation and
>users don't need to see it, or its not in which case huh?

So, I'm not 100% happy with this either.

What's going on is that I think it's best for users not to know about
these implementation details, and that's why I had moved these away
from include/linux/rbtree.h. However, I haven't been successful in
hiding these details from augmented rbtree users, so with my proposal,
if you want to implement some new feature using augmented rbtrees, you
do get exposed to some rbtree implementation details. This is
unfortunate but at least this exposure doesn't leak to your users -
you'd have to include linux/rbtree_internal.h only in your feature's C
file, so your users will never have to know about rbtree
implementation details.

>> +static inline void
>> +rb_erase_augmented(struct rb_node *node, struct rb_root *root,
>> +                  rb_augment_propagate *augment_propagate,
>> +                  rb_augment_rotate *augment_rotate)
>
> So why put all this in a static inline in a header? As it stands
> rb_erase() isn't inlined and its rather big, why would you want to
> inline it for augmented callers?

Just as the non-augmented rb_erase() is generated (as a non-inline
function) by merging together the rb_erase_augmented() inline function
and its dummy callbacks, I want each library that uses augmented
rbtrees to generate their own rb_erase() equivalent using their own
callbacks. The inline function in rbtree_internal.h is only to be used
as a template for generating one non-inline instance for each data
structure that uses augmented rbtrees.

> You could at least pull out the initial erase stuff into a separate
> function, that way the rb_erase_augmented thing would shrink to
> something like:
>
> rb_erase_augmented(node, root)
> {
>         struct rb_node *parent, *child;
>         bool black;
>
>         __rb_erase(node, root, &parent, &child, &black);
>         augmented_propagate(parent);
>         if (black)
>                 __rb_erase_color(child, parent, root, augment_rotate);
> }

I see that you looked at the first version of patch 5, where
augmented_propagate() still always updated all the way to the root. I
have since sent an updated version of patch 5 that does more limited
updates; however this makes it harder to do what you propose as the
callbacks now need to happen in more places than just before
__rb_erase_color().

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
