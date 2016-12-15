Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5A86B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 20:11:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so52400020pfg.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 17:11:38 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id m8si55280736pfi.25.2016.12.14.17.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 17:11:37 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 144so1805913pfv.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 17:11:37 -0800 (PST)
Date: Thu, 15 Dec 2016 10:11:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161215011142.GA485@jagdpanzerIV.localdomain>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161213170628.GC18362@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161213170628.GC18362@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com

On (12/13/16 18:06), Michal Hocko wrote:
[..]
> What if we lower the loglevel as much as possible to only see KERN_ERR
> should be sufficient to see few oom killer messages while suppressing
> most of the other noise. Unfortunatelly, even messages with level >
> loglevel get stored into the ringbuffer (as I've just learned) so
> console_unlock() has to crawl through them just to drop them (Meh) but
> at least it doesn't have to go to the serial console drivers and spend
> even more time there. An alternative would be to tweak printk to not
> even store those messaes. Something like the below
> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index f7a55e9ff2f7..197f2b9fb703 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -1865,6 +1865,15 @@ asmlinkage int vprintk_emit(int facility, int level,
>  				lflags |= LOG_CONT;
>  			}
>  
> +			if (suppress_message_printing(kern_level)) {

aren't we supposed to check level here:
				suppress_message_printing(level)?

kern_level is '0' away from actual level:

	kern_level = printk_get_level(text)
	switch (kern_level)
	case '0' ... '7':
		level = kern_level - '0';

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
