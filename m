Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 680CB6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 08:50:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u56-v6so16836240wrf.18
        for <linux-mm@kvack.org>; Wed, 23 May 2018 05:50:13 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w10-v6si1678972wma.87.2018.05.23.05.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 05:50:12 -0700 (PDT)
Date: Wed, 23 May 2018 14:50:07 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180523125007.pbxcxef622cde3jz@linutronix.de>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
 <20180523123615.GY12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180523123615.GY12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On 2018-05-23 14:36:15 [+0200], Peter Zijlstra wrote:
> > Most changes are 1:1 replacements except for
> > 	BUG_ON(atomic_inc_return(&sh->count) != 1);
> 
> That doesn't look right, 'inc_return == 1' implies inc-from-zero, which
> is not allowed by refcount.
> 
> > which has been turned into
> >         refcount_inc(&sh->count);
> >         BUG_ON(refcount_read(&sh->count) != 1);
> 
> And that is racy, you can have additional increments in between.

so do we stay with the atomic* API here or do we extend refcount* API?

Sebastian
