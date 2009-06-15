Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5966B0055
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 09:20:48 -0400 (EDT)
Date: Mon, 15 Jun 2009 15:29:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615132934.GE31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <Pine.LNX.4.64.0906151341160.25162@sister.anvils> <20090615140019.4e405d37@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615140019.4e405d37@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


I think you're wrong about killing processes decreasing
reliability. Traditionally we always tried to keep things running if possible
instead of panicing. That is why ext3 or block does not default to panic
on each IO error for example. Or oops does not panic by default like
on BSDs. Your argumentation would be good for a traditional early Unix
which likes to panic instead of handling errors, but that's not the
Linux way as I know it.

Also BTW in many cases (e.g. a lot of file cache pages) there 
is actually no process kill involved; just a reload of the page from
disk.

Then for example in a cluster you typically have a application level
heartbeat on the application and restarting the app is faster
if you don't need to reboot the box too. If you don't have a cluster
with failover then gracefull degradation is the best. In general
panic is a very nasty failure mode and should be avoided.

That said you can configure it anyways to panic if you want,
but it would be a very bad default.

See also Linus' or hpa's statement on the topic.

> no testing, 

There's an extensive test suite in mce-test.git 

We did a lot of testing with these separate test suites and also
some other tests. For much more it needs actual users pounding on it, and that 
can be only adequately done in mainline.

That said the real tests of this can be only done with test suites
really, these errors tend to not happen quickly. 

> integration shakedown, no builds on non-x86 boxes, no work with other
> arch maintainers who have similar abilities and needs.

We did build tests on ia64 and power and it was reviewed by Tony for IA64.
The ia64 specific code is not quite ready yet, but will come at some point.

I don't think it's a requirement for merging to have PPC64 support.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
