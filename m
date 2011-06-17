Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C93B76B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:24:06 -0400 (EDT)
Message-ID: <4DFA9EA4.4010904@linux.intel.com>
Date: Thu, 16 Jun 2011 17:24:04 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com> <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK> <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com> <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins> <87ea4bd7-8b16-4b24-8fcb-d8e9b6f421ec@email.android.com> <4DF92FE1.5010208@linux.intel.com> <BANLkTi=Tw6je7zpi4L=pE0JJpZfeEC9Jsg@mail.gmail.com> <4DFA6442.9000103@linux.intel.com> <BANLkTin_46==epHKUbWJ55bt3mPaJieV2Q@mail.gmail.com>
In-Reply-To: <BANLkTin_46==epHKUbWJ55bt3mPaJieV2Q@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------030601030204070203060001"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

This is a multi-part message in MIME format.
--------------030601030204070203060001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


> The fact is, glibc is just total crap.
>
> I tried to send uli a patch to just add caching. No go. I sent
> *another* patch to at least make glibc use a sane interface (and the
> cache if it needs to fall back on /proc/stat for some legacy reason).
> We'll see what happens.

FWIW a rerun with this modified LD_PRELOAD that does caching seems
to have the same performance as the version that does sched_getaffinity.

So you're right. Caching indeed helps and my assumption that the child
would only do it once was incorrect.

The only problem I see with it is that it doesn't handle CPU hotplug,
but Paul's suggestion would fix that too.

> Paul Eggbert suggested "caching for one second" - by just calling
> "gettimtofday()" to see how old the cache is. That would work too.
>

Maybe we need a "standard LD_PRELOAD library to improve glibc" @)

-Andi


--------------030601030204070203060001
Content-Type: text/plain;
 name="sysconf-caching.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="sysconf-caching.c"

// gcc -fPIC -shared sysconf-caching.c -ldl  -o sysconf-caching.so
#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <sched.h>
#include <unistd.h>

static long int (*real_sysconf)(int name);

long int sysconf(int name)
{
	if (!real_sysconf) 
		real_sysconf = dlsym(RTLD_NEXT, "sysconf");

	if (name == _SC_NPROCESSORS_ONLN) {
		static int cache = -1; 

		if (cache == -1)
			cache = real_sysconf( _SC_NPROCESSORS_ONLN);
		return cache;
	}

	return real_sysconf(name);
}


--------------030601030204070203060001--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
