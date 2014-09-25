Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9056B0038
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 23:28:50 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id ij19so5859545vcb.30
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 20:28:50 -0700 (PDT)
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
        by mx.google.com with ESMTPS id td13si528274vdb.70.2014.09.24.20.28.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 20:28:50 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq12so84832vcb.25
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 20:28:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140925132339.2629ffaa@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
	<20140924012832.4838.59410.stgit@notabene.brown>
	<20140924070418.GA990@gmail.com>
	<20140925132339.2629ffaa@notabene.brown>
Date: Wed, 24 Sep 2014 23:28:49 -0400
Message-ID: <CAHQdGtQzWOZ=X6CYubv=W6A4T5y4RPoq0EssAVkEPh759o32wg@mail.gmail.com>
Subject: Re: [PATCH 1/5] SCHED: add some "wait..on_bit...timeout()" interfaces.
From: Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux Kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Devel FS Linux <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Sep 24, 2014 at 11:23 PM, NeilBrown <neilb@suse.de> wrote:
> On Wed, 24 Sep 2014 09:04:18 +0200 Ingo Molnar <mingo@kernel.org> wrote:
>
>>
>> * NeilBrown <neilb@suse.de> wrote:
>>
>> > @@ -859,6 +860,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
>> >
>> >  extern int bit_wait(struct wait_bit_key *);
>> >  extern int bit_wait_io(struct wait_bit_key *);
>> > +extern int bit_wait_timeout(struct wait_bit_key *);
>> > +extern int bit_wait_io_timeout(struct wait_bit_key *);
>> >
>> >  /**
>> >   * wait_on_bit - wait for a bit to be cleared
>> > diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
>> > index 15cab1a4f84e..380678b3cba4 100644
>> > --- a/kernel/sched/wait.c
>> > +++ b/kernel/sched/wait.c
>> > @@ -343,6 +343,18 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
>> >  }
>> >  EXPORT_SYMBOL(out_of_line_wait_on_bit);
>> >
>> > +int __sched out_of_line_wait_on_bit_timeout(
>> > +   void *word, int bit, wait_bit_action_f *action,
>> > +   unsigned mode, unsigned long timeout)
>> > +{
>> > +   wait_queue_head_t *wq = bit_waitqueue(word, bit);
>> > +   DEFINE_WAIT_BIT(wait, word, bit);
>> > +
>> > +   wait.key.timeout = jiffies + timeout;
>> > +   return __wait_on_bit(wq, &wait, action, mode);
>> > +}
>> > +EXPORT_SYMBOL(out_of_line_wait_on_bit_timeout);
>> > +
>> >  int __sched
>> >  __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
>> >                     wait_bit_action_f *action, unsigned mode)
>> > @@ -520,3 +532,27 @@ __sched int bit_wait_io(struct wait_bit_key *word)
>> >     return 0;
>> >  }
>> >  EXPORT_SYMBOL(bit_wait_io);
>> > +
>> > +__sched int bit_wait_timeout(struct wait_bit_key *word)
>> > +{
>> > +   unsigned long now = ACCESS_ONCE(jiffies);
>> > +   if (signal_pending_state(current->state, current))
>> > +           return 1;
>> > +   if (time_after_eq(now, word->timeout))
>> > +           return -EAGAIN;
>> > +   schedule_timeout(word->timeout - now);
>> > +   return 0;
>> > +}
>> > +EXPORT_SYMBOL(bit_wait_timeout);
>> > +
>> > +__sched int bit_wait_io_timeout(struct wait_bit_key *word)
>> > +{
>> > +   unsigned long now = ACCESS_ONCE(jiffies);
>> > +   if (signal_pending_state(current->state, current))
>> > +           return 1;
>> > +   if (time_after_eq(now, word->timeout))
>> > +           return -EAGAIN;
>> > +   io_schedule_timeout(word->timeout - now);
>> > +   return 0;
>> > +}
>> > +EXPORT_SYMBOL(bit_wait_io_timeout);
>>
>> New scheduler APIs should be exported via EXPORT_SYMBOL_GPL().
>>
>
> Fine with me.
>
>  Trond, can you just edit that into the patch you have, or do you want me to
>  re-send?
>  Also maybe added Jeff's
>     Acked-by: Jeff Layton <jlayton@primarydata.com>
>  to the NFS bits.
>

Can you please resend just this patch so that the final version goes
out to linux-mm, linux-kernel etc?
I can edit in the Acked-by Jeff to the NFS bits as I apply.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
