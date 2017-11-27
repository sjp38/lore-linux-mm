Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 329DE6B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:06:52 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id a72so19966280ioe.13
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:06:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n88sor12920317ioo.193.2017.11.27.00.06.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 00:06:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201711261938.BCD34864.QLVFOSJFHOtOFM@I-love.SAKURA.ne.jp>
References: <CALOAHbB05YJvVPRE0VsEDj+U7Wqv64XoGOQtpDP1a50mbpYXGg@mail.gmail.com>
 <201711261142.EIE82842.LFOtSHOFVOFJQM@I-love.SAKURA.ne.jp>
 <CALOAHbCov=Dd7bYjL6+abiVu_WgT1ZmFN_TfLTs8A1jfw8=bOQ@mail.gmail.com>
 <201711261703.HDI52138.JSFVOFOtHLMOFQ@I-love.SAKURA.ne.jp>
 <CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com> <201711261938.BCD34864.QLVFOSJFHOtOFM@I-love.SAKURA.ne.jp>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 27 Nov 2017 16:06:50 +0800
Message-ID: <CALOAHbCVoy=5U0_7wg9nZR+sa8buG41BAE4KDnr2Fb4tYqhaXw@mail.gmail.com>
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, fcicq@fcicq.net

+cc fcicq

2017-11-26 18:38 GMT+08:00 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>:
> Yafang Shao wrote:
>> 2017-11-26 16:03 GMT+08:00 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>:
>> > Yafang Shao wrote:
>> >> >> I have also verified your test code on my machine, but can not find
>> >> >> this message.
>> >> >>
>> >> >
>> >> > Not always printed. It is timing dependent.
>> >> >
>> >>
>> >> I will try and analysis why this happen.
>> >>
>> > I see.
>> >
>> > Here is dump of variables. Always mostly 0 when this happens.
>> >
>> > --- a/mm/page-writeback.c
>> > +++ b/mm/page-writeback.c
>> > @@ -434,7 +434,8 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
>> >                 bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
>> >
>> >         if (unlikely(bg_thresh >= thresh)) {
>> > -               pr_warn("vm direct limit must be set greater than background limit.\n");
>> > +               pr_warn("vm direct limit must be set greater than background limit. bg_thresh=%lu thresh=%lu bg_bytes=%lu bytes=%lu bg_ratio=%lu ratio=%lu gdtc=%p gdtc->vail=%lu vm_dirty_bytes=%lu dirty_background_bytes=%lu\n",
>> > +                       bg_thresh, thresh, bg_bytes, bytes, bg_ratio, ratio, gdtc, gdtc ? gdtc->avail : 0UL, vm_dirty_bytes, dirty_background_bytes);
>> >                 bg_thresh = thresh / 2;
>> >         }
>>
>> You could print dtc->avail as well.
>> Seems bg_thresh and thresh are not so acurate as they are interger
>> other than float.
>
> Indeed, dtc->avail < 4 when this message is printed.
>
> [  314.730541] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=2
> [  315.864111] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
> [  315.864126] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
> [  315.993866] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=2
> [  355.807392] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=2
> [  406.819939] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
> [  407.782790] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
> [  416.939906] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
> [  417.090872] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093164] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093176] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093183] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093191] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093198] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093206] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093213] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093223] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093232] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
> [  417.093240] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3


What about bellow change ?

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 8a15511..6c5c018 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -377,7 +377,16 @@ static unsigned long global_dirtyable_memory(void)
    if (!vm_highmem_is_dirtyable)
        x -= highmem_dirtyable_memory(x);

-   return x + 1;   /* Ensure that we never return 0 */
+   /*
+    * - Why 100 ?
+    * - Because the return value will be used by dirty ratio and
+    *   dirty background ratio to calculate dirty thresh and bg thresh,
+    *   so if the return value is two small, the thresh value maybe
+    *   calculated to 0.
+    *   As the max value of ratio is 100, so the return value is added
+    *   by 100 here.
+    */
+   return x + 100;



Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
