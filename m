Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A20E86B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:21:42 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so183534788wmf.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:21:42 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id h70si41185461wmd.58.2016.01.20.07.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 07:21:41 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id r129so135531070wmr.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:21:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160120070019.GC12293@bbox>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox> <20160115032712.GC1993@swordfish>
 <20160115044916.GB11203@bbox> <20160115050722.GE1993@swordfish>
 <CAGfvh60CYegQ1fRMzuWbRNsv5eYEEiXtXFSBr_CbnJHuYMs5pQ@mail.gmail.com> <20160120070019.GC12293@bbox>
From: Russell Knize <rknize@motorola.com>
Date: Wed, 20 Jan 2016 09:21:11 -0600
Message-ID: <CAGfvh62kn1px+NmV3vJ_-KtJNP7LH48QTiJ6vYrg3AC4jEZPMA@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Yes, I saw your v5 and have already started testing it.  I suspect it
will be stable, as the key for us was to set that bit before the
store.  We were only seeing it on ARM32, but those platforms tend
perform compaction far more often due to the memory pressure.  We
don't see it at all anymore.

Honestly, at first I didn't think setting the bit would help that much
as I assumed it was the barrier in the clear_bit_unlock() that
mattered.  Then I saw the same sort of race happening in the page
migration stuff I've been working on.  I had done the same type of
"optimization" there and in fact did not call unpin_tag() at all after
updating the object handles with the bit dropped.

Russ

On Wed, Jan 20, 2016 at 1:00 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hello Russ,
>
> On Tue, Jan 19, 2016 at 09:47:12AM -0600, Russell Knize wrote:
>>    Just wanted to ack this, as we have been seeing the same problem (weird
>>    race conditions during compaction) and fixed it in the same way a few
>>    weeks ago (resetting the pin bit before recording the obj).
>>    Russ
>
> First of all, thanks for your comment.
>
> The patch you tested have a problem although it's really subtle(ie,
> it doesn't do store tearing when I disassemble ARM{32|64}) but it
> could have a problem potentially for other architecutres or future ARM.
> For right fix, I sent v5 - https://lkml.org/lkml/2016/1/18/263.
> If you can prove it fixes your problem, please Tested-by to the thread.
> It's really valuable to do testing for stable material.
>
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
