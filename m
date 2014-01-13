Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3726B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 22:51:44 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so2111826yhz.1
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 19:51:43 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id o28si18762910yhd.266.2014.01.12.19.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 19:51:43 -0800 (PST)
Received: by mail-ig0-f177.google.com with SMTP id k19so1730964igc.4
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 19:51:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140112192744.9bca5c6d.akpm@linux-foundation.org>
References: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
	<20140110171108.32b2be171cd5e54bf22fb2a4@linux-foundation.org>
	<CAL1ERfPnaROPiRAeWHpvwGezHsqN4R8j=QSyS48xs25ax14AhA@mail.gmail.com>
	<20140112192744.9bca5c6d.akpm@linux-foundation.org>
Date: Mon, 13 Jan 2014 11:51:42 +0800
Message-ID: <CAL1ERfOx7NF-GLuCnK4KXYpunKxQnVmSDA6FkPKXH3CxauzQcQ@mail.gmail.com>
Subject: Re: [PATCH] mm/swap: fix race on swap_info reuse between swapoff and swapon
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fusionio.com>, Bob Liu <bob.liu@oracle.com>, stable@vger.kernel.org, Krzysztof Kozlowski <k.kozlowski@samsung.com>

On Mon, Jan 13, 2014 at 11:27 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 13 Jan 2014 11:08:58 +0800 Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>
>> >> --- a/mm/swapfile.c
>> >> +++ b/mm/swapfile.c
>> >> @@ -1922,7 +1922,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>> >>       p->swap_map = NULL;
>> >>       cluster_info = p->cluster_info;
>> >>       p->cluster_info = NULL;
>> >> -     p->flags = 0;
>> >>       frontswap_map = frontswap_map_get(p);
>> >>       spin_unlock(&p->lock);
>> >>       spin_unlock(&swap_lock);
>> >> @@ -1948,6 +1947,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>> >>               mutex_unlock(&inode->i_mutex);
>> >>       }
>> >>       filp_close(swap_file, NULL);
>> >> +
>> >> +     /*
>> >> +     * clear SWP_USED flag after all resources freed
>> >> +     * so that swapon can reuse this swap_info in alloc_swap_info() safely
>> >> +     * it is ok to not hold p->lock after we cleared its SWP_WRITEOK
>> >> +     */
>> >> +     spin_lock(&swap_lock);
>> >> +     p->flags = 0;
>> >> +     spin_unlock(&swap_lock);
>> >> +
>> >>       err = 0;
>> >>       atomic_inc(&proc_poll_event);
>> >>       wake_up_interruptible(&proc_poll_wait);
>> >
>> > I didn't look too closely, but this patch might also address the race
>> > which Krzysztof addressed with
>> > http://ozlabs.org/~akpm/mmots/broken-out/swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch.
>> > Can we please check that out?
>> >
>> > I do prefer fixing all these swapon-vs-swapoff races with some large,
>> > simple, wide-scope exclusion scheme.  Perhaps SWP_USED is that scheme.
>> >
>> > An alternative would be to add another mutex and just make sys_swapon()
>> > and sys_swapoff() 100% exclusive.  But that is plastering yet another
>> > lock over this mess to hide the horrors which lurk within :(
>> >
>>
>> Hi, Andrew. Thanks for your suggestion.
>>
>> I checked Krzysztof's patch, it use the global swapon_mutex to protect
>> race condition among
>> swapon, swapoff and swap_start(). It is a kind of correct method, but
>> a heavy method.
>
> But do you agree that your
> http://ozlabs.org/~akpm/mmots/broken-out/mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon.patch
> makes Krzysztof's
> http://ozlabs.org/~akpm/mmots/broken-out/swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch
> obsolete?

Yes, I agree.

> I've been sitting on Krzysztof's
> swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch
> for several months - Hugh had issues with it so I put it on hold and
> nothing further happened.
>
>> I will try to resend a patchset to make lock usage in swapfile.c clear
>> and fine grit
>
> OK, thanks.  In the meanwhile I'm planning on dropping Krzysztof's
> patch and merging your patch into 3.14-rc1, which is why I'd like
> confirmation that your patch addresses the issues which Krzysztof
> identified?
>

I think so, Krzysztof and I both try to fix the same issue(reuse
swap_info while its
previous resources are not cleared completely). The different is
Krzysztof's patch
uses a global swapon_mutex and its commit log only focuses on set_blocksize(),
while my patch try to maintain the fine grit lock usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
