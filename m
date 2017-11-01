Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 862CB6B028B
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:33:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n14so2497245pfh.15
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:33:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c7si1300001pfc.157.2017.11.01.08.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 08:33:39 -0700 (PDT)
Date: Wed, 1 Nov 2017 11:33:36 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too
 long
Message-ID: <20171101113336.19758220@gandalf.local.home>
In-Reply-To: <187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171031153225.218234b4@gandalf.local.home>
	<187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Wed, 1 Nov 2017 09:30:05 +0100
Vlastimil Babka <vbabka@suse.cz> wrote:

> 
> But still, it seems to me that the scheme only works as long as there
> are printk()'s coming with some reasonable frequency. There's still a
> corner case when a storm of printk()'s can come that will fill the ring
> buffers, and while during the storm the printing will be distributed
> between CPUs nicely, the last unfortunate CPU after the storm subsides
> will be left with a large accumulated buffer to print, and there will be
> no waiters to take over if there are no more printk()'s coming. What
> then, should it detect such situation and defer the flushing?

No!

If such a case happened, that means the system is doing something
really stupid.

Btw, each printk that takes over, does one message, so the last one to
take over, shouldn't have a full buffer anyway.

But still, if you have such a hypothetical situation, the system should
just crash. The printk is still bounded by the length of the buffer.
Although it is slow, it will finish. Which is not the case with the
current situation. And the current situation (as which this patch
demonstrates) does happen today and is not hypothetical.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
