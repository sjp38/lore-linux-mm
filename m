Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D788F90010D
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:47:57 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4HKixkT014127
	for <linux-mm@kvack.org>; Tue, 17 May 2011 14:44:59 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4HKlnbE137528
	for <linux-mm@kvack.org>; Tue, 17 May 2011 14:47:49 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HKlmrm003452
	for <linux-mm@kvack.org>; Tue, 17 May 2011 14:47:49 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/3] checkpatch.pl: Add check for task comm references
Date: Tue, 17 May 2011 13:47:43 -0700
Message-Id: <1305665263-20933-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Now that accessing current->comm needs to be protected,
avoid new current->comm or other task->comm usage by adding
a warning to checkpatch.pl.

Fair warning: I know zero perl, so this was written in the
style of "monkey see, monkey do". It does appear to work
in my testing though.

Thanks to Jiri Slaby, Michal Nazarewicz and Joe Perches
for help improving the regex!

Close review and feedback would be appreciated.

CC: Joe Perches <joe@perches.com>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Andy Whitcroft <apw@canonical.com>
CC: Jiri Slaby <jirislaby@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 scripts/checkpatch.pl |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index d867081..a67ea69 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2868,6 +2868,13 @@ sub process {
 			WARN("usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" . $herecurr);
 		}
 
+# check for current->comm usage
+		our $common_comm_vars = qr{(?x:
+		        current|tsk|p|task|curr|chip|t|object|me
+		)};
+		if ($line =~ /\b($common_comm_vars)\s*->\s*comm\b/) {
+			WARN("comm access needs to be protected. Use get_task_comm, or printk's \%ptc formatting.\n" . $herecurr);
+		}
 # check for %L{u,d,i} in strings
 		my $string;
 		while ($line =~ /(?:^|")([X\t]*)(?:"|$)/g) {
-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
