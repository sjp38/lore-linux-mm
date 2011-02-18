Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE8028D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:31:37 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1I4V2AQ000595
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:31:02 -0800
Received: by iyi20 with SMTP id 20so3166892iyi.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:31:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <m1sjvm822m.fsf@fess.ebiederm.org>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz> <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com> <m1sjvm822m.fsf@fess.ebiederm.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 20:30:42 -0800
Message-ID: <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Eric Dumazet <eric.dumazet@gmail.com>, Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>
Cc: Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 17, 2011 at 7:16 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> Interesting. =A0I just got this with DEBUG_PAGEALLOC
> It looks like something in DEBUG_PAGEALLOC is interfering with taking a
> successful crashdump.

Hmm. I don't see why, but we don't care. Just the IP and the Code:
section is plenty good enough.

> BUG: unable to handle kernel paging request at ffff8801adf8d760
> IP: [<ffffffff8140c7ca>] unregister_netdevice_queue+0x3a/0xb0

Yup. That's the "list_move()". The disassembly is exactly what I'd
expect from __list_del():

  16:	48 8b 93 a0 00 00 00 	mov    0xa0(%rbx),%rdx
  1d:	48 8b 83 a8 00 00 00 	mov    0xa8(%rbx),%rax
  24:	48 8d bb a0 00 00 00 	lea    0xa0(%rbx),%rdi
  2b:*	48 89 42 08          	mov    %rax,0x8(%rdx)     <-- trapping instruc=
tion
  2f:	48 89 10             	mov    %rdx,(%rax)

So I think we can consider this confirmed: it really is the stale
queue left over on the stack (introduced by commit 443457242beb). With
CONFIG_DEBUG_PAGEALLOC, you get a page fault when it tries to update
the now stale pointers.

The patch from Eric Dumazet (which adds a few more cases to my patch
and hopefully catches them all) almost certainly fixes this rather
nasty memory corruption.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
