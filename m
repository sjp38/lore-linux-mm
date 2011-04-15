Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1829E900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:38:24 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FHHHlv028864
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:17:17 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FHcMYX235262
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:38:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FHcLTW018024
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:38:21 -0400
Subject: [RFC][PATCH 0/3] track pte pages and use in OOM score
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 15 Apr 2011 10:38:21 -0700
Message-Id: <20110415173821.62660715@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>

PTE pages are a relatively invisible memory user.  Neither users
nor the kernel have any way of telling how many of them any given
application is using.  Nefarious applications can also
potentially tie up lagre amounts of memory in them:

	foo = malloc(big);
	touch(foo);
	madvise(foo, big, MADV_DONTNEED);

That'll leave you with no RSS for "foo", but the pagetable pages
will still be there.  Do that enough times, and you can
potentially harm the system.  Even worse, the OOM killer will not
necessarily go after such an application since the kernel has no
record of the pages.

For the containers and OpenVZ folks, pte pages are one of the
main consumers of kernel memory.  They should be able to use this
code as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
