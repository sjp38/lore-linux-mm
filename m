Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id BA7376B0255
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 06:15:42 -0400 (EDT)
Received: by wikq8 with SMTP id q8so24288514wik.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 03:15:42 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id c11si18074930wiv.87.2015.10.22.03.15.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 03:15:41 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so128176595wic.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 03:15:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1445444938-28018-1-git-send-email-aryabinin@virtuozzo.com>
References: <1445444938-28018-1-git-send-email-aryabinin@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 22 Oct 2015 12:15:21 +0200
Message-ID: <CACT4Y+awYZCxpfpZ3Dq-B6Y2-QCVO+jnJ0QPJ5o+_w7TxQOoNA@mail.gmail.com>
Subject: Re: [PATCH] kasan: always taint kernel on report.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>

Look good to me.

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>


On Wed, Oct 21, 2015 at 6:28 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> Currently we already taint the kernel in some cases.
> E.g. if we hit some bug in slub memory we call object_err()
> which will taint the kernel with TAINT_BAD_PAGE flag.
> But for other kind of bugs kernel left untainted.
>
> Always taint with TAINT_BAD_PAGE if kasan found some bug.
> This is useful for automated testing.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  mm/kasan/report.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index f5e068a..12f222d 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -238,6 +238,7 @@ static void kasan_report_error(struct kasan_access_info *info)
>         }
>         pr_err("================================="
>                 "=================================\n");
> +       add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>         spin_unlock_irqrestore(&report_lock, flags);
>         kasan_enable_current();
>  }
> --
> 2.4.10
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
