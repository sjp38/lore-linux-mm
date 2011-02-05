Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2D28D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 19:10:02 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p1509xLN011165
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 16:09:59 -0800
Received: from vws14 (vws14.prod.google.com [10.241.21.142])
	by wpaz37.hot.corp.google.com with ESMTP id p1509tTF024464
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 16:09:58 -0800
Received: by vws14 with SMTP id 14so1904355vws.23
        for <linux-mm@kvack.org>; Fri, 04 Feb 2011 16:09:57 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 4 Feb 2011 16:09:57 -0800
Message-ID: <AANLkTi=bMvdnxJOJTsNpg=KCSG40cgDkx+ZMPXXJh8UN@mail.gmail.com>
Subject: [LSF/MM TOPIC] Kernel memory tracking in memcg
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linuxfoundation.org
Cc: linux-mm@kvack.org

Hi,

Currently, memcg only tracks user memory.

However, some workloads can cause heavy kernel memory use (for
example, when doing a lot of network I/O), which would ideally be
counted towards the limit in memory cgroup.

Without this, memory isolation could be damaged, as one cgroup using a
lot of kernel memory could penalize other cgroups by causing global
reclaim on the machine.

Things that could potentially be discussed:
- Should all kinds of kernel allocations be accounted (get_free_pages,
slab, vmalloc)?
- Should every allocation done in a process context be accounted?
- Should kernel memory be counted towards the memcg limit, or should a
different limit be used?
- Implementation.

Is this worth discussing?

[ My initial thoughts on the issue: Slab makes for the bulk of kernel
allocations, and any solution would need a slab component, so it's a
good starting point.
Also, most kernel allocations in process context belong to that
process (although there are some exceptions), so it should be mostly
ok to account every allocation in process context.
For slab, we can do tracking per slab (instead of per-object), by
making sure objects from a slab are only used by one cgroup. ]

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
