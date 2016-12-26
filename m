Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAD76B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 06:41:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so482120009pfy.2
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 03:41:25 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id k74si16607867pfj.185.2016.12.26.03.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 03:41:24 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id g1so9078871pgn.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 03:41:24 -0800 (PST)
Date: Mon, 26 Dec 2016 20:41:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161226114106.GB515@tigerII.localdomain>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

On (12/26/16 19:54), Tetsuo Handa wrote:
> I tried these 9 patches. Generally OK.
> 
> Although there is still "schedule_timeout_killable() lockup with oom_lock held"
> problem, async-printk patches help avoiding "printk() lockup with oom_lock held"
> problem. Thank you.
> 
> Three comments from me.
> 
> (1) Messages from e.g. SysRq-b is not waited for sent to consoles.
>     "SysRq : Resetting" line is needed as a note that I gave up waiting.
> 
> (2) Messages from e.g. SysRq-t should be sent to consoles synchronously?
>     "echo t > /proc/sysrq-trigger" case can use asynchronous printing.
>     But since ALT-SysRq-T sequence from keyboard may be used when scheduler
>     is not responding, it might be better to use synchronous printing.
>     (Or define a magic key sequence to toggle synchronous/asynchronous?)

it's really hard to tell if the message comes from sysrq or from
somewhere else. the current approach -- switch to *always* sync printk
once we see the first LOGLEVEL_EMERG message. so you can add
printk(LOGLEVEL_EMERG "sysrq-t\n"); for example, and printk will
switch to sync mode. sync mode, is might be a bit dangerous though,
since we printk from IRQ.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
