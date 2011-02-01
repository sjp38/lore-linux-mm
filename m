Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 209078D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:06 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p110K3tT005429
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:20:03 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p110XwQQ245514
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:33:58 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p110Xwhj006148
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:33:58 -0700
Subject: [RFC][PATCH 0/6] more detailed per-process transparent hugepage statistics
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 31 Jan 2011 16:33:57 -0800
Message-Id: <20110201003357.D6F0BE0D@kernel>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
