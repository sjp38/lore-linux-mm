Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 57C626B002E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:55:52 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9DKtoQR016682
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:55:50 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz29.hot.corp.google.com with ESMTP id p9DKnEs3017195
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:55:48 -0700
Received: by pzk33 with SMTP id 33so5492635pzk.8
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:55:48 -0700 (PDT)
Date: Thu, 13 Oct 2011 13:55:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1110131351270.24853@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
 <20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, hannes@cmpxchg.org

On Thu, 13 Oct 2011, KAMEZAWA Hiroyuki wrote:

> sys_mem_shrink(int nid, int nr_scan_pages, int flags)
> 
> This system call scans LRU of specified nodes and free pages on LRU.
> This scan nr_scan_pages in LRU and returns the number of successfully
> freed pages.
> ==
> 
> Then, running this progam in SCHED_IDLE, a user can make free pages while
> the system is idle. If running in the highest priority, a user can keep
> free pages as he want. If a user run this under a memcg, user can free
> pages in a memcg. 
> 

Satoru was specifically talking about the VM using free memory for 
pagecache, so doing echo echo 1 > /proc/sys/vm/drop_caches can mitigate 
that almost immediately.  I think the key to the discussion, though, is 
that even the application doesn't know it's bursty memory behavior before 
it happens and the kernel entering direct reclaim hurts latency-sensitive 
applications.

If there were a change to increase the space significantly between the 
high and min watermark when min_free_kbytes changes, that would fix the 
problem.  The problem is two-fold: that comes at a penalty for systems 
or workloads that don't need to reclaim the additional memory, and it's 
not clear how much space should exist between those watermarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
