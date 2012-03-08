Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id E64C86B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 18:51:40 -0500 (EST)
Date: Thu, 8 Mar 2012 15:51:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
Message-Id: <20120308155139.19f0ce7e.akpm@linux-foundation.org>
In-Reply-To: <4F570168.6050008@gmail.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
	<20120306160833.0e9bf50a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
	<CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com>
	<alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com>
	<4F570168.6050008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 07 Mar 2012 01:34:16 -0500
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> >> And, now BUG() has renreachable() annotation. why don't it work?
> >>
> >>
> >> #define BUG()                                                   \
> >> do {                                                            \
> >>          asm volatile("ud2");                                    \
> >>          unreachable();                                          \
> >> } while (0)
> >>
> >
> > That's not compiled for CONFIG_BUG=n; such a config fallsback to
> > include/asm-generic/bug.h which just does
> >
> > 	#define BUG()	do {} while (0)
> >
> > because CONFIG_BUG specifically _wants_ to bypass BUG()s and is reasonably
> > protected by CONFIG_EXPERT.
> 
> So, I strongly suggest to remove CONFIG_BUG=n. It is neglected very long time and
> much plenty code assume BUG() is not no-op. I don't think we can fix all place.
> 
> Just one instruction don't hurt code size nor performance.

Well yes, CONFIG_BUG=n is a crazy thing to do.  a) because programmers
universally assume that BUG() doesn't return and b) given that the
kernel KNOWS that it is about to fall off a cliff, why would anyone
want to deprive themselves of information about the forthcoming crash?

So perhaps a good compromise here is to do nothing: let the
CONFIG_BUG=n build spew a pile of warnings, and let the crazy
CONFIG_BUG=n people suffer.  That's if any such people exist...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
