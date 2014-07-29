Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BA52C6B0035
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 11:04:52 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so12482745pad.21
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:04:52 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2lp0210.outbound.protection.outlook.com. [207.46.163.210])
        by mx.google.com with ESMTPS id dl5si9837811pbb.173.2014.07.29.08.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Jul 2014 08:04:51 -0700 (PDT)
Message-ID: <53D7B800.6050700@amd.com>
Date: Tue, 29 Jul 2014 18:04:32 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mmu_notifier: add call_srcu and sync function for
 listener to delay call and sync.
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
 <1405622809-3797-2-git-send-email-j.glisse@gmail.com>
 <53CD2B43.3090405@amd.com>
In-Reply-To: <53CD2B43.3090405@amd.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: j.glisse@gmail.com, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind
 Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John
 Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xp?= =?UTF-8?B?c3Nl?= <jglisse@redhat.com>

On 21/07/14 18:01, Oded Gabbay wrote:
> On 17/07/14 21:46, j.glisse@gmail.com wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> New mmu_notifier listener are eager to cleanup there structure after t=
he
>> mmu_notifier::release callback. In order to allow this the patch provi=
de
>> a function that allows to add a delayed call to the mmu_notifier srcu.=
 It
>> also add a function that will call barrier_srcu so those listener can =
sync
>> with mmu_notifier.
>
> Tested with amdkfd and iommuv2 driver
> So,
> Tested-by: Oded Gabbay <oded.gabbay@amd.com>

akpm, any chance that only this specific patch from Peter.Z will get in 3=
.17 ?
I must have it for amdkfd (HSA driver). Without it, I can't be in 3.17 ei=
ther.

	Oded

>>
>> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> ---
>>   include/linux/mmu_notifier.h |  6 ++++++
>>   mm/mmu_notifier.c            | 40 ++++++++++++++++++++++++++++++++++=
+++++-
>>   2 files changed, 45 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier=
.h
>> index deca874..2728869 100644
>> --- a/include/linux/mmu_notifier.h
>> +++ b/include/linux/mmu_notifier.h
>> @@ -170,6 +170,8 @@ extern int __mmu_notifier_register(struct mmu_noti=
fier *mn,
>>                      struct mm_struct *mm);
>>   extern void mmu_notifier_unregister(struct mmu_notifier *mn,
>>                       struct mm_struct *mm);
>> +extern void mmu_notifier_unregister_no_release(struct mmu_notifier *m=
n,
>> +                           struct mm_struct *mm);
>>   extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
>>   extern void __mmu_notifier_release(struct mm_struct *mm);
>>   extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
>> @@ -288,6 +290,10 @@ static inline void mmu_notifier_mm_destroy(struct
>> mm_struct *mm)
>>       set_pte_at(___mm, ___address, __ptep, ___pte);            \
>>   })
>>
>> +extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
>> +                   void (*func)(struct rcu_head *rcu));
>> +extern void mmu_notifier_synchronize(void);
>> +
>>   #else /* CONFIG_MMU_NOTIFIER */
>>
>>   static inline void mmu_notifier_release(struct mm_struct *mm)
>> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
>> index 41cefdf..950813b 100644
>> --- a/mm/mmu_notifier.c
>> +++ b/mm/mmu_notifier.c
>> @@ -23,6 +23,25 @@
>>   static struct srcu_struct srcu;
>>
>>   /*
>> + * This function allows mmu_notifier::release callback to delay a cal=
l to
>> + * a function that will free appropriate resources. The function must=
 be
>> + * quick and must not block.
>> + */
>> +void mmu_notifier_call_srcu(struct rcu_head *rcu,
>> +                void (*func)(struct rcu_head *rcu))
>> +{
>> +    call_srcu(&srcu, rcu, func);
>> +}
>> +EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
>> +
>> +void mmu_notifier_synchronize(void)
>> +{
>> +    /* Wait for any running method to finish. */
>> +    srcu_barrier(&srcu);
>> +}
>> +EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
>> +
>> +/*
>>    * This function can't run concurrently against mmu_notifier_registe=
r
>>    * because mm->mm_users > 0 during mmu_notifier_register and exit_mm=
ap
>>    * runs with mm_users =3D=3D 0. Other tasks may still invoke mmu not=
ifiers
>> @@ -53,7 +72,6 @@ void __mmu_notifier_release(struct mm_struct *mm)
>>            */
>>           if (mn->ops->release)
>>               mn->ops->release(mn, mm);
>> -    srcu_read_unlock(&srcu, id);
>>
>>       spin_lock(&mm->mmu_notifier_mm->lock);
>>       while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
>> @@ -69,6 +87,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
>>           hlist_del_init_rcu(&mn->hlist);
>>       }
>>       spin_unlock(&mm->mmu_notifier_mm->lock);
>> +    srcu_read_unlock(&srcu, id);
>>
>>       /*
>>        * synchronize_srcu here prevents mmu_notifier_release from retu=
rning to
>> @@ -325,6 +344,25 @@ void mmu_notifier_unregister(struct mmu_notifier =
*mn,
>> struct mm_struct *mm)
>>   }
>>   EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
>>
>> +/*
>> + * Same as mmu_notifier_unregister but no callback and no srcu synchr=
onization.
>> + */
>> +void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
>> +                    struct mm_struct *mm)
>> +{
>> +    spin_lock(&mm->mmu_notifier_mm->lock);
>> +    /*
>> +     * Can not use list_del_rcu() since __mmu_notifier_release
>> +     * can delete it before we hold the lock.
>> +     */
>> +    hlist_del_init_rcu(&mn->hlist);
>> +    spin_unlock(&mm->mmu_notifier_mm->lock);
>> +
>> +    BUG_ON(atomic_read(&mm->mm_count) <=3D 0);
>> +    mmdrop(mm);
>> +}
>> +EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
>> +
>>   static int __init mmu_notifier_init(void)
>>   {
>>       return init_srcu_struct(&srcu);
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
