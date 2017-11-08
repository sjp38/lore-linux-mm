Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 375936B02F8
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 09:29:56 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a192so2744371pge.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 06:29:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t18si4148492plo.255.2017.11.08.06.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 06:29:55 -0800 (PST)
Date: Wed, 8 Nov 2017 09:29:51 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171108092951.4d677bca@gandalf.local.home>
In-Reply-To: <20171108051955.GA468@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
	<201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
	<20171107014015.GA1822@jagdpanzerIV>
	<20171108051955.GA468@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

On Wed, 8 Nov 2017 14:19:55 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> the change goes further. I did express some of my concerns during the KS,
> I'll just bring them to the list.
> 
> 
> we now always shift printing from a save - scheduleable - context to
> a potentially unsafe one - atomic. by example:

And vice versa. We are now likely to go from a unscheduleable context
to a schedule one, where before, that didn't exist.

And my approach, makes it more likely that the task doing the printk
prints its own message, and less likely to print someone else's.

> 
> CPU0			CPU1~CPU10	CPU11
> 
> console_lock()
> 
> 			printk();
> 
> console_unlock()			IRQ
>  set console_owner			printk()
> 					 sees console_owner
> 					 set console_waiter
>  sees console_waiter
>  break
> 					 console_unlock()
> 					 ^^^^ lockup [?]

How?

> 
> 
> so we are forcibly moving console_unlock() from safe CPU0 to unsafe CPU11.
> previously we would continue printing from a schedulable context.

And previously, we could be in unsafe CPU11 printing, and keep adding
to the buffer from safe CPUs, keeping CPU11 from ever stopping.

If anything, the patch makes the situation better, not worse.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
