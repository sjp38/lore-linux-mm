Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 61F896B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 17:39:46 -0400 (EDT)
Date: Fri, 19 Aug 2011 22:38:10 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: running of out memory => kernel crash
Message-ID: <20110819223810.0f02016e@lxorguk.ukuu.org.uk>
In-Reply-To: <4E4ED366.1090104@genband.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com>
	<CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com>
	<1313075625.50520.YahooMailNeo@web111715.mail.gq1.yahoo.com>
	<201108111938.25836.vda.linux@googlemail.com>
	<CAG1a4rsO7JDqmYiwyxPrAHdLNbJt+wqymSzU9i1dv5w5C2OFog@mail.gmail.com>
	<CAK1hOcM5u-zB7fUnR5QVJGBrEnLMhK9Q+EmWBknThga70UQaLw@mail.gmail.com>
	<CAG1a4rus+VVhhB3ayuDF2pCQDusLekGOAxf33+u_uzxC1yz1MA@mail.gmail.com>
	<CAF_S4t--+Ufkb2bVrt9e59R=yty5U5Cb=Kt5RbjPjraM_equog@mail.gmail.com>
	<4E4ED366.1090104@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Friesen <chris.friesen@genband.com>
Cc: Bryan Donlan <bdonlan@gmail.com>, Pavel Ivanov <paivanof@gmail.com>, Denys Vlasenko <vda.linux@googlemail.com>, Mahmood Naderan <nt_mahmood@yahoo.com>, David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Indeed.  From the point of view of the OS, it's running everything on 
> the system without a problem.  It's deep into swap, but it's running.

Watchdogs can help here

> If there are application requirements on grade-of-service, it's up to 
> the application to check whether those are being met and if not to do 
> something about it.

Or it can request such a level of service from the kernel using the
various memory control interfaces provided but not enabled by
distributors in default configurations.

In particular you can tell the kernel to stop the system hitting the
point where it runs near to out of memory + swap and begins to thrash
horribly. For many workloads you will need a lot of pretty much excess
swap, but disk is cheap. It's like banking, you can either pretend it's
safe in which case you do impressions of the US banking system now and
then and the government has to reboot it, or you can do traditional
banking models where you have a reserve which is sufficient to cover the
worst case of making progress. Our zero overcommit isn't specifically
aimed at the page rate problem but is sufficiently related it usually
does the trick.

http://opsmonkey.blogspot.com/2007/01/linux-memory-overcommit.html

I would btw disagree strongly that this is a 'sorry we can't help'
situation. Back when memory was scarce and systems habitually ran at high
memory loads 4.2 and 4.3BSD coped just fine with very high fault rates
that make modern systems curl up and die. That was entirely down to
having good paging and swap policies linked to scheduling behaviour so
they always made progress. Your latency went through the roof but work
got done which meant that if it was transient load the system would feel
like treacle then perk up again where these days it seems the fashion of
most OS's to just explode messily.

In particular they did two things
- Actively tried to swap out all the bits of entire process victims to
  make space to do work under very high load
- When a process was pulled in it got time to run before it as opposed
  to someone else got dumped out

That has two good effects. Firstly the system could write out the process
data very efficiently and get it back likewise. Secondly the system ended
up in a kick one out, do work in the space we have to breath, stop, kick
next out, do work, and in most cases had little CPU contention so could
make good progress in each burst, albeit with the high latency cost.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
