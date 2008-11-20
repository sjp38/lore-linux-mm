Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAKGkBOK026141
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 03:46:11 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAKGfxdZ033468
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 03:42:00 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAKGfxHa024921
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 03:41:59 +1100
Message-ID: <49259354.2030604@linux.vnet.ibm.com>
Date: Thu, 20 Nov 2008 22:11:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm: remove cgroup_mm_owner_callbacks
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site> <Pine.LNX.4.64.0811200110180.19216@blonde.site> <6599ad830811191723v3c346a17kf5ae5494987373c1@mail.gmail.com> <Pine.LNX.4.64.0811200125100.21820@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811200125100.21820@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 19 Nov 2008, Paul Menage wrote:
>> On Wed, Nov 19, 2008 at 5:11 PM, Hugh Dickins <hugh@veritas.com> wrote:
>>>  assign_new_owner:
>>>        BUG_ON(c == p);
>>>        get_task_struct(c);
>>> -       read_unlock(&tasklist_lock);
>>> -       down_write(&mm->mmap_sem);
>>>        /*
>>>         * The task_lock protects c->mm from changing.
>>>         * We always want mm->owner->mm == mm
>>>         */
>>>        task_lock(c);
>>> +       /*
>>> +        * Delay read_unlock() till we have the task_lock()
>>> +        * to ensure that c does not slip away underneath us
>>> +        */
>>> +       read_unlock(&tasklist_lock);
>> How can c slip away when we've done get_task_struct(c) earlier?
> 

"c" cannot slip away, but c->mm can change, but see below.

> I don't know, I did vaguely wonder the same myself: just putting
> this back to how it was before (including that comment),
> maybe Balbir can enlighten us.

Looking at the patch, we do handle a c->mm != mm case. The code seems to keep
the task on the global tasklist and protects task->mm, which might not be
necessary here. It would seem reasonable to allow the read_unlock() to occur
prior to task_lock().

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
