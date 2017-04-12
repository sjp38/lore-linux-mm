Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32DB66B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:11:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 21so12425862pgg.4
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:11:00 -0700 (PDT)
Received: from out0-201.mail.aliyun.com (out0-201.mail.aliyun.com. [140.205.0.201])
        by mx.google.com with ESMTP id z63si19545942pgd.263.2017.04.12.01.10.58
        for <linux-mm@kvack.org>;
        Wed, 12 Apr 2017 01:10:59 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170411140609.3787-1-vbabka@suse.cz> <20170411140609.3787-6-vbabka@suse.cz>
In-Reply-To: <20170411140609.3787-6-vbabka@suse.cz>
Subject: Re: [RFC 5/6] mm, cpuset: always use seqlock when changing task's nodemask
Date: Wed, 12 Apr 2017 16:10:53 +0800
Message-ID: <0c2d01d2b364$4eaba920$ec02fb60$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, 'Li Zefan' <lizefan@huawei.com>, 'Michal Hocko' <mhocko@kernel.org>, 'Mel Gorman' <mgorman@techsingularity.net>, 'David Rientjes' <rientjes@google.com>, 'Christoph Lameter' <cl@linux.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>

On April 11, 2017 10:06 PM Vlastimil Babka wrote: 
> 
>  static void cpuset_change_task_nodemask(struct task_struct *tsk,
>  					nodemask_t *newmems)
>  {
> -	bool need_loop;
> -
>  	task_lock(tsk);
> -	/*
> -	 * Determine if a loop is necessary if another thread is doing
> -	 * read_mems_allowed_begin().  If at least one node remains unchanged and
> -	 * tsk does not have a mempolicy, then an empty nodemask will not be
> -	 * possible when mems_allowed is larger than a word.
> -	 */
> -	need_loop = task_has_mempolicy(tsk) ||
> -			!nodes_intersects(*newmems, tsk->mems_allowed);
> 
> -	if (need_loop) {
> -		local_irq_disable();
> -		write_seqcount_begin(&tsk->mems_allowed_seq);
> -	}
> +	local_irq_disable();
> +	write_seqcount_begin(&tsk->mems_allowed_seq);
> 
> -	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
>  	mpol_rebind_task(tsk, newmems);
>  	tsk->mems_allowed = *newmems;
> 
> -	if (need_loop) {
> -		write_seqcount_end(&tsk->mems_allowed_seq);
> -		local_irq_enable();
> -	}
> +	write_seqcount_end(&tsk->mems_allowed_seq);
> 
Doubt if we'd listen irq again.

>  	task_unlock(tsk);
>  }
> --
> 2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
