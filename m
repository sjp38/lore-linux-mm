Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2732C6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 03:54:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so9824152wmz.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:54:54 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v8si1310963wjg.51.2016.08.11.00.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 00:54:52 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so1455503wma.1
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:54:52 -0700 (PDT)
Date: Thu, 11 Aug 2016 09:54:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH/RFC] mm, oom: Fix uninitialized ret in
 task_will_free_mem()
Message-ID: <20160811075451.GA6908@dhcp22.suse.cz>
References: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-08-16 22:19:59, Geert Uytterhoeven wrote:
>     mm/oom_kill.c: In function a??task_will_free_mema??:
>     mm/oom_kill.c:767: warning: a??reta?? may be used uninitialized in this function
> 
> If __task_will_free_mem() is never called inside the for_each_process()
> loop, ret will not be initialized.
> 
> Fixes: 1af8bb43269563e4 ("mm, oom: fortify task_will_free_mem()")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for catching that!

> ---
> Untested. I'm not familiar with the code, hence the default value of
> true was deducted from the logic in the loop (return false as soon as
> __task_will_free_mem() has returned false).
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
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
