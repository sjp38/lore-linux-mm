Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCCD60021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:01:53 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n92M1prm004599
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 23:01:51 +0100
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by spaceape9.eur.corp.google.com with ESMTP id n92M1SGr023880
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 15:01:49 -0700
Received: by pzk9 with SMTP id 9so1341544pzk.16
        for <linux-mm@kvack.org>; Fri, 02 Oct 2009 15:01:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091002173955.5F72.A69D9226@jp.fujitsu.com>
References: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
	 <20091002173955.5F72.A69D9226@jp.fujitsu.com>
Date: Fri, 2 Oct 2009 15:01:48 -0700
Message-ID: <6599ad830910021501s66cfc108r9a109b84b0f658a4@mail.gmail.com>
Subject: Re: [PATCH 3/3] cgroup: fix strstrip() abuse
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 2, 2009 at 1:41 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> cgroup_write_X64() and cgroup_write_string() ignore the return
> value of strstrip().
> it makes small inconsistent behavior.
>
> example:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> =A0# cd /mnt/cgroup/hoge
> =A0# cat memory.swappiness
> =A060
> =A0# echo "59 " > memory.swappiness
> =A0# cat memory.swappiness
> =A059
> =A0# echo " 58" > memory.swappiness
> =A0bash: echo: write error: Invalid argument
>
>
> This patch fixes it.
>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Paul Menage <menage@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

Thanks - although I think I'd s/abuse/misuse/ in the description.

> ---
> =A0kernel/cgroup.c | =A0 =A08 +++-----
> =A01 file changed, 3 insertions(+), 5 deletions(-)
>
> Index: b/kernel/cgroup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1710,14 +1710,13 @@ static ssize_t cgroup_write_X64(struct c
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
>
> =A0 =A0 =A0 =A0buffer[nbytes] =3D 0; =A0 =A0 /* nul-terminate */
> - =A0 =A0 =A0 strstrip(buffer);
> =A0 =A0 =A0 =A0if (cft->write_u64) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 val =3D simple_strtoull(buffer, &end, 0=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 val =3D simple_strtoull(strstrip(buffer=
), &end, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (*end)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D cft->write_u64(cgrp, cft, val);
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s64 val =3D simple_strtoll(buffer, &end, 0)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s64 val =3D simple_strtoll(strstrip(buffer)=
, &end, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (*end)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D cft->write_s64(cgrp, cft, val);
> @@ -1753,8 +1752,7 @@ static ssize_t cgroup_write_string(struc
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0buffer[nbytes] =3D 0; =A0 =A0 /* nul-terminate */
> - =A0 =A0 =A0 strstrip(buffer);
> - =A0 =A0 =A0 retval =3D cft->write_string(cgrp, cft, buffer);
> + =A0 =A0 =A0 retval =3D cft->write_string(cgrp, cft, strstrip(buffer));
> =A0 =A0 =A0 =A0if (!retval)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D nbytes;
> =A0out:
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
