Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E37008E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:06:49 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id o23so11144283pll.0
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 22:06:49 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id i66si4248399pfb.91.2018.12.17.22.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 22:06:48 -0800 (PST)
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
 <20181217093337.GC30879@dhcp22.suse.cz>
 <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
From: Hou Tao <houtao1@huawei.com>
Message-ID: <5ba9aba1-e00d-ae07-caf0-3e7eca7de4b6@huawei.com>
Date: Tue, 18 Dec 2018 14:06:11 +0800
MIME-Version: 1.0
In-Reply-To: <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On 2018/12/17 18:51, Tetsuo Handa wrote:
> On 2018/12/17 18:33, Michal Hocko wrote:
>> On Sun 16-12-18 19:51:57, Matthew Wilcox wrote:
>> [...]
>>> Ah, yes, that makes perfect sense.  Thank you for the explanation.
>>>
>>> I wonder if the correct fix, however, is not to move the check for
>>> GFP_NOFS in out_of_memory() down to below the check whether to kill
>>> the current task.  That would solve your problem, and I don't _think_
>>> it would cause any new ones.  Michal, you touched this code last, what
>>> do you think?
>>
>> What do you mean exactly? Whether we kill a current task or something
>> else doesn't change much on the fact that NOFS is a reclaim restricted
>> context and we might kill too early. If the fs can do GFP_FS then it is
>> obviously a better thing to do because FS metadata can be reclaimed as
>> well and therefore there is potentially less memory pressure on
>> application data.
>>
> 
> I interpreted "to move the check for GFP_NOFS in out_of_memory() down to
> below the check whether to kill the current task" as
> 
> @@ -1077,15 +1077,6 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	/*
> -	 * The OOM killer does not compensate for IO-less reclaim.
> -	 * pagefault_out_of_memory lost its gfp context so we have to
> -	 * make sure exclude 0 mask - all other users should have at least
> -	 * ___GFP_DIRECT_RECLAIM to get here.
> -	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> -		return true;
> -
> -	/*
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA and memcg) that may require different handling.
>  	 */
> @@ -1104,6 +1095,19 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	select_bad_process(oc);
> +
> +	/*
> +	 * The OOM killer does not compensate for IO-less reclaim.
> +	 * pagefault_out_of_memory lost its gfp context so we have to
> +	 * make sure exclude 0 mask - all other users should have at least
> +	 * ___GFP_DIRECT_RECLAIM to get here.
> +	 */
> +	if ((oc->gfp_mask && !(oc->gfp_mask & __GFP_FS)) && oc->chosen &&
> +	    oc->chosen != (void *)-1UL && oc->chosen != current) {
> +		put_task_struct(oc->chosen);
> +		return true;
> +	}
> +
>  	/* Found nothing?!?! */
>  	if (!oc->chosen) {
>  		dump_header(oc, NULL);
> 
> which is prefixed by "the correct fix is not".
> 
> Behaving like sysctl_oom_kill_allocating_task == 1 if __GFP_FS is not used
> will not be the correct fix. But ...
> 
> Hou Tao wrote:
>> There is no need to disable __GFP_FS in ->readpage:
>> * It's a read-only fs, so there will be no dirty/writeback page and
>>   there will be no deadlock against the caller's locked page
> 
> is read-only filesystem sufficient for safe to use __GFP_FS?
> 
> Isn't "whether it is safe to use __GFP_FS" depends on "whether fs locks
> are held or not" rather than "whether fs has dirty/writeback page or not" ?
> 
In my understanding (correct me if I am wrong), there are three ways through which
reclamation will invoked fs related code and may cause dead-lock:

(1) write-back dirty pages. Not possible for squashfs.
(2) the reclamation of inodes & dentries. The current file is in-use, so it will be not
    reclaimed, and for other reclaimable inodes, squashfs_destroy_inode() will
    be invoked and it doesn't take any locks.
(3) customized shrinker defined by fs. No customized shrinker in squashfs.

So my point is that even a page lock is already held by squashfs_readpage() and
reclamation invokes back to squashfs code, there will be no dead-lock, so it's
safe to use __GFP_FS.

Regards,
Tao

> .
> 
