Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 04A496B004A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 16:44:04 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5GKhSHE005532
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:43:29 -0700
Received: by wwi36 with SMTP id 36so1647659wwi.26
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:43:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DFA6442.9000103@linux.intel.com>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <87ea4bd7-8b16-4b24-8fcb-d8e9b6f421ec@email.android.com> <4DF92FE1.5010208@linux.intel.com>
 <BANLkTi=Tw6je7zpi4L=pE0JJpZfeEC9Jsg@mail.gmail.com> <4DFA6442.9000103@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Jun 2011 13:37:47 -0700
Message-ID: <BANLkTin_46==epHKUbWJ55bt3mPaJieV2Q@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Jun 16, 2011 at 1:14 PM, Andi Kleen <ak@linux.intel.com> wrote:
>
> I haven't analyzed it in detail, but I suspect it's some cache line bounc=
e,
> which
> can slow things down quite a lot. =A0Also the total number of invocations
> is quite high (hundreds of messages per core * 32 cores)

The fact is, glibc is just total crap.

I tried to send uli a patch to just add caching. No go. I sent
*another* patch to at least make glibc use a sane interface (and the
cache if it needs to fall back on /proc/stat for some legacy reason).
We'll see what happens.

Paul Eggbert suggested "caching for one second" - by just calling
"gettimtofday()" to see how old the cache is. That would work too.

The point I'm making is that it really is a glibc problem. Glibc is
doing stupid expensive things, and not trying to correct for the fact
that it's expensive.

> I did, but I gave up fully following that code path because it's so
> convoluted :-/

I do agree that glibc sources are incomprehensible, with multiple
layers of abstraction (sysdeps, "posix", helper functions etc etc).

In this case it was really trivial to find the culprit with a simple

   git grep /proc/stat

though. The code is crap. It's insane. It's using
/sys/devices/system/cpu for _SC_NPROCESSORS_CONF, which is at least a
reasonable interface to use. But it does it in odd ways, and actually
counts the CPU's by doing a readdir call. And it doesn't cache the
result, even though that particular result had better be 100% stable -
it has nothing to do with "online" vs "offline" etc.

But then for _SC_NPROCESSORS_ONLN, it doesn't actually use
/sys/devices/system/cpu at all, but the /proc/stat interface. Which is
slow, mostly because it has all the crazy interrupt stuff in it, but
also because it has lots of legacy stuff.

I wrote a _much_ cleaner routine (loosely based on what we do in
tools/prof) to just parse /sys/devices/system/cpu/online. I didn't
even time it, but I can almost guarantee that it's an order of
magnitude faster than /proc/stat. And if that doesn't work, you can
fall back on a cached version of the /proc/stat parsing, since if
those files don't exist, you can forget about CPU hotplug.

> So you mean caching it at startup time? Otherwise the parent would
> need to do sysconf() at least , which it doesn't do (the exim source does=
n't
> really know anything about libdb internals)

Even if you do it in the children, it will help. At least it would be
run just _once_ per fork.

But actually looking at glibc just shows that they are simply doing
stupid things. And I absolutely _refuse_ to add new interfaces to the
kernel only because glibc is being a moron.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
