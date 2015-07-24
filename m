Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF976B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:26:05 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so30411541wib.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:26:05 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id q8si4624351wiz.6.2015.07.24.07.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 07:26:03 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so30320071wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:26:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150721121932.GJ11967@dhcp22.suse.cz>
References: <1434398602.1903.15.camel@stgolabs.net> <1437080113.3596.2.camel@stgolabs.net>
 <20150721121932.GJ11967@dhcp22.suse.cz>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 24 Jul 2015 10:25:33 -0400
Message-ID: <CAP=VYLr0rPWi1aeuk4w1On9CYRNmnEWwJgGtaX=wEvGaBURtrg@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm: srcu-ify shrinkers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On Tue, Jul 21, 2015 at 8:19 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 16-07-15 13:55:13, Davidlohr Bueso wrote:
>> The shrinker_rwsem is a global lock that protects the shrinker_list,
>> serializing a shrinking call with register/unregistering the shrinker
>> itself. As such, this lock is taken mostly for reading. In the unlikely
>> case that the the list is being modified, we simply return indicating
>> we want to iterate again. However, the only caller of shrink_slab()
>> that acknowledges this return is drop_slab_node(), so in practice, the
>> rest of the callers never try again.
>>
>> This patch proposes replacing the rwsem with an srcu aware list of
>> shrinkers, where (un)registering tasks use a spinlock. Upon shrinker
>> calls, the srcu read lock will guarantee the existence of the structure,
>> thus safely optimizing the common (read locked) case. These guarantees
>> also allow us to cleanup and simplify the code, getting rid of the
>> ugly trylock mechanism to retry the shrinker operation when the list
>> is concurrently being modified. As Michal pointed this is only worth
>> mentioning for unregister purposes.
>>
>> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>
> Looks reasonable to me. I am pretty sure that any performance
> improvements are close to 0 but the code looks better to me.
>
> Acked-by: Michal Hocko <mhocko@suse.com>

The version of this commit in linux-next currently fails on arm allnoconfig:

mm/built-in.o: In function `shrink_slab.part.66.constprop.73':
slub.c:(.text+0xce10): undefined reference to `__srcu_read_lock'
slub.c:(.text+0xd00c): undefined reference to `__srcu_read_unlock'
mm/built-in.o: In function `unregister_shrinker':
slub.c:(.text+0xd0f4): undefined reference to `synchronize_srcu'
mm/built-in.o:(.data+0x1c8): undefined reference to `process_srcu'
make: *** [vmlinux] Error 1

Bisect says:

dab937da82f9504fbac75592a1825614318d73e7 is the first bad commit
commit dab937da82f9504fbac75592a1825614318d73e7
Author: Davidlohr Bueso <dave@stgolabs.net>
Date:   Fri Jul 24 09:11:26 2015 +1000

    mm: srcu-ify shrinkers

Paul.
--

>> ---
>> Changes from v1:
>>  - Got rid of the trylock, per mhocko.
>>
>>  fs/super.c  |  8 ++++----
>>  mm/vmscan.c | 39 ++++++++++++++++++---------------------
>>  2 files changed, 22 insertions(+), 25 deletions(-)
>>
>> diff --git a/fs/super.c b/fs/super.c
>> index b613723..c917817 100644
>> --- a/fs/super.c
>> +++ b/fs/super.c
>> @@ -49,8 +49,8 @@ static char *sb_writers_name[SB_FREEZE_LEVELS] = {
>>   * One thing we have to be careful of with a per-sb shrinker is that we don't
>>   * drop the last active reference to the superblock from within the shrinker.
>>   * If that happens we could trigger unregistering the shrinker from within the
>> - * shrinker path and that leads to deadlock on the shrinker_rwsem. Hence we
>> - * take a passive reference to the superblock to avoid this from occurring.
>> + * shrinker path. Hence we take a passive reference to the superblock to avoid
>> + * this from occurring.
>>   */
>>  static unsigned long super_cache_scan(struct shrinker *shrink,
>>                                     struct shrink_control *sc)
>> @@ -121,8 +121,8 @@ static unsigned long super_cache_count(struct shrinker *shrink,
>>        * Don't call trylock_super as it is a potential
>>        * scalability bottleneck. The counts could get updated
>>        * between super_cache_count and super_cache_scan anyway.
>> -      * Call to super_cache_count with shrinker_rwsem held
>> -      * ensures the safety of call to list_lru_shrink_count() and
>> +      * SRCU guarantees object validity across this call -- thus
>> +      * it is safe to call list_lru_shrink_count() and
>>        * s_op->nr_cached_objects().
>>        */
>>       if (sb->s_op && sb->s_op->nr_cached_objects)
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index c8d8282..fc820cf 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -36,7 +36,7 @@
>>  #include <linux/cpuset.h>
>>  #include <linux/compaction.h>
>>  #include <linux/notifier.h>
>> -#include <linux/rwsem.h>
>> +#include <linux/srcu.h>
>>  #include <linux/delay.h>
>>  #include <linux/kthread.h>
>>  #include <linux/freezer.h>
>> @@ -146,8 +146,9 @@ int vm_swappiness = 60;
>>   */
>>  unsigned long vm_total_pages;
>>
>> +DEFINE_STATIC_SRCU(shrinker_srcu);
>>  static LIST_HEAD(shrinker_list);
>> -static DECLARE_RWSEM(shrinker_rwsem);
>> +static DEFINE_SPINLOCK(shrinker_list_lock);
>>
>>  #ifdef CONFIG_MEMCG
>>  static bool global_reclaim(struct scan_control *sc)
>> @@ -242,9 +243,9 @@ int register_shrinker(struct shrinker *shrinker)
>>       if (!shrinker->nr_deferred)
>>               return -ENOMEM;
>>
>> -     down_write(&shrinker_rwsem);
>> -     list_add_tail(&shrinker->list, &shrinker_list);
>> -     up_write(&shrinker_rwsem);
>> +     spin_lock(&shrinker_list_lock);
>> +     list_add_tail_rcu(&shrinker->list, &shrinker_list);
>> +     spin_unlock(&shrinker_list_lock);
>>       return 0;
>>  }
>>  EXPORT_SYMBOL(register_shrinker);
>> @@ -254,9 +255,14 @@ EXPORT_SYMBOL(register_shrinker);
>>   */
>>  void unregister_shrinker(struct shrinker *shrinker)
>>  {
>> -     down_write(&shrinker_rwsem);
>> -     list_del(&shrinker->list);
>> -     up_write(&shrinker_rwsem);
>> +     spin_lock(&shrinker_list_lock);
>> +     list_del_rcu(&shrinker->list);
>> +     spin_unlock(&shrinker_list_lock);
>> +     /*
>> +      * Before freeing nr_deferred, ensure all srcu
>> +      * readers are done with their critical region.
>> +      */
>> +     synchronize_srcu(&shrinker_srcu);
>>       kfree(shrinker->nr_deferred);
>>  }
>>  EXPORT_SYMBOL(unregister_shrinker);
>> @@ -408,6 +414,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>                                unsigned long nr_scanned,
>>                                unsigned long nr_eligible)
>>  {
>> +     int idx;
>>       struct shrinker *shrinker;
>>       unsigned long freed = 0;
>>
>> @@ -417,18 +424,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>       if (nr_scanned == 0)
>>               nr_scanned = SWAP_CLUSTER_MAX;
>>
>> -     if (!down_read_trylock(&shrinker_rwsem)) {
>> -             /*
>> -              * If we would return 0, our callers would understand that we
>> -              * have nothing else to shrink and give up trying. By returning
>> -              * 1 we keep it going and assume we'll be able to shrink next
>> -              * time.
>> -              */
>> -             freed = 1;
>> -             goto out;
>> -     }
>> +     idx = srcu_read_lock(&shrinker_srcu);
>>
>> -     list_for_each_entry(shrinker, &shrinker_list, list) {
>> +     list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
>>               struct shrink_control sc = {
>>                       .gfp_mask = gfp_mask,
>>                       .nid = nid,
>> @@ -444,8 +442,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>               freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
>>       }
>>
>> -     up_read(&shrinker_rwsem);
>> -out:
>> +     srcu_read_unlock(&shrinker_srcu, idx);
>>       cond_resched();
>>       return freed;
>>  }
>> --
>> 2.1.4
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
> --
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
