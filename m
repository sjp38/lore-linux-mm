Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAA1D6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 04:26:30 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so32597133lfd.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 01:26:30 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id s127si19656189wme.28.2016.05.02.01.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 01:26:29 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id n129so98097067wmn.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 01:26:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 2 May 2016 10:26:09 +0200
Message-ID: <CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 7:36 AM,  <chengang@emindsoft.com.cn> wrote:
> From: Chen Gang <chengang@emindsoft.com.cn>
>
> According to kasan_[dis|en]able_current() comments and the kasan_depth'
> s initialization, if kasan_depth is zero, it means disable.
>
> So need use "!!kasan_depth" instead of "!kasan_depth" for checking
> enable.
>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/kasan/kasan.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 7da78a6..6464b8f 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -102,7 +102,7 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
>
>  static inline bool kasan_report_enabled(void)
>  {
> -       return !current->kasan_depth;
> +       return !!current->kasan_depth;
>  }
>
>  void kasan_report(unsigned long addr, size_t size,

Hi Chen,

I don't think this is correct.
We seem to have some incorrect comments around kasan_depth, and a
weird way of manipulating it (disable should increment, and enable
should decrement). But in the end it is working. This change will
suppress all true reports and enable all false reports.

If you want to improve kasan_depth handling, then please fix the
comments and make disable increment and enable decrement (potentially
with WARNING on overflow/underflow). It's better to produce a WARNING
rather than silently ignore the error. We've ate enough unmatched
annotations in user space (e.g. enable is skipped on an error path).
These unmatched annotations are hard to notice (they suppress
reports). So in user space we bark loudly on overflows/underflows and
also check that a thread does not exit with enabled suppressions.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
