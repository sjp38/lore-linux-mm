Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2006B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 05:49:50 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id p30so754573uap.19
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 02:49:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor306735uab.19.2018.03.09.02.49.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 02:49:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4ebee1c2-57f6-bcb8-0e2d-1833d1ee0bb7@huawei.com>
References: <CAG_fn=VW5tfzT6cHJd+jF=t3WO6XS3HqSF_TYnKdycX_M_48vw@mail.gmail.com>
 <4ebee1c2-57f6-bcb8-0e2d-1833d1ee0bb7@huawei.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 9 Mar 2018 11:49:43 +0100
Message-ID: <CAG_fn=XP6X5rqRVBameyU-F2UOc4hpbowUBNxZENf2ZHpMSmfQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mempolicy: Avoid use uninitialized preferred_node
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Dmitriy Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, "mhocko@suse.com" <mhocko@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Mar 9, 2018 at 6:21 AM, Yisheng Xie <xieyisheng1@huawei.com> wrote:
> Alexander reported an use of uninitialized memory in __mpol_equal(),
> which is caused by incorrect use of preferred_node.
>
> When mempolicy in mode MPOL_PREFERRED with flags MPOL_F_LOCAL, it use
> numa_node_id() instead of preferred_node, however, __mpol_equeue() use
> preferred_node without check whether it is MPOL_F_LOCAL or not.
>
> Reported-by: Alexander Potapenko <glider@google.com>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Tested-by: Alexander Potapenko <glider@google.com>

I confirm that the patch fixes the problem. Thanks for the quick turnaround=
!
Any idea which commit had introduced the bug in the first place?
> ---
>  mm/mempolicy.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index d879f1d..641545e 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2124,6 +2124,9 @@ bool __mpol_equal(struct mempolicy *a, struct mempo=
licy *b)
>         case MPOL_INTERLEAVE:
>                 return !!nodes_equal(a->v.nodes, b->v.nodes);
>         case MPOL_PREFERRED:
> +               /* a's flags is the same as b's */
> +               if (a->flags & MPOL_F_LOCAL)
> +                       return true;
>                 return a->v.preferred_node =3D=3D b->v.preferred_node;
>         default:
>                 BUG();
> --
> 1.8.3.1
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
