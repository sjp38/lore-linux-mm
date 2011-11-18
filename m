Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 346186B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 09:16:05 -0500 (EST)
Received: by yenm10 with SMTP id m10so3290322yen.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:16:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
References: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
Date: Fri, 18 Nov 2011 15:16:02 +0100
Message-ID: <CAONaPpGQdpNDT9EuTq_xian+bRFDUsLn7AgjtG-=y0C6-9fDTQ@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: detect race if fail to COW
From: John Kacur <jkacur@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 18, 2011 at 3:04 PM, Hillf Danton <dhillf@gmail.com> wrote:
> In the error path that we fail to allocate new huge page, before try agai=
n, we
> have to check race since page_table_lock is re-acquired.
>
> If racing, our job is done.
>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
>
> --- a/mm/hugetlb.c =A0 =A0 =A0Fri Nov 18 21:38:30 2011
> +++ b/mm/hugetlb.c =A0 =A0 =A0Fri Nov 18 21:48:15 2011
> @@ -2407,7 +2407,14 @@ retry_avoidcopy:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(pag=
e_count(old_page) !=3D 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(hug=
e_pte_none(pte));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(=
&mm->page_table_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry_=
avoidcopy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptep =3D hu=
ge_pte_offset(mm, address & huge_page_mask(h));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(=
pte_same(huge_ptep_get(ptep), pte)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto retry_avoidcopy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* race o=
ccurs while re-acquiring page_table_lock, and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* our jo=
b is done.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_ON_ONCE(1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}


I'm not sure about the veracity of the race condition, but you better
do spin_unlock before you return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
