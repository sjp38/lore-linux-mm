Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 543F26B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 06:59:12 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so25205052pac.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 03:59:12 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id gc5si10743091pbd.186.2015.08.06.03.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 03:59:11 -0700 (PDT)
Received: by pawu10 with SMTP id u10so60543532paw.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 03:59:10 -0700 (PDT)
Date: Thu, 6 Aug 2015 19:59:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] zswap: change zpool/compressor at runtime
Message-ID: <20150806105945.GA566@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-4-git-send-email-ddstreet@ieee.org>
 <20150806000843.GA3927@swordfish>
 <CALZtONCuj8hh-GS0KFokBEDrs_BH=R+_yChqra4t4TpuWQWKTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCuj8hh-GS0KFokBEDrs_BH=R+_yChqra4t4TpuWQWKTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On (08/06/15 06:20), Dan Streetman wrote:
> > On (08/05/15 09:46), Dan Streetman wrote:
> >> Update the zpool and compressor parameters to be changeable at runtime.
> >> When changed, a new pool is created with the requested zpool/compressor,
> >> and added as the current pool at the front of the pool list.  Previous
> >> pools remain in the list only to remove existing compressed pages from.
> >> The old pool(s) are removed once they become empty.
> >>
> >
> > Sorry, just curious, is this functionality/complication really
> > necessary?
> 
> Well you could ask the same question about many other module params;
> can't people just configure everything using boot params?  ;-)
> 
> > How often do you expect people to do that? The way I
> > see it -- a static configuration works just fine: boot, test,
> > re-configure, boot test; compare the results and done.
> 
> Sure a static configuration will work (it has since Seth wrote zswap),
> but that doesn't guarantee everyone will want to do it that way.
> Certainly for testing/development/benchmarking avoiding a reboot is
> helpful.  And for long-running and/or critical systems that need to
> change their zpool or compressor, for whatever reason, forcing a
> reboot isn't desirable.

Sorry, I didn't have time to read the patches carefully/attentively
(will do); so my email may be a complete nonsense.

> Why would someone want to change their compressor or zpool?  A simple
> exampe comes to mind - maybe they have 1000's of systems and a bug was
> found in the current level of compressor or zpool - they would then
> have to either reboot all the systems to change to a different
> zpool/compressor, or leave it using the known-buggy one.

Well, if that buggy compressor is being used by other modules
then rebooting is sort of inevitable. But you still preserve pages
compressed with the old compressor and let user access them, right?
Thus read operation possibly will hit the bug regardless of current
'front' pool.

> In addition, a static boot-time configuration requires adding params
> to the bootloader configuration, *and* rebuilding the initramfs to
> include both the required zpool and compressor.  So even for static
> configurations, it's simpler to be able to set the zpool and
> compressor immediately after boot, instead of at boot time.

I mean, it just feels that this is a way too big change for no particular
use case (no offense). It doesn't take much time to figure out (a simple
google request does the trick here) which one of the available compressors
gives best ratio in general or which one has better read/write
(compress/decompress) speeds.

A buggy compressor is a good use case, I agree (with the exception that
reboot is still very much possible). But if someone changes compressing
backend because he or she estimates a better compression ratio or
performance then there will be no immediate benefit -- pages compressed
with the old compressor are still there and it will take some unpredictable
amount of time to drain old pools and to remove them.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
