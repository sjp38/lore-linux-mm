Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4C7376B0203
	for <linux-mm@kvack.org>; Wed, 12 May 2010 02:15:23 -0400 (EDT)
Message-ID: <4BEA47CA.2020508@cn.fujitsu.com>
Date: Wed, 12 May 2010 14:16:42 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] cpuset,mm: fix no node to alloc memory when changing
 cpuset's mems
References: <4BDFFCCA.3020906@cn.fujitsu.com> <20100511184900.8211b6f9.akpm@linux-foundation.org>
In-Reply-To: <20100511184900.8211b6f9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-5-12 9:49, Andrew Morton wrote:
...
>> --- a/kernel/exit.c
>> +++ b/kernel/exit.c
>> @@ -16,6 +16,7 @@
>>  #include <linux/key.h>
>>  #include <linux/security.h>
>>  #include <linux/cpu.h>
>> +#include <linux/cpuset.h>
>>  #include <linux/acct.h>
>>  #include <linux/tsacct_kern.h>
>>  #include <linux/file.h>
>> @@ -1003,8 +1004,10 @@ NORET_TYPE void do_exit(long code)
>>  
>>  	exit_notify(tsk, group_dead);
>>  #ifdef CONFIG_NUMA
>> +	task_lock(tsk);
>>  	mpol_put(tsk->mempolicy);
>>  	tsk->mempolicy = NULL;
>> +	task_unlock(tsk);
>>  #endif
>>  #ifdef CONFIG_FUTEX
>>  	if (unlikely(current->pi_state_cache))
> 
> Given that this function is already holding task_lock(tsk), this
> didn't work very well.

Sorry for replying late.

Thanks for your patch that removes task_lock(tsk).

I made this patch against the mainline tree, and do_exit() in the mainline tree
doesn't hold task_lock(tsk), so I took task_lock(tsk). But I didn't take notice
that do_exit() in the mmotm tree had been changed, and I made this mistake.

> Also, why was the inclusion of cpuset.h added?  Nothing which this
> patch adds appears to need it?
> 

This is my mistake, I will make patch to cleanup it.

Thanks!
Miao 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
