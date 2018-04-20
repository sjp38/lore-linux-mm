Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A33E16B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:04:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x184so4560250pfd.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 05:04:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g15si4899096pgu.112.2018.04.20.05.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 05:04:31 -0700 (PDT)
Date: Fri, 20 Apr 2018 08:04:28 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180420080428.622a8e7f@gandalf.local.home>
In-Reply-To: <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
References: <20180413124704.19335-1-pmladek@suse.com>
	<20180413101233.0792ebf0@gandalf.local.home>
	<20180414023516.GA17806@tigerII.localdomain>
	<20180416014729.GB1034@jagdpanzerIV>
	<20180416042553.GA555@jagdpanzerIV>
	<20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
	<20180420021511.GB6397@jagdpanzerIV>
	<20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, 20 Apr 2018 11:12:24 +0200
Petr Mladek <pmladek@suse.com> wrote:

> Yes, my number was arbitrary. The important thing is that it was long
> enough. Or do you know about an console that will not be able to write
> 100 lines within one hour?

The problem is the way rate limit works. If you print 100 lines (or
1000) in 5 seconds, then you just stopped printing from that context
for 59 minutes and 55 seconds. That's a long time to block printing.

What happens if you had a couple of NMIs go off that takes up that
time, and then you hit a bug 10 minutes later from that context. You
just lost it.

This is a magnitude larger than any other user of rate limit in the
kernel. The most common time is 5 seconds. The longest I can find is 1
minute. You are saying you want to block printing from this context for
60 minutes!

That is HUGE! I don't understand your rational for such a huge number.
What data do you have to back that up with?

-- Steve
