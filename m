Return-Path: <linux-kernel-owner@vger.kernel.org>
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
 <d630011ed50140b082e15ddc05d0c640@AcuMS.aculab.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1d29f61a-8f36-ab1c-bb92-402ee9ad161d@i-love.sakura.ne.jp>
Date: Thu, 29 Nov 2018 19:09:26 +0900
MIME-Version: 1.0
In-Reply-To: <d630011ed50140b082e15ddc05d0c640@AcuMS.aculab.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>, 'Steven Rostedt' <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>
List-ID: <linux-mm.kvack.org>

On 2018/11/28 22:29, David Laight wrote:
> I also spent a week trying to work out why a customer kernel was
> locking up - only to finally find out that the distro they were
> using set 'panic on opps' - making it almost impossible to find
> out what was happening.

How can line buffering negatively affect this case? The current thread
which triggered an oops will keep calling printk() until that current
thread reaches panic(), won't it?

The only case where line buffering negatively affects will be that the
initial 10 bytes of a critical line failed to reach log_store() because
some other thread (not the current thread doing a series of printk())
halted CPUs / reset the whole machine _before_ the initial 10 bytes of
a critical line reaches log_store().



On 2018/11/26 13:34, Sergey Senozhatsky wrote:
> Or... Instead.
> We can just leave pr_cont() alone for now. And make it possible to
> reconstruct messages - IOW, inject some info to printk messages. We
> do this at Samsung (inject CPU number at the beginning of every
> message. `cat serial.0 | grep "\[1\]"` to grep for all messages from
> CPU1). Probably this would be the simplest thing.

Yes, I sent a patch which helps reconstructing messages at
http://lkml.kernel.org/r/1543045075-3008-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
