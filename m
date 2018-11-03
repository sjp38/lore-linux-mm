Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id DBBA76B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 21:56:39 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x9so2349406otg.19
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 18:56:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n205-v6si16109167oif.11.2018.11.02.18.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 18:56:38 -0700 (PDT)
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181102144028.GQ10491@bombadil.infradead.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <865018bd-6352-cb92-1b8a-9254768f0b5c@i-love.sakura.ne.jp>
Date: Sat, 3 Nov 2018 10:55:57 +0900
MIME-Version: 1.0
In-Reply-To: <20181102144028.GQ10491@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/02 23:40, Matthew Wilcox wrote:
> On Fri, Nov 02, 2018 at 10:31:55PM +0900, Tetsuo Handa wrote:
>>   get_printk_buffer() tries to assign a "struct printk_buffer" from
>>   statically preallocated array. get_printk_buffer() returns NULL if
>>   all "struct printk_buffer" are in use, but the caller does not need to
>>   check for NULL.
> 
> This seems like a great way of wasting 16kB of memory.  Since you've
> already made printk_buffered() work with a NULL initial argument, what's
> the advantage over just doing kmalloc(1024, GFP_ATOMIC)?

Like "[PATCH 2/3] mm: Use line-buffered printk() for show_free_areas()."
demonstrates, kzalloc(sizeof(struct printk_buffer), GFP_ATOMIC) can fail.

And using statically preallocated buffers helps avoiding

  (1) out of buffers when memory cannot be allocated

  (2) kernel stack overflow when kernel stack is already tight (e.g.
      a memory allocation attempt from an interrupt handler which was
      invoked from deep inside call chain of a process context)

. Whether

  (A) tuning the number of statically preallocated buffers

  (B) allocating buffers on caller side (e.g. kzalloc() or in .bss section)

are useful is a future decision, for too much concurrent printk() will lockup
the system even if there are enough buffers. I think that starting with
statically preallocated buffers is (at least for now) a good choice for
minimizing risk of (1) (2) while offering practically acceptable result.
