Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF01F6B0003
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 20:28:33 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j1-v6so4201360pll.8
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:28:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a93-v6si14593513pla.226.2018.11.10.17.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 17:28:32 -0800 (PST)
Date: Sun, 11 Nov 2018 02:28:23 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 01/12] locking/lockdep: Rework
 lockdep_set_novalidate_class()
Message-ID: <20181111012823.GB12766@worktop.psav.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-2-git-send-email-longman@redhat.com>
 <20181110141458.GE3339@worktop.programming.kicks-ass.net>
 <bc8ef8ae-c673-f4ae-fab1-3fe1bc884087@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <bc8ef8ae-c673-f4ae-fab1-3fe1bc884087@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Nov 10, 2018 at 07:26:51PM -0500, Waiman Long wrote:
> On 11/10/2018 09:14 AM, Peter Zijlstra wrote:
> > On Thu, Nov 08, 2018 at 03:34:17PM -0500, Waiman Long wrote:
> >> The current lockdep_set_novalidate_class() implementation is like
> >> a hack. It assigns a special class key for that lock and calls
> >> lockdep_init_map() twice.
> > Ideally it would go away.. it is not thing that should be used.
> 
> Yes, I agree. Right now, lockdep_set_novalidate_class() is used in
> 
> drivers/base/core.c:    lockdep_set_novalidate_class(&dev->mutex);
> drivers/md/bcache/btree.c:      lockdep_set_novalidate_class(&b->lock);
> drivers/md/bcache/btree.c:     
> lockdep_set_novalidate_class(&b->write_lock);
> 
> Do you know the history behind making them novalidate?

Only of the driver/base/core.c one; there the locking order depends on
the hardware and we never quite found a way to annotate that sanely. I
forgot most details though.

The other stuff I only 'recently' found out about :-( And ideally would
have never made it into the tree, but alas.
