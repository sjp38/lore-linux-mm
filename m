Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BD0B86B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 14:34:57 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so4442894pab.31
        for <linux-mm@kvack.org>; Fri, 23 May 2014 11:34:57 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id tc9si978836pbc.52.2014.05.23.11.34.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 May 2014 11:34:56 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: Re: [PATCH] staging: ion: WARN when the handle kmap_cnt is going to wrap around
References: <1400806281-32716-1-git-send-email-mitchelh@codeaurora.org>
	<CAMbhsRQpR-Q=kgr92ezauBj200_2cfnsXHkk+3oPD51ZKD=4RQ@mail.gmail.com>
Date: Fri, 23 May 2014 11:34:59 -0700
In-Reply-To: <CAMbhsRQpR-Q=kgr92ezauBj200_2cfnsXHkk+3oPD51ZKD=4RQ@mail.gmail.com>
	(Colin Cross's message of "Thu, 22 May 2014 18:09:11 -0700")
Message-ID: <vnkw61kws5rg.fsf@mitchelh-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org
Cc: Linux-MM <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>, Android Kernel Team <kernel-team@android.com>, lkml <linux-kernel@vger.kernel.org>

++greg-kh and devel@driverdev.osuosl.org
(my bad for missing you the first time around)

On Thu, May 22 2014 at 06:09:11 PM, Colin Cross <ccross@android.com> wrote:
> On Thu, May 22, 2014 at 5:51 PM, Mitchel Humpherys
> <mitchelh@codeaurora.org> wrote:
>> There are certain client bugs (double unmap, for example) that can cause
>> the handle->kmap_cnt (an unsigned int) to wrap around from zero. This
>> causes problems when the handle is destroyed because we have:
>>
>>         while (handle->kmap_cnt)
>>                 ion_handle_kmap_put(handle);
>>
>> which takes a long time to complete when kmap_cnt starts at ~0 and can
>> result in a watchdog timeout.
>>
>> WARN and bail when kmap_cnt is about to wrap around from zero.
>>
>> Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
>> ---
>>  drivers/staging/android/ion/ion.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
>> index 3d5bf14722..f55f61a4cc 100644
>> --- a/drivers/staging/android/ion/ion.c
>> +++ b/drivers/staging/android/ion/ion.c
>> @@ -626,6 +626,10 @@ static void ion_handle_kmap_put(struct ion_handle *handle)
>>  {
>>         struct ion_buffer *buffer = handle->buffer;
>>
>> +       if (!handle->kmap_cnt) {
>> +               WARN(1, "%s: Double unmap detected! bailing...\n", __func__);
>> +               return;
>> +       }
>>         handle->kmap_cnt--;
>>         if (!handle->kmap_cnt)
>>                 ion_buffer_kmap_put(buffer);
>> --
>> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
>> hosted by The Linux Foundation
>>
>> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>
> Acked-by: Colin Cross <ccross@android.com>

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
