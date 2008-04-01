Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m318Hbjh009624
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 13:47:37 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m318Hbb21490972
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 13:47:37 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m318Ha2f030633
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 08:17:37 GMT
Message-ID: <47F1EE8F.2050508@linux.vnet.ibm.com>
Date: Tue, 01 Apr 2008 13:43:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain> <6599ad830803312316m17f9e6f1mf7f068c0314a789e@mail.gmail.com> <47F1D4F3.3040207@linux.vnet.ibm.com> <6599ad830803312348u3ee4d815i2e24c130978f8e04@mail.gmail.com> <47F1E3C1.6050802@linux.vnet.ibm.com>
In-Reply-To: <47F1E3C1.6050802@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Paul Menage wrote:
>> On Mon, Mar 31, 2008 at 11:23 PM, Balbir Singh
>> <balbir@linux.vnet.ibm.com> wrote:
>>>  > Here we'll want to call vm_cgroup_update_mm_owner(), to adjust the
>>>  > accounting. (Or if in future we end up with more than a couple of
>>>  > subsystems that want notification at this time, we'll want to call
>>>  > cgroup_update_mm_owner() and have it call any interested subsystems.
>>>  >
>>>
>>>  I don't think we need to adjust accounting, since only mm->owner is changing and
>>>  not the cgroup to which the task/mm belongs. Do we really need to notify? I
>>>  don't want to do any notifications under task_lock().
>> It's possible but unlikely that the new owner is in a different cgroup.
> 
> Hmmm... that can never happen with thread groups, since mm->owner is
> p->group_leader and that never exits unless all threads are gone (it can
> explicitly change groups though). Without thread groups, the new owner can
> belong to a different cgroup, so we might need notification.
> 
> 

Thinking out aloud

If mm->owner changes and belongs to a different cgroup, we have a whole new
problem. We need to determine all tasks that share the mm and belong to a
particular cgroup, which changed since the new owner belongs to a different
cgroup and then update the charge.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
