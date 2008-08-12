Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7C45mpg027647
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 14:05:48 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7C46dHR4206754
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 14:06:53 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7C46c1I030858
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 14:06:38 +1000
Message-ID: <48A10C4C.6020009@linux.vnet.ibm.com>
Date: Tue, 12 Aug 2008 09:36:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/2] mm owner fix race between swap and exit
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop> <20080811100733.26336.31346.sendpatchset@balbir-laptop> <20080811173138.71f5bbe4.akpm@linux-foundation.org>
In-Reply-To: <20080811173138.71f5bbe4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 11 Aug 2008 15:37:33 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> There's a race between mm->owner assignment and try_to_unuse(). The condition
>> occurs when try_to_unuse() runs in parallel with an exiting task.
>>
>> The race can be visualized below. To quote Hugh
>> "I don't think your careful alternation of CPU0/1 events at the end matters:
>> the swapoff CPU simply dereferences mm->owner after that task has gone"
>>
>> But the alteration does help understand the race better (at-least for me :))
>>
>> CPU0					CPU1
>> 					try_to_unuse
>> task 1 stars exiting			look at mm = task1->mm
>> ..					increment mm_users
>> task 1 exits
>> mm->owner needs to be updated, but
>> no new owner is found
>> (mm_users > 1, but no other task
>> has task->mm = task1->mm)
>> mm_update_next_owner() leaves
>>
>> grace period
>> 					user count drops, call mmput(mm)
>> task 1 freed
>> 					dereferencing mm->owner fails
>>
>> The fix is to notify the subsystem (via mm_owner_changed callback), if
>> no new owner is found by specifying the new task as NULL.
> 
> This patch applies to mainline, 2.6.27-rc2 and even 2.6.26.
> 
> Against which kernel/patch is it actually applicable?
> 
> (If the answer was "all of the above" then please don't go embedding
> mainline bugfixes in the middle of a -mm-only patch series!)

Andrew,

The answer is all, but the bug is not exposed *outside* of the memrlimit
controller, thus the push into -mm. I can redo and rework the patches for
mainline if required and pull it out of -mm.

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
