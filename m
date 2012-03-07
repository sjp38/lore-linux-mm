Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3BAB36B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 00:58:44 -0500 (EST)
Received: by iajr24 with SMTP id r24so10599841iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 21:58:43 -0800 (PST)
Date: Tue, 6 Mar 2012 21:58:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
In-Reply-To: <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com> <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
 <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-664089629-1331099922=:6424"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-664089629-1331099922=:6424
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 7 Mar 2012, KOSAKI Motohiro wrote:

> > It's unnecessary to BUG() in situations when a mempolicy has an
> > unsupported mode, it just means that a mode doesn't have complete coverage
> > in all mempolicy functions -- which is an error, but not a fatal error --
> > or that a bit has flipped.  Regardless, it's sufficient to warn the user
> > in the kernel log of the situation once and then proceed without crashing
> > the system.
> >
> > This patch converts nearly all the BUG()'s in mm/mempolicy.c to
> > WARN_ON_ONCE(1) and provides the necessary code to return successfully.
> 
> I'm sorry. I simple don't understand the purpose of this patch. every
> mem policy  syscalls have input check then we can't hit BUG()s in
> mempolicy.c. To me, BUG() is obvious notation than WARN_ON_ONCE().
> 

Right, this patch doesn't functionally change anything except it will (1) 
continue to warn users when there's a legitimate mempolicy code error by 
way of WARN_ON_ONCE() (which is good), just without crashing the machine 
unnecessarily and (2) allow the system to stay alive since no mempolicy 
error changed by this bug is fatal.  We should only be using BUG() when 
the side-effects of continuing are fatal; doing WARN_ON_ONCE(1) is 
sufficient annotation, I think, that this code should never be reached -- 
BUG() has no advantage here.

> We usually use WARN_ON_ONCE() for hw drivers code. Because of, the
> warn-on mean "we believe this route never reach, but we afraid there
> is crazy buggy hardware".
> 
> And, now BUG() has renreachable() annotation. why don't it work?
> 
> 
> #define BUG()                                                   \
> do {                                                            \
>         asm volatile("ud2");                                    \
>         unreachable();                                          \
> } while (0)
> 

That's not compiled for CONFIG_BUG=n; such a config fallsback to 
include/asm-generic/bug.h which just does

	#define BUG()	do {} while (0)

because CONFIG_BUG specifically _wants_ to bypass BUG()s and is reasonably 
protected by CONFIG_EXPERT.
--397155492-664089629-1331099922=:6424--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
