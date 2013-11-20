Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 49F906B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 22:01:35 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so5982201pdi.24
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 19:01:34 -0800 (PST)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id hi3si13037682pbb.213.2013.11.19.19.01.26
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 19:01:34 -0800 (PST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 20 Nov 2013 13:01:07 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 7E2372BB005B
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 14:01:00 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAK2hCR866781284
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 13:43:13 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAK30wIO014985
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 14:00:58 +1100
Date: Wed, 20 Nov 2013 11:00:56 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131120030056.GA15273@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123008.GJ14934@mtj.dyndns.org>
 <20131028030055.GC15642@weiyang.vnet.ibm.com>
 <20131028113120.GB11541@mtj.dyndns.org>
 <20131028151746.GA7548@weiyang.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131028151746.GA7548@weiyang.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 28, 2013 at 11:17:46PM +0800, Wei Yang wrote:
>On Mon, Oct 28, 2013 at 07:31:20AM -0400, Tejun Heo wrote:
>>Hello,
>>
>>On Mon, Oct 28, 2013 at 11:00:55AM +0800, Wei Yang wrote:
>>> >Does this actually matter?  If so, it'd probably make a lot more sense
>>> >to start inner loop at @cpu + 1 so that it becomes O(N).
>>> 
>>> One of the worst case in my mind:
>>> 
>>> CPU:        0    1    2    3    4    ...
>>> Group:      0    1    2    3    4    ...
>>> (sounds it is impossible in the real world)
>>
>>I was wondering whether you had an actual case where this actually
>>matters or it's just something you thought of while reading the code.
>
>Tejun,
>
>Thanks for your comments.
>
>I found this just in code review. :-)
>
>>
>>> Every time, when we encounter a new CPU and try to assign it to a group, we
>>> found it belongs to a new group. The original logic will iterate on all old
>>> CPUs again, while the new logic could skip this and assign it to a new group.
>>> 
>>> Again, this is a tiny change, which doesn't matters a lot.
>>
>>I think it *could* matter because the current implementation is O(N^2)
>>where N is the number of CPUs.  On machines, say, with 4k CPU, it's
>>gonna loop 16M times but then again even that takes only a few
>>millisecs on modern machines.
>
>I am not familiar with the real cases of the CPU numbers. Thanks for leting me
>know there could be 4K CPUs.
>
>Yep, a few millisecs sounds not a big a mount.
>
>>
>>> BTW, I don't get your point for "start inner loop at @cpu+1".
>>> 
>>> The original logic is:
>>> 	loop 1:   0 - nr_cpus
>>> 	loop 2:      0 - (cpu - 1)
>>> 
>>> If you found one better approach to improve the logic, I believe all the users
>>> will appreciate your efforts :-)
>>
>>Ooh, right, I forgot about the break and then I thought somehow that
>>would make it O(N).  Sorry about that.  I blame jetlag. :)
>>
>>Yeah, I don't know.  The function is quite hairy which makes me keep
>>things simpler and reluctant to make changes unless it actually makes
>>non-trivial difference.  The change looks okay to me but it seems
>>neither necessary or substantially beneficial and if my experience is
>>anything to go by, *any* change involves some risk of brekage no
>>matter how innocent it may look, so given the circumstances, I'd like
>>to keep things the way they are.
>
>Yep, I really agree with you. If no big improvement, it is really not
>necessary to change the code, which will face some risk.
>
>Here I have another one, which in my mind will improve it in one case. Looking
>forward to your comments :-) If I am not correct, please let me know. :-)

Tejun,

What do you think about this one?

>
>From bd70498b9df47b25ff20054e24bb510c5430c0c3 Mon Sep 17 00:00:00 2001
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Thu, 10 Oct 2013 09:42:14 +0800
>Subject: [PATCH] percpu: optimize group assignment when cpu_distance_fn is
> NULL
>
>When cpu_distance_fn is NULL, all CPUs belongs to group 0. The original logic
>will continue to go through each CPU and its predecessor. cpu_distance_fn is
>always NULL when pcpu_build_alloc_info() is called from pcpu_page_first_chunk().
>
>By applying this patch, the time complexity will drop to O(n) form O(n^2) in
>case cpu_distance_fn is NULL.
>
>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>---
> mm/percpu.c |   23 ++++++++++++-----------
> 1 files changed, 12 insertions(+), 11 deletions(-)
>
>diff --git a/mm/percpu.c b/mm/percpu.c
>index f79c807..8e6034f 100644
>--- a/mm/percpu.c
>+++ b/mm/percpu.c
>@@ -1481,20 +1481,21 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
> 	for_each_possible_cpu(cpu) {
> 		group = 0;
> 	next_group:
>-		for_each_possible_cpu(tcpu) {
>-			if (cpu == tcpu)
>-				break;
>-			if (group_map[tcpu] == group && cpu_distance_fn &&
>-			    (cpu_distance_fn(cpu, tcpu) > LOCAL_DISTANCE ||
>-			     cpu_distance_fn(tcpu, cpu) > LOCAL_DISTANCE)) {
>-				group++;
>-				if (group == nr_groups) {
>-					nr_groups++;
>+		if (cpu_distance_fn)
>+			for_each_possible_cpu(tcpu) {
>+				if (cpu == tcpu)
> 					break;
>+				if (group_map[tcpu] == group &&
>+				    (cpu_distance_fn(cpu, tcpu) > LOCAL_DISTANCE ||
>+				     cpu_distance_fn(tcpu, cpu) > LOCAL_DISTANCE)) {
>+					group++;
>+					if (group == nr_groups) {
>+						nr_groups++;
>+						break;
>+					}
>+					goto next_group;
> 				}
>-				goto next_group;
> 			}
>-		}
> 		group_map[cpu] = group;
> 		group_cnt[group]++;
> 	}
>-- 
>1.7.5.4
>
>BTW, this one is based on my previous patch.
>
>>
>>Thanks a lot!
>>
>>-- 
>>tejun
>
>-- 
>Richard Yang
>Help you, Help me

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
