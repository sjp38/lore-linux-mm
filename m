Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BEF588D0041
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 10:39:00 -0500 (EST)
Date: Tue, 1 Feb 2011 16:38:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent
 hugepage statistics
Message-ID: <20110201153857.GA18740@random.random>
References: <20110201003357.D6F0BE0D@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110201003357.D6F0BE0D@kernel>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 04:33:57PM -0800, Dave Hansen wrote:
> I'm working on some more reports that transparent huge pages and
> KSM do not play nicely together.  Basically, whenever THP's are
> present along with KSM, there is a lot of attrition over time,
> and we do not see much overall progress keeping THP's around:
> 
> 	http://sr71.net/~dave/ibm/038_System_Anonymous_Pages.png
> 
> (That's Karl Rister's graph, thanks Karl!)

Well if the pages_sharing/pages_shared count goes up, this is a
feature not a bug.... You need to print that too in the chart to show
this is not ok.

KSM will slowdown performance also during copy-on-writes when
pages_sharing goes up, not only because of creating non-linearity
inside 2m chunks (which makes mandatory to use ptes and not hugepmd,
it's not an inefficiency of some sort that can be optimized away
unfortunately). We sure could change KSM to merge 2M pages instead of
4k pages, but then the memory-density would decrease of several order
of magnitudes making the KSM scan almost useless (ok, with guest
heavily using THP that may change, but all pagecache is still 4k... so
for now it'd be next to useless).

I'm in the process of adding a no-ksm option to qemu-kvm command line
so you can selectively choose which VM runs with KSM or not (otherwise
you can switch ksm off globally to be sure not to degrade
performance).

> However, I realized that we do not currently have a nice way to find
> out where individual THP's might be on the system.  We have an
> overall count, but no way of telling which processes or VMAs they
> might be in.
> 
> I started to implement this in the /proc/$pid/smaps code, but
> quickly realized that the lib/pagewalk.c code unconditionally
> splits THPs up.  This set reworks that code a bit and, in the
> end, gives you a per-map count of the numbers of huge pages.
> It also makes it possible for page walks to _not_ split THPs.

That's something in the TODO list indeed thanks a lot for working on
this (I think we discussed this earlier too).

I would prefer to close the issues that you just previously reported,
sometime with mmap_sem and issues like that, before adding more
features though but I don't want to defer things either so it's up to
you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
