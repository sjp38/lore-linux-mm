Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5386B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 13:36:22 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so20212201obc.3
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 10:36:22 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id fh4si2577916obb.73.2015.10.20.10.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 20 Oct 2015 10:36:21 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <65a10261038346b1a778443fd15f0980@SHMBX01.spreadtrum.com>
Date: Tue, 20 Oct 2015 12:27:58 -0500
In-Reply-To: <65a10261038346b1a778443fd15f0980@SHMBX01.spreadtrum.com>
	("Hongjie Fang \=\?utf-8\?B\?KOaWuea0quadsCkiJ3M\=\?\= message of "Tue, 20 Oct
 2015 12:34:36
	+0000")
Message-ID: <87zizdfo0x.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 4.3-rc6] proc: fix oom_adj value read from /proc/<pid>/oom_adj
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SG9uZ2ppZSBGYW5nICjmlrnmtKrmnbAp?= <Hongjie.Fang@spreadtrum.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

"Hongjie Fang (=E6=96=B9=E6=B4=AA=E6=9D=B0)" <Hongjie.Fang@spreadtrum.com> =
writes:

> The oom_adj's value reading through /proc/<pid>/oom_adj is different=20
> with the value written into /proc/<pid>/oom_adj.
> Fix this by adding a adjustment factor.

*Scratches my head*

Won't changing the interpretation of what is written break existing
userspace applications that write this value?

Added a few more likely memory management suspects that might understand
what is going on here.

Eric

>
> Signed-off-by: Hongjie Fang <hongjie.fang@spreadtrum.com>
> ---
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index b25eee4..1ea0589 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1043,6 +1043,7 @@ static ssize_t oom_adj_write(struct file *file, con=
st char __user *buf,
>  	int oom_adj;
>  	unsigned long flags;
>  	int err;
> +	int adjust;
>=20=20
>  	memset(buffer, 0, sizeof(buffer));
>  	if (count > sizeof(buffer) - 1)
> @@ -1084,8 +1085,10 @@ static ssize_t oom_adj_write(struct file *file, co=
nst char __user *buf,
>  	 */
>  	if (oom_adj =3D=3D OOM_ADJUST_MAX)
>  		oom_adj =3D OOM_SCORE_ADJ_MAX;
> -	else
> -		oom_adj =3D (oom_adj * OOM_SCORE_ADJ_MAX) / -OOM_DISABLE;
> +	else{
> +		adjust =3D oom_adj > 0 ? (-OOM_DISABLE-1) : -(-OOM_DISABLE-1);
> +		oom_adj =3D (oom_adj * OOM_SCORE_ADJ_MAX + adjust) / -OOM_DISABLE;
> +	}
>=20=20
>  	if (oom_adj < task->signal->oom_score_adj &&
>  	    !capable(CAP_SYS_RESOURCE)) {
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
