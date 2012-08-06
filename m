Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A567C6B0069
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 17:38:35 -0400 (EDT)
Received: by yenr5 with SMTP id r5so3640224yen.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 14:38:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344263368.27828.60.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	<1343946858-8170-9-git-send-email-walken@google.com>
	<1344263368.27828.60.camel@twins>
Date: Mon, 6 Aug 2012 14:38:33 -0700
Message-ID: <CANN689FD8VvO1iaDKneOTWyioTvdUVPrm=R9doOU7G_sBHNx_A@mail.gmail.com>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, Aug 6, 2012 at 7:29 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
>> +void __rb_insert_augmented(struct rb_node *node, struct rb_root *root,
>> +       void (*augment_rotate)(struct rb_node *old, struct rb_node *new))
>> +{
>> +       __rb_insert(node, root, augment_rotate);
>> +}
>> +EXPORT_SYMBOL(__rb_insert_augmented);
>> +
>> +void rb_erase_augmented(struct rb_node *node, struct rb_root *root,
>> +                       const struct rb_augment_callbacks *augment)
>> +{
>> +       __rb_erase(node, root, augment);
>> +}
>> +EXPORT_SYMBOL(rb_erase_augmented);
>
> From a symmetry POV I'd say have both take the rb_augment_callbacks
> thing. The two taking different arguments is confusing at best.

The idea there is that from the user's point of view, both take the
struct rb_augment_callbacks. Note that include/linux/rbtree.h has
this:

static inline void
rb_insert_augmented(struct rb_node *node, struct rb_root *root,
                    const struct rb_augment_callbacks *augment)
{
        __rb_insert_augmented(node, root, augment->rotate);
}

Now the reason why the actual implementation takes the function
pointer directly (and not the struct) is that the expected case is
that the call site will have the struct declared as a const, so the
compiler will be able to optimize out the dereference and directly
pass out the function pointer as a constant.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
