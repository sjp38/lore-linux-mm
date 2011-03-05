Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 20E938D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 15:53:00 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p25Kqtig005851
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2011 12:52:56 -0800
Received: by iyf13 with SMTP id 13so3836848iyf.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 12:52:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110305203140.GD7546@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com>
 <20110303114952.B94B.A69D9226@jp.fujitsu.com> <20110303154706.GA22560@redhat.com>
 <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com>
 <20110305203040.GA7546@redhat.com> <20110305203140.GD7546@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Mar 2011 12:52:34 -0800
Message-ID: <AANLkTi=mce6tzg=vwf45XUQoADA=YbP2QJ2_tpg=QgQE@mail.gmail.com>
Subject: Re: [PATCH v4 3/4] exec: unify do_execve/compat_do_execve code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

Ok, everything looks fine to me.

Except looking at this, I don't think this part:

On Sat, Mar 5, 2011 at 12:31 PM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> =A0struct user_arg_ptr {
> - =A0 =A0 =A0 const char __user *const __user *native;
> +#ifdef CONFIG_COMPAT
> + =A0 =A0 =A0 bool is_compat;
> +#endif
> + =A0 =A0 =A0 union {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char __user *const __user *native;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 compat_uptr_t __user *compat;
> + =A0 =A0 =A0 } ptr;
> =A0};

will necessarily even compile on an architecture that doesn't have any
'compat' support.

Do we even define 'compat_uptr_t' for that case? I don't think so.

So I suspect you need two of those annoying #ifdef's. Or we need to
have some way to guarantee that 'compat_uptr_t' exists.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
