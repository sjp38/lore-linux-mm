Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 58AFF6B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 12:52:59 -0400 (EDT)
Message-ID: <4C696CFD.7070003@tmr.com>
Date: Mon, 16 Aug 2010 12:53:17 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
References: <201008160949.51512.knikanth@suse.de>
In-Reply-To: <201008160949.51512.knikanth@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Nikanth Karthikesan wrote:
> When the total dirty pages exceed vm_dirty_ratio, the dirtier is made to do
> the writeback. But this dirtier may not be the one who took the system to this
> state. Instead, if we can track the dirty count per-file, we could throttle
> the dirtier of a file, when the file's dirty pages exceed a certain limit.
> Even though this dirtier may not be the one who dirtied the other pages of
> this file, it is fair to throttle this process, as it uses that file.
> 
I agree with your problem description, a single program which writes a single 
large file can make an interactive system suck. Creating a 25+GB Blu-Ray image 
will often saturate the buffer space. I played with per-fd limiting during 
2.5.xx development and I had an app writing 5-10GB files. While I wanted to get 
something to submit while the kernel was changing, I kept hitting cornet cases.

> This patch
> 1. Adds dirty page accounting per-file.
> 2. Exports the number of pages of this file in cache and no of pages dirty via
> proc-fdinfo.
> 3. Adds a new tunable, /proc/sys/vm/file_dirty_bytes. When a files dirty data
> exceeds this limit, the writeback of that inode is done by the current
> dirtier.
> 
I think you have this in the wrong place, can't it go in balance_dirty_pages?

> This certainly will affect the throughput of certain heavy-dirtying workloads,
> but should help for interactive systems.
> 
I found that the effect was about the same as forcing the application to use 
O_DIRECT, and since it was our application I could do that. Not all 
badly-behaved programs are open source, so that addressed my issue but not the 
general case.

I think you really need to track by process, not file, as you said "Even though 
this dirtier may not be the one who dirtied the other pages of this file..." 
that doesn't work, you block a process which is contributing minimally to the 
problem while letting the real problem process continue. Ex: a log file, with 
one process spewing error messages while others write a few lines/min. You have 
to get it right, I think.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
