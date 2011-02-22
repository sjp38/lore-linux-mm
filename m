Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B4B648D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:40 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1M1ZWPw030991
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:35:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1M1rdKj479264
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:39 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1M1rcWm023017
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 18:53:38 -0700
Subject: [PATCH 0/5] fix up /proc/$pid/smaps to not split huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Feb 2011 17:53:38 -0800
Message-Id: <20110222015338.309727CA@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>

Andrew, these have gone through a couple of review rounds.  Can
they have a spin in -mm?

--

I'm working on some more reports that transparent huge pages and
KSM do not play nicely together.  Basically, whenever THP's are
present along with KSM, there is a lot of attrition over time,
and we do not see much overall progress keeping THP's around:

	http://sr71.net/~dave/ibm/038_System_Anonymous_Pages.png

(That's Karl Rister's graph, thanks Karl!)

However, I realized that we do not currently have a nice way to
find out where individual THP's might be on the system.  We
have an overall count, but no way of telling which processes or
VMAs they might be in.

I started to implement this in the /proc/$pid/smaps code, but
quickly realized that the lib/pagewalk.c code unconditionally
splits THPs up.  This set reworks that code a bit and, in the
end, gives you a per-map count of the numbers of huge pages.
It also makes it possible for page walks to _not_ split THPs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
