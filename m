Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA07541
	for <linux-mm@kvack.org>; Wed, 8 Jul 1998 13:13:47 -0400
Date: Wed, 8 Jul 1998 14:45:49 +0100
Message-Id: <199807081345.OAA01509@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980707175139.18757A-100000@mirkwood.dummy.home>
References: <199807071201.NAA00934@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980707175139.18757A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 7 Jul 1998 17:54:46 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> There's a good compromize between balancing per-page
> and per-process. We can simply declare the last X
> (say 8) pages of a process holy unless that process
> has slept for more than Y (say 5) seconds.

Yep --- this is per-process RSS management, and there is a _lot_ we
can do once we start following this route.  I've been talking with
some folk about it already, and this is something we definitely want
to look into for 2.3.

For example, we can do both RSS limits (upper limits to RSS) plus RSS
quotas (a guaranteed lower limit which we allocate to the process).
Consider a machine where we have some very large processes thrashing
away; placing an RSS limit on those excessive processes will prevent
them from hogging all of physical memory, and giving interactive
processes a small guaranteed RSS quota will ensure that those
processes are allowed to make at least some progress even under severe
VM load.

The hard part is the self-tuning --- making sure that we don't give a
resident quota to idle processes, so that they can be fully swapped
out, and making sure that we don't overly trim back large processes
for which there is actually sufficient physical memory.  However, the
principle of RSS management is a powerful one and we should most
certainly be doing this for 2.3.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
