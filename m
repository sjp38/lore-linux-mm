Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D66AB6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 21:57:41 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id k86so13163852lfi.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 18:57:41 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id l137si1392203lfe.285.2017.01.18.18.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 18:57:40 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id x1so3857206lff.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 18:57:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1484719121.25232.1.camel@list.ru>
References: <bug-192571-27@https.bugzilla.kernel.org/> <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
 <20170118013948.GA580@jagdpanzerIV.localdomain> <1484719121.25232.1.camel@list.ru>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 18 Jan 2017 21:56:59 -0500
Message-ID: <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandr <sss123next@list.ru>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 18, 2017 at 12:58 AM, Alexandr <sss123next@list.ru> wrote:
> no, nothing interesting in dmesg. but i suspect what it may be because
> of usage zram and zswap together.
> i have following configuration:
> 1. boot option to kernel "ro radeon.audio=0 dma_debug=off reboot=warm
> gbpages rootfstype=ext4
> rootflags=relatime,user_xattr,journal_async_commit,delalloc,nobarrier
> zswap.enabled=1"
> 2. zram activation in userspace:
> "
> cat /etc/local.d/zram.start
> #!/bin/sh
>
> modprobe zram
> echo 10G > /sys/block/zram0/disksize
> mkswap /dev/zram0
> swapon --priority 200 /dev/zram0

Why would you do this?  There's no benefit of using zswap together with zram.


> "
>
> 3. also i have normal swap block device as fall back if all memory used
> "
> swapon
> NAME             TYPE      SIZE USED PRIO
> /dev/mapper/swap partition  16G   0B    0
> /dev/zram0       partition  10G   1G  200
> "
>
> so, maybe problem related to zswap on zram ? just a guess...

it think it's unlikely, but it's hard to tell exactly why the page
couldn't be uncompressed; my guess would be more likely a bug in the
zpool backend.  Were you using the default (zbud)?

> -----BEGIN PGP SIGNATURE-----
>
> iQIzBAEBCgAdFiEEl/sA7WQg6czXWI/dsEApXVthX7wFAlh/BBIACgkQsEApXVth
> X7w9lw/+O55XK/YZHszD/DMKRuZaaAQz7to/JrkJOCOJaYsV/PpUBh6liqYH8LCV
> 6vYaavzKt3ICW1qRa6Wjj7QC2YZKZTe8i8ERGTamDOnSu/gMlJz3EQ/uOEsNxde5
> eoJr9n+JtUqf0PUUaMc61FcRbePcb3csQDD7KAwMSO7Q7+uP/osFUApjFVBOv0yd
> KggONcuyIlE0CIhmMk31Id+C7XoKeJogHa2qTIolGzi+yLCmiL+q+CujfXfrbOAz
> N6mDr7v6RTwzzOyXULZahceVxVtpUSgj84HG9wxTF7dwN6kwbW/YtdMu7UruqRyb
> SYHauUQSuEcbyb5m7tAPWfy4WsWaTacscdBCrOVqYJcn0nb945RMDz0RPIFZmLQS
> da6/zh67UF9KuSgprVakvgQ/ITJOfd96USlwZ+E8icJzT36IPWkSmFe6pNEa+KMn
> FiUf0JPN6ivO2q2wuwkIEKIeLiqDNX7QwcMxowMHKxezZobrzdyd4LoLx143mAa/
> Ls0nABaN9bk+jzl3Ffl2Vx7YowuercwGaRzBuPEdxVQflA1gVPi7o/zwJ75CPAre
> ntQk8nWAqpxB30s0/++xYPbYaJFqWtXM2e4AQKQjiZSAdq34yl+q+di/1iGS/u4Q
> gfvGaprAtViK6AqURT8dXrWTv8KzAT2prIs3wdpmrc3V92p1cAo=
> =5ZmQ
> -----END PGP SIGNATURE-----
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
