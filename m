Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id B7A4B6B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 11:37:10 -0400 (EDT)
Date: Thu, 20 Sep 2012 16:37:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MMTests 0.05
Message-ID: <20120920153705.GQ11266@suse.de>
References: <20120907124232.GA11266@suse.de>
 <505AF81C.1080404@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <505AF81C.1080404@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 20, 2012 at 03:03:56PM +0400, Glauber Costa wrote:
> On 09/07/2012 04:42 PM, Mel Gorman wrote:
> > ./run-mmtests.sh test-run-1
> 
> Mel, would you share with us the command line and config tweaks you had
> in place to run the memcg tests you presented in the memcg summit?
> 

Apply the following patch to mmtests 0.05 and then from within the
mmtests directory do

./run-mmtests.sh testrun

At the very least you should have oprofile installed. Optionally install
libnuma-devel but the test will cope if it's not available. Automatic package
installation will be in 0.06 for opensuse at least but other distros can
be easily supported if I know the names of the equivalent packages.

The above command will run both with and without profiling. The profiles
will be in work/log/pft-testrun/fine-profile-timer/base/ and an annotated
profile will be included in the file. If you have "recode" installed the
annotated profile will be compressed and can be extracted with something like

grep -A 9999999 "=== annotate ===" oprofile-compressed.report | grep -v annotate | recode /b64..char | gunzip -c

Each of the memcg functions will be small but when all the functions that
are in mm/memcontrol.c are added together it becomes a big problem.  What I
actually showed at the meeting was based on piping the oprofile report
through another quick and dirty script to match functions to filenames.

The bulk of this patch is renaming  profile-disabled-hooks-a.sh to
profile-hooks-a.sh. Let me know if you run into problems.

---8<--
mmtests: Configure for PFT profile

Signed-off-by: Mel Gorman <mgorman@suse.de>

diff --git a/config b/config
index 184864f..e1afb2a 100644
--- a/config
+++ b/config
@@ -9,9 +9,9 @@ export SKIP_WARMUP=yes
 
 # Profiling parameters
 export SKIP_NOPROFILE=no
-export SKIP_FINEPROFILE=yes
+export SKIP_FINEPROFILE=no
 export SKIP_COARSEPROFILE=yes
-export OPROFILE_REPORT_ANNOTATE=no
+export OPROFILE_REPORT_ANNOTATE=yes
 
 # Fixups
 if [ "`which check-confidence.pl 2> /dev/null`" = "" ]; then
@@ -57,7 +57,7 @@ export SWAP_NBD_PORT=100`ifconfig eth0 | sed -n 2p | cut -d ":" -f2 | cut -d " "
 #export TESTDISK_NBD_PORT=100`ifconfig eth0 | sed -n 2p | cut -d ":" -f2 | cut -d " " -f1 | cut -d "." -f4`
 
 # List of monitors
-export RUN_MONITOR=yes
+export RUN_MONITOR=no
 export MONITORS_ALWAYS=
 export MONITORS_PLAIN=
 export MONITORS_GZIP="proc-vmstat top slabinfo"
diff --git a/profile-disabled-hooks-a.sh b/profile-disabled-hooks-a.sh
deleted file mode 100644
index c953dff..0000000
--- a/profile-disabled-hooks-a.sh
+++ /dev/null
@@ -1,48 +0,0 @@
-if [ "$SAMPLE_CYCLE_FACTOR" = "" ]; then
-	SAMPLE_CYCLE_FACTOR=1
-fi
-
-CALLGRAPH=0
-if [ "$OPROFILE_REPORT_CALLGRAPH" != "" ]; then
-	CALLGRAPH=$OPROFILE_REPORT_CALLGRAPH
-	if [ $SAMPLE_CYCLE_FACTOR -lt 15 ]; then
-		SAMPLE_CYCLE_FACTOR=15
-	fi
-fi
-
-# Create profiling hooks
-PROFILE_TITLE="timer"
-
-echo "#!/bin/bash" > monitor-pre-hook
-case `uname -m` in
-	i?86)
-		echo "oprofile_start.sh --callgraph $CALLGRAPH --sample-cycle-factor $SAMPLE_CYCLE_FACTOR --event timer" >> monitor-pre-hook
-		export PROFILE_EVENTS=timer
-		;;
-	x86_64)
-		echo "oprofile_start.sh --callgraph $CALLGRAPH --sample-cycle-factor $SAMPLE_CYCLE_FACTOR --event timer" >> monitor-pre-hook
-		export PROFILE_EVENTS=timer
-		;;
-	ppc64)
-		echo "oprofile_start.sh --callgraph $CALLGRAPH --sample-cycle-factor $SAMPLE_CYCLE_FACTOR --event timer" >> monitor-pre-hook
-		export PROFILE_EVENTS=timer
-		;;
-	*)
-		echo Unrecognised architecture
-		exit -1
-		;;
-esac
-
-echo "#!/bin/bash" > monitor-post-hook
-echo "opcontrol --dump" >> monitor-post-hook
-echo "opcontrol --stop" >> monitor-post-hook
-echo "oprofile_report.sh > \$1/oprofile-\$2-report-$PROFILE_TITLE.txt" >> monitor-post-hook
-
-echo "#!/bin/bash" > monitor-cleanup-hook
-echo "rm \$1/oprofile-\$2-report-$PROFILE_TITLE.txt" >> monitor-cleanup-hook
-
-echo "#!/bin/bash" > monitor-reset
-echo "opcontrol --stop   > /dev/null 2> /dev/null" >> monitor-reset
-echo "opcontrol --deinit > /dev/null 2> /dev/null" >> monitor-reset
-
-chmod u+x monitor-*
diff --git a/profile-hooks-a.sh b/profile-hooks-a.sh
new file mode 100644
index 0000000..c953dff
--- /dev/null
+++ b/profile-hooks-a.sh
@@ -0,0 +1,48 @@
+if [ "$SAMPLE_CYCLE_FACTOR" = "" ]; then
+	SAMPLE_CYCLE_FACTOR=1
+fi
+
+CALLGRAPH=0
+if [ "$OPROFILE_REPORT_CALLGRAPH" != "" ]; then
+	CALLGRAPH=$OPROFILE_REPORT_CALLGRAPH
+	if [ $SAMPLE_CYCLE_FACTOR -lt 15 ]; then
+		SAMPLE_CYCLE_FACTOR=15
+	fi
+fi
+
+# Create profiling hooks
+PROFILE_TITLE="timer"
+
+echo "#!/bin/bash" > monitor-pre-hook
+case `uname -m` in
+	i?86)
+		echo "oprofile_start.sh --callgraph $CALLGRAPH --sample-cycle-factor $SAMPLE_CYCLE_FACTOR --event timer" >> monitor-pre-hook
+		export PROFILE_EVENTS=timer
+		;;
+	x86_64)
+		echo "oprofile_start.sh --callgraph $CALLGRAPH --sample-cycle-factor $SAMPLE_CYCLE_FACTOR --event timer" >> monitor-pre-hook
+		export PROFILE_EVENTS=timer
+		;;
+	ppc64)
+		echo "oprofile_start.sh --callgraph $CALLGRAPH --sample-cycle-factor $SAMPLE_CYCLE_FACTOR --event timer" >> monitor-pre-hook
+		export PROFILE_EVENTS=timer
+		;;
+	*)
+		echo Unrecognised architecture
+		exit -1
+		;;
+esac
+
+echo "#!/bin/bash" > monitor-post-hook
+echo "opcontrol --dump" >> monitor-post-hook
+echo "opcontrol --stop" >> monitor-post-hook
+echo "oprofile_report.sh > \$1/oprofile-\$2-report-$PROFILE_TITLE.txt" >> monitor-post-hook
+
+echo "#!/bin/bash" > monitor-cleanup-hook
+echo "rm \$1/oprofile-\$2-report-$PROFILE_TITLE.txt" >> monitor-cleanup-hook
+
+echo "#!/bin/bash" > monitor-reset
+echo "opcontrol --stop   > /dev/null 2> /dev/null" >> monitor-reset
+echo "opcontrol --deinit > /dev/null 2> /dev/null" >> monitor-reset
+
+chmod u+x monitor-*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
