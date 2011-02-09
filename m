Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADF2E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 14:54:59 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p19JSWtH030044
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 14:28:56 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A0D50728047
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 14:54:07 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p19Js725290876
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 14:54:07 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p19Js7Ei001884
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 14:54:07 -0500
Subject: [PATCH 0/5] fix up /proc/$pid/smaps to not split huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 09 Feb 2011 11:54:06 -0800
Message-Id: <20110209195406.B9F23C9F@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>

Andrea, after playing with this for a week or two, I'm quite a bit
more confident that it's not causing much harm.  Seems a fairly
low-risk feature.  Could we stick these somewhere so they'll at
least hit linux-next for the 2.6.40 cycle perhaps?

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
