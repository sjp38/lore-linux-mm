Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6E5356B0092
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 18:55:11 -0400 (EDT)
Received: by iwn9 with SMTP id 9so3776070iwn.14
        for <linux-mm@kvack.org>; Sun, 24 Oct 2010 15:55:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101022045509.GA16804@localhost>
References: <20101022045509.GA16804@localhost>
Date: Mon, 25 Oct 2010 07:55:09 +0900
Message-ID: <AANLkTinU7UqBpoUOzE=JfMLtk006Ou=EVJ+6dB1KnBVj@mail.gmail.com>
Subject: Re: [PATCH] mm: Avoid possible deadlock caused by too_many_isolated()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Neil find that if too_many_isolated() returns true while performing
> direct reclaim we can end up waiting for other threads to complete their
> direct reclaim. =A0If those threads are allowed to enter the FS or IO to
> free memory, but this thread is not, then it is possible that those
> threads will be waiting on this thread and so we get a circular
> deadlock.
>
> some task enters direct reclaim with GFP_KERNEL
> =A0=3D> too_many_isolated() false
> =A0 =A0=3D> vmscan and run into dirty pages
> =A0 =A0 =A0=3D> pageout()
> =A0 =A0 =A0 =A0=3D> take some FS lock
> =A0 =A0 =A0 =A0 =A0=3D> fs/block code does GFP_NOIO allocation
> =A0 =A0 =A0 =A0 =A0 =A0=3D> enter direct reclaim again
> =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D> too_many_isolated() true
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D> waiting for others to progress, h=
owever the other
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tasks may be circular waiting for=
 the FS lock..
>
> The fix is to let !__GFP_IO and !__GFP_FS direct reclaims enjoy higher
> priority than normal ones, by lowering the throttle threshold for the
> latter.
>
> Allowing ~1/8 isolated pages in normal is large enough. For example,
> for a 1GB LRU list, that's ~128MB isolated pages, or 1k blocked tasks
> (each isolates 32 4KB pages), or 64 blocked tasks per logical CPU
> (assuming 16 logical CPUs per NUMA node). So it's not likely some CPU
> goes idle waiting (when it could make progress) because of this limit:
> there are much more sleeping reclaim tasks than the number of CPU, so
> the task may well be blocked by some low level queue/lock anyway.
>
> Now !GFP_IOFS reclaims won't be waiting for GFP_IOFS reclaims to
> progress. They will be blocked only when there are too many concurrent
> !GFP_IOFS reclaims, however that's very unlikely because the IO-less
> direct reclaims is able to progress much more faster, and they won't
> deadlock each other. The threshold is raised high enough for them, so
> that there can be sufficient parallel progress of !GFP_IOFS reclaims.
>
> CC: Torsten Kaiser <just.for.lkml@googlemail.com>
> CC: Minchan Kim <minchan.kim@gmail.com>
> Tested-by: NeilBrown <neilb@suse.de>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
