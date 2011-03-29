Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D34418D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:40:34 -0400 (EDT)
Received: by iwg8 with SMTP id 8so264558iwg.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 06:40:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329132800.GA3361@tiehlicka.suse.cz>
References: <20110329132800.GA3361@tiehlicka.suse.cz>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Tue, 29 Mar 2011 21:40:13 +0800
Message-ID: <AANLkTikYepYY01P+MELCpT+nFiPor3+-Oo=kyr2FE03C@mail.gmail.com>
Subject: Re: [trivial PATCH] Remove pointless next_mz nullification in mem_cgroup_soft_limit_reclaim
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Michal,
IIUC it's to prevent the infinite loop, as in the end of the do-while
there's
if (!nr_reclaimed &&
    (next_mz =3D=3D NULL ||
    loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
		break;
so the loop will break earlier if all groups are iterated once and no
pages are freed.

Thanks,
Zhu Yanhai

2011/3/29 Michal Hocko <mhocko@suse.cz>:
> Hi,
> while reading the code I have encountered the following thing. It is no
> biggie but...
> ---
> From: Michal Hocko <mhocko@suse.cz>
> Subject: Remove pointless next_mz nullification in mem_cgroup_soft_limit_=
reclaim
>
> next_mz is assigned to NULL if __mem_cgroup_largest_soft_limit_node selec=
ts
> the same mz. This doesn't make much sense as we assign to the variable
> right in the next loop.
>
> Compiler will probably optimize this out but it is little bit confusing f=
or
> the code reading.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
>
> Index: linux-2.6.38-rc8/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.38-rc8.orig/mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 2011-03-28=
 11:25:14.000000000 +0200
> +++ linux-2.6.38-rc8/mm/memcontrol.c =C2=A0 =C2=A02011-03-29 15:24:08.000=
000000 +0200
> @@ -3349,7 +3349,6 @@ unsigned long mem_cgroup_soft_limit_recl
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__mem_cgroup_largest_soft_limit_node(=
mctz);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (next_mz =3D=3D mz) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0css_put(&=
next_mz->mem->css);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 next_mz =3D =
NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else /* next_mz =3D=3D NULL or othe=
r memcg */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0} while (1);
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
