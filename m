Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0F67B6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 21:09:12 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id vb8so4722229obc.0
        for <linux-mm@kvack.org>; Thu, 22 May 2014 18:09:11 -0700 (PDT)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id rt10si1916398obb.61.2014.05.22.18.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 18:09:11 -0700 (PDT)
Received: by mail-ob0-f171.google.com with SMTP id wn1so4722852obc.2
        for <linux-mm@kvack.org>; Thu, 22 May 2014 18:09:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1400806281-32716-1-git-send-email-mitchelh@codeaurora.org>
References: <1400806281-32716-1-git-send-email-mitchelh@codeaurora.org>
Date: Thu, 22 May 2014 18:09:11 -0700
Message-ID: <CAMbhsRQpR-Q=kgr92ezauBj200_2cfnsXHkk+3oPD51ZKD=4RQ@mail.gmail.com>
Subject: Re: [PATCH] staging: ion: WARN when the handle kmap_cnt is going to
 wrap around
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Linux-MM <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>, Android Kernel Team <kernel-team@android.com>, lkml <linux-kernel@vger.kernel.org>

On Thu, May 22, 2014 at 5:51 PM, Mitchel Humpherys
<mitchelh@codeaurora.org> wrote:
> There are certain client bugs (double unmap, for example) that can cause
> the handle->kmap_cnt (an unsigned int) to wrap around from zero. This
> causes problems when the handle is destroyed because we have:
>
>         while (handle->kmap_cnt)
>                 ion_handle_kmap_put(handle);
>
> which takes a long time to complete when kmap_cnt starts at ~0 and can
> result in a watchdog timeout.
>
> WARN and bail when kmap_cnt is about to wrap around from zero.
>
> Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
> ---
>  drivers/staging/android/ion/ion.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
> index 3d5bf14722..f55f61a4cc 100644
> --- a/drivers/staging/android/ion/ion.c
> +++ b/drivers/staging/android/ion/ion.c
> @@ -626,6 +626,10 @@ static void ion_handle_kmap_put(struct ion_handle *handle)
>  {
>         struct ion_buffer *buffer = handle->buffer;
>
> +       if (!handle->kmap_cnt) {
> +               WARN(1, "%s: Double unmap detected! bailing...\n", __func__);
> +               return;
> +       }
>         handle->kmap_cnt--;
>         if (!handle->kmap_cnt)
>                 ion_buffer_kmap_put(buffer);
> --
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> hosted by The Linux Foundation
>
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.

Acked-by: Colin Cross <ccross@android.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
