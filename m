Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2F5FC6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 07:28:36 -0400 (EDT)
Message-ID: <51669E5F.4000801@parallels.com>
Date: Thu, 11 Apr 2013 15:28:31 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 0/5] mm: Ability to monitor task memory changes (v3)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hello,

This is the implementation of the soft-dirty bit concept that should help
keep track of changes in user memory, which in turn is very-very required by
the checkpoint-restore project (http://criu.org). Let me briefly remind what
the issue is.

<< EOF
To create a dump of an application(s) we save all the information about it
to files, and the biggest part of such dump is the contents of tasks' memory.
However, there are usage scenarios where it's not required to get _all_ the
task memory while creating a dump. For example, when doing periodical dumps,
it's only required to take full memory dump only at the first step and then
take incremental changes of memory. Another example is live migration. We 
copy all the memory to the destination node without stopping all tasks, then
stop them, check for what pages has changed, dump it and the rest of the state,
then copy it to the destination node. This decreases freeze time significantly.

That said, some help from kernel to watch how processes modify the contents
of their memory is required.
EOF

The proposal is to track changes with the help of new soft-dirty bit this way:

1. First do "echo 4 > /proc/$pid/clear_refs".
   At that point kernel clears the soft dirty _and_ the writable bits from all 
   ptes of process $pid. From now on every write to any page will result in #pf 
   and the subsequent call to pte_mkdirty/pmd_mkdirty, which in turn will set
   the soft dirty flag.

2. Then read the /proc/$pid/pagemap2 and check the soft-dirty bit reported there
   (the 55'th one). If set, the respective pte was written to since last call
   to clear refs.

The soft-dirty bit is the _PAGE_BIT_HIDDEN one. Although it's used by kmemcheck,
the latter one marks kernel pages with it, while the former bit is put on user 
pages so they do not conflict to each other.

The set is against the v3.9-rc5.
It includes preparations to /proc/pid's clear_refs file, adds the pagemap2 one
and the soft-dirty concept itself with Andrew's comments on the previous patch 
(hopefully) fixed.


History of the set:

* Previous version of this patch, commented out by Andrew:
  http://lwn.net/Articles/546184/

* Pre-previous ftrace-based approach:
  http://permalink.gmane.org/gmane.linux.kernel.mm/91428

  This one was not nice, because ftrace could drop events so we might
  miss significant information about page updates.

  Another issue with it -- it was impossible to use one to watch arbitrary
  task -- task had to mark memory areas with madvise itself to make events
  occur.

  Also, program, that monitored the update events could interfere with 
  anyone else trying to mess with ftrace.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
