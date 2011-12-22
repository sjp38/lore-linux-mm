Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 975CE6B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 11:58:37 -0500 (EST)
Received: by yhgm50 with SMTP id m50so5175261yhg.14
        for <linux-mm@kvack.org>; Thu, 22 Dec 2011 08:58:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF2F9EB.7000006@jp.fujitsu.com>
References: <4EF2F9EB.7000006@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 22 Dec 2011 11:58:13 -0500
Message-ID: <CAHGf_=ov5B6LTB+fXHAsVkw-qW7QrnJ1y-nEzWOxPK_KKm7hGQ@mail.gmail.com>
Subject: Re: [PATCH] mm: mmap system call does not return EOVERFLOW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

> To fix this bug, it is necessary to compare "off" plus "len"
> with "off" by units of "off_t". The patch is here:
>
> Signed-off-by: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
> ---
> =A0mm/mmap.c | =A0 =A03 ++-
> =A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index eae90af..e74e736 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -948,6 +948,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsign=
ed long addr,
> =A0 =A0 =A0 =A0vm_flags_t vm_flags;
> =A0 =A0 =A0 =A0int error;
> =A0 =A0 =A0 =A0unsigned long reqprot =3D prot;
> + =A0 =A0 =A0 off_t off =3D pgoff << PAGE_SHIFT;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Does the application expect PROT_READ to imply PROT_EXE=
C?
> @@ -971,7 +972,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsign=
ed long addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> =A0 =A0 =A0 =A0/* offset overflow? */
> - =A0 =A0 =A0 if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> + =A0 =A0 =A0 if ((off + len) < off)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EOVERFLOW;

Hmm...
pgoff doesn't make actual overflow. do_mmap_pgoff() can calculate big
value. We have
no reason to make artificial limit. Why don't you meke a overflow
check in sys_mmap()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
