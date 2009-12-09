Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4D9BE60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 04:37:40 -0500 (EST)
Received: by fxm9 with SMTP id 9so6343877fxm.10
        for <linux-mm@kvack.org>; Wed, 09 Dec 2009 01:37:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cc557aab0912071041j5c5731dbj9fd669ef26e6f2ae@mail.gmail.com>
References: <cc557aab0912071041j5c5731dbj9fd669ef26e6f2ae@mail.gmail.com>
Date: Wed, 9 Dec 2009 11:37:30 +0200
Message-ID: <cc557aab0912090137l5f4c923by9b3fbe5241bbf49a@mail.gmail.com>
Subject: Re: [BUG?] [PATCH] soft limits and root cgroups
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 7, 2009 at 8:41 PM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
> Currently, mem_cgroup_update_tree() on root cgroup calls only on
> uncharge, not on charge.
>
> Is it a bug or not?

Any comments?

> Patch to fix, if it's a bug:
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8aa6026..6babef1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1366,13 +1366,15 @@ static int __mem_cgroup_try_charge(struct mm_stru=
ct *mm
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto nomem;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> +done:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Insert ancestor (and ancestor's ancestors),=
 to softlimit RB-tree.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * if they exceeds softlimit.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_soft_limit_check(mem))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_update_=
tree(mem, page);
> -done:
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0nomem:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0css_put(&mem->css);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
