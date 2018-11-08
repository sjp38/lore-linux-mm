Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD5D6B05E7
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 06:47:10 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id x12-v6so22192514iob.23
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 03:47:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h11si970403itl.7.2018.11.08.03.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 03:47:09 -0800 (PST)
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
 <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c1f9b048-e4ed-bc69-9ee6-6fe24233de4a@i-love.sakura.ne.jp>
Date: Thu, 8 Nov 2018 20:46:28 +0900
MIME-Version: 1.0
In-Reply-To: <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/08 20:24, Petr Mladek wrote:
>> Let's have one more look at what we will fix and what we will break.
>>
>> 'cont' has premature flushes.
>>
>>   Why is it good.
>>   It preserves the correct order of events.
>>
>>   pr_cont("calling foo->init()....");
>>   foo->init()
>>    printk("Can't allocate buffer\n");    // premature flush
>>   pr_cont("...blah\h");
>>
>>  Will end up in the logbuf as:
>>  [12345.123] calling foo->init()....
>>  [12345.124] Can't allocate buffer
>>  [12345.125] ...blah
>>
>>  Where buffered printk will endup as:
>>  [12345.123] Can't allocate buffer
>>  [12345.124] calling foo->init().......blah
> 
> We will always have this problem with API using explicit buffers.
> What do you suggest instead, please?
> 
> I am afraid that we are running in cycles. The other serious
> alternative was having per-process and per-context buffers
> but it was rejected several times.

Is it possible to identify all locations which should use their own
printk() buffers (e.g. interrupt handlers, oops handlers) ? If yes,
automatically switching printk() buffers (like memalloc_nofs_save()/
memalloc_nofs_restore()) will be easiest and least error prone.
