Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74EC0C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28A4F2082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:26:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tNqI2/n1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28A4F2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B30E36B0005; Thu, 16 May 2019 12:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE1906B0006; Thu, 16 May 2019 12:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F7D66B0007; Thu, 16 May 2019 12:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75F0D6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:26:02 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id k78so1424472vkk.17
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aF7z4HMLUnakhny7k0GasKk7IF4REIlPL6fyWISpTgk=;
        b=qE3NIEeVxUXI7Qxfeg56kS514PkZmMm2CHtlitoVu3vDRINLz7Jq3nMZvErJJ0nzvg
         1EQkQrpTkLUo7is+E9X9pbuwApTrxiNWWOseLrC3q37JRZYNC+woNA1dtH4VYncYT1Wz
         AHc6aYcJqi/2DO+EwsctKcQnqIDiUUGZLer84LPESzA/d1YQxTNA0VmBMqkEI9KY3Aet
         TRGYRjRaywqefAbbt2ZuoCa7zOx99jyEmzXakaHx7j5FJHNTGowY3C384Rm8Xfk2cT8T
         1yT3LwYrONpKcV+gIdZzFNmDfLpGLKvoZJeyPdmXwYEGRGwa5rA4Hsn8A4vJ8J7qSvIz
         zpdg==
X-Gm-Message-State: APjAAAVlBtYdHJIvJUd7sntHT0l3EhUff+kFItVe1Z9Ld9xJBS45cGmF
	dPANR4gBRsX/gwi3eie1qeGDaJYWi8ko9/4/qTVxsQK6JW9TuFsgcRkBxkTzKW27Xn24ePbapXq
	a+YgkMOjN6jbwEgjdu3BoA17Tf2wHJByb7Sz5xaOeyiND4sSBC9Owdq6wWpiNWI9p1w==
X-Received: by 2002:a67:2c51:: with SMTP id s78mr2420407vss.114.1558023962033;
        Thu, 16 May 2019 09:26:02 -0700 (PDT)
X-Received: by 2002:a67:2c51:: with SMTP id s78mr2420361vss.114.1558023961248;
        Thu, 16 May 2019 09:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558023961; cv=none;
        d=google.com; s=arc-20160816;
        b=xLKMJOHMj8F3R99nQBZCGnhy/NtwICz+o0IkWijK3AbB6/Y8Xw86BsBYPQWAroQMm9
         Mv1UKk+/6TwEZeFBEOjMXXmu97zieWQYFx4aLpoP10P0UTLmqZUnCfM4MuQdJI23GqcV
         gpx1zUEb7Z60/RUr/BvCqLjwGYtT2ysF8yic30XzY7N025+UWF2Hu7gB8DBeFGuzyOZs
         uzQjCAd34mP7yV2HIyrhKxRrYfOWqlRVg6MrXhRm96gC7Xn+fQo3mJ9kugsEy8+dNOjU
         7N97sx2yywse4WKqf5rS4xgg/1bgcqybTEtitdWeo0nJTpAbwpT2tgZiKsHy2AKh0W72
         qbzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aF7z4HMLUnakhny7k0GasKk7IF4REIlPL6fyWISpTgk=;
        b=ednibF9RGFZyXQfmHQVLMXpe1cKa9O/N8RPRSaXscJ0AsB/m/Kr8yLoM8ozZejJuS3
         OGK4/djxxL5cacZ2kyJdEx4+GWBXPrKx2Edgyfw4uIil92ttMs0+ayZ2xH1Op8H26xKx
         Svs8NuEYxFGKU4NymUaj0fhraND7mIrVf5mfV1WZQadB2OkTGoYQHvsiZzVXUf446Xg7
         vehQ/DtSlwzqfcKMpwnVYbF2NU97u4SuuMHZ58FSWj4z7L7lc1NtFnVSG6+zW6fAqOoa
         pK53xNSu3PST+G8FlfZ0wzJXGGWugvbPEzL0W+ClP1lzU2S+rLae2MSuz3fClKxg1Xew
         +wlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="tNqI2/n1";
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k184sor2872537vsk.21.2019.05.16.09.26.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:26:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="tNqI2/n1";
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aF7z4HMLUnakhny7k0GasKk7IF4REIlPL6fyWISpTgk=;
        b=tNqI2/n1/KRWaJC+/CpSW6dpIqwdsMYCdLezQXGYWXVbirGLs2g6o5eFI8o7yn3+fy
         zoP1qOF3qa/Ft/+eb6VML5ISPaIJxdHsZahgMeuB3cDrPgk5NlWNVi7VcgXobHzL37vA
         VYT4v1aRcr5tm9LBwLpSLP/+yE6YIGXDhlwaQiUexHLdFnVcVGcGZ6nZTw/5Mo+yHzcc
         HPFl2Juc+RnIB0MPzP0JfxkaEtrwWJK/Bnsv08I8r221StpqU1iDcSBXMUP/xw7YAinb
         T5+IC4xAPzZyHwQmvh11vFQWFg1Tz8fszmCRdto1rJaDjf1gPy1nHNTLHjuSoImf4/si
         jdng==
X-Google-Smtp-Source: APXvYqx/cc7lJi9PCpEFthV94uIkRRjAs7sIeQj5KsGC3UjX5CEfXwDS+OwvGnUgD0g4EfbKAsvbZknBvShClFQYgak=
X-Received: by 2002:a67:f6c4:: with SMTP id v4mr144463vso.182.1558023960664;
 Thu, 16 May 2019 09:26:00 -0700 (PDT)
MIME-Version: 1.0
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
From: Andrei Vagin <avagin@gmail.com>
Date: Thu, 16 May 2019 09:25:49 -0700
Message-ID: <CANaxB-zxz5oSeNS2cK-3m6_d9x_kw2pkwWibgOEgr+uOP6YhOA@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for pre-faults
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 7:32 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> When get_user_pages*() is called with pages = NULL, the processing of
> VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> the pages.
>
> If the pages in the requested range belong to a VMA that has userfaultfd
> registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> has populated the page, but for the gup pre-fault case there's no actual
> retry and the caller will get no pages although they are present.
>
> This issue was uncovered when running post-copy memory restore in CRIU
> after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> copy_fpstate_to_sigframe() fails").
>
> After this change, the copying of FPU state to the sigframe switched from
> copy_to_user() variants which caused a real page fault to get_user_pages()
> with pages parameter set to NULL.
>
> In post-copy mode of CRIU, the destination memory is managed with
> userfaultfd and lack of the retry for pre-fault case in get_user_pages()
> causes a crash of the restored process.
>
> Making the pre-fault behavior of get_user_pages() the same as the "normal"
> one fixes the issue.
>

Tested-by: Andrei Vagin <avagin@gmail.com>

https://travis-ci.org/avagin/linux/builds/533184940

> Fixes: d9c9ce34ed5c ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  mm/gup.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/mm/gup.c b/mm/gup.c
> index 91819b8..c32ae5a 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -936,10 +936,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>                         BUG_ON(ret >= nr_pages);
>                 }
>
> -               if (!pages)
> -                       /* If it's a prefault don't insist harder */
> -                       return ret;
> -
>                 if (ret > 0) {
>                         nr_pages -= ret;
>                         pages_done += ret;
> @@ -955,8 +951,12 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>                                 pages_done = ret;
>                         break;
>                 }
> -               /* VM_FAULT_RETRY triggered, so seek to the faulting offset */
> -               pages += ret;
> +               /*
> +                * VM_FAULT_RETRY triggered, so seek to the faulting offset.
> +                * For the prefault case (!pages) we only update counts.
> +                */
> +               if (likely(pages))
> +                       pages += ret;
>                 start += ret << PAGE_SHIFT;
>
>                 /*
> @@ -979,7 +979,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>                 pages_done++;
>                 if (!nr_pages)
>                         break;
> -               pages++;
> +               if (likely(pages))
> +                       pages++;
>                 start += PAGE_SIZE;
>         }
>         if (lock_dropped && *locked) {
> --
> 2.7.4
>

