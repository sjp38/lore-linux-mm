Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 715B86B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 05:36:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s12so4611271pgc.2
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 02:36:28 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id f1si6786020pld.384.2017.06.05.02.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 02:36:27 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id v18so5864270pgb.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 02:36:27 -0700 (PDT)
Date: Mon, 5 Jun 2017 18:36:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170605093632.GA565@jagdpanzerIV.localdomain>
References: <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
 <20170603073221.GB21524@dhcp22.suse.cz>
 <201706031736.DHB82306.QOOHtVFFSJFOLM@I-love.SAKURA.ne.jp>
 <20170605071053.GA471@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170605071053.GA471@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky@gmail.com, pmladek@suse.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/05/17 16:10), Sergey Senozhatsky wrote:
[..]
> > Notice the timestamp jump between [  351.239144] and [  389.308085].
> 
> do you have a restrictive console loglevel and a ton of messages that
> were simply filtered out by console loglevel check? we still store those
> messages to the logbuf (for dmesg, etc.) and process them in console_unlock(),
> but don't print to the serial console. so, in other words,
> 
> logbuf:
> 
> 	timestamp T0	message M0		-- visible loglevel
> 	timestamp T1	message M1  		-- suppressed loglevel
> 	....
> 	timestamp T100	message M101		-- suppressed loglevel
> 	timestamp T101	message M102		-- visible loglevel
> 
> on the serial console you'll see
> 
> 	T0	M0
> 	T101	M102
> 
> which might look like a spike in timestamps (while there weren't any).
> just a thought.

does it make any difference if you disable preemption in console_unlock()?
something like below... just curious...

---

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index a1aecf44ab07..25fe408cb994 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2204,6 +2204,8 @@ void console_unlock(void)
 		return;
 	}
 
+	preempt_disable();
+
 	for (;;) {
 		struct printk_log *msg;
 		size_t ext_len = 0;
@@ -2260,9 +2262,6 @@ void console_unlock(void)
 		call_console_drivers(ext_text, ext_len, text, len);
 		start_critical_timings();
 		printk_safe_exit_irqrestore(flags);
-
-		if (do_cond_resched)
-			cond_resched();
 	}
 	console_locked = 0;
 
@@ -2274,6 +2273,8 @@ void console_unlock(void)
 
 	up_console_sem();
 
+	preempt_enable();
+
 	/*
 	 * Someone could have filled up the buffer again, so re-check if there's
 	 * something to flush. In case we cannot trylock the console_sem again,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
