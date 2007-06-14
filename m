Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch 0/3] no MAX_ARG_PAGES -v2
Date: Thu, 14 Jun 2007 11:22:02 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A01AF8CE6@scsmsx411.amr.corp.intel.com>
In-Reply-To: <1181810319.7348.345.camel@twins>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ollie Wild <aaw@google.com>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> > Interesting.  If you're exceeding your stack ulimit, you should be
> > seeing either an "argument list too long" message or getting a
> > SIGSEGV.  Have you tried bypassing wc and piping the output straight
> > to a file?
>
> I think it sends SIGKILL on failure paths.

Setting stack limit to unlimited I managed to exec with 10MB, and
"wc" produced the correct output when it (finally) ran, so no
odd limits being hit in there.

Setting a lower (4MB) stack limit, and then increasing the
amount of args in 100K steps I saw this:

Up to an including 32 * 100K => works fine.

33:40 * 100K => no errors from the script, but wc reports "0 0 0"

>40 * 100K => "/bin/echo: Argument list too long".


All this might be connected to ia64's confusing implementation
of stack limit (since we have *two* stacks ... the regular one
and the upward growing one for the h/w register stack engine).

Ah ... running the 34*100K case direct from my shell prompt, I
do see a "Killed" that must get lost when I run this in the
shell script loop.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
