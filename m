Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 195AA6B01B9
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 10:35:54 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o2NEZaGA007944
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:35:36 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2NEZanP1241266
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:35:36 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o2NEZZMf024370
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:35:36 GMT
Message-ID: <4BA8D1B3.8050509@linux.vnet.ibm.com>
Date: Tue, 23 Mar 2010 15:35:31 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie>
In-Reply-To: <20100322235053.GD9590@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Mon, Mar 15, 2010 at 01:09:35PM -0700, Andrew Morton wrote:
>> On Mon, 15 Mar 2010 13:34:50 +0100
>> Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
>>
[...]
> 
> 120+ kernels and a lot of hurt later;

Thanks for all your effort in searching the real cause behind 
congestion_wait becoming such a time sink for some benchmarks.

> 
> 2.6.32                                          0        0        0          3         2           44437   221753  2760857     132517         0
> 2.6.32-revertevict                              0        0        0          3         2              35       14     1570        460         0
> 2.6.32-ttyfix                                   0        0        0          2         0           60770   303206  3659254     166293         0
> 2.6.32-ttyfix-revertevict                       0        0        0          3         0              55       62     2496        494         0
> 2.6.32.10                                       0        0        0          2         1           90769   447702  4251448     234868         0
> 2.6.32.10-revertevict                           0        0        0          3         2             148      597     8642        478         0
> 2.6.32.10-ttyfix                                0        0        0          3         0           91729   453337  4374070     238593         0
> 2.6.32.10-ttyfix-revertevict                    0        0        0          3         1              65      146     3408        347         0
> 
> Again, fixing tty and reverting evict-once helps bring figures more in line
> with 2.6.29.
> 
> 2.6.33                                          0        0        0          3         0          152248   754226  4940952     267214         0
> 2.6.33-revertevict                              0        0        0          3         0             883     4306    28918        507         0
> 2.6.33-ttyfix                                   0        0        0          3         0          157831   782473  5129011     237116         0
> 2.6.33-ttyfix-revertevict                       0        0        0          2         0            1056     5235    34796        519         0
> 2.6.33.1                                        0        0        0          3         1          156422   776724  5078145     234938         0
> 2.6.33.1-revertevict                            0        0        0          2         0            1095     5405    36058        477         0
> 2.6.33.1-ttyfix                                 0        0        0          3         1          136324   673148  4434461     236597         0
> 2.6.33.1-ttyfix-revertevict                     0        0        0          1         1            1339     6624    43583        466         0
> 

[...]

> 
> Christian, can you test the following amalgamated patch on 2.6.32.10 and
> 2.6.33 please? Note it's 2.6.32.10 because the patches below will not apply
> cleanly to 2.6.32 but it will against 2.6.33. It's a combination of ttyfix
> and revertevict. If your problem goes away, it implies that the stalls I
> can measure are roughly correlated to the more significant problem you have.

While your tty&evict patch might fix something as seen by your numbers, 
it unfortunately doesn't affect my big throughput loss.

Again the scenario was 4,8 and 16 threads iozone sequential read with 
2Gb files and one disk per process, running on a s390x machine with 4 
cpus and 256m.
My table shows the throughput deviation to plain 2.6.32 git in percent.

percentage                       4thr     8thr    16thr
2.6.32                          0.00%    0.00%    0.00%
2.6.32.10 (stable)              4.44%    7.97%    4.11%
2.6.32.10-ttyfix-revertevict    3.33%    6.64%    5.07%
2.6.33                          5.33%   -2.82%  -10.87%
2.6.33-ttyfix-revertevict       3.33%   -3.32%  -10.51%
2.6.32-watermarkwait           40.00%   58.47%   42.03%

In terms of throughput for my load your patch doesn't change anything 
significantly above the noise level of the test case (which is around 
~1%). The fix probably even has a slight performance decrease in low 
thread cases.

For better comparison I added a 2.6.32 run with your watermark wait 
patch which is still the only one fixing the issue.

That said I'd still love to see watermark wait getting accepted :-)

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
