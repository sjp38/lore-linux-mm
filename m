Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEAE86B0261
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:16:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so38183657pfg.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:16:51 -0700 (PDT)
Received: from out0-153.mail.aliyun.com (out0-153.mail.aliyun.com. [140.205.0.153])
        by mx.google.com with ESMTP id a13si7152258pag.258.2016.10.12.03.16.50
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 03:16:51 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Ensure that the task stack is not freed during scanning
Date: Wed, 12 Oct 2016 18:16:46 +0800
Message-ID: <00ca01d22471$bcef4ef0$36cdecd0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Catalin Marinas' <catalin.marinas@arm.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Andy Lutomirski' <luto@kernel.org>, 'CAI Qian' <caiqian@redhat.com>

> @@ -1453,8 +1453,11 @@ static void kmemleak_scan(void)
> 
>  		read_lock(&tasklist_lock);
>  		do_each_thread(g, p) {

Take a look at this commit please.
	1da4db0cd5 ("oom_kill: change oom_kill.c to use for_each_thread()")

> -			scan_block(task_stack_page(p), task_stack_page(p) +
> -				   THREAD_SIZE, NULL);
> +			void *stack = try_get_task_stack(p);
> +			if (stack) {
> +				scan_block(stack, stack + THREAD_SIZE, NULL);
> +				put_task_stack(p);
> +			}
>  		} while_each_thread(g, p);
>  		read_unlock(&tasklist_lock);
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
