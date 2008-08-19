Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7J7Hed3020004
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 17:17:40 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7J7INVE215964
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 17:18:23 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7J7IMu1006347
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 17:18:22 +1000
Message-ID: <48AA73B5.7010302@linux.vnet.ibm.com>
Date: Tue, 19 Aug 2008 12:48:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [discuss] memrlimit - potential applications that can use
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

After having discussed memrlimit at the container mini-summit, I've been
investigating potential users of memrlimits. Here are the use cases that I have
so far.

1. To provide a soft landing mechanism for applications that exceed their memory
limit. Currently in the memory resource controller, we swap and on failure OOM.
2. To provide a mechanism similar to memory overcommit for control groups.
Overcommit has finer accounting, we just account for virtual address space usage.
3. Vserver will directly be able to port over on top of memrlimit (their address
space limitation feature)

The case against 1 has been that applications, do not tolerate malloc failure,
does not imply that applications should not have the capability or will never be
allowed the flexibility of doing so

Other users of memory limits I found are

1. php - through php.ini allows setting of maximum memory limit
2. Apache - supports setting of memory limits for child processes (RLimitMEM
Directive)
3. Java/KVM all take hints about the maximum memory to be used by the application
4. google.com/codesearch for RLIMIT_AS will show up a big list of applications
that use memory limits.

With this background, I propose that we need a mechanism of providing a memory
overcommit feature for cgroups, the options are

1. We keep memrlimit and use it. It's very flexible, but on the down side it
does simple total_vm based accounting and provides functionality similar to
RLIMIT_AS for control groups.
2. We port the overcommit feature (Andrea did post patches for this), it's
harder to implement, but provides functionality similar to what exists for
overcommit.


Comments?

-- 
	Warm Regards,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
