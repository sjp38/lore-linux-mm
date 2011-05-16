Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF4C90011A
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:19:31 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GKo7a6023801
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:50:07 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GLJTIP128500
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:19:29 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GHJ8vM030188
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:19:09 -0300
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/3] checkpatch.pl: Add check for task comm references
Date: Mon, 16 May 2011 14:19:17 -0700
Message-Id: <1305580757-13175-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, Michal Nazarewicz <mina86@mina86.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Now that accessing current->comm needs to be protected,
avoid new current->comm or other task->comm usage by adding
a warning to checkpatch.pl.

Fair warning: I know zero perl, so this was written in the
style of "monkey see, monkey do". It does appear to work
in my testing though.

Thanks to Jiri Slaby and Michal Nazarewicz for help improving
the regex!

Close review and feedback would be appreciated.

CC: Ted Ts'o <tytso@mit.edu>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Jiri Slaby <jirislaby@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 scripts/checkpatch.pl |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index d867081..3a713c2 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2868,6 +2868,10 @@ sub process {
 			WARN("usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" . $herecurr);
 		}
 
+# check for current->comm usage
+		if ($line =~ /\b(?:current|task|tsk|t)\s*->\s*comm\b/) {
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
