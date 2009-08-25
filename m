Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 117EC6B00B1
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:29:39 -0400 (EDT)
Received: by pxi15 with SMTP id 15so6278868pxi.23
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:29:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200908241008.02184.ngupta@vflare.org>
References: <200908241008.02184.ngupta@vflare.org>
Date: Tue, 25 Aug 2009 22:33:43 +0530
Message-ID: <661de9470908251003y3db1fb3awb648f9340cd0beb4@mail.gmail.com>
Subject: Re: [PATCH 4/4] compcache: documentation
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 10:08 AM, Nitin Gupta<ngupta@vflare.org> wrote:
> Short guide on how to setup and use ramzswap.
>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> ---
>
> =A0Documentation/blockdev/00-INDEX =A0 =A0 | =A0 =A02 +
> =A0Documentation/blockdev/ramzswap.txt | =A0 52 +++++++++++++++++++++++++=
++++++++++
> =A02 files changed, 54 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/blockdev/00-INDEX b/Documentation/blockdev/00-=
INDEX
> index c08df56..c1cb074 100644
> --- a/Documentation/blockdev/00-INDEX
> +++ b/Documentation/blockdev/00-INDEX
> @@ -16,3 +16,5 @@ paride.txt
> =A0 =A0 =A0 =A0- information about the parallel port IDE subsystem.
> =A0ramdisk.txt
> =A0 =A0 =A0 =A0- short guide on how to set up and use the RAM disk.
> +ramzswap.txt
> + =A0 =A0 =A0 - short guide on how to setup compressed in-memory swap dev=
ice.
> diff --git a/Documentation/blockdev/ramzswap.txt b/Documentation/blockdev=
/ramzswap.txt
> new file mode 100644
> index 0000000..463dd2d
> --- /dev/null
> +++ b/Documentation/blockdev/ramzswap.txt
> @@ -0,0 +1,52 @@
> +ramzswap: Compressed RAM based swap device
> +-------------------------------------------
> +
> +Project home: http://compcache.googlecode.com/
> +
> +* Introduction
> +
> +It creates RAM based block devices which can be used (only) as swap disk=
s.
> +Pages swapped to these devices are compressed and stored in memory itsel=
f.
> +See project home for use cases, performance numbers and a lot more.
> +
> +It consists of three modules:
> + - xvmalloc.ko: memory allocator

I've seen your case for a custom allocator, but why can't we

1) Refactor slob and use it
2) Do we care about the optimizations in SLUB w.r.t. scalability in
your module? If so.. will xvmalloc meet those requirements?

> + - ramzswap.ko: virtual block device driver
> + - rzscontrol userspace utility: to control individual ramzswap devices
> +
> +* Usage
> +
> +Following shows a typical sequence of steps for using ramzswap.
> +
> +1) Load Modules:
> + =A0 =A0 =A0 modprobe ramzswap NUM_DEVICES=3D4
> + =A0 =A0 =A0 This creates 4 (uninitialized) devices: /dev/ramzswap{0,1,2=
,3}
> + =A0 =A0 =A0 (NUM_DEVICES parameter is optional. Default: 1)
> +
> +2) Initialize:
> + =A0 =A0 =A0 Use rzscontrol utility to configure and initialize individu=
al
> + =A0 =A0 =A0 ramzswap devices. Example:
> + =A0 =A0 =A0 rzscontrol /dev/ramzswap2 --init # uses default value of di=
sksize_kb
> +
> + =A0 =A0 =A0 *See rzscontrol manpage for more details and examples*
> +
> +3) Activate:
> + =A0 =A0 =A0 swapon /dev/ramzswap2 # or any other initialized ramzswap d=
evice
> +
> +4) Stats:
> + =A0 =A0 =A0 rzscontrol /dev/ramzswap2 --stats
> +
> +5) Deactivate:
> + =A0 =A0 =A0 swapoff /dev/ramzswap2
> +
> +6) Reset:
> + =A0 =A0 =A0 rzscontrol /dev/ramzswap2 --reset
> + =A0 =A0 =A0 (This frees all the memory allocated for this device).

What level of compression have you observed? Any speed trade-offs?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
