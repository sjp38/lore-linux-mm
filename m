Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C60FD6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 17:55:46 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so945033ggn.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 14:55:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344267537.27828.93.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	<1343946858-8170-9-git-send-email-walken@google.com>
	<1344262669.27828.55.camel@twins>
	<1344267537.27828.93.camel@twins>
Date: Mon, 6 Aug 2012 14:55:45 -0700
Message-ID: <CANN689HKPKeZ-sqqwXGPhv=Jno4c=v=ffeOxLPkOFmMzEVXexw@mail.gmail.com>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, Aug 6, 2012 at 8:38 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, 2012-08-06 at 16:17 +0200, Peter Zijlstra wrote:
>
>> Why would every user need to replicate the propagate and rotate
>> boilerplate?
>
> So I don't have a tree near that any of this applies to (hence no actual
> patch)

All right, here are instructions to get a tree this will apply to :)
1- fetch linux-next tree
2- check out next-20120806
3- revert e406c4110c968b7691c4ccfadcd866a74a72fa5b (was sent as
previous RFC version of this series, didn't realize it had made it
into -mm)
4- apply patches 1 and 3-9 of this series (patch 2 was also sent as
previous RFC version and made it into -mm)

> but why can't we have something like:
>
> struct rb_augment_callback {
>         const bool (*update)(struct rb_node *node);
>         const int offset;
>         const int size;
> };
>
> #define RB_AUGMENT_CALLBACK(_update, _type, _rb_member, _aug_member)    \
> (struct rb_augment_callback){                                           \
>         .update = _update,                                              \
>         .offset = offsetof(_type, _aug_member) -                        \
>                   offsetof(_type, _rb_member),                          \
>         .size   = sizeof(((_type *)NULL)->_aug_member),                 \
> }
>
> static __always_inline void
> augment_copy(struct rb_node *dst, struct rb_node *src,
>              const rb_augment_callback *ac)
> {
>         memcpy((void *)dst + ac->offset,
>                (void *)src + ac->offset,
>                ac->size);
> }
>
> static __always_inline void
> augment_propagate(struct rb_node *rb, struct rb_node *stop,
>                   const struct rb_augment_callback *ac)
> {
>         while (rb != stop) {
>                 if (!ac->update(rb))
>                         break;
>                 rb = rb_parent(rb);
>         }
> }
>
> static __always_inline void
> augment_rotate(struct rb_node *old, struct rb_node *new.
>                const struct rb_augment_callback *ac)
> {
>         augment_copy(new, old, ac);
>         (void)ac->update(old);
> }

I don't think this would work well, because ac->offset and ac->size
wouldn't be known at the point where they are needed, so the memcpy
wouldn't be nicely optimized into a fetch and store of the desired
size.

However, I wouldn't have a problem with declaring all 3 callbacks (and
the struct holding them) using a preprocessor macro as you propose.
Would that seem fine with you ? I can send an add-on patch to do that.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
