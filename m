Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 082C16B04C9
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 01:48:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x189so2724930wmg.5
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 22:48:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 5si6645841wry.0.2017.09.04.22.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 22:48:24 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v855i7eb136656
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 01:48:23 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2csnjh1a74-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 01:48:23 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 15:48:20 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v855l39938928442
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 15:47:03 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v855l2wF010652
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 15:47:03 +1000
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove timeout from
 __offline_memory
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-3-mhocko@kernel.org> <59AD15B6.7080304@huawei.com>
 <20170904090114.mrjxipvucieadxa6@dhcp22.suse.cz>
 <59AD174B.4020807@huawei.com>
 <20170904091505.xffd7orldpwlmrlx@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 5 Sep 2017 11:16:57 +0530
MIME-Version: 1.0
In-Reply-To: <20170904091505.xffd7orldpwlmrlx@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c217dbb1-6ee9-1401-04f1-a46f13488aaf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 09/04/2017 02:45 PM, Michal Hocko wrote:
> On Mon 04-09-17 17:05:15, Xishi Qiu wrote:
>> On 2017/9/4 17:01, Michal Hocko wrote:
>>
>>> On Mon 04-09-17 16:58:30, Xishi Qiu wrote:
>>>> On 2017/9/4 16:21, Michal Hocko wrote:
>>>>
>>>>> From: Michal Hocko <mhocko@suse.com>
>>>>>
>>>>> We have a hardcoded 120s timeout after which the memory offline fails
>>>>> basically since the hot remove has been introduced. This is essentially
>>>>> a policy implemented in the kernel. Moreover there is no way to adjust
>>>>> the timeout and so we are sometimes facing memory offline failures if
>>>>> the system is under a heavy memory pressure or very intensive CPU
>>>>> workload on large machines.
>>>>>
>>>>> It is not very clear what purpose the timeout actually serves. The
>>>>> offline operation is interruptible by a signal so if userspace wants
>>>> Hi Michal,
>>>>
>>>> If the user know what he should do if migration for a long time,
>>>> it is OK, but I don't think all the users know this operation
>>>> (e.g. ctrl + c) and the affect.
>>> How is this operation any different from other potentially long
>>> interruptible syscalls?
>>>
>> Hi Michal,
>>
>> I means the user should stop it by himself if migration always retry in endless.
> If the memory is migrateable then the migration should finish
> eventually. It can take some time but it shouldn't be an endless loop.

But what if some how the temporary condition (page removed from the PCP
LRU list and has not been freed yet to the buddy) happens again and again.
I understand we have schedule() and yield() to make sure that the context
does not hold the CPU for ever but it can take theoretically very long
time if not endless to finish. In that case sending signal to the user
space process who initiated the offline request is the only way to stop
this retry loop. I think this is still a better approach than the 120
second timeout which was kind of arbitrary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
