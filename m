Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5546B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 00:08:25 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id l13so1703367iga.5
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 21:08:24 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0056.hostedemail.com. [216.40.44.56])
        by mx.google.com with ESMTP id g19si487679igz.43.2014.10.01.21.08.23
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 21:08:23 -0700 (PDT)
Message-ID: <1412222900.3247.33.camel@joe-AO725>
Subject: [PATCH] checkpatch: Warn on logging functions with KERN_<LEVEL>
From: Joe Perches <joe@perches.com>
Date: Wed, 01 Oct 2014 21:08:20 -0700
In-Reply-To: <20141001135055.c849d1a34e9c687775a40a0f@linux-foundation.org>
References: <1412195730-9629-1-git-send-email-paulmcquad@gmail.com>
	 <20141001135055.c849d1a34e9c687775a40a0f@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul McQuade <paulmcquad@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, neilb@suse.de, sasha.levin@oracle.com, rientjes@google.com, hughd@google.com, paul.gortmaker@windriver.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com

Warn on probable misuses of logging functions with KERN_<LEVEL>
like pr_err(KERN_ERR "foo\n");

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Joe Perches <joe@perches.com>

---
> > -		printk(KERN_ERR "ksm: register sysfs failed\n");
> > +		pr_err(KERN_ERR "ksm: register sysfs failed\n");

> A quick grep indicates that we have the same mistake in tens of places.
> checkpatch rule, please?

 scripts/checkpatch.pl | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 52a223e..374abf4 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4447,6 +4447,17 @@ sub process {
 			}
 		}
 
+# check for logging functions with KERN_<LEVEL>
+		if ($line !~ /printk\s*\(/ &&
+		    $line =~ /\b$logFunctions\s*\(.*\b(KERN_[A-Z]+)\b/) {
+			my $level = $1;
+			if (WARN("UNNECESSARY_KERN_LEVEL",
+				 "Possible unnecessary $level\n" . $herecurr) &&
+			    $fix) {
+				$fixed[$fixlinenr] =~ s/\s*$level\s*//;
+			}
+		}
+
 # check for bad placement of section $InitAttribute (e.g.: __initdata)
 		if ($line =~ /(\b$InitAttribute\b)/) {
 			my $attr = $1;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
