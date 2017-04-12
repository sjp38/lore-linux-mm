Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E45146B0397
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:18:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o21so2174364wrb.9
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:18:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x14si29940129wrb.290.2017.04.12.01.18.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 01:18:23 -0700 (PDT)
Subject: Re: [RFC 5/6] mm, cpuset: always use seqlock when changing task's
 nodemask
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-6-vbabka@suse.cz>
 <0c2d01d2b364$4eaba920$ec02fb60$@alibaba-inc.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3a978d8c-c5c6-fc5d-cb40-85c7d7811146@suse.cz>
Date: Wed, 12 Apr 2017 10:18:21 +0200
MIME-Version: 1.0
In-Reply-To: <0c2d01d2b364$4eaba920$ec02fb60$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, 'Li Zefan' <lizefan@huawei.com>, 'Michal Hocko' <mhocko@kernel.org>, 'Mel Gorman' <mgorman@techsingularity.net>, 'David Rientjes' <rientjes@google.com>, 'Christoph Lameter' <cl@linux.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>

On 04/12/2017 10:10 AM, Hillf Danton wrote:
> On April 11, 2017 10:06 PM Vlastimil Babka wrote: 
>>
>>  static void cpuset_change_task_nodemask(struct task_struct *tsk,
>>  					nodemask_t *newmems)
>>  {
>> -	bool need_loop;
>> -
>>  	task_lock(tsk);
>> -	/*
>> -	 * Determine if a loop is necessary if another thread is doing
>> -	 * read_mems_allowed_begin().  If at least one node remains unchanged and
>> -	 * tsk does not have a mempolicy, then an empty nodemask will not be
>> -	 * possible when mems_allowed is larger than a word.
>> -	 */
>> -	need_loop = task_has_mempolicy(tsk) ||
>> -			!nodes_intersects(*newmems, tsk->mems_allowed);
>>
>> -	if (need_loop) {
>> -		local_irq_disable();
>> -		write_seqcount_begin(&tsk->mems_allowed_seq);
>> -	}
>> +	local_irq_disable();
>> +	write_seqcount_begin(&tsk->mems_allowed_seq);
>>
>> -	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
>>  	mpol_rebind_task(tsk, newmems);
>>  	tsk->mems_allowed = *newmems;
>>
>> -	if (need_loop) {
>> -		write_seqcount_end(&tsk->mems_allowed_seq);
>> -		local_irq_enable();
>> -	}
>> +	write_seqcount_end(&tsk->mems_allowed_seq);
>>
> Doubt if we'd listen irq again.

Ugh, thanks for catching this. Looks like my testing config didn't have
lockup detectors enabled.

>>  	task_unlock(tsk);
>>  }
>> --
>> 2.12.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
