Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 22AB06B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 18:10:43 -0500 (EST)
Received: by ghrr17 with SMTP id r17so4329642ghr.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 15:10:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
References: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
Date: Mon, 21 Nov 2011 15:10:39 -0800
Message-ID: <CANN689EDDy9PTSvt10Gk3jiW-QjQpsZmCnrqoTwmPecEQYT2Ew@mail.gmail.com>
Subject: Re: [PATCH] ksm: use FAULT_FLAG_ALLOW_RETRY in breaking COW
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Sat, Nov 19, 2011 at 3:50 AM, Hillf Danton <dhillf@gmail.com> wrote:
> The flag, FAULT_FLAG_ALLOW_RETRY, was introduced by the patch,
>
> =A0 =A0 =A0 =A0mm: retry page fault when blocking on disk transfer
> =A0 =A0 =A0 =A0commit: d065bd810b6deb67d4897a14bfe21f8eb526ba99
>
> for reducing mmap_sem hold times that are caused by waiting for disk
> transfers when accessing file mapped VMAs.
>
> To break COW, handle_mm_fault() is repeated with mmap_sem held, where
> the introduced flag could be used again.
>
> The straight way is to add changes in break_ksm(), but the function could=
 be
> under write-mode mmap_sem, so it has to be dupilcated.
>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

I have to concur with Hugh here - FAULT_FLAG_ALLOW_RETRY was
introduced to avoid holding mmap_sem while we block on a disk read,
but you shouldn't hit this case in the break COW case, so there seems
to be little point in adding the flag there.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
