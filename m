Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24EAB900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 20:18:10 -0400 (EDT)
Message-ID: <4E695B3D.7060804@hp.com>
Date: Thu, 08 Sep 2011 17:18:05 -0700
From: Rick Jones <rick.jones2@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1315276556-10970-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/05/2011 07:35 PM, Glauber Costa wrote:
> To test for any performance impacts of this patch, I used netperf's
> TCP_RR benchmark on localhost, so we can have both recv and snd in action.
>
> Command line used was ./src/netperf -t TCP_RR -H localhost, and the
> results:
>
> Without the patch
> =================
>
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 16384  87380  1        1       10.00    26996.35
> 16384  87380
>
> With the patch
> ===============
>
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 16384  87380  1        1       10.00    27291.86
> 16384  87380

Comment about netperf TCP_RR - it can often have > 1% variability, so it 
would be a Good Idea (tm) to either run it multiple times in a row, or 
rely on the confidence intervals functionality.  Here, for example, is 
an invoking of netperf using confidence intervals and the recently 
added, related output selectors.  The options request that netperf be 
99% confident that the width of the confidence interval is 1%, and it 
should run at least 3 but no more than 30 (those are both the high and 
low limits respectively) iterations of the test.


raj@tardy:~/netperf2_trunk$ src/netperf -t TCP_RR -i 30,3 -I 99,1 -- -k 
throughput,confidence_level,confidence_interval,confidence_iteration,throughput_confid
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to localhost.localdomain (127.0.0.1) port 0 AF_INET : +/-0.500% @ 99% 
conf.  : histogram : first burst 0
THROUGHPUT=55555.94
CONFIDENCE_LEVEL=99
CONFIDENCE_INTERVAL=1.000000
CONFIDENCE_ITERATION=26
THROUGHPUT_CONFID=0.984

it took 26 iterations for netperf to be 99% confident the interval width 
was < 1% .  Here is a "several times in a row" for the sake of completeness:

raj@tardy:~/netperf2_trunk$ HDR="-P 1";for i in `seq 1 10`; do netperf 
-t TCP_RR $HDR -B "iteration $i" -- -o result_brand,throughput; HDR="-P 
0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to localhost.localdomain (127.0.0.1) port 0 AF_INET : first burst 0
Result Tag,Throughput
"iteration 1",55768.37
"iteration 2",55949.97
"iteration 3",55653.36
"iteration 4",55994.65
"iteration 5",54712.42
"iteration 6",55285.27
"iteration 7",55638.65
"iteration 8",55135.56
"iteration 9",56275.87
"iteration 10",55607.66

That way one can have greater confidence that one isn't accidentally 
comparing the trough of one configuration with the peak of another.

happy benchmarking,

rick jones

PS - while it may not really matter for loopback testing, where 
presumably 99 times out of 10 a single core will run at saturation, when 
running TCP_RR over a "real" network, including CPU utilization to get 
the differences in service demand is another Good Idea (tm) - 
particularly in the face of interrupt coalescing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
