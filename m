Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDDF6B0082
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:30:40 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0LFUXaw008602
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:30:33 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0LFPrnw1622182
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:25:53 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0LFUY5P021581
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:30:34 +1100
Message-ID: <4B587317.6060404@linux.vnet.ibm.com>
Date: Thu, 21 Jan 2010 21:00:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH mmotm] memcg use generic percpu allocator instead of private
 one
References: <20100120161825.15c372ac.kamezawa.hiroyu@jp.fujitsu.com> <4B56CEF0.2040406@linux.vnet.ibm.com> <20100121110759.250ed739.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100121110759.250ed739.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

On Thursday 21 January 2010 07:37 AM, KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Jan 2010 15:07:52 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> This includes no functional changes.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>>
>> Before review, could you please post parallel pagefault data on a large
>> system, since root now uses these per cpu counters and its overhead is
>> now dependent on these counters. Also the data read from root cgroup is
>> also dependent on these, could you make sure that is not broken.
>>
> Hmm, I rewrote test program for avoidng mmap_sem. This version does fork()
> instead of pthread_create() and meausre parallel-process page fault speed.
> 
> [Before patch]
> [root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-fork 8
> 
>  Performance counter stats for './multi-fault-fork 8' (5 runs):
> 
>        45256919  page-faults                ( +-   0.851% )
>       602230144  cache-misses               ( +-   0.187% )
> 
>    61.020533723  seconds time elapsed   ( +-   0.002% 
> 
> [After patch]
> [root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-fork 8
> 
>  Performance counter stats for './multi-fault-fork 8' (5 runs):
> 
>        46007166  page-faults                ( +-   0.339% )
>       599553505  cache-misses               ( +-   0.298% )
> 
>    61.020937843  seconds time elapsed   ( +-   0.004% )
> 
> slightly improved ? But this test program does some extreme behavior and
> you can't see difference in real-world applications, I think.
> So, I guess this is in error-range in famous (not small) benchmarks.

Looks good, please give me a couple of days to test, I'll revert back
with numbers and review.

-- 
Three Cheers,
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
