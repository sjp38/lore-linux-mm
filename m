Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id BFDB86B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 18:41:32 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so3032792wib.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 15:41:30 -0800 (PST)
Date: Thu, 22 Dec 2011 03:41:26 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: Android low memory killer vs. memory pressure notifications
Message-ID: <20111221234126.GA14610@oksana.dev.rtsoft.ru>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
 <20111219121255.GA2086@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com>
 <20111220145654.GA26881@oksana.dev.rtsoft.ru>
 <alpine.DEB.2.00.1112201322170.22077@chino.kir.corp.google.com>
 <20111221002853.GA11504@oksana.dev.rtsoft.ru>
 <4EF132EA.7000300@am.sony.com>
 <20111221020723.GA5214@oksana.dev.rtsoft.ru>
 <4EF144D1.2020807@am.sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4EF144D1.2020807@am.sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Rowand <frank.rowand@am.sony.com>
Cc: "Rowand, Frank" <Frank_Rowand@sonyusa.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "tbird20d@gmail.com" <tbird20d@gmail.com>

On Tue, Dec 20, 2011 at 06:30:41PM -0800, Frank Rowand wrote:
> >> And for embedded and for real-time, some of us do not want cgroups to be
> >> a mandatory thing.  We want it to remain configurable.  My personal
> >> interest is in keeping the latency of certain critical paths (especially
> >> in the scheduler) short and consistent.
> > 
> > Much thanks for your input! That would be quite strong argument for going
> > with /dev/mem_notify approach. Do you have any specific numbers how cgroups
> > makes scheduler latencies worse?
> 
> Sorry, I don't have specific numbers.  And the numbers would be workload
> specific anyway.

OK, here are some numbers I captured using rt-tests suite.

I don't see any huge latency drops w/ cyclictest, but there is ~8% drop
in hackbench. Might be interesting to cgroups folks?

Kernel config, w/ preempt and only minimal options enabled for mem_cg:
http://ix.io/22w

rt-tests: https://github.com/clrkwllms/rt-tests.git

- - - - - test script
#!/bin/sh
echo cyclic
for i in `seq 1 3`; do ./cyclictest  -l 50000 -q ; done
echo signal
for i in `seq 1 3`; do ./signaltest  -l 30000 -q ; done
echo hackbench
for i in `seq 1 3`; do ./hackbench -l 1000 | grep Time ; done
- - - - -

I run this script inside a QEMU KVM guest on a idling host. The host's
cpufreq governor is set to powersave (so that's effectively becomes a
800 MHz machine). I can re-run this on a real HW, but I don't think
that results would differ significantly.


Results:

bzImage_nocgroups_nopreempt
---------------------------
cyclic
T: 0 ( 2240) P: 0 I:1000 C:  50000 Min:     46 Act:  228 Avg:  226 Max:    5693
T: 0 ( 2242) P: 0 I:1000 C:  50000 Min:     57 Act:  234 Avg:  244 Max:    9041
T: 0 ( 2244) P: 0 I:1000 C:  50000 Min:     47 Act:  246 Avg:  227 Max:    6612
signal
T: 0 ( 2247) P: 0 C:  30000 Min:      5 Act:    5 Avg:    6 Max:     236
T: 1 ( 2248) P: 0 C:  30000 Min:      5 Act:    5 Avg:  645 Max:   11719
T: 0 ( 2250) P: 0 C:  30000 Min:      6 Act:    6 Avg:    7 Max:     248
T: 1 ( 2251) P: 0 C:  30000 Min:      6 Act:    6 Avg:  647 Max:   14581
T: 0 ( 2253) P: 0 C:  30000 Min:      5 Act:    5 Avg:    7 Max:     210
T: 1 ( 2254) P: 0 C:  30000 Min:      5 Act:    6 Avg:  646 Max:   13892
hackbench
Time: 14.940
Time: 14.883
Time: 14.959

bzImage_cgroups_nopreempt:
--------------------------
cyclic
T: 0 (  963) P: 0 I:1000 C:  50000 Min:     52 Act:  248 Avg:  235 Max:    6497
T: 0 (  965) P: 0 I:1000 C:  50000 Min:     55 Act:  230 Avg:  228 Max:   10438
T: 0 (  967) P: 0 I:1000 C:  50000 Min:     51 Act:  173 Avg:  183 Max:    4396
signal
T: 0 (  970) P: 0 C:  30000 Min:      5 Act:    5 Avg:    6 Max:      98
T: 1 (  971) P: 0 C:  30000 Min:      5 Act:    5 Avg:  646 Max:   13654
T: 0 (  973) P: 0 C:  30000 Min:      5 Act:    5 Avg:    6 Max:     150
T: 1 (  974) P: 0 C:  30000 Min:      5 Act:    5 Avg:  646 Max:   10560
T: 0 (  976) P: 0 C:  30000 Min:      5 Act:    5 Avg:    6 Max:     107
T: 1 (  977) P: 0 C:  30000 Min:      5 Act:    5 Avg:  646 Max:   13453
hackbench
Time: 15.857
Time: 15.745
Time: 15.588

bzImage_cgroups_preempt:
------------------------
cyclic
T: 0 (  986) P: 0 I:1000 C:  50000 Min:     50 Act:  278 Avg:  239 Max:    8259
T: 0 (  988) P: 0 I:1000 C:  50000 Min:     53 Act:  236 Avg:  228 Max:    3565
T: 0 (  990) P: 0 I:1000 C:  50000 Min:     76 Act:  242 Avg:  238 Max:    3902
signal
T: 0 (  993) P: 0 C:  30000 Min:      6 Act:    6 Avg:    7 Max:     102
T: 1 (  994) P: 0 C:  30000 Min:      6 Act:    6 Avg:  646 Max:   10683
T: 0 (  996) P: 0 C:  30000 Min:      6 Act:    6 Avg:    7 Max:     129
T: 1 (  997) P: 0 C:  30000 Min:      6 Act:    6 Avg:  647 Max:   10973
T: 0 (  999) P: 0 C:  30000 Min:      6 Act:   43 Avg:    7 Max:      95
T: 1 ( 1000) P: 0 C:  30000 Min:      6 Act:   44 Avg:  646 Max:   10552
hackbench
Time: 15.632
Time: 15.221
Time: 15.443

bzImage_nocgroups_preempt:
--------------------------
cyclic
T: 0 (  974) P: 0 I:1000 C:  50000 Min:     50 Act:  268 Avg:  258 Max:    8324
T: 0 (  976) P: 0 I:1000 C:  50000 Min:     61 Act:  185 Avg:  183 Max:    2998
T: 0 (  978) P: 0 I:1000 C:  50000 Min:     55 Act:  234 Avg:  236 Max:    2858
signal
T: 0 (  981) P: 0 C:  30000 Min:      6 Act:    6 Avg:    7 Max:      85
T: 1 (  982) P: 0 C:  30000 Min:      6 Act:    6 Avg:  647 Max:   10479
T: 0 (  984) P: 0 C:  30000 Min:      6 Act:    6 Avg:    7 Max:     129
T: 1 (  985) P: 0 C:  30000 Min:      6 Act:    6 Avg:  647 Max:   11178
T: 0 (  987) P: 0 C:  30000 Min:      6 Act:    6 Avg:    7 Max:      94
T: 1 (  988) P: 0 C:  30000 Min:      6 Act:    6 Avg:  647 Max:   11587
hackbench
Time: 14.488
Time: 14.390
Time: 14.310

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
