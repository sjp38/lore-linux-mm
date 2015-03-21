Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 823816B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 20:47:52 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so2030799iec.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:47:52 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id b15si206345igv.12.2015.03.20.17.47.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 17:47:51 -0700 (PDT)
Received: by igcqo1 with SMTP id qo1so1705051igc.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:47:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550CB8D1.9030608@oracle.com>
References: <550C37C9.2060200@oracle.com>
	<CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com>
	<550CA3F9.9040201@oracle.com>
	<550CB8D1.9030608@oracle.com>
Date: Fri, 20 Mar 2015 17:47:51 -0700
Message-ID: <CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 20, 2015 at 5:18 PM, David Ahern <david.ahern@oracle.com> wrote:
> On 3/20/15 4:49 PM, David Ahern wrote:
>>
>> I did ask around and apparently this bug is hit only with the new M7
>> processors. DaveM: that's why you are not hitting this.

Quite frankly, this smells even more like an architecture bug. It
could be anywhere: it could be a CPU memory ordering issue, a compiler
bug, or a missing barrier or other thing.

How confident are you in the M7 memory ordering rules? It's a fairly
new core, no? With new speculative reads etc? Maybe the Linux
spinlocks don't have the right serialization, and more aggressive
reordering in the new core shows a bug?

Looking at this code, if this is a race, I see a few things that are
worth checking out

 - it does a very much overlapping "memmove()". The
sparc/lib/memmove.S file looks suspiciously bad (is that a
byte-at-a-time loop? Is it even correctly checking overlap?)

 - it relies on both percpu data and a spinlock. I'm sure the sparc
spinlock code has been tested *extensively* with old cores, but maybe
some new speculative read ends up breaking them?

I'm assuming M7 still TSO and 'ldsub' has acquire semantics? Is it
configurable like some sparc versions? I'm wondering whether the
Solaris locks might have some extra memory barriers due to supporting
the other (weaker) sparc memory models, and maybe they hid some M7
"feature" by mistake...

*Some* of the sparc memcpy routines have odd membar's in them.  Why
would a TSO machine need a memory barrier inside a memcpy. That just
makes me go "Ehh?"

> Here's another data point: If I disable NUMA I don't see the problem.
> Performance drops, but no NULL pointer splats which would have been panics.

So the NUMA case triggers the per-node "n->shared" logic, which
*should* be protected by "n->list_lock". Maybe there is some bug there
- but since that code seems to do ok on x86-64 (and apparently older
sparc too), I really would look at arch-specific issues first.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
