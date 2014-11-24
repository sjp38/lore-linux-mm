Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id E79316B00E5
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 15:06:34 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id a108so7206357qge.39
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:06:34 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id r10si16918479qck.17.2014.11.24.12.06.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 12:06:33 -0800 (PST)
Date: Mon, 24 Nov 2014 14:06:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [LSF/MM ATTEND] Expanding OS noise suppression
Message-ID: <alpine.DEB.2.11.1411241345250.10694@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-c@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Recently a lot of work has been done in the kernel to be able to keep OS
threads off low latency cores with the NOHZ work mainly pushed by Frederic
Weisbecker (also also Paul McKenney modifying RCU for that purpose). With
that approach we may now reduce the timer tick to a frequency of 1 per
second. The result of that work is now available in Redhat 7.

I have recently submitted work on the vmstat kworkers that makes the
kworkers run on demand with a shepherd worker checking from a non low
latency processor if there is actual work to be done on a processor in low
latency mode. If not then the kworker requests can be avoided and
therefore activities on that processor are reduced. This approach can be
extended to cover other necessary activities on low latency cores.

There is other work in progress to limit unbound kworker threads to no
NOHZ processors. Also more work is in flight to work on various issues in
the scheduler to enable us to hold off the timer tick for more than one
second.

There are numerous other issues that can impact on a low latency core from
the memory management system. I would like to discuss ways that we can
further ensure that OS activities do not impact latency critical threads
running on special nohz cores.

This may cover:
 - minor and major faults and how to suppress them effectively.
 - Processor cache impacts by sibling threads.
 - IPIs
 - Control over various subsystem specific per cpu threads.
 - Control impacts of scans for defragmentation and THP on these cores.

There was a recent discussion on the subject matter on lkml that mentions
a number of the pending issues in this area:

https://lkml.org/lkml/2014/11/11/679
https://lkml.org/lkml/2014/10/31/364

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
