Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 043F06B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:38:42 -0500 (EST)
Received: by oies6 with SMTP id s6so123373087oie.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:38:41 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a62si7352935oib.7.2015.11.23.04.38.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 04:38:41 -0800 (PST)
Subject: Re: linux-4.4-rc1: TIF_MEMDIE without SIGKILL pending?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511222113.FCF57847.OOMJVQtFFSOFLH@I-love.SAKURA.ne.jp>
	<20151123083024.GA21436@dhcp22.suse.cz>
	<201511232006.EDD81713.JMSFOOtQFOHLFV@I-love.SAKURA.ne.jp>
	<20151123113352.GH21050@dhcp22.suse.cz>
In-Reply-To: <20151123113352.GH21050@dhcp22.suse.cz>
Message-Id: <201511232138.DJG69728.SQLFOJOFOMVHFt@I-love.SAKURA.ne.jp>
Date: Mon, 23 Nov 2015 21:38:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

Michal Hocko wrote:
> I haven't checked where exactly you added the BUG_ON, I was merely
> comenting on the possibility that TIF_MEMDIE is set without sending
> SIGKILL.
> 
> Now that I am looking at your BUG_ON more closely I am wondering whether
> it makes sense at all. The fatal signal has been dequeued in get_signal
> before we call into do_group_exit AFAICS.

Indeed, it makes no sense at all.
Making below change made expected output.

  MemAlloc: oom-tester4(11306) uninterruptible exiting victim

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 01127b8..8c8fb6d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3289,8 +3289,9 @@ static int kmallocwd(void *unused)
 			snprintf(buf, sizeof(buf),
 				 " gfp=0x%x order=%u delay=%lu", memalloc.gfp,
 				 memalloc.order, now - memalloc.start);
-		pr_warn("MemAlloc: %s(%u)%s%s%s%s\n", p->comm, p->pid, buf,
+		pr_warn("MemAlloc: %s(%u)%s%s%s%s%s\n", p->comm, p->pid, buf,
 			(type & 8) ? " uninterruptible" : "",
+			(p->flags & PF_EXITING) ? " exiting" : "",
 			(type & 2) ? " dying" : "",
 			(type & 1) ? " victim" : "");
 		touch_nmi_watchdog();
----------

I'll make V3 of kmallocwd. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
