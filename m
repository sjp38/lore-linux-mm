Subject: Re: [PATCH] fix spurious OOM kills
From: Thomas Gleixner <tglx@linutronix.de>
Reply-To: tglx@linutronix.de
In-Reply-To: <41A08765.7030402@ribosome.natur.cuni.cz>
References: <20041111112922.GA15948@logos.cnet>
	 <4193E056.6070100@tebibyte.org>	<4194EA45.90800@tebibyte.org>
	 <20041113233740.GA4121@x30.random>	<20041114094417.GC29267@logos.cnet>
	 <20041114170339.GB13733@dualathlon.random>
	 <20041114202155.GB2764@logos.cnet>	<419A2B3A.80702@tebibyte.org>
	 <419B14F9.7080204@tebibyte.org>	<20041117012346.5bfdf7bc.akpm@osdl.org>
	 <419CD8C1.4030506@ribosome.natur.cuni.cz>
	 <20041118131655.6782108e.akpm@osdl.org>
	 <419D25B5.1060504@ribosome.natur.cuni.cz>
	 <419D2987.8010305@cyberone.com.au>
	 <419D383D.4000901@ribosome.natur.cuni.cz>
	 <20041118160824.3bfc961c.akpm@osdl.org>
	 <419E821F.7010601@ribosome.natur.cuni.cz>
	 <1100946207.2635.202.camel@thomas> <419F2AB4.30401@ribosome.natur.cuni.cz>
	 <1100957349.2635.213.camel@thomas>
	 <419FB4CD.7090601@ribosome.natur.cuni.cz> <1101037999.23692.5.camel@thomas>
	 <41A08765.7030402@ribosome.natur.cuni.cz>
Content-Type: text/plain; charset=iso-8859-2
Date: Sun, 21 Nov 2004 14:57:49 +0100
Message-Id: <1101045469.23692.16.camel@thomas>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin =?iso-8859-2?Q?MOKREJ=A9?= <mmokrejs@ribosome.natur.cuni.cz>
Cc: Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, chris@tebibyte.org, marcelo.tosatti@cyclades.com, andrea@novell.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2004-11-21 at 13:17 +0100, Martin MOKREJ(C) wrote:
> Why can't the algorithm first find the asking for memory now.
> When found, kernel should kill first it's children, wait some time,
> then kill this process if still exists (it might exit itself when children
> get closed).
> You have said it's safer to kill that to send ENOMEM as happens
> in 2.4, but I still don't undertand why kernel first doesn't send
> ENOMEM, and only if that doesn't help it can start after those 5 seconds
> OOM killer, and try to kill the very same application.
> I don't get the idea why to kill immediately.

I see your concern. There are some more changes neccecary to make this
reliably work. I'm not sure if it can be done without really big
changes. I will look a bit deeper into this.

> As it has happened to me in the past, that random OOM selection has killed
> sshd or init, I believe the algorithm should be improved to not to try
> to kill these. First of all, sshd is well tested, so it will never
> be source of memleaks. Second, if the algorithm would really insist on
> killing either of these, I personally prefer it rather do clean reboot
> than a system in a state without sshd. I have to get to the console.
> Actually, it's several kilometers for me. :(

Yeah, I observed this too and therefor came up with the whom to kill and
reentrancy patch.

> It's a pitty no-one has time to at least figure out why those changes have
> exposed this stupid random part of the algorithm. Before 2.6.9-rc2
> OOM killer was also started in my tests, but it worked deterministically.
> I wouldn't prefer extra algorithm to check what we kill now, I'd rather look
> why we kill randomly since -rc2.

As I said before the random behaviour was _not_ introduced in -rc2. It
might have changed in -rc2. The random kill with overkill can also be
triggered in 2.6.7 and 2.6.8. I have not tried elder versions though.

tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
