Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E33C6B0062
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 21:03:55 -0500 (EST)
Received: by pwi1 with SMTP id 1so365427pwi.6
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 18:03:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091210185626.26f9828a@cuia.bos.redhat.com>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
Date: Fri, 11 Dec 2009 11:03:53 +0900
Message-ID: <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Rik.


On Fri, Dec 11, 2009 at 8:56 AM, Rik van Riel <riel@redhat.com> wrote:
> Under very heavy multi-process workloads, like AIM7, the VM can
> get into trouble in a variety of ways. =C2=A0The trouble start when
> there are hundreds, or even thousands of processes active in the
> page reclaim code.
>
> Not only can the system suffer enormous slowdowns because of
> lock contention (and conditional reschedules) between thousands
> of processes in the page reclaim code, but each process will try
> to free up to SWAP_CLUSTER_MAX pages, even when the system already
> has lots of memory free. =C2=A0In Larry's case, this resulted in over
> 6000 processes fighting over locks in the page reclaim code, even
> though the system already had 1.5GB of free memory.
>
> It should be possible to avoid both of those issues at once, by
> simply limiting how many processes are active in the page reclaim
> code simultaneously.
>
> If too many processes are active doing page reclaim in one zone,
> simply go to sleep in shrink_zone().
>
> On wakeup, check whether enough memory has been freed already
> before jumping into the page reclaim code ourselves. =C2=A0We want
> to use the same threshold here that is used in the page allocator
> for deciding whether or not to call the page reclaim code in the
> first place, otherwise some unlucky processes could end up freeing
> memory for the rest of the system.
>
> Reported-by: Larry Woodman <lwoodman@redhat.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
>
> ---
> This patch is against today's MMOTM tree. It has only been compile tested=
,
> I do not have an AIM7 system standing by.
>
> Larry, does this fix your issue?
>
> =C2=A0Documentation/sysctl/vm.txt | =C2=A0 18 ++++++++++++++++++
> =C2=A0include/linux/mmzone.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++++
> =C2=A0include/linux/swap.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0kernel/sysctl.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A07 +++++++
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A03 +++
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0 38 ++++++++++++++++++++++++++++++++++++++
> =C2=A06 files changed, 71 insertions(+)
>
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index fc5790d..5cf766f 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -32,6 +32,7 @@ Currently, these files are in /proc/sys/vm:
> =C2=A0- legacy_va_layout
> =C2=A0- lowmem_reserve_ratio
> =C2=A0- max_map_count
> +- max_zone_concurrent_reclaim
> =C2=A0- memory_failure_early_kill
> =C2=A0- memory_failure_recovery
> =C2=A0- min_free_kbytes
> @@ -278,6 +279,23 @@ The default value is 65536.
>
> =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> +max_zone_concurrent_reclaim:
> +
> +The number of processes that are allowed to simultaneously reclaim
> +memory from a particular memory zone.
> +
> +With certain workloads, hundreds of processes end up in the page
> +reclaim code simultaneously. =C2=A0This can cause large slowdowns due
> +to lock contention, freeing of way too much memory and occasionally
> +false OOM kills.
> +
> +To avoid these problems, only allow a smaller number of processes
> +to reclaim pages from each memory zone simultaneously.
> +
> +The default value is 8.
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

I like this. but why do you select default value as constant 8?
Do you have any reason?

I think it would be better to select the number proportional to NR_CPU.
ex) NR_CPU * 2 or something.

Otherwise looks good to me.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
