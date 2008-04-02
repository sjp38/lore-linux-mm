From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 02 Apr 2008 08:55:34 +0530
Message-ID: <47F2FCAE.7070401@linux.vnet.ibm.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain> <20080402093157.e445acfb.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758710AbYDBDal@vger.kernel.org>
In-Reply-To: <20080402093157.e445acfb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

KAMEZAWA Hiroyuki wrote:
> On Tue, 01 Apr 2008 18:13:12 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> +	/*
>> +	 * Search in the children
>> +	 */
>> +	list_for_each_entry(c, &p->children, sibling) {
>> +		if (c->mm == mm)
>> +			goto assign_new_owner;
>> +	}
>> +
> This finds new owner when "current" is multi-threaded and
> "current" called pthread_create(), right ?
> 

No, it won't find the new owner if we have CLONE_THREAD passed while creating
threads. mm_need_new_owner() checks for !delay_group_leader(). If the
group_leader is set, we don't need a new owner, it stays around till all threads
exit.

>> +	/*
>> +	 * Search in the siblings
>> +	 */
>> +	list_for_each_entry(c, &p->parent->children, sibling) {
>> +		if (c->mm == mm)
>> +			goto assign_new_owner;
>> +	}
>> +
> This finds new owner when "current" is multi-threaded and
> "current" is just a child (means it doesn't call pthread_create()) ?
> 

Ditto

> 
>> +	/*
>> +	 * Search through everything else. We should not get
>> +	 * here often
>> +	 */
>> +	do_each_thread(g, c) {
>> +		if (c->mm == mm)
>> +			goto assign_new_owner;
>> +	} while_each_thread(g, c);
> 
> Doing above in synchronized manner seems too heavy.
> When this happen ? or Can this be done in lazy "on-demand" manner ?
> 

Do you mean under task_lock()?

> +assign_new_owner:
> +	rcu_read_unlock();
> +	BUG_ON(c == p);
> +	task_lock(c);
> +	if (c->mm != mm) {
> +		task_unlock(c);
> +		goto retry;
> +	}
> +	cgroup_mm_owner_callbacks(mm->owner, c);
> +	mm->owner = c;
> +	task_unlock(c);
> +}
> Why rcu_read_unlock() before changing owner ? Is it safe ?
> 

It should be safe, since we take task_lock(), but to be doubly sure, we can drop
rcu read lock after taking the task_lock().

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
