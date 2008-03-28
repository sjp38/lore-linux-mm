Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2SCwKKO022972
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 18:28:20 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SCwJZX1347828
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 18:28:19 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2SCwJxS024144
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 12:58:19 GMT
Message-ID: <47ECEA8F.5060505@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 18:24:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com> <47ECE662.3060506@linux.vnet.ibm.com>
In-Reply-To: <47ECE662.3060506@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Paul Menage wrote:
>> On Fri, Mar 28, 2008 at 1:23 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>  diff -puN include/linux/mm_types.h~memory-controller-add-mm-owner include/linux/mm_types.h
>>>  --- linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner    2008-03-28 09:30:47.000000000 +0530
>>>  +++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h    2008-03-28 12:26:59.000000000 +0530
>>>  @@ -227,8 +227,10 @@ struct mm_struct {
>>>         /* aio bits */
>>>         rwlock_t                ioctx_list_lock;
>>>         struct kioctx           *ioctx_list;
>>>  -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>>>  -       struct mem_cgroup *mem_cgroup;
>>>  +#ifdef CONFIG_MM_OWNER
>>>  +       spinlock_t owner_lock;
>>>  +       struct task_struct *owner;      /* The thread group leader that */
>>>  +                                       /* owns the mm_struct.          */
>>>   #endif
>> I'm not convinced that we need the spinlock. Just use the simple rule
>> that you can only modify mm->owner if:
>>
>> - mm->owner points to current
>> - the new owner is a user of mm
> 
> This will always hold, otherwise it cannot be the new owner :)
> 
>> - you hold task_lock() for the new owner (which is necessary anyway to
>> ensure that the new owner's mm doesn't change while you're updating
>> mm->owner)
>>

Thinking more, I don't think it makes sense for us to overload task_lock() to do
the mm->owner handling (we don't want to mix lock domains). task_lock() is used
for several things

1. We don't want to make task_lock() rules more complicated by having it protect
an mm member to save space
2. We don't want more contention on task_lock()

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
