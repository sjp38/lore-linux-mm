Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id C98766B002C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 00:03:01 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so5353608vbb.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 21:03:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1203052046410.24068@eggly.anvils>
References: <alpine.LSU.2.00.1203052046410.24068@eggly.anvils>
Date: Tue, 6 Mar 2012 13:03:00 +0800
Message-ID: <CAA_GA1cQ4i8Rtrh6OBrgw-dPc7dqnoJbbPRBrBoawihtgn2zLA@mail.gmail.com>
Subject: Re: [PATCH] page_cgroup: fix horrid swap accounting regression
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Tue, Mar 6, 2012 at 12:52 PM, Hugh Dickins <hughd@google.com> wrote:
> Why is memcg's swap accounting so broken? =C2=A0Insane counts, wrong owne=
rship,
> unfreeable structures, which later get freed and then accessed after free=
.
>
> Turns out to be a tiny a little 3.3-rc1 regression in 9fb4b7cc0724
> "page_cgroup: add helper function to get swap_cgroup": the helper
> function (actually named lookup_swap_cgroup()) returns an address
> using void* arithmetic, but the structure in question is a short.
>

Sorry for my mistake.

> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>
> =C2=A0mm/page_cgroup.c | =C2=A0 =C2=A04 +++-
> =C2=A01 file changed, 3 insertions(+), 1 deletion(-)
>
> --- 3.3-rc6/mm/page_cgroup.c =C2=A0 =C2=A02012-01-20 08:42:35.320020840 -=
0800
> +++ linux/mm/page_cgroup.c =C2=A0 =C2=A0 =C2=A02012-03-05 19:51:13.535372=
098 -0800
> @@ -379,13 +379,15 @@ static struct swap_cgroup *lookup_swap_c
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgoff_t offset =3D swp_offset(ent);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct swap_cgroup_ctrl *ctrl;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *mappage;
> + =C2=A0 =C2=A0 =C2=A0 struct swap_cgroup *sc;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ctrl =3D &swap_cgroup_ctrl[swp_type(ent)];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ctrlp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*ctrlp =3D ctrl;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mappage =3D ctrl->map[offset / SC_PER_PAGE];
> - =C2=A0 =C2=A0 =C2=A0 return page_address(mappage) + offset % SC_PER_PAG=
E;
> + =C2=A0 =C2=A0 =C2=A0 sc =3D page_address(mappage);
> + =C2=A0 =C2=A0 =C2=A0 return sc + offset % SC_PER_PAGE;
> =C2=A0}
>
> =C2=A0/**

Reviewed-by: Bob Liu <lliubbo@gmail.com>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
