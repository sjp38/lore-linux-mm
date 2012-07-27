Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A16CB6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 17:55:48 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4432560ggm.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 14:55:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343419466.32120.50.camel@twins>
References: <1342787467-5493-1-git-send-email-walken@google.com>
	<1342787467-5493-5-git-send-email-walken@google.com>
	<1343419466.32120.50.camel@twins>
Date: Fri, 27 Jul 2012 14:55:46 -0700
Message-ID: <CANN689HSP-yKt6z6Szv-=_MT8sEWJ8dmJ5sr+HzkYgTD2P3xug@mail.gmail.com>
Subject: Re: [PATCH 4/6] rbtree: faster augmented insert
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 27, 2012 at 1:04 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, 2012-07-20 at 05:31 -0700, Michel Lespinasse wrote:
>> +static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_new)
>> +{
>> +       struct test_node *old = rb_entry(rb_old, struct test_node, rb);
>> +       struct test_node *new = rb_entry(rb_new, struct test_node, rb);
>> +
>> +       /* Rotation doesn't change subtree's augmented value */
>> +       new->augmented = old->augmented;
>> +       old->augmented = augment_recompute(old);
>> +}
>
>> +static inline void augment_propagate(struct rb_node *rb)
>> +{
>> +       while (rb) {
>> +               struct test_node *node = rb_entry(rb, struct test_node, rb);
>> +               node->augmented = augment_recompute(node);
>> +               rb = rb_parent(&node->rb);
>> +       }
>> +}
>
> So why do we have to introduce these two new function pointers to pass
> along when they can both be trivially expressed in the old single
> augment function?

Its because augment_rotate() needs to be a static function that we can
take the address of and pass along as a callback to the tree
rebalancing functions, while augment_propagate() needs to be an inline
function that gets compiled within an __rb_erase() variant for a given
type of augmented rbtree.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
