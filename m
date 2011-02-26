Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 72F338D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 10:56:11 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1QFu6Su007305
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 07:56:06 -0800
Received: by iyf13 with SMTP id 13so2319501iyf.14
        for <linux-mm@kvack.org>; Sat, 26 Feb 2011 07:56:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110226123731.GC4416@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com>
 <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com>
 <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com>
 <20110226123731.GC4416@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 Feb 2011 07:55:44 -0800
Message-ID: <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com>
Subject: Re: [PATCH 3/5] exec: unify compat_do_execve() code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Sat, Feb 26, 2011 at 4:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>>
>> =A0 typedef union {
>> =A0 =A0 =A0compat_uptr_t compat;
>> =A0 =A0 =A0const char __user *native;
>> =A0 =A0} conditional_user_ptr_t;
>
> Personally I don't really like this union, to me "void __user*" looks
> better, but I won't insist.

Umm. "void __user *" may look simpler/better, but it's WRONG.

Using "const char __user *const __user *" is correct - but only for
the non-compat case.

And using "void __user *" may result in compiling code, but it will
have lost all actual information about the type. We don't do that in
the kernel if we can avoid it, because "void *" basically does no type
checking. Sure, sometimes it's the only thing we can do, but _if_ we
have a type, we should use it.

And that "union" really is the true type. You are passing a user
pointer down that can be either of those members.

So if you think it looks ugly, then you shouldn't do that "conditional
compat argument at run-time at all". Because the real ugliness of the
type comes not from the type, but from the fact that you pass a
pointer that can contain two different things.


> Once again, to me "void __user*" looks better (just simpler). In this
> case get_arg_ptr() becomes (without const/__user for the clarity)

No.

I simply won't apply that. It's WRONG. It's wrong because you've
dropped all the type information.

With the right union,

> =A0 =A0 =A0 =A0void *get_arg_ptr(void **argv, int argc, bool compat)
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0char *ptr;
>
> =A0 =A0 =A0 =A0#ifdef CONFIG_COMPAT
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(compat)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compat_uptr_t *a =3D argv;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compat_uptr_t p;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (get_user(p, a + argc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR=
_PTR(-EFAULT);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return compat_ptr(p);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0#endif
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (get_user(ptr, &argv. + argc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-EFAULT);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ptr;
> =A0 =A0 =A0 =A0}
>
> Otherwise, get_arg_ptr() should return conditional_user_ptr_t as well,

No it shouldn't. The get_arg_ptr() should always just return the
actual pointer. It will have _resolved_ the ambiguity! That's what the
"compat_ptr()" thing does in the return case inside teh CONFIG_COMPAT.

So the correct way to do this is something like the following (yeah,
maybe I got the syntax wrong, I didn't test this, I just wrote it in
my MUA):

       void *get_arg_ptr(const union compat_ptr_union __user *argv,
int argc, bool compat)
       {
               char *ptr;

        #ifdef CONFIG_COMPAT
               if (unlikely(compat)) {
                       compat_uptr_t p;

                       if (get_user(p, &argv->compat + argc))
                               return ERR_PTR(-EFAULT);

                       return compat_ptr(p);
               }
        #endif

               if (get_user(ptr, &argv->noncompat +argc))
                       return ERR_PTR(-EFAULT);

               return ptr;
       }

and notice how it gets the types right, and it even has one line LESS
than your version, exactly because it gets the types right and doesn't
need that implied cast in your

     compat_uptr_t *a =3D argv;

(in fact, I think your version needs an _explicit_ cast in order to
not get a warning: you can't just cast "void **" to something else).

See? The advantage of the union is that the types are correct, which
means that the casts are unnecessary.

The advantage of the union is also that you see what is going on, and
it's clear from the function prototype that this doesn't just take a
random user pointer, it takes a user pointer to something that can be
two different types.

See? Correct typing is important.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
