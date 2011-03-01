Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9B4C8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 16:40:35 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.14.2/Debian-2build1) with ESMTP id p21Ldu26007713
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 13:39:57 -0800
Received: by iyf13 with SMTP id 13so5786218iyf.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 13:39:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110301204739.GA30406@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com>
 <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com>
 <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com>
 <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com>
 <20110226174408.GA17442@redhat.com> <20110301204739.GA30406@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 1 Mar 2011 13:39:35 -0800
Message-ID: <AANLkTikVecxcGoZ9a4hmkoi4wynrNfH9_AU7Vb+hOvbH@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] exec: unify native/compat code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Tue, Mar 1, 2011 at 12:47 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> =A0 =A0 =A0 =A0where that 'do_execve_common()' takes it's arguments as
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0union conditional_user_ptr_t __user *argv,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0union conditional_user_ptr_t __user *envp
>
> I hope you didn't really mean this...

I really did mean that (although not the double "union" + "_t" thing
for the typedef).

But I'm not going to claim that it has to be done exactly that way,
the union can certainly be encapsulated differently too.

So I'm ok with your alternative

> =A0 =A0 =A0 =A0typedef union {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char __user *const __user *native;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compat_uptr_t __user *compat;
> =A0 =A0 =A0 =A0} conditional_user_ptr_t;

model instead, which moves the pointer into the union.

However, if you do this, then I have one more suggestion: just move
the "compat" flag in there too!

Every time you pass the union, you're going to pass the compat flag to
distinguish the cases. So do it like this:

  struct conditional_ptr {
    int is_compat;
    union {
      const char __user *const __user *native;
      compat_uptr_t __user *compat;
    };
  };

and it will all look much cleaner, I bet.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
