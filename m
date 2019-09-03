Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FAKE_REPLY_C,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E708AC3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 10:00:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8227C22CF7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 10:00:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8227C22CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lge.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C476C6B0003; Tue,  3 Sep 2019 06:00:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF7516B0005; Tue,  3 Sep 2019 06:00:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE6136B0006; Tue,  3 Sep 2019 06:00:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0135.hostedemail.com [216.40.44.135])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0756B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 06:00:04 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2CD8232635
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:00:04 +0000 (UTC)
X-FDA: 75893163528.30.rings94_74da62be3b432
X-HE-Tag: rings94_74da62be3b432
X-Filterd-Recvd-Size: 5337
Received: from lgeamrelo11.lge.com (lgeamrelo12.lge.com [156.147.23.52])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:00:02 +0000 (UTC)
Received: from unknown (HELO lgemrelse7q.lge.com) (156.147.1.151)
	by 156.147.23.52 with ESMTP; 3 Sep 2019 18:59:59 +0900
X-Original-SENDERIP: 156.147.1.151
X-Original-MAILFROM: sangwoo2.park@lge.com
Received: from unknown (HELO LGEARND18B2) (10.168.178.132)
	by 156.147.1.151 with ESMTP; 3 Sep 2019 18:59:59 +0900
X-Original-SENDERIP: 10.168.178.132
X-Original-MAILFROM: sangwoo2.park@lge.com
Date: Tue, 3 Sep 2019 18:59:59 +0900
From: Park Sangwoo <sangwoo2.park@lge.com>
To: akpm@linux-foundation.org, vbabka@suse.cz, dan.j.williams@intel.com,
	mhocko@suse.com, mgorman@techsingularity.net,
	richard.weiyang@gmail.com, hannes@cmpxchg.org,
	arunks@codeaurora.org, osalvador@suse.de, rppt@linux.vnet.ibm.com,
	alexander.h.duyck@linux.intel.com, glider@google.com,
	gregkh@linuxfoundation.org, guro@fb.com, jannh@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: RE: Re: Re: [PATCH] mm: Add nr_free_highatomimic to fix incorrect
 watermatk routine
Message-ID: <20190903095959.GA4458@LGEARND18B2>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>On Mon 02-09-19 13:34:54, Sangwoo=EF=BF=BD wrote:
>>>On Fri 30-08-19 18:25:53, Sangwoo wrote:
>>>> The highatomic migrate block can be increased to 1% of Total memory.
>>>> And, this is for only highorder ( > 0 order). So, this block size is
>>>> excepted during check watermark if allocation type isn't alloc_harde=
r.
>>>>
>>>> It has problem. The usage of highatomic is already calculated at
>> NR_FREE_PAGES.
>>>> So, if we except total block size of highatomic, it's twice minus si=
ze of
>>allocated
>>>> highatomic.
>>>> It's cause allocation fail although free pages enough.
>>>>
>>>> We checked this by random test on my target(8GB RAM).
>>>>
>>>>  Binder:6218_2: page allocation failure: order:0, mode:0x14200ca
>> (GFP_HIGHUSER_MOVABLE), nodemask=3D(null)
>>>>  Binder:6218_2 cpuset=3Dbackground mems_allowed=3D0
>>>
>>>How come this order-0 sleepable allocation fails? The upstream kernel
>>>doesn't fail those allocations unless the process context is killed by
>>>the oom killer.
>>=20
>> Most calltacks are zsmalloc, as shown below.
>
>What makes those allocations special so that they fail unlike any other
>normal order-0 requests? Also do you see the same problem with the
>current upstream kernel? Is it possible this is an Android specific
>issue?

There is the other case of fail order-0 fail.
----
hvdcp_opti: page allocation failure: order:0, mode:0x1004000(GFP_NOWAIT|_=
_GFP_COMP), nodemask=3D(null)
hvdcp_opti cpuset=3D/ mems_allowed=3D0
CPU: 0 PID: 1882 Comm: hvdcp_opti Tainted: P S      W  O    4.14.83-perf+=
 #1
Hardware name: Qualcomm Technologies, Inc. SM6150 PM6150 LG Electronics, =
mh3_lao_kr, rev-C (DT)
Call trace:
dump_backtrace+0x0/0x1f0
show_stack+0x18/0x20
dump_stack+0xc4/0x100
warn_alloc+0x100/0x198
__alloc_pages_nodemask+0x116c/0x1188
new_slab+0x130/0x5e0
___slab_alloc+0x490/0x610
kmem_cache_alloc+0x2a8/0x2c8
avc_alloc_node+0x34/0x268
avc_compute_av+0xb8/0x1f8
avc_has_perm_noaudit+0xcc/0x100
selinux_inode_permission+0x100/0x1b0
security_inode_permission+0x58/0x78
__inode_permission2+0x40/0xe8
may_open+0x78/0x118
path_openat+0x8f8/0x14d0
do_filp_open+0x74/0x120
do_sys_open+0x13c/0x260
SyS_openat+0x10/0x18
el0_svc_naked+0x34/0x38
snipped...
DMA free:11320kB min:3440kB low:46092kB high:47812kB active_anon:143344kB=
 inactive_anon:145812kB active_file:171900kB inactive_file:146976kB u
lowmem_reserve[]: 0 1901 1901
Normal free:3928kB min:3940kB low:52748kB high:54716kB active_anon:85100k=
B inactive_anon:81772kB active_file:103312kB inactive_file:114732kB u
lowmem_reserve[]: 0 0 0
DMA: 343*4kB (UMECH) 947*8kB (UMCH) 26*16kB (UH) 23*32kB (UH) 11*64kB (H)=
 6*128kB (H) 3*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 12340kB
Normal: 798*4kB (UMH) 104*8kB (UMH) 20*16kB (U) 3*32kB (UH) 11*64kB (H) 1=
*128kB (H) 1*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 5528kB
----
In my test, most case are using camera. So, memory usage is increased mom=
entarily,
it cause free page go to under low value of watermark.
If free page is under low and 0-order fail is occured, its normal operati=
on.
But, although free page is higher than min, fail is occurred.
After fix routin for checking highatomic size, it's not reproduced.

I now develop smartphone is applied kernel-4.14. And I didn't checked cur=
rent upstream kernel.
I thinks this symptom can be occurred the any platform that have use-case=
 of memory intensive moment.

>
>>  Call trace:
>>   dump_backtrace+0x0/0x1f0
>>   show_stack+0x18/0x20
>>   dump_stack+0xc4/0x100
>>   warn_alloc+0x100/0x198
>>   __alloc_pages_nodemask+0x116c/0x1188
>>   do_swap_page+0x10c/0x6f0
>>   handle_pte_fault+0x12c/0xfe0
>>   handle_mm_fault+0x1d0/0x328
>>   do_page_fault+0x2a0/0x3e0
>>   do_translation_fault+0x44/0xa8
>>   do_mem_abort+0x4c/0xd0
>>   el1_da+0x24/0x84
>>   __arch_copy_to_user+0x5c/0x220
>>   binder_ioctl+0x20c/0x740
>>   compat_SyS_ioctl+0x128/0x248
>>   __sys_trace_return+0x0/0x4
>

