Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBE46B0023
	for <linux-mm@kvack.org>; Thu, 12 May 2011 19:03:02 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4CMpcFb028843
	for <linux-mm@kvack.org>; Thu, 12 May 2011 16:51:38 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4CN4AO4101184
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:04:10 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4CH2trc002543
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:02:55 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/3] checkpatch.pl: Add check for current->comm references
Date: Thu, 12 May 2011 16:02:51 -0700
Message-Id: <1305241371-25276-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Now that accessing current->comm needs to be protected,
avoid new current->comm usage by adding a warning to
checkpatch.pl.

Fair warning: I know zero perl, so this was written in the
style of "monkey see, monkey do". It does appear to work
in my testing though.

Close review and feedback would be appreciated.

CC: Ted Ts'o <tytso@mit.edu>
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
index d867081..9d2eab5 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2868,6 +2868,10 @@ sub process {
 			WARN("usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" . $herecurr);
 		}
 
+# check for current->comm usage
+		if ($line =~ /current->comm/) {
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
