Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F40966B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 11:21:17 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so451254fgg.4
        for <linux-mm@kvack.org>; Thu, 26 Feb 2009 08:21:15 -0800 (PST)
Date: Thu, 26 Feb 2009 19:27:56 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090226162755.GB1456@x200.localdomain>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1234479845.30155.220.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, mingo@elte.hu, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Regarding interactions of C/R with other code:

1. trivia
1a. field in some datastructure is removed

	technically, compilation breaks

	Need to decide what to do -- from trivial compile fix
	by removing code to ignoring some fields in dump image.

1b. field is added

	This is likely to happen silently, so maintainers
	will have to keep an eye on critical data structures
	and general big changes in core kernel.

	Need to decide what to do with new field --
	anything from 'doesn't matter' to 'yeah, needs C/R part'
	with dump format change.

2. non-trivia
2a. standalone subsystem added (say, network protocol)

    If submitter sends C/R part -- excellent.
    If he doesn't, well, don't forget to add tiny bit of check
	and abort if said subsystem is in use.

2b. massacre inside some subsystem (say, struct cred introduction)

	Likely, C/R non-trivially breaks both in compilation and
	in working, requires non-trivial changes in algorithms and in
	C/R dump image.

For some very core data structures dump file images should be made
fatter than needed to more future-proof, like
a) statistics in u64 regardless of in-kernel width.
b) ->vm_flags in image should be at least u64 and bits made append-only
	so dump format would survive flags addition, removal and
	renumbering.
and so on.



So I guess, at first C/R maintainers will take care of all of these issues
with default policy being 'return -E, implement C/R later',
but, ideally, C/R will have same rights as other kernel subsystem, so people
will make non-trivial changes in C/R as they make their own non-trivial
changes.

If last statement isn't acceptable, in-kernel C/R is likely doomed from
the start (especially given lack of in-kernel testsuite).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
