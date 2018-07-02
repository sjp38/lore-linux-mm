Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B32C6B0297
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 18:38:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x6-v6so5171wrl.6
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 15:38:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c2-v6si11742627wrr.201.2018.07.02.15.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 15:38:31 -0700 (PDT)
Date: Tue, 3 Jul 2018 00:38:30 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use
 locking suffix
Message-ID: <20180702223830.33eeyqjoqy2t5uqe@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-3-bigeasy@linutronix.de>
 <20180624195753.2e277k5xhujypwre@esperanza>
 <20180626212534.sp4p76gcvldcai57@linutronix.de>
 <20180627085003.rz3dzzggjxps34wb@esperanza>
 <20180627092059.temrhpvyc7ggcmxd@linutronix.de>
 <20180628093057.4u7ncd42s2wu4oin@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180628093057.4u7ncd42s2wu4oin@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On 2018-06-28 12:30:57 [+0300], Vladimir Davydov wrote:
> > It helps to keep the locking annotation in one place. If it helps I
> > could add the _irqsave() suffix to list_lru_add/del like it is already
> > done in other places (in this file).
> 
> AFAIK local_irqsave/restore don't come for free so using them just to
> keep the code clean doesn't seem to be reasonable.

exactly. So I kept those two as is since there is no need for it.

> > > As for RT, it wouldn't need mm/workingset altogether AFAIU. 
> > Why wouldn't it need it?
> 
> I may be wrong, but AFAIU RT kernel doesn't do swapping.

swapping the RT task out would be bad indeed. This does not stop you
from using it. You can mlock() your RT application (well should because
you don't want do remove RO-data or code from memory because it is
unchanged on disk) and everything else that is not essential (say
SCHED_OTHER) could be swapped out then if memory goes low.

> > invokes. I could also add a different function (say
> > list_lru_walk_one_irq()) which behaves like list_lru_walk_one() but does
> > spin_lock_irq() instead.
> 
> That would look better IMHO. I mean, passing the flag as an argument to
> __list_lru_walk_one and introducing list_lru_shrink_walk_irq.

You think so? So I had this earlier and decided to go with what I
posted. But hey. I will post it later as suggested here and we will see
how it goes.
I just wrote this here to let akpm know that I will do as asked here
(since he Cc: me in other thread on this topic, thank you will act).

Sebastian
