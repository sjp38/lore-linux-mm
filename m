Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAD1Z4Q9025780
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 07:05:04 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAD1Z5nV4309128
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 07:05:05 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAD1Z4XV024350
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 07:05:04 +0530
Message-ID: <491B8423.3080304@linux.vnet.ibm.com>
Date: Thu, 13 Nov 2008 07:04:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
 (v3)
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop> <20081111123448.6566.55973.sendpatchset@balbir-laptop> <491B82B7.5030002@cn.fujitsu.com>
In-Reply-To: <491B82B7.5030002@cn.fujitsu.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>> +	/*
>> +	 * If parent's use_hiearchy is set, we can't make any modifications
>> +	 * in the child subtrees. If it is unset, then the change can
>> +	 * occur, provided the current cgroup has no children.
>> +	 *
>> +	 * For the root cgroup, parent_mem is NULL, we allow value to be
>> +	 * set if there are no children.
>> +	 */
>> +	if (!parent_mem || (!parent_mem->use_hierarchy &&
>> +				(val == 1 || val == 0))) {
>> +		if (list_empty(&cont->children))
>> +			mem->use_hierarchy = val;
>> +		else
>> +			retval = -EBUSY;
>> +	} else
>> +		retval = -EINVAL;
>> +
>> +	return retval;
>> +}
> 
> As I mentioned there is a race here. :(
> 
> echo 1 > /memcg/memory.use_hierarchy
>  =>if (list_empty(&cont->children))
>                                       mkdir /memcg/0
>                                        => mem->use_hierarchy = 0
>        mem->use_hierarchy = 1;
> 

Hi, Li,

I thought I had the cgroup_lock() around that check, but I seemed to have missed
it. I'll fix that in v4.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
