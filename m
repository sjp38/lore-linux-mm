Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 62D156B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 07:07:36 -0400 (EDT)
Received: by ioii16 with SMTP id i16so77383086ioi.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 04:07:36 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id z7si1335957igg.93.2015.08.06.04.07.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 04:07:35 -0700 (PDT)
Received: by igbpg9 with SMTP id pg9so8916427igb.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 04:07:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150806105945.GA566@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-4-git-send-email-ddstreet@ieee.org> <20150806000843.GA3927@swordfish>
 <CALZtONCuj8hh-GS0KFokBEDrs_BH=R+_yChqra4t4TpuWQWKTQ@mail.gmail.com> <20150806105945.GA566@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 6 Aug 2015 07:07:16 -0400
Message-ID: <CALZtONC8fVXfAPvofPefOgdhrCsRrurix9v_PSsN2PTHxRfJWQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] zswap: change zpool/compressor at runtime
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Aug 6, 2015 at 6:59 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (08/06/15 06:20), Dan Streetman wrote:
>> > On (08/05/15 09:46), Dan Streetman wrote:
>> >> Update the zpool and compressor parameters to be changeable at runtime.
>> >> When changed, a new pool is created with the requested zpool/compressor,
>> >> and added as the current pool at the front of the pool list.  Previous
>> >> pools remain in the list only to remove existing compressed pages from.
>> >> The old pool(s) are removed once they become empty.
>> >>
>> >
>> > Sorry, just curious, is this functionality/complication really
>> > necessary?
>>
>> Well you could ask the same question about many other module params;
>> can't people just configure everything using boot params?  ;-)
>>
>> > How often do you expect people to do that? The way I
>> > see it -- a static configuration works just fine: boot, test,
>> > re-configure, boot test; compare the results and done.
>>
>> Sure a static configuration will work (it has since Seth wrote zswap),
>> but that doesn't guarantee everyone will want to do it that way.
>> Certainly for testing/development/benchmarking avoiding a reboot is
>> helpful.  And for long-running and/or critical systems that need to
>> change their zpool or compressor, for whatever reason, forcing a
>> reboot isn't desirable.
>
> Sorry, I didn't have time to read the patches carefully/attentively
> (will do); so my email may be a complete nonsense.
>
>> Why would someone want to change their compressor or zpool?  A simple
>> exampe comes to mind - maybe they have 1000's of systems and a bug was
>> found in the current level of compressor or zpool - they would then
>> have to either reboot all the systems to change to a different
>> zpool/compressor, or leave it using the known-buggy one.
>
> Well, if that buggy compressor is being used by other modules
> then rebooting is sort of inevitable. But you still preserve pages
> compressed with the old compressor and let user access them, right?
> Thus read operation possibly will hit the bug regardless of current
> 'front' pool.

Yes, currently-compressed pages will be uncompressed using the same
compressor.  It's only freed once all the pages using it have been
removed.

>
>> In addition, a static boot-time configuration requires adding params
>> to the bootloader configuration, *and* rebuilding the initramfs to
>> include both the required zpool and compressor.  So even for static
>> configurations, it's simpler to be able to set the zpool and
>> compressor immediately after boot, instead of at boot time.
>
> I mean, it just feels that this is a way too big change for no particular
> use case (no offense). It doesn't take much time to figure out (a simple
> google request does the trick here) which one of the available compressors
> gives best ratio in general or which one has better read/write
> (compress/decompress) speeds.

There are hardware compressors now, you know (see PowerPC 842 hw
compressor).  While a sw compressor won't fail during use (excepting a
buggy driver), a hw compressor might fail for
who-knows-what-hardware-issue.  I suspect there will be more hw
compressors in the future.

>
> A buggy compressor is a good use case, I agree (with the exception that
> reboot is still very much possible). But if someone changes compressing
> backend because he or she estimates a better compression ratio or
> performance then there will be no immediate benefit -- pages compressed
> with the old compressor are still there and it will take some unpredictable
> amount of time to drain old pools and to remove them.

To me, avoiding the need to set boot parameters through the bootloader
AND the need to rebuild the initramfs is use case enough to justify
this.  I can't think of any other driver configuration that *requires*
updating the bootloader config and rebuilding the initramfs.

>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
