Received: from bolivar.varner.com (root@bolivar.varner.com [208.236.160.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA22752
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 13:47:13 -0400
Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by bolivar.varner.com (8.8.5/8.8.5) with ESMTP id MAA00606
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 12:47:15 -0500 (CDT)
Subject: Re: Linux wppage patch (fwd)
References: <Pine.LNX.3.96.980626073357.2529L-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 30 Jun 1998 12:59:11 -0500
In-Reply-To: Rik van Riel's message of Fri, 26 Jun 1998 07:34:10 +0200 (CEST)
Message-ID: <m1ww9y7ouo.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Jason Crawford <jasonc@cacr.caltech.edu>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "JC" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

JC> ---------- Forwarded message ----------
JC> Date: Thu, 25 Jun 1998 21:10:00 -0700 (PDT)
JC> From: Jason Crawford <jasonc@cacr.caltech.edu>
JC> To: h.h.vanriel@phys.uu.nl
JC> Subject: Linux wppage patch

JC> 2. Make a slight change to the way the custom nopage routine is called.
JC> The third argument to nopage is declared as "write_access" in the
JC> definition of the VM operations struct in mm.h. But when it's called, it
JC> is actually "no_share", computed as:

JC> 	(vma->vm_flags & VM_SHARED) ? 0 : write_access

JC> My code, however, needs to know whether the access was a write even
JC> though it is shared memory, so I would like to change this argument to
JC> just "write_access". Since the VMA is passed in to the routine anyway,
JC> the VM flags will be available, and any routine which wants to calculate
JC> "no_share" can do so. Again, I searched the Linux source tree, and only
JC> the generic filemap_nopage routine uses the no_share argument. It can
JC> easily be changed to accept "write_access" instead of "no_share" and
JC> calculate "no_share" before it does any work.

Your code basically looks reasonable but there is a potential gotcha
in the works.

Shared pages are never write protected by the nopage routine so you
will never discover if a shared page has been written too...

Which could cause all kinds of havoc for distrubuted shared memory.

Eric
