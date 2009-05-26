Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EFB036B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:19:29 -0400 (EDT)
Received: by fxm12 with SMTP id 12so5439494fxm.38
        for <linux-mm@kvack.org>; Tue, 26 May 2009 06:19:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200905261844.33864.knikanth@suse.de>
References: <200905261844.33864.knikanth@suse.de>
Date: Tue, 26 May 2009 16:19:46 +0300
Message-ID: <84144f020905260619j301c130ev8906a15942397678@mail.gmail.com>
Subject: Re: [PATCH] Fix build warning and avoid checking for mem != null
	twice
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 4:14 PM, Nikanth Karthikesan <knikanth@suse.de> wro=
te:
> Fix build warning, "mem_cgroup_is_obsolete defined but not used" when
> CONFIG_DEBUG_VM is not set. Also avoid checking for !mem twice.
>
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

I also sent a patch to fix this but yours is much nicer.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

>
> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 01c2d8f..420fc61 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -314,14 +314,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_mm=
(struct mm_struct *mm)
> =A0 =A0 =A0 =A0return mem;
> =A0}
>
> -static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> -{
> - =A0 =A0 =A0 if (!mem)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> - =A0 =A0 =A0 return css_is_removed(&mem->css);
> -}
> -
> -
> =A0/*
> =A0* Call callback function against all cgroup under hierarchy tree.
> =A0*/
> @@ -932,7 +924,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *=
mm,
> =A0 =A0 =A0 =A0if (unlikely(!mem))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
> + =A0 =A0 =A0 VM_BUG_ON(!mem || css_is_removed(&mem->css));
>
> =A0 =A0 =A0 =A0while (1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
