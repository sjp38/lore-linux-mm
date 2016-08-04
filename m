Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 378B96B025E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 08:28:21 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m130so513248337ioa.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 05:28:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d45si7522824ote.16.2016.08.04.05.28.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 05:28:20 -0700 (PDT)
Subject: Re: [PATCH/RFC] mm, oom: Fix uninitialized ret in
 task_will_free_mem()
References: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <178c5e9b-b92d-b62b-40a9-ee98b10d6bce@I-love.SAKURA.ne.jp>
Date: Thu, 4 Aug 2016 21:28:13 +0900
MIME-Version: 1.0
In-Reply-To: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/08/04 5:19, Geert Uytterhoeven wrote:
>     mm/oom_kill.c: In function a??task_will_free_mema??:
>     mm/oom_kill.c:767: warning: a??reta?? may be used uninitialized in this function
> 
> If __task_will_free_mem() is never called inside the for_each_process()
> loop, ret will not be initialized.

Recently we are likely overlook this warning because newer versions (!?) do
not warn it. We need to try to compile using newer and older versions.

> 
> Fixes: 1af8bb43269563e4 ("mm, oom: fortify task_will_free_mem()")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Untested. I'm not familiar with the code, hence the default value of
> true was deducted from the logic in the loop (return false as soon as
> __task_will_free_mem() has returned false).

I think ret = true is correct. Andrew, please send to linux.git.

> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7d0a275df822e9e1..d53a9aa00977cbd0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -764,7 +764,7 @@ bool task_will_free_mem(struct task_struct *task)
>  {
>  	struct mm_struct *mm = task->mm;
>  	struct task_struct *p;
> -	bool ret;
> +	bool ret = true;
>  
>  	/*
>  	 * Skip tasks without mm because it might have passed its exit_mm and
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
