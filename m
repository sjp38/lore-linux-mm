Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B750F6B0038
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 20:31:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id i66so5149056itf.0
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 17:31:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e71sor14634684ita.106.2017.12.30.17.31.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Dec 2017 17:31:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9b4ff6ee-3f77-2a97-05bb-1bc9c562ab0c@os.korea.ac.kr>
References: <20171229095241.23345-1-nefelim4ag@gmail.com> <CAGqmi77nViCyuXhZ92fSSO0oiM1o7wRFR8tqb6YRtC7SvMOdbg@mail.gmail.com>
 <9b4ff6ee-3f77-2a97-05bb-1bc9c562ab0c@os.korea.ac.kr>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Sun, 31 Dec 2017 04:30:58 +0300
Message-ID: <CAGqmi75pZE98UJ+09RsL7j7K0u8FXvndzgx9m0FLaJ+U5zzPsw@mail.gmail.com>
Subject: Re: [PATCH v2] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sioh Lee <solee@os.korea.ac.kr>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

Hi,
I was send v5, with minor changes,
but performance numbers are valid.

2017-12-31 3:07 GMT+03:00 sioh Lee <solee@os.korea.ac.kr>:
> hello
>
> First, thanks for organizing all the experiments.
>
> and i'm sending you the results of experiments
>
> Test platform: openstack cloud platform (NEWTON version)
> Experiment node: openstack based cloud compute node (CPU: xeon E5-2620 v3=
, memory 64gb)
> VM: (2 VCPU, RAM 4GB, DISK 20GB) * 4
> Linux kernel: 4.14 (latest version)
> KSM setup - sleep_millisecs: 200ms, pages_to_scan: 200
>
> Experiment process
> Firstly, we turn off KSM and launch 4 VMs.
> Then we turn on the KSM and measure the checksum computation time until f=
ull_scans become two.
>
> The experimental results (the experimental value is the average of the me=
asured values)
> crc32c_intel: 1084.10ns
> crc32c (no hardware acceleration): 7012.51ns
> xxhash32: 2227.75ns
> xxhash64: 1413.16ns
> jhash2: 5128.30ns
>
> In summary, the result shows that crc32c_intel has advantages over all of=
 the hash function used in the experiment. (decreased by 84.54% compared to=
 crc32c, 78.86% compared to jhash2, 51.33% xxhash32, 23.28% compared to xxh=
ash64)
>
> the results are similar to those of Timofey.
>
> anyway, i saw the problem of Timofey and i had the same situation before.
>
> the solution is to call crc32c using crce32c library instead of shash all=
oc (e.g. checksum =3D crc32c(0,addr,PAGE_SIZE);)

Not sure what are better allocate own shash, or use library crc32c,
because in both cases we need external dep and performance are same.
Usage of Crypto API and that library, looks mixed in kernel.

> and change code from subsys_initcall(ksm_init)  to  late_initcall(ksm_ini=
t).
>
> I have solved kernel problem using this method so this will be helpful.
That proof, what i understood correctly, ksm run too early %).

I have other workaround in V5 patch.
i.e. i already do 'choice checksum on first hash call'.
Only that i did, is move zero_checksum calculation to first call of fasthas=
h().

That can just be never called, or will called late enough, where init are d=
one.
(I.e. that will happen on first call of first ksm_enter()).

What better, your solution or mine, or we must again mix the work,
i can't say.

> please tell me if other problems exists.
No other problem exists.

> thanks.
>
> -sioh lee-
>

In sum, we can prove, change hash are useful and good performance
improvement in general.
With good potential on hardware acceleration on CPU.

Let's wait on advice of mm folks,
If that ok, and that do next if needed.

Thanks!

> 2017-12-31 =EC=98=A4=EC=A0=84 6:27=EC=97=90 Timofey Titovets =EC=9D=B4(=
=EA=B0=80) =EC=93=B4 =EA=B8=80:
>> *FACEPALM*,
>> Sorry, just forgot about numbering of old jhash2 -> xxhash conversion
>> Also pickup patch for xxhash - arch dependent xxhash() function that wil=
l use
>> fastest algo for current arch.
>>
>> So next will be v5, as that must be v4.
>>
>> Thanks.
>>
>> 2017-12-29 12:52 GMT+03:00 Timofey Titovets <nefelim4ag@gmail.com>:
>>> Pickup, Sioh Lee crc32 patch, after some long conversation
>>> and hassles, merge with my work on xxhash, add
>>> choice fastest hash helper.
>>>
>>> Base idea are same, replace jhash2 with something faster.
>>>
>>> Perf numbers:
>>> Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
>>> ksm: crc32c   hash() 12081 MB/s
>>> ksm: jhash2   hash()  1569 MB/s
>>> ksm: xxh64    hash()  8770 MB/s
>>> ksm: xxh32    hash()  4529 MB/s
>>>
>>> As jhash2 always will be slower, just drop it from choice.
>>>
>>> Add function to autoselect hash algo on boot, based on speed,
>>> like raid6 code does.
>>>
>>> Move init of zero_hash from init, to start of ksm thread,
>>> as ksm init run on early kernel init, run perf testing stuff on
>>> main kernel thread looks bad to me.
>>>
>>> One problem exists with that patch,
>>> ksm init run too early, and crc32c module, even compiled in
>>> can't be found, so i see:
>>>  - ksm: alloc crc32c shash error 2 in dmesg.
>>>
>>> I give up on that, so ideas welcomed.
>>>
>>> Only idea that i have, are to avoid early init by moving
>>> zero_checksum to sysfs_store parm,
>>> i.e. that's default to false, and that will work, i think.
>>>
>>> Thanks.
>>>
>>> Changes:
>>>   v1 -> v2:
>>>     - Merge xxhash/crc32 patches
>>>     - Replace crc32 with crc32c (crc32 have same as jhash2 speed)
>>>     - Add auto speed test and auto choice of fastest hash function
>>>
>>> Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
>>> Signed-off-by: leesioh <solee@os.korea.ac.kr>
>>> CC: Andrea Arcangeli <aarcange@redhat.com>
>>> CC: linux-mm@kvack.org
>>> CC: kvm@vger.kernel.org
>>> ---
>>>  mm/Kconfig |   4 ++
>>>  mm/ksm.c   | 133 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++-----
>>>  2 files changed, 128 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>> index 03ff7703d322..d4fb147d4a22 100644
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -305,6 +305,10 @@ config MMU_NOTIFIER
>>>  config KSM
>>>         bool "Enable KSM for page merging"
>>>         depends on MMU
>>> +       select XXHASH
>>> +       select CRYPTO
>>> +       select CRYPTO_HASH
>>> +       select CONFIG_CRYPTO_CRC32C
>>>         help
>>>           Enable Kernel Samepage Merging: KSM periodically scans those =
areas
>>>           of an application's address space that an app has advised may=
 be
>>> diff --git a/mm/ksm.c b/mm/ksm.c
>>> index be8f4576f842..fd5c9d0f7bc2 100644
>>> --- a/mm/ksm.c
>>> +++ b/mm/ksm.c
>>> @@ -25,7 +25,6 @@
>>>  #include <linux/pagemap.h>
>>>  #include <linux/rmap.h>
>>>  #include <linux/spinlock.h>
>>> -#include <linux/jhash.h>
>>>  #include <linux/delay.h>
>>>  #include <linux/kthread.h>
>>>  #include <linux/wait.h>
>>> @@ -41,6 +40,12 @@
>>>  #include <linux/numa.h>
>>>
>>>  #include <asm/tlbflush.h>
>>> +
>>> +/* Support for xxhash and crc32c */
>>> +#include <linux/crypto.h>
>>> +#include <crypto/hash.h>
>>> +#include <linux/xxhash.h>
>>> +
>>>  #include "internal.h"
>>>
>>>  #ifdef CONFIG_NUMA
>>> @@ -186,7 +191,7 @@ struct rmap_item {
>>>         };
>>>         struct mm_struct *mm;
>>>         unsigned long address;          /* + low bits used for flags be=
low */
>>> -       unsigned int oldchecksum;       /* when unstable */
>>> +       unsigned long oldchecksum;      /* when unstable */
>>>         union {
>>>                 struct rb_node node;    /* when node of unstable tree *=
/
>>>                 struct {                /* when listed from stable tree=
 */
>>> @@ -255,7 +260,7 @@ static unsigned int ksm_thread_pages_to_scan =3D 10=
0;
>>>  static unsigned int ksm_thread_sleep_millisecs =3D 20;
>>>
>>>  /* Checksum of an empty (zeroed) page */
>>> -static unsigned int zero_checksum __read_mostly;
>>> +static unsigned long zero_checksum __read_mostly;
>>>
>>>  /* Whether to merge empty (zeroed) pages with actual zero pages */
>>>  static bool ksm_use_zero_pages __read_mostly;
>>> @@ -284,6 +289,115 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
>>>                 sizeof(struct __struct), __alignof__(struct __struct),\
>>>                 (__flags), NULL)
>>>
>>> +#define CRC32C_HASH 1
>>> +#define XXH32_HASH  2
>>> +#define XXH64_HASH  3
>>> +
>>> +const static char *hash_func_names[] =3D { "", "crc32c", "xxh32", "xxh=
64" };
>>> +
>>> +static struct shash_desc desc;
>>> +static struct crypto_shash *tfm;
>>> +static uint8_t fastest_hash =3D 0;
>>> +
>>> +static void __init choice_fastest_hash(void)
>>> +{
>>> +       void *page =3D kmalloc(PAGE_SIZE, GFP_KERNEL);
>>> +       unsigned long checksum, perf, js, je;
>>> +       unsigned long best_perf =3D 0;
>>> +
>>> +       tfm =3D crypto_alloc_shash(hash_func_names[CRC32C_HASH],
>>> +                                CRYPTO_ALG_TYPE_SHASH, 0);
>>> +
>>> +       if (IS_ERR(tfm)) {
>>> +               pr_warn("ksm: alloc %s shash error %ld\n",
>>> +                       hash_func_names[CRC32C_HASH], -PTR_ERR(tfm));
>>> +       } else {
>>> +               desc.tfm =3D tfm;
>>> +               desc.flags =3D 0;
>>> +
>>> +               perf =3D 0;
>>> +               preempt_disable();
>>> +               js =3D jiffies;
>>> +               je =3D js + (HZ >> 3);
>>> +               while (time_before(jiffies, je)) {
>>> +                       crypto_shash_digest(&desc, page, PAGE_SIZE,
>>> +                                           (u8 *)&checksum);
>>> +                       perf++;
>>> +               }
>>> +               preempt_enable();
>>> +               if (best_perf < perf) {
>>> +                       best_perf =3D perf;
>>> +                       fastest_hash =3D CRC32C_HASH;
>>> +               }
>>> +               pr_info("ksm: %-8s hash() %5ld MB/s\n",
>>> +                       hash_func_names[CRC32C_HASH], perf*PAGE_SIZE >>=
 17);
>>> +       }
>>> +
>>> +       perf =3D 0;
>>> +       preempt_disable();
>>> +       js =3D jiffies;
>>> +       je =3D js + (HZ >> 3);
>>> +       while (time_before(jiffies, je)) {
>>> +               checksum =3D xxh32(page, PAGE_SIZE, 0);
>>> +               perf++;
>>> +       }
>>> +       preempt_enable();
>>> +       if (best_perf < perf) {
>>> +               best_perf =3D perf;
>>> +               fastest_hash =3D XXH32_HASH;
>>> +       }
>>> +       pr_info("ksm: %-8s hash() %5ld MB/s\n",
>>> +               hash_func_names[XXH32_HASH], perf*PAGE_SIZE >> 17);
>>> +
>>> +       perf =3D 0;
>>> +       preempt_disable();
>>> +       js =3D jiffies;
>>> +       je =3D js + (HZ >> 3);
>>> +       while (time_before(jiffies, je)) {
>>> +               checksum =3D xxh64(page, PAGE_SIZE, 0);
>>> +               perf++;
>>> +       }
>>> +       preempt_enable();
>>> +       if (best_perf < perf) {
>>> +               best_perf =3D perf;
>>> +               fastest_hash =3D XXH64_HASH;
>>> +       }
>>> +       pr_info("ksm: %-8s hash() %5ld MB/s\n",
>>> +               hash_func_names[XXH64_HASH], perf*PAGE_SIZE >> 17);
>>> +
>>> +       if (!IS_ERR(tfm) && fastest_hash !=3D CRC32C_HASH)
>>> +               crypto_free_shash(tfm);
>>> +
>>> +       pr_info("ksm: choise %s as hash function\n",
>>> +               hash_func_names[fastest_hash]);
>>> +
>>> +       kfree(page);
>>> +}
>>> +
>>> +unsigned long fasthash(const void *input, size_t length)
>>> +{
>>> +       unsigned long checksum =3D 0;
>>> +
>>> +       switch (fastest_hash) {
>>> +       case 0:
>>> +               choice_fastest_hash();
>>> +               checksum =3D fasthash(input, length);
>>> +               break;
>>> +       case CRC32C_HASH:
>>> +               crypto_shash_digest(&desc, input, length,
>>> +                           (u8 *)&checksum);
>>> +               break;
>>> +       case XXH32_HASH:
>>> +               checksum =3D xxh32(input, length, 0);
>>> +               break;
>>> +       case XXH64_HASH:
>>> +               checksum =3D xxh64(input, length, 0);
>>> +               break;
>>> +       }
>>> +
>>> +       return checksum;
>>> +}
>>> +
>>>  static int __init ksm_slab_init(void)
>>>  {
>>>         rmap_item_cache =3D KSM_KMEM_CACHE(rmap_item, 0);
>>> @@ -982,11 +1096,11 @@ static int unmerge_and_remove_all_rmap_items(voi=
d)
>>>  }
>>>  #endif /* CONFIG_SYSFS */
>>>
>>> -static u32 calc_checksum(struct page *page)
>>> +static unsigned long calc_checksum(struct page *page)
>>>  {
>>> -       u32 checksum;
>>> +       unsigned long checksum;
>>>         void *addr =3D kmap_atomic(page);
>>> -       checksum =3D jhash2(addr, PAGE_SIZE / 4, 17);
>>> +       checksum =3D fasthash(addr, PAGE_SIZE);
>>>         kunmap_atomic(addr);
>>>         return checksum;
>>>  }
>>> @@ -2006,7 +2120,7 @@ static void cmp_and_merge_page(struct page *page,=
 struct rmap_item *rmap_item)
>>>         struct page *tree_page =3D NULL;
>>>         struct stable_node *stable_node;
>>>         struct page *kpage;
>>> -       unsigned int checksum;
>>> +       unsigned long checksum;
>>>         int err;
>>>         bool max_page_sharing_bypass =3D false;
>>>
>>> @@ -2336,6 +2450,9 @@ static int ksm_scan_thread(void *nothing)
>>>         set_freezable();
>>>         set_user_nice(current, 5);
>>>
>>> +       /* The correct value depends on page size and endianness */
>>> +       zero_checksum =3D calc_checksum(ZERO_PAGE(0));
>>> +
>>>         while (!kthread_should_stop()) {
>>>                 mutex_lock(&ksm_thread_mutex);
>>>                 wait_while_offlining();
>>> @@ -3068,8 +3185,6 @@ static int __init ksm_init(void)
>>>         struct task_struct *ksm_thread;
>>>         int err;
>>>
>>> -       /* The correct value depends on page size and endianness */
>>> -       zero_checksum =3D calc_checksum(ZERO_PAGE(0));
>>>         /* Default to false for backwards compatibility */
>>>         ksm_use_zero_pages =3D false;
>>>
>>> --
>>> 2.15.1
>>
>>
>



--=20
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
