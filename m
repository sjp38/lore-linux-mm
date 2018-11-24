Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 074AB6B33A9
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 19:25:42 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id n22so12694772iob.9
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 16:25:42 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 190si25635630jae.24.2018.11.23.16.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 16:25:40 -0800 (PST)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
 <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
 <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
 <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
 <20181123105634.4956c255@vmware.local.home>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <6422717f-db27-8ba8-1183-ccb9f0400fc3@i-love.sakura.ne.jp>
Date: Sat, 24 Nov 2018 09:24:55 +0900
MIME-Version: 1.0
In-Reply-To: <20181123105634.4956c255@vmware.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/24 0:56, Steven Rostedt wrote:
> On Fri, 23 Nov 2018 13:46:47 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> 
>> Steven told me on Plumbers conference that even few initial
>> characters saved him a day few times.
> 
> Yes, and that has happened more than once. I would reboot and retest
> code that is crashing, and due to a triple fault, the machine would
> reboot because of some race, and the little output I get from the
> console would help tremendously.
> 
> Remember, debugging the kernel is a lot like forensics, especially when
> it's from a customer's site. You look at all the evidence that you can
> get, and sometimes it's just 10 characters in the output that gives you
> an idea of where things went wrong. I'm really not liking the buffering
> idea because of this.

Then, we should not enforce buffering in a way that requires modification of
printk() callers. That is, we should not ask printk() callers to use their
private buffer. What we can do is to enable/disable line buffering inside
printk() depending on the problem the user wants to debug.

Also, we should allow disabling "struct cont" depending on the problem (in
order to allow flushing the 10 characters in the "cont" buffer).



By the way, is the comment

  /*
   * Continuation lines are buffered, and not committed to the record buffer
   * until the line is complete, or a race forces it. The line fragments
   * though, are printed immediately to the consoles to ensure everything has
   * reached the console in case of a kernel crash.
   */

appropriate despite we don't call cont_flush() upon a kernel crash?
