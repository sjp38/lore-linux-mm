Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 311FC6B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 09:32:10 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id h15so2501853igd.4
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 06:32:10 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id j13si19072044igf.10.2014.10.06.06.32.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Oct 2014 06:32:08 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id rd18so3269837iec.36
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 06:32:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141006093740.GA19574@suse.de>
References: <CABe+QzA=0YVpQ8rN+3X-cbH6JP1nWTvp2spb93P9PqJhmjBROA@mail.gmail.com>
	<CABe+QzA-E40bFFXYJBc663Kx0KrE3xy2uZq5xOH2XL6mFPA6+w@mail.gmail.com>
	<CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
	<20141006093740.GA19574@suse.de>
Date: Mon, 6 Oct 2014 15:32:08 +0200
Message-ID: <CAKMK7uG8r06rKL=YU4XZhMuUxw_4qOv2vg2+04y1QBGSayPLCA@mail.gmail.com>
Subject: Re: Kswapd 100% CPU since 3.8 on Sandybridge
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Sarah A Sharp <sarah@thesharps.us>, Linux MM <linux-mm@kvack.org>, intel-gfx <intel-gfx@lists.freedesktop.org>

On Mon, Oct 6, 2014 at 11:37 AM, Mel Gorman <mgorman@suse.de> wrote:
> Minimally I wanted you to sample the stack traces for kswapd, narrow down
> to the time of its failure and see if it was stuck in a shrinker loop. What
> I suspected at the time was that it was hammering on the i915 shrinker and
> possibly doing repeated shrinks of the GPU objects in there. At one point
> at least, that was an extremely heavy operation if the objections were
> not freeable and I wanted to see if that was still the case. I confess I
> haven't looked at the code to see what has changed recently.

We've stopped doing that with

commit 2cfcd32a929b21c3cf77256dd8b858c076803ccc
Author: Chris Wilson <chris@chris-wilson.co.uk>
Date:   Tue May 20 08:28:43 2014 +0100

    drm/i915: Implement an oom-notifier for last resort shrinking


so now we do the handbreak last ditch shrinking really only when the
mm decided that it's time to oom. Until that point we should just do
the proportional shrinking the vm asked us to, but not more.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
