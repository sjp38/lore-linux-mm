Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5398D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 13:55:21 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1PIsiQg024446
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 10:54:44 -0800
Received: by iwl42 with SMTP id 42so1806062iwl.14
        for <linux-mm@kvack.org>; Fri, 25 Feb 2011 10:54:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110225175202.GA19059@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com>
 <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Feb 2011 10:54:24 -0800
Message-ID: <AANLkTimv6=QuK2+ye=OFCdRN_285GsNc4CnWEQf8OY26@mail.gmail.com>
Subject: Re: [PATCH 0/4 RESEND] exec: unify compat/non-compat code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Fri, Feb 25, 2011 at 9:52 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>> On 12/01, Milton Miller wrote:
>> >
>> > > +#ifdef CONFIG_COMPAT
>> > > +int compat_do_execve(char * filename,
>> > > + compat_uptr_t __user *argv,
>> > > + compat_uptr_t __user *envp,
>> > > + struct pt_regs * regs)
>> > > +{
>> > > + return do_execve_common(filename,
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void __user*)argv=
, (void __user*)envp,
>> >
>> > Shouldn't these be compat_ptr(argv)? =A0(makes a difference on s390)

Indeed. The "compat_uptr_t __user *argv" is wrong, and it should be just

    compat_uptr_t argv;

and then every time you turn it into a pointer, it should use
"compat_ptr(argv)".

Then, since it's a pointer to an array of pointers, when you do that,
you should turn it into a pointer to "compat_uptr_t", so you actually
have this:

 - user passes "compat_uptr_t"

 - the kernel can turn that into "compat_uptr_t __user *" by doing

       compat_uptr_t __user *pptr;
       pptr =3D compat_ptr(argv);

 - the kernel needs to fetch the individual entries with

       compat_uptr_t cuptr =3D get_user(pptr);

 - the kernel can then turn _those_ into the actual pointers to the string =
with

       const char __user *str =3D compat_ptr(cuptr);

so you need two levels of compat_ptr() conversion.

> So, once again, this should not (and can not) be compat_ptr(argv) afaics.

It can be, and probably should. But the low-level s390 wrapper
function may have done one of the levels already. It probably
shouldn't, and we _should_ do the "compat_ptr()" thing a the generic C
level. That's what we do with all the other pointers, after all.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
