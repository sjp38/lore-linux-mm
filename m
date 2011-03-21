Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2A1A98D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 10:09:12 -0400 (EDT)
Date: Mon, 21 Mar 2011 15:08:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: sysfs interface to transparent hugepages
Message-ID: <20110321140812.GD5719@random.random>
References: <1300676431.26693.317.camel@localhost>
 <20110321124203.GB5719@random.random>
 <1300713183.26693.343.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1300713183.26693.343.camel@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Mon, Mar 21, 2011 at 01:13:03PM +0000, Ben Hutchings wrote:
> You have tristates {never, madvise, always} for various THM features.
> Internally, these are represented as a pair of flags.  They are exposed
> through sysfs as tristates, but then they are also exposed as flags.

They must be bitflags for performance and cacheline saving reasons in
the kernel (1 bitflag not enough in kernel for a userland
tristate). They're more intuitive as tristate in the same file for the
user to set (some combination of these flags is forbidden so exposing
the flags to the user doesn't sound good idea, also considering it's
an internal representation which may change, keeping the two separated
is best, especially if you want your current lib not to break).

There is no expectation however that you have to alter any of these
settings even in server environment other than for debugging purposes:
with the exception of: 1) pages_to_scan, 2) scan_sleep_millisecs 3)
alloc_sleep_millisecs inside the khugepaged dir, and those three are
in a format that your current sysfs lib will mangle just fine.

If you've a lib that pretends to turn off THP as root, you may as well
handle the cfq/deadline I/O scheduler switch in the same lib. Not
really sure if your effort is worth it considering it will slightly
complicate things in shell usage for debug purposes (I'd find more
intuitive if also cpufreq governors were shown and selected like io
schedulers).

But again I'm fully neutral on issues like these as long as the
patches don't break anything I'm surely fine if others like your
changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
