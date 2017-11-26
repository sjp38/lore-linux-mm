Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id E45656B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 05:38:24 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id u10so14163088otc.21
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 02:38:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e13si10207693oib.255.2017.11.26.02.38.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 02:38:23 -0800 (PST)
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CALOAHbB05YJvVPRE0VsEDj+U7Wqv64XoGOQtpDP1a50mbpYXGg@mail.gmail.com>
	<201711261142.EIE82842.LFOtSHOFVOFJQM@I-love.SAKURA.ne.jp>
	<CALOAHbCov=Dd7bYjL6+abiVu_WgT1ZmFN_TfLTs8A1jfw8=bOQ@mail.gmail.com>
	<201711261703.HDI52138.JSFVOFOtHLMOFQ@I-love.SAKURA.ne.jp>
	<CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com>
In-Reply-To: <CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com>
Message-Id: <201711261938.BCD34864.QLVFOSJFHOtOFM@I-love.SAKURA.ne.jp>
Date: Sun, 26 Nov 2017 19:38:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: laoar.shao@gmail.com
Cc: akpm@linux-foundation.org, jack@suse.cz, mhocko@suse.com, linux-mm@kvack.org

Yafang Shao wrote:
> 2017-11-26 16:03 GMT+08:00 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>:
> > Yafang Shao wrote:
> >> >> I have also verified your test code on my machine, but can not find
> >> >> this message.
> >> >>
> >> >
> >> > Not always printed. It is timing dependent.
> >> >
> >>
> >> I will try and analysis why this happen.
> >>
> > I see.
> >
> > Here is dump of variables. Always mostly 0 when this happens.
> >
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -434,7 +434,8 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
> >                 bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
> >
> >         if (unlikely(bg_thresh >= thresh)) {
> > -               pr_warn("vm direct limit must be set greater than background limit.\n");
> > +               pr_warn("vm direct limit must be set greater than background limit. bg_thresh=%lu thresh=%lu bg_bytes=%lu bytes=%lu bg_ratio=%lu ratio=%lu gdtc=%p gdtc->vail=%lu vm_dirty_bytes=%lu dirty_background_bytes=%lu\n",
> > +                       bg_thresh, thresh, bg_bytes, bytes, bg_ratio, ratio, gdtc, gdtc ? gdtc->avail : 0UL, vm_dirty_bytes, dirty_background_bytes);
> >                 bg_thresh = thresh / 2;
> >         }
> 
> You could print dtc->avail as well.
> Seems bg_thresh and thresh are not so acurate as they are interger
> other than float.

Indeed, dtc->avail < 4 when this message is printed.

[  314.730541] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=2
[  315.864111] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
[  315.864126] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
[  315.993866] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=2
[  355.807392] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=2
[  406.819939] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
[  407.782790] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
[  416.939906] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=1
[  417.090872] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093164] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093176] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093183] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093191] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093198] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093206] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093213] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093223] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093232] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3
[  417.093240] vm direct limit must be set greater than background limit. bg_thresh=0 thresh=0 bg_bytes=0 bytes=0 bg_ratio=409 ratio=1228 gdtc=          (null) gdtc->avail=0 vm_dirty_bytes=0 dirty_background_bytes=0 dtc->avail=3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
