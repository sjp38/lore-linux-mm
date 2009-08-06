Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BABEB6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 01:06:11 -0400 (EDT)
Received: by gxk3 with SMTP id 3so763475gxk.14
        for <linux-mm@kvack.org>; Wed, 05 Aug 2009 22:06:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090805163325.14a4a77f.akpm@linux-foundation.org>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
	 <20090804192721.6A49.A69D9226@jp.fujitsu.com>
	 <20090805163325.14a4a77f.akpm@linux-foundation.org>
Date: Thu, 6 Aug 2009 14:06:11 +0900
Message-ID: <2f11576a0908052206t421686c9q9a458afee49b1d6f@mail.gmail.com>
Subject: Re: [PATCH 4/4] oom: fix oom_adjust_write() input sanity check.
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> @@ -1033,12 +1033,15 @@ static ssize_t oom_adjust_write(struct f
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D sizeof(buffer) - 1;
>> =A0 =A0 =A0 if (copy_from_user(buffer, buf, count))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
>> +
>> + =A0 =A0 strstrip(buffer);
>
> +1 for using strstrip()
>
> -1 for using it wrongly. =A0If it strips leading whitespace it will
> return a new address for the caller to use.

Will fix. thanks.

Paul, hehe your kernel/cgroup.c parsing have the same problem. Could you
please fix it too? :-)

> We could mark it __must_check() to prevent reoccurences of this error.
>
> How does this look?

I see.
I'll do and send it.

>
> --- a/fs/proc/base.c~oom-fix-oom_adjust_write-input-sanity-check-fix
> +++ a/fs/proc/base.c
> @@ -1033,8 +1033,7 @@ static ssize_t oom_adjust_write(struct f
> =A0 =A0 =A0 =A0if (copy_from_user(buffer, buf, count))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
>
> - =A0 =A0 =A0 strstrip(buffer);
> - =A0 =A0 =A0 oom_adjust =3D simple_strtol(buffer, &end, 0);
> + =A0 =A0 =A0 oom_adjust =3D simple_strtol(strstrip(buffer), &end, 0);
> =A0 =A0 =A0 =A0if (*end)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0if ((oom_adjust < OOM_ADJUST_MIN || oom_adjust > OOM_ADJUS=
T_MAX) &&
>
>
>> =A0 =A0 =A0 oom_adjust =3D simple_strtol(buffer, &end, 0);
>
> That should've used strict_strtoul() but it's too late to fix it now.

Perhaps, it's not too late. I never seen userland program pass non number v=
alue
into this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
