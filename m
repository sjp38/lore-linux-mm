Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBE2E6B0069
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 03:46:30 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n134so14696857itg.3
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 00:46:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n142sor6844730itn.37.2017.11.26.00.46.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 Nov 2017 00:46:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201711261703.HDI52138.JSFVOFOtHLMOFQ@I-love.SAKURA.ne.jp>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <CALOAHbB05YJvVPRE0VsEDj+U7Wqv64XoGOQtpDP1a50mbpYXGg@mail.gmail.com>
 <201711261142.EIE82842.LFOtSHOFVOFJQM@I-love.SAKURA.ne.jp>
 <CALOAHbCov=Dd7bYjL6+abiVu_WgT1ZmFN_TfLTs8A1jfw8=bOQ@mail.gmail.com> <201711261703.HDI52138.JSFVOFOtHLMOFQ@I-love.SAKURA.ne.jp>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sun, 26 Nov 2017 16:46:29 +0800
Message-ID: <CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com>
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>

2017-11-26 16:03 GMT+08:00 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>:
> Yafang Shao wrote:
>> >> I have also verified your test code on my machine, but can not find
>> >> this message.
>> >>
>> >
>> > Not always printed. It is timing dependent.
>> >
>>
>> I will try and analysis why this happen.
>>
> I see.
>
> Here is dump of variables. Always mostly 0 when this happens.
>
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -434,7 +434,8 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
>                 bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
>
>         if (unlikely(bg_thresh >= thresh)) {
> -               pr_warn("vm direct limit must be set greater than background limit.\n");
> +               pr_warn("vm direct limit must be set greater than background limit. bg_thresh=%lu thresh=%lu bg_bytes=%lu bytes=%lu bg_ratio=%lu ratio=%lu gdtc=%p gdtc->vail=%lu vm_dirty_bytes=%lu dirty_background_bytes=%lu\n",
> +                       bg_thresh, thresh, bg_bytes, bytes, bg_ratio, ratio, gdtc, gdtc ? gdtc->avail : 0UL, vm_dirty_bytes, dirty_background_bytes);
>                 bg_thresh = thresh / 2;
>         }

You could print dtc->avail as well.
Seems bg_thresh and thresh are not so acurate as they are interger
other than float.

Should find a smart way to fix it.

>
> [  259.641324] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  317.798913] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  317.798935] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  317.976210] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  417.781194] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  466.322615] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  466.322618] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  466.497893] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0
> [  466.504687] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->vail=0 vm_dirty_bytes=0 dirty_background_bytes=0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
