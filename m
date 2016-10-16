Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1BD76B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 18:48:45 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d186so88409955lfg.7
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 15:48:45 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id 65si16797459lfa.57.2016.10.16.15.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 15:48:44 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id b75so254877466lfg.3
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 15:48:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1476655575-6588-1-git-send-email-joelaf@google.com>
References: <20161016061057.GA26990@infradead.org> <1476655575-6588-1-git-send-email-joelaf@google.com>
From: Joel Fernandes <joelaf@google.com>
Date: Sun, 16 Oct 2016 15:48:42 -0700
Message-ID: <CAJWu+opXocyNmL2bA43NZjx7Se42fzEg6YphiE+Bon2qhpvqSg@mail.gmail.com>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic refcount
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, Joel Fernandes <joelaf@google.com>, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Christoph,

On Sun, Oct 16, 2016 at 3:06 PM, Joel Fernandes <joelaf@google.com> wrote:
> On Sat, Oct 15, 2016 at 11:10 PM, Christoph Hellwig <hch@infradead.org> wrote:
>> On Sat, Oct 15, 2016 at 03:59:34PM -0700, Joel Fernandes wrote:
>>> Also, could you share your concerns about use of atomic_t in my patch?
>>> I believe that since this is not a contented variable, the question of
>>> lock fairness is not a concern. It is also not a lock really the way
>>> I'm using it, it just keeps track of how many purges are in progress..
>>
>> atomic_t doesn't have any acquire/release semantics, and will require
>> off memory barrier dances to actually get the behavior you intended.
>> And from looking at the code I can't really see why we even would
>> want synchronization behavior - for the sort of problems where we
>> don't want multiple threads to run the same code at the same time
>> for effiency but not correctness reasons it's usually better to have
>> batch thresholds and/or splicing into local data structures before
>> operations.  Both are techniques used in this code, and I'd rather
>> rely on them and if required improve on them then using very odd
>> hoc synchronization methods.
>
> Thanks for the explanation. If you know of a better way to handle the sync=1
> case, let me know. In defense of atomics, even vmap_lazy_nr in the same code is
> atomic_t :) I am also not using it as a lock really, but just to count how many
> times something is in progress that's all - I added some more comments to my
> last patch to make this clearer in the code and now I'm also handling the case
> for sync=1.

Also, one more thing about the barrier dances you mentioned, this will
also be done by the spinlock which was there before my patch. So in
favor of my patch, it doesn't make things any worse than they were and
actually fixes the reported issue while preserving the original code
behavior. So I think it is a good thing to fix the issue considering
so many people are reporting it and any clean ups of the vmalloc code
itself can follow.

If you want I can looking into replacing the atomic_cmpxchg with an
atomic_inc and not do anything different for sync vs !sync except for
spinning when purges are pending. Would that make you feel a bit
better?

So instead of:
        if (!sync && !force_flush) {
                /*
                 * Incase a purge is already in progress, just return.
                 */
                if (atomic_cmpxchg(&purging, 0, 1))
                        return;
        } else
                atomic_inc(&purging);
,
Just do a:
                atomic_inc(&purging);


This should be Ok to do since in the !sync case, we'll just return
anyway if another purge was in progress.

Thanks,

Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
