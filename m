Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9A0648D0001
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 00:27:43 -0400 (EDT)
Received: by iwn38 with SMTP id 38so7191957iwn.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 21:27:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
Date: Tue, 2 Nov 2010 13:27:41 +0900
Message-ID: <AANLkTim0oHFehpJggt9c8PhSZpOZZA1Qz=h6rC5NjeCY@mail.gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 2, 2010 at 12:20 PM, Ben Gamari <bgamari.foss@gmail.com> wrote:
> This will allow distributions to tune this important vm parameter in a mo=
re
> self-contained manner.
>
> Signed-off-by: Ben Gamari <bgamari.foss@gmail.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =A0Documentation/sysctl/vm.txt | =A0 =A02 +-
> =A0mm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 14 ++++++++++++++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A03 files changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 30289fa..d159d02 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -643,7 +643,7 @@ This control is used to define how aggressive the ker=
nel will swap
> =A0memory pages. =A0Higher values will increase agressiveness, lower valu=
es
> =A0decrease the amount of swap.
>
> -The default value is 60.
> +The default value is 60 (changed with CONFIG_DEFAULT_SWAPINESS).
>
> =A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index c2c8a4a..dc23737 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -61,6 +61,20 @@ config SPARSEMEM_MANUAL
>
> =A0endchoice
>
> +config DEFAULT_SWAPPINESS
> + =A0 =A0 =A0 int "Default swappiness"
> + =A0 =A0 =A0 default "60"
> + =A0 =A0 =A0 range 0 100
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This control is used to define how aggressive the kerne=
l will swap
> + =A0 =A0 =A0 =A0 memory pages. =A0Higher values will increase agressiven=
ess, lower
> + =A0 =A0 =A0 =A0 values decrease the amount of swap. Valid values range =
from 0 to 100.
> +
> + =A0 =A0 =A0 =A0 This only sets the default value at boot. Swappiness ca=
n be set at
> + =A0 =A0 =A0 =A0 runtime through /proc/sys/vm/swappiness.
> +
> + =A0 =A0 =A0 =A0 If unsure, keep default value of 60.
> +
> =A0config DISCONTIGMEM
> =A0 =A0 =A0 =A0def_bool y
> =A0 =A0 =A0 =A0depends on (!SELECT_MEMORY_MODEL && ARCH_DISCONTIGMEM_ENAB=
LE) || DISCONTIGMEM_MANUAL
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b8a6fdc..d9f5bba 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -133,7 +133,7 @@ struct scan_control {
> =A0/*
> =A0* From 0 .. 100. =A0Higher means more swappy.
> =A0*/
> -int vm_swappiness =3D 60;
> +int vm_swappiness =3D CONFIG_DEFAULT_SWAPPINESS;
> =A0long vm_total_pages; =A0 /* The total number of pages which the VM con=
trols */
>
> =A0static LIST_HEAD(shrinker_list);

Apparently, it wouldn't hurt maintain the kernel. But I have a concern.
As someone think this parameter is very important and would be better
to control by kernel config rather than init script to make the
package, it would make new potential kernel configs by someone in
future.
But I can't convince my opinion myself. Because if there will be lots
of kernel config for tuning parameters, could it hurt
maintain/usability? I can't say "Yes" strongly. so I am not against
this idea strongly.
Hmm,,  Just pass the decision to others.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
