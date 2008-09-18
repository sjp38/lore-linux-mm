Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8INts7d004989
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 09:55:54 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8INuRIA307856
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 09:56:27 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8INuRpL015947
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 09:56:27 +1000
Message-ID: <48D2EAA1.1000301@linux.vnet.ibm.com>
Date: Thu, 18 Sep 2008 16:56:17 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page (v3)
References: <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com> <20080910012048.GA32752@balbir.in.ibm.com> <1221085260.6781.69.camel@nimitz> <48C84C0A.30902@linux.vnet.ibm.com> <1221087408.6781.73.camel@nimitz> <20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com> <48C878AD.4040404@linux.vnet.ibm.com> <20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com> <20080917232826.GA19256@balbir.in.ibm.com> <20080917184008.92b7fc4c.akpm@linux-foundation.org> <20080918134304.93985542.kamezawa.hiroyu@jp.fujitsu.com> <48D1DFE0.5010208@linux.vnet.ibm.com> <20080918200116.06b41fa7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080918200116.06b41fa7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 17 Sep 2008 21:58:08 -0700
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> BTW, I already have lazy-lru-by-pagevec protocol on my patch(hash version) and
>>> seems to work well. I'm now testing it and will post today if I'm enough lucky.
>> cool! Please do post what numbers you see as well. I would appreciate if you can
>> try this version and see what sort of performance issues you see.
>>
> 
> This is the result on 8cpu box. I think I have to reduce footprint of fastpath of
> my patch ;)
> 
> Test result of your patch is (2).
> ==
> Xeon 8cpu/2socket/1-node equips 48GB of memory.
> run shell/exec benchmark 3 times just after boot.
> 
> lps ... loops per sec.
> lpm ... loops per min.
> (*) Shell tests somtimes fail because of division by zero, etc...
> 
> (1). rc6-mm1(2008/9/13 version)
> ==
> Run                                       == 1st ==  == 2nd ==  ==3rd==
> Execl Throughput                           2425.2     2534.5     2465.8  (lps)
> C Compiler Throughput                      1438.3     1476.3     1459.1  (lpm)
> Shell Scripts (1 concurrent)               9360.3     9368.3     9360.0  (lpm)
> Shell Scripts (8 concurrent)               3868.0     3870.0     3868.0  (lpm)
> Shell Scripts (16 concurrent)              2207.0     2204.0     2201.0  (lpm)
> Dc: sqrt(2) to 99 decimal places         101644.3   102184.5   102118.5  (lpm)
> 
> (2). (1) +remove-page-cgroup-pointer-v3 (radix-tree + dynamic allocation)
> ==
> Run                                       == 1st ==  == 2nd ==  == 3rd ==
> Execl Throughput                           2514.1      2548.9    2648.7  (lps)
> C Compiler Throughput                      1353.9      1324.6    1324.7  (lpm)
> Shell Scripts (1 concurrent)               8866.7      8871.0    8856.0  (lpm)
> Shell Scripts (8 concurrent)               3674.3      3680.0    3677.7  (lpm)
> Shell Scripts (16 concurrent)              failed.     failed    2094.3  (lpm)
> Dc: sqrt(2) to 99 decimal places          98837.0     98206.9   98250.6  (lpm)
> 
> (3). (1) + pre-allocation by "vmalloc" + hash + misc(atomic flags etc..)
> ==
> Run                                       == 1st ==  == 2nd ==  == 3rd ==
> Execl Throughput                           2385.4      2579.2    2361.5  (lps)
> C Compiler Throughput                      1424.3      1436.3    1430.6  (lpm)
> Shell Scripts (1 concurrent)               9222.0      9234.0    9246.7  (lpm)
> Shell Scripts (8 concurrent)               3787.7      3799.3    failed  (lpm)
> Shell Scripts (16 concurrent)              2165.7      2166.7    failed  (lpm)
> Dc: sqrt(2) to 99 decimal places         102228.9    102658.5   104049.8 (lpm)
> 
> (4). (3) + get/put page charge/uncharge + lazy lru handling
> Run                                       == 1st ==  == 2nd ==  == 3rd ==
> Execl Throughput                           2349.4      2335.7    2338.9  (lps)
> C Compiler Throughput                      1430.8      1445.0    1435.3  (lpm)
> Shell Scripts (1 concurrent)               9250.3      9262.0    9265.0  (lpm)
> Shell Scripts (8 concurrent)               3831.0      3834.4    3833.3  (lpm)
> Shell Scripts (16 concurrent)              2193.3      2195.3    2196.0  (lpm)
> Dc: sqrt(2) to 99 decimal places         102956.8    102886.9   101884.6 (lpm)
> 
> 
> It seems "execl" test is affected by footprint and cache hit rate than other
> tests. I need some more efforts for reducing overhead in (4).
> 
> Note:
> (1)'s struct page is 64 bytes.
> (2)(3)(4)'s struct page is 56 bytes.

Thanks, Kame! I'll look at the lazy lru patches and see if I can find anything.
Do you have a unified patch anywhere, I seem to get confused with the patches, I
see 10/9, 11/9 and 12/9. I'll do some analysis when I find some free time, I am
currently at plumbers conference.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
