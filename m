Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1DC6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 10:46:46 -0400 (EDT)
Date: Mon, 15 Jun 2009 15:48:32 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615154832.73c89733@lxorguk.ukuu.org.uk>
In-Reply-To: <20090615132934.GE31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com>
	<4A35BD7A.9070208@linux.vnet.ibm.com>
	<20090615042753.GA20788@localhost>
	<Pine.LNX.4.64.0906151341160.25162@sister.anvils>
	<20090615140019.4e405d37@lxorguk.ukuu.org.uk>
	<20090615132934.GE31969@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 15:29:34 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> 
> I think you're wrong about killing processes decreasing
> reliability. Traditionally we always tried to keep things running if possible
> instead of panicing. That is why ext3 or block does not default to panic
> on each IO error for example. Or oops does not panic by default like
> on BSDs. Your argumentation would be good for a traditional early Unix
> which likes to panic instead of handling errors, but that's not the
> Linux way as I know it.

Everyone I knew in the business end of deploying Linux turned on panics
for I/O errors, reboot on panic and all the rest of those.

Why ? because they don't want a system where the web server is running
but not logging transactions, or to find out the database is up but that
some other "must not fail" layer killed or stalled the backup server for
it last week ...

The I/O ones can really blow up on you in a reliable environment because
often the process still exists but isn't working so fools much of the
monitoring software.

> That said you can configure it anyways to panic if you want,
> but it would be a very bad default.

That depends for whom

> See also Linus' or hpa's statement on the topic.

Linus doesn't run big server systems. Its a really bad default for
developers. Its probably a bad default for desktop users.

> We did a lot of testing with these separate test suites and also
> some other tests. For much more it needs actual users pounding on it, and that 
> can be only adequately done in mainline.

Thats why we have -next and -mm

> We did build tests on ia64 and power and it was reviewed by Tony for IA64.
> The ia64 specific code is not quite ready yet, but will come at some point.
> 
> I don't think it's a requirement for merging to have PPC64 support.

Really - so if your design is wrong for the way PPC wants to work what
are we going to do ? It's not a requirement that PPC64 support is there
but it is most certainly a requirement that its been in -next a while and
other arch maintainers have at least had time to say "works for me",
"irrelevant to my platform" or "Arghhh noooo.. ECC errors work like
[this] so we need ..."

I'd guess that zSeries has some rather different views on how ECC
failures propogate through the hypervisors for example, including the
fact that a failed page can be unfailed which you don't seem to allow for.

(You can unfail pages on x86 as well it appears by scrubbing them via DMA
- yes ?)


Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
