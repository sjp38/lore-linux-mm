Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f176.google.com (mail-gg0-f176.google.com [209.85.161.176])
	by kanga.kvack.org (Postfix) with ESMTP id BC5AA6B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 22:09:00 -0500 (EST)
Received: by mail-gg0-f176.google.com with SMTP id b1so1579404ggn.35
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 19:09:00 -0800 (PST)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id z48si18697052yha.106.2014.01.12.19.08.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 19:08:59 -0800 (PST)
Received: by mail-ie0-f172.google.com with SMTP id u16so6814736iet.31
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 19:08:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140110171108.32b2be171cd5e54bf22fb2a4@linux-foundation.org>
References: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
	<20140110171108.32b2be171cd5e54bf22fb2a4@linux-foundation.org>
Date: Mon, 13 Jan 2014 11:08:58 +0800
Message-ID: <CAL1ERfPnaROPiRAeWHpvwGezHsqN4R8j=QSyS48xs25ax14AhA@mail.gmail.com>
Subject: Re: [PATCH] mm/swap: fix race on swap_info reuse between swapoff and swapon
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fusionio.com>, Bob Liu <bob.liu@oracle.com>, stable@vger.kernel.org, Krzysztof Kozlowski <k.kozlowski@samsung.com>

On Sat, Jan 11, 2014 at 9:11 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 09 Jan 2014 13:39:55 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:
>
>> swapoff clear swap_info's SWP_USED flag prematurely and free its resources
>> after that. A concurrent swapon will reuse this swap_info while its previous
>> resources are not cleared completely.
>>
>> These late freed resources are:
>> - p->percpu_cluster
>> - swap_cgroup_ctrl[type]
>> - block_device setting
>> - inode->i_flags &= ~S_SWAPFILE
>>
>> This patch clear SWP_USED flag after all its resources freed, so that swapon
>> can reuse this swap_info by alloc_swap_info() safely.
>>
>> ...
>>
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -1922,7 +1922,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>       p->swap_map = NULL;
>>       cluster_info = p->cluster_info;
>>       p->cluster_info = NULL;
>> -     p->flags = 0;
>>       frontswap_map = frontswap_map_get(p);
>>       spin_unlock(&p->lock);
>>       spin_unlock(&swap_lock);
>> @@ -1948,6 +1947,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>>               mutex_unlock(&inode->i_mutex);
>>       }
>>       filp_close(swap_file, NULL);
>> +
>> +     /*
>> +     * clear SWP_USED flag after all resources freed
>> +     * so that swapon can reuse this swap_info in alloc_swap_info() safely
>> +     * it is ok to not hold p->lock after we cleared its SWP_WRITEOK
>> +     */
>> +     spin_lock(&swap_lock);
>> +     p->flags = 0;
>> +     spin_unlock(&swap_lock);
>> +
>>       err = 0;
>>       atomic_inc(&proc_poll_event);
>>       wake_up_interruptible(&proc_poll_wait);
>
> I didn't look too closely, but this patch might also address the race
> which Krzysztof addressed with
> http://ozlabs.org/~akpm/mmots/broken-out/swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch.
> Can we please check that out?
>
> I do prefer fixing all these swapon-vs-swapoff races with some large,
> simple, wide-scope exclusion scheme.  Perhaps SWP_USED is that scheme.
>
> An alternative would be to add another mutex and just make sys_swapon()
> and sys_swapoff() 100% exclusive.  But that is plastering yet another
> lock over this mess to hide the horrors which lurk within :(
>

Hi, Andrew. Thanks for your suggestion.

I checked Krzysztof's patch, it use the global swapon_mutex to protect
race condition among
swapon, swapoff and swap_start(). It is a kind of correct method, but
a heavy method.

I will try to resend a patchset to make lock usage in swapfile.c clear
and fine grit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
