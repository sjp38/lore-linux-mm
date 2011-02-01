Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFF28D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:09:03 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p11190Wj025669
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:09:00 -0800
Received: from ywf9 (ywf9.prod.google.com [10.192.6.9])
	by hpaq7.eem.corp.google.com with ESMTP id p1118TWG007806
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:08:59 -0800
Received: by ywf9 with SMTP id 9so2774365ywf.11
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:08:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110201010341.GA21676@google.com>
References: <20110201010341.GA21676@google.com>
Date: Mon, 31 Jan 2011 17:08:59 -0800
Message-ID: <AANLkTimycdE11kyPSxpVHuCLV7wshj-CPt+HVNcJsTTZ@mail.gmail.com>
Subject: Re: [PATCH] mlock: operate on any regions with protection != PROT_NONE
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tao Ma <tm@tao.ma>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

(forgot the signoff...)

On Mon, Jan 31, 2011 at 5:03 PM, Michel Lespinasse <walken@google.com> wrot=
e:
> As Tao Ma noticed, change 5ecfda0 breaks blktrace. This is because
> blktrace mmaps a file with PROT_WRITE permissions but without PROT_READ,
> so my attempt to not unnecessarity break COW during mlock ended up
> causing mlock to fail with a permission problem.
>
> I am proposing to let mlock ignore vma protection in all cases except
> PROT_NONE. In particular, mlock should not fail for PROT_WRITE regions
> (as in the blktrace case, which broke at 5ecfda0) or for PROT_EXEC
> regions (which seem to me like they were always broken).
>
> Please review. I am proposing this as a candidate for 2.6.38 inclusion,
> because of the behavior change with blktrace.

Signed-off-by: Michel Lespinasse <walken@google.com>

> diff --git a/mm/mlock.c b/mm/mlock.c
> index 13e81ee..c3924c7f 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -178,6 +178,13 @@ static long __mlock_vma_pages_range(struct vm_area_s=
truct *vma,
> =A0 =A0 =A0 =A0if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) =3D=3D VM_WRI=
TE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gup_flags |=3D FOLL_WRITE;
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We want mlock to succeed for regions that have any per=
missions
> + =A0 =A0 =A0 =A0* other than PROT_NONE.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gup_flags |=3D FOLL_FORCE;
> +
> =A0 =A0 =A0 =A0if (vma->vm_flags & VM_LOCKED)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gup_flags |=3D FOLL_MLOCK;

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
