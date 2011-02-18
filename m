Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5F28D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:25:33 -0500 (EST)
Received: by bwz16 with SMTP id 16so3497549bwz.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 22:25:29 -0800 (PST)
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110217.203647.193696765.davem@davemloft.net>
References: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <m1sjvm822m.fsf@fess.ebiederm.org>
	 <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	 <20110217.203647.193696765.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 07:25:20 +0100
Message-ID: <1298010320.2642.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, ebiederm@xmission.com, opurdila@ixiacom.com, mingo@elte.hu, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Le jeudi 17 fA(C)vrier 2011 A  20:36 -0800, David Miller a A(C)crit :
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 17 Feb 2011 20:30:42 -0800
> 
> > On Thu, Feb 17, 2011 at 7:16 PM, Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> >> BUG: unable to handle kernel paging request at ffff8801adf8d760
> >> IP: [<ffffffff8140c7ca>] unregister_netdevice_queue+0x3a/0xb0
> > 
> > Yup. That's the "list_move()". The disassembly is exactly what I'd
> > expect from __list_del():
> > 
> >   16:	48 8b 93 a0 00 00 00 	mov    0xa0(%rbx),%rdx
> >   1d:	48 8b 83 a8 00 00 00 	mov    0xa8(%rbx),%rax
> >   24:	48 8d bb a0 00 00 00 	lea    0xa0(%rbx),%rdi
> >   2b:*	48 89 42 08          	mov    %rax,0x8(%rdx)     <-- trapping instruction
> >   2f:	48 89 10             	mov    %rdx,(%rax)
> > 
> > So I think we can consider this confirmed: it really is the stale
> > queue left over on the stack (introduced by commit 443457242beb). With
> > CONFIG_DEBUG_PAGEALLOC, you get a page fault when it tries to update
> > the now stale pointers.
> > 
> > The patch from Eric Dumazet (which adds a few more cases to my patch
> > and hopefully catches them all) almost certainly fixes this rather
> > nasty memory corruption.
> 
> Eric D., please get a final version of the fix posted to netdev and
> I'll make sure it slithers it's way to Linus's tree :-)
> 
> Thanks!

I believe we can apply Linus patch as is for current linux-2.6

Then add a second patch for previous kernels (the parts I added), since
we might had a previous bug, un-noticed ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
