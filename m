Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 640F86B0038
	for <linux-mm@kvack.org>; Sat, 31 May 2014 17:04:36 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so3402261wgg.25
        for <linux-mm@kvack.org>; Sat, 31 May 2014 14:04:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z15si13570345wia.47.2014.05.31.14.04.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 May 2014 14:04:35 -0700 (PDT)
Message-ID: <538A43E0.5070706@suse.cz>
Date: Sat, 31 May 2014 23:04:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: sleeping function warning from __put_anon_vma
References: <20140530000944.GA29942@redhat.com> <alpine.LSU.2.11.1405311321340.10272@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1405311321340.10272@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/31/2014 10:33 PM, Hugh Dickins wrote:
> On Thu, 29 May 2014, Dave Jones wrote:
> 
>> BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:47
>> in_atomic(): 0, irqs_disabled(): 0, pid: 5787, name: trinity-c27
>> Preemption disabled at:[<ffffffff990acc7e>] vtime_account_system+0x1e/0x50

Just wondering, since I'm not familiar with this kind of bug, is the line above
bogus or what does it mean? I don't see how the stack trace or the fix patch is
related to vtime_account_system?

Thanks,
Vlastimil

>> CPU: 0 PID: 5787 Comm: trinity-c27 Not tainted 3.15.0-rc7+ #219
>>  ffffffff99a47203 0000000099b50bef ffff880239f138c8 ffffffff99739dfb
>>  0000000000000000 ffff880239f138f0 ffffffff990a026c ffff8801078b5458
>>  ffff8801078b5450 ffffea00044be980 ffff880239f13908 ffffffff99741c30
>> Call Trace:
>>  [<ffffffff99739dfb>] dump_stack+0x4e/0x7a
>>  [<ffffffff990a026c>] __might_sleep+0x11c/0x1b0
>>  [<ffffffff99741c30>] down_write+0x20/0x40
>>  [<ffffffff9919337d>] __put_anon_vma+0x3d/0xc0
>>  [<ffffffff99193998>] page_get_anon_vma+0x68/0xb0
>>  [<ffffffff991b97e9>] migrate_pages+0x449/0x880
>>  [<ffffffff9917dc00>] ? isolate_freepages_block+0x360/0x360
>>  [<ffffffff9917ec8a>] compact_zone+0x38a/0x580
>>  [<ffffffff9917ef29>] compact_zone_order+0xa9/0x130
>>  [<ffffffff9917f329>] try_to_compact_pages+0xe9/0x140
>>  [<ffffffff991616da>] __alloc_pages_direct_compact+0x7a/0x250
>>  [<ffffffff99161fbb>] __alloc_pages_nodemask+0x70b/0xbb0
>>  [<ffffffff991a9c3f>] alloc_pages_vma+0xaf/0x1c0
>>  [<ffffffff991bdc8d>] do_huge_pmd_anonymous_page+0xed/0x3d0
>>  [<ffffffff991871b4>] handle_mm_fault+0x1b4/0xc50
>>  [<ffffffff9974358d>] ? retint_restore_args+0xe/0xe
>>  [<ffffffff99746939>] __do_page_fault+0x1c9/0x630
>>  [<ffffffff99118acb>] ? __acct_update_integrals+0x8b/0x120
>>  [<ffffffff9974725b>] ? preempt_count_sub+0xab/0x100
>>  [<ffffffff99746dbe>] do_page_fault+0x1e/0x70
>>  [<ffffffff997437f2>] page_fault+0x22/0x30
> 
> Well caught again.  This one doesn't seem to have been plaguing users,
> but nice to find and fix it.  I don't think there are any gotchas to
> the patch below (in each case we've done a good atomic_inc_not_zero,
> so the anon_vma cannot be surprisingly freed when we rcu_read_unlock).
> But even so, I don't think it should go into a tree without Ack from
> Peter - in looking back there, he might notice something else has
> changed, or be inspired to fix it in a more satisfying way.
> 
> Hugh
> 
> [PATCH] mm: fix sleeping function warning from __put_anon_vma
> 
> Trinity reports BUG:
> sleeping function called from invalid context at kernel/locking/rwsem.c:47
> in_atomic(): 0, irqs_disabled(): 0, pid: 5787, name: trinity-c27
> __might_sleep < down_write < __put_anon_vma < page_get_anon_vma <
> migrate_pages < compact_zone < compact_zone_order < try_to_compact_pages ..
> 
> Right, since conversion to mutex then rwsem, we should not put_anon_vma()
> from inside an rcu_read_lock()ed section: fix the two places that did so.
> 
> Fixes: 88c22088bf23 ("mm: optimize page_lock_anon_vma() fast-path")
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Needs-Ack-from: Peter Zijlstra <peterz@infradead.org>
> ---
> 
>  mm/rmap.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> --- 3.15-rc7/mm/rmap.c	2014-04-13 17:24:36.680507189 -0700
> +++ linux/mm/rmap.c	2014-05-31 12:02:08.496088637 -0700
> @@ -426,12 +426,14 @@ struct anon_vma *page_get_anon_vma(struc
>  	 * above cannot corrupt).
>  	 */
>  	if (!page_mapped(page)) {
> +		rcu_read_unlock();
>  		put_anon_vma(anon_vma);
>  		anon_vma = NULL;
> +		goto outer;
>  	}
>  out:
>  	rcu_read_unlock();
> -
> +outer:
>  	return anon_vma;
>  }
>  
> @@ -477,9 +479,10 @@ struct anon_vma *page_lock_anon_vma_read
>  	}
>  
>  	if (!page_mapped(page)) {
> +		rcu_read_unlock();
>  		put_anon_vma(anon_vma);
>  		anon_vma = NULL;
> -		goto out;
> +		goto outer;
>  	}
>  
>  	/* we pinned the anon_vma, its safe to sleep */
> @@ -501,6 +504,7 @@ struct anon_vma *page_lock_anon_vma_read
>  
>  out:
>  	rcu_read_unlock();
> +outer:
>  	return anon_vma;
>  }
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
