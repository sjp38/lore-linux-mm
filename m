Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32D716B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 09:48:22 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q128so347201608qkd.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 06:48:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o22si17453093qta.236.2016.12.08.06.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 06:48:21 -0800 (PST)
Date: Thu, 8 Dec 2016 15:48:13 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161208154813.5dafae7b@redhat.com>
In-Reply-To: <20161208110656.bnkvqg73qnjkehbc@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
	<1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
	<20161207194801.krhonj7yggbedpba@techsingularity.net>
	<1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
	<20161207211958.s3ymjva54wgakpkm@techsingularity.net>
	<20161207232531.fxqdgrweilej5gs6@techsingularity.net>
	<20161208092231.55c7eacf@redhat.com>
	<20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
	<20161208114308.1c6a424f@redhat.com>
	<20161208110656.bnkvqg73qnjkehbc@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, brouer@redhat.com

On Thu, 8 Dec 2016 11:06:56 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Thu, Dec 08, 2016 at 11:43:08AM +0100, Jesper Dangaard Brouer wrote:
> > > That's expected. In the initial sniff-test, I saw negligible packet loss.
> > > I'm waiting to see what the full set of network tests look like before
> > > doing any further adjustments.  
> > 
> > For netperf I will not recommend adjusting the global default
> > /proc/sys/net/core/rmem_default as netperf have means of adjusting this
> > value from the application (which were the options you setup too low
> > and just removed). I think you should keep this as the default for now
> > (unless Eric says something else), as this should cover most users.
> >   
> 
> Ok, the current state is that buffer sizes are only set for netperf
> UDP_STREAM and only when running over a real network. The values selected
> were specific to the network I had available so milage may vary.
> localhost is left at the defaults.

Looks like you made a mistake when re-implementing using buffer sizes
for netperf. See patch below signature.

Besides I think you misunderstood me, you can adjust:
 sysctl net.core.rmem_max
 sysctl net.core.wmem_max

And you should if you plan to use/set 851968 as socket size for UDP
remote tests, else you will be limited to the "max" values (212992 well
actually 425984 2x default value, for reasons I cannot remember)


https://github.com/gormanm/mmtests/commit/de9f8cdb7146021
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

[PATCH] mmtests: actually use variable SOCKETSIZE_OPT

From: Jesper Dangaard Brouer <brouer@redhat.com>

commit 7f16226577b2 ("netperf: Set remote and local socket max buffer
sizes") removed netperf's setting of the socket buffer sizes and
instead used global /proc/sys settings.

commit de9f8cdb7146 ("netperf: Only adjust socket sizes for
UDP_STREAM") re-added explicit netperf setting socket buffer sizes for
remote-host testing (saved in SOCKETSIZE_OPT). Only problem is this
variable is not used after commit 7f16226577b2.

Simply use $SOCKETSIZE_OPT when invoking netperf command.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 shellpack_src/src/netperf/netperf-bench |    2 +-
 shellpacks/shellpack-bench-netperf      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/shellpack_src/src/netperf/netperf-bench b/shellpack_src/src/netperf/netperf-bench
index 8e7d02864c4a..b2820610936e 100755
--- a/shellpack_src/src/netperf/netperf-bench
+++ b/shellpack_src/src/netperf/netperf-bench
@@ -93,7 +93,7 @@ mmtests_server_ctl start --serverside-name $PROTOCOL-$SIZE
 		-t $PROTOCOL \
 		-i 3,3 -I 95,5 \
 		-H $SERVER_HOST \
-		-- $MSGSIZE_OPT $EXTRA \
+		-- $SOCKETSIZE_OPT $MSGSIZE_OPT $EXTRA \
 			2>&1 | tee $LOGDIR_RESULTS/$PROTOCOL-${SIZE}.$ITERATION \
 			|| die Failed to run netperf
 	monitor_post_hook $LOGDIR_RESULTS $SIZE
diff --git a/shellpacks/shellpack-bench-netperf b/shellpacks/shellpack-bench-netperf
index 2ce26ba39f1b..7356082d5a78 100755
--- a/shellpacks/shellpack-bench-netperf
+++ b/shellpacks/shellpack-bench-netperf
@@ -190,7 +190,7 @@ for ITERATION in `seq 1 $ITERATIONS`; do
 		-t $PROTOCOL \
 		-i 3,3 -I 95,5 \
 		-H $SERVER_HOST \
-		-- $MSGSIZE_OPT $EXTRA \
+		-- $SOCKETSIZE_OPT $MSGSIZE_OPT $EXTRA \
 			2>&1 | tee $LOGDIR_RESULTS/$PROTOCOL-${SIZE}.$ITERATION \
 			|| die Failed to run netperf
 	monitor_post_hook $LOGDIR_RESULTS $SIZE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
