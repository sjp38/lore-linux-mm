Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 614926B0145
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 10:28:02 -0400 (EDT)
Message-ID: <4E00A96D.8020806@draigBrady.com>
Date: Tue, 21 Jun 2011 15:23:41 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <4E0069FE.4000708@draigBrady.com> <20110621103920.GF9396@suse.de> <4E0076C7.4000809@draigBrady.com> <20110621113447.GG9396@suse.de> <4E008784.80107@draigBrady.com> <20110621130756.GH9396@suse.de>
In-Reply-To: <20110621130756.GH9396@suse.de>
Content-Type: multipart/mixed;
 boundary="------------040405040406070906010105"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------040405040406070906010105
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

On 21/06/11 14:07, Mel Gorman wrote:
> On Tue, Jun 21, 2011 at 12:59:00PM +0100, P?draig Brady wrote:
>> On 21/06/11 12:34, Mel Gorman wrote:
>>> On Tue, Jun 21, 2011 at 11:47:35AM +0100, P?draig Brady wrote:
>>>> On 21/06/11 11:39, Mel Gorman wrote:
>>>>> On Tue, Jun 21, 2011 at 10:53:02AM +0100, P?draig Brady wrote:
>>>>>> I tried the 2 patches here to no avail:
>>>>>> http://marc.info/?l=linux-mm&m=130503811704830&w=2
>>>>>>
>>>>>> I originally logged this at:
>>>>>> https://bugzilla.redhat.com/show_bug.cgi?id=712019
>>>>>>
>>>>>> I can compile up and quickly test any suggestions.
>>>>>>
>>>>>
>>>>> I recently looked through what kswapd does and there are a number
>>>>> of problem areas. Unfortunately, I haven't gotten around to doing
>>>>> anything about it yet or running the test cases to see if they are
>>>>> really problems. In your case, the following is a strong possibility
>>>>> though. This should be applied on top of the two patches merged from
>>>>> that thread.
>>>>>
>>>>> This is not tested in any way, based on 3.0-rc3
>>>>
>>>> This does not fix the issue here.
>>>>
>>>
>>> I made a silly mistake here.  When you mentioned two patches applied,
>>> I assumed you meant two patches that were finally merged from that
>>> discussion thread instead of looking at your linked mail. Now that I
>>> have checked, I think you applied the SLUB patches while the patches
>>> I was thinking of are;
>>>
>>> [afc7e326: mm: vmscan: correct use of pgdat_balanced in sleeping_prematurely]
>>> [f06590bd: mm: vmscan: correctly check if reclaimer should schedule during shrink_slab]
>>>
>>> The first one in particular has been reported by another user to fix
>>> hangs related to copying large files. I'm assuming you are testing
>>> against the Fedora kernel. As these patches were merged for 3.0-rc1, can
>>> you check if applying just these two patches to your kernel helps?
>>
>> These patches are already present in my 2.6.38.8-32.fc15.x86_64 kernel :(
>>
> 
> Would it be possible to record a profile while it is livelocked to check
> if it's stuck in this loop in shrink_slab()?

I did:

perf record -a -g sleep 10
perf report --stdio > livelock.perf #attached
perf annotate shrink_slab -k rpmbuild/BUILD/kernel-2.6.38.fc15/linux-2.6.38.x86_64/vmlinux > shrink_slab.annotate #attached

> 
>                 while (total_scan >= SHRINK_BATCH) {
>                         long this_scan = SHRINK_BATCH;
>                         int shrink_ret;
>                         int nr_before;
> 
>                         nr_before = do_shrinker_shrink(shrinker, shrink, 0);
>                         shrink_ret = do_shrinker_shrink(shrinker, shrink,
>                                                         this_scan);
>                         if (shrink_ret == -1)
>                                 break;
>                         if (shrink_ret < nr_before)
>                                 ret += nr_before - shrink_ret;
>                         count_vm_events(SLABS_SCANNED, this_scan);
>                         total_scan -= this_scan;
> 
>                         cond_resched();
>                 }

shrink_slab() looks to be the culprit, but it seems
to be the loop outside the above that is spinning.

> Also, can you post the output of sysrq+m at a few different times while
> kswapd is spinning heavily? I want to see if all_unreclaimable has been
> set on zones with a reasonable amount of memory. If they are, it's
> possible for kswapd to be in a continual loop calling shrink_slab() and
> skipping over normal page reclaim because all_unreclaimable is set
> everywhere until a page is freed.

I did that 3 times. Attached.

cheers,
Padraig.

--------------040405040406070906010105
Content-Type: text/plain;
 name="shrink_slab.annotate"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="shrink_slab.annotate"



------------------------------------------------
 Percent |	Source code & Disassembly of vmlinux
------------------------------------------------
         :
         :
         :
         :	Disassembly of section .text:
         :
         :	ffffffff810e4460 <shrink_slab>:
         :	 *
         :	 * Returns the number of slab objects which we shrunk.
         :	 */
         :	unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
         :	                        unsigned long lru_pages)
         :	{
    0.00 :	ffffffff810e4460:       55                      push   %rbp
    0.27 :	ffffffff810e4461:       48 89 e5                mov    %rsp,%rbp
    0.00 :	ffffffff810e4464:       41 57                   push   %r15
    0.00 :	ffffffff810e4466:       41 56                   push   %r14
    0.36 :	ffffffff810e4468:       41 55                   push   %r13
    0.00 :	ffffffff810e446a:       41 54                   push   %r12
    0.00 :	ffffffff810e446c:       53                      push   %rbx
    0.00 :	ffffffff810e446d:       48 83 ec 18             sub    $0x18,%rsp
    0.45 :	ffffffff810e4471:       e8 8a 54 f2 ff          callq  ffffffff81009900 <mcount>
         :	        struct shrinker *shrinker;
         :	        unsigned long ret = 0;
         :
         :	        if (scanned == 0)
         :	                scanned = SWAP_CLUSTER_MAX;
    0.00 :	ffffffff810e4476:       b8 20 00 00 00          mov    $0x20,%eax
         :
         :	        if (!down_read_trylock(&shrinker_rwsem)) {
         :	                /* Assume we'll be able to shrink next time */
         :	                ret = 1;
    0.00 :	ffffffff810e447b:       41 bc 01 00 00 00       mov    $0x1,%r12d
         :	{
         :	        struct shrinker *shrinker;
         :	        unsigned long ret = 0;
         :
         :	        if (scanned == 0)
         :	                scanned = SWAP_CLUSTER_MAX;
    0.09 :	ffffffff810e4481:       48 85 ff                test   %rdi,%rdi
         :	 *
         :	 * Returns the number of slab objects which we shrunk.
         :	 */
         :	unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
         :	                        unsigned long lru_pages)
         :	{
    0.00 :	ffffffff810e4484:       49 89 fd                mov    %rdi,%r13
         :	        unsigned long ret = 0;
         :
         :	        if (scanned == 0)
         :	                scanned = SWAP_CLUSTER_MAX;
         :
         :	        if (!down_read_trylock(&shrinker_rwsem)) {
    0.00 :	ffffffff810e4487:       48 c7 c7 30 16 a3 81    mov    $0xffffffff81a31630,%rdi
         :	{
         :	        struct shrinker *shrinker;
         :	        unsigned long ret = 0;
         :
         :	        if (scanned == 0)
         :	                scanned = SWAP_CLUSTER_MAX;
    0.00 :	ffffffff810e448e:       4c 0f 44 e8             cmove  %rax,%r13
         :	 *
         :	 * Returns the number of slab objects which we shrunk.
         :	 */
         :	unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
         :	                        unsigned long lru_pages)
         :	{
    0.27 :	ffffffff810e4492:       41 89 f6                mov    %esi,%r14d
    0.00 :	ffffffff810e4495:       49 89 d7                mov    %rdx,%r15
         :	        unsigned long ret = 0;
         :
         :	        if (scanned == 0)
         :	                scanned = SWAP_CLUSTER_MAX;
         :
         :	        if (!down_read_trylock(&shrinker_rwsem)) {
    0.00 :	ffffffff810e4498:       e8 07 e7 f8 ff          callq  ffffffff81072ba4 <down_read_trylock>
    0.00 :	ffffffff810e449d:       85 c0                   test   %eax,%eax
    0.00 :	ffffffff810e449f:       0f 84 0f 01 00 00       je     ffffffff810e45b4 <shrink_slab+0x154>
         :	                /* Assume we'll be able to shrink next time */
         :	                ret = 1;
         :	                goto out;
         :	        }
         :
         :	        list_for_each_entry(shrinker, &shrinker_list, list) {
    0.00 :	ffffffff810e44a5:       48 8b 1d a4 d1 94 00    mov    0x94d1a4(%rip),%rbx        # ffffffff81a31650 <shrinker_list>
         :	                unsigned long long delta;
         :	                unsigned long total_scan;
         :	                unsigned long max_pass;
         :
         :	                max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
         :	                delta = (4 * scanned) / shrinker->seeks;
    0.71 :	ffffffff810e44ac:       49 c1 e5 02             shl    $0x2,%r13
         :	 */
         :	unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
         :	                        unsigned long lru_pages)
         :	{
         :	        struct shrinker *shrinker;
         :	        unsigned long ret = 0;
    0.00 :	ffffffff810e44b0:       45 30 e4                xor    %r12b,%r12b
         :	                unsigned long long delta;
         :	                unsigned long total_scan;
         :	                unsigned long max_pass;
         :
         :	                max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
         :	                delta = (4 * scanned) / shrinker->seeks;
    0.00 :	ffffffff810e44b3:       4c 89 6d c8             mov    %r13,-0x38(%rbp)
         :	                delta *= max_pass;
         :	                do_div(delta, lru_pages + 1);
    0.00 :	ffffffff810e44b7:       41 ff c7                inc    %r15d
         :	                /* Assume we'll be able to shrink next time */
         :	                ret = 1;
         :	                goto out;
         :	        }
         :
         :	        list_for_each_entry(shrinker, &shrinker_list, list) {
    0.18 :	ffffffff810e44ba:       48 83 eb 10             sub    $0x10,%rbx
    0.00 :	ffffffff810e44be:       e9 ce 00 00 00          jmpq   ffffffff810e4591 <shrink_slab+0x131>
         :	                unsigned long long delta;
         :	                unsigned long total_scan;
         :	                unsigned long max_pass;
         :
         :	                max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
    0.00 :	ffffffff810e44c3:       44 89 f2                mov    %r14d,%edx
    0.00 :	ffffffff810e44c6:       31 f6                   xor    %esi,%esi
    1.69 :	ffffffff810e44c8:       48 89 df                mov    %rbx,%rdi
    0.00 :	ffffffff810e44cb:       ff 13                   callq  *(%rbx)
         :	                delta = (4 * scanned) / shrinker->seeks;
    0.62 :	ffffffff810e44cd:       48 63 4b 08             movslq 0x8(%rbx),%rcx
         :	        list_for_each_entry(shrinker, &shrinker_list, list) {
         :	                unsigned long long delta;
         :	                unsigned long total_scan;
         :	                unsigned long max_pass;
         :
         :	                max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
    0.71 :	ffffffff810e44d1:       4c 63 e8                movslq %eax,%r13
         :	                delta = (4 * scanned) / shrinker->seeks;
    0.09 :	ffffffff810e44d4:       48 8b 45 c8             mov    -0x38(%rbp),%rax
    0.36 :	ffffffff810e44d8:       31 d2                   xor    %edx,%edx
    0.36 :	ffffffff810e44da:       48 f7 f1                div    %rcx
         :	                delta *= max_pass;
         :	                do_div(delta, lru_pages + 1);
   30.21 :	ffffffff810e44dd:       31 d2                   xor    %edx,%edx
         :	                unsigned long total_scan;
         :	                unsigned long max_pass;
         :
         :	                max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
         :	                delta = (4 * scanned) / shrinker->seeks;
         :	                delta *= max_pass;
    0.00 :	ffffffff810e44df:       49 0f af c5             imul   %r13,%rax
         :	                do_div(delta, lru_pages + 1);
    4.01 :	ffffffff810e44e3:       49 f7 f7                div    %r15
         :	                shrinker->nr += delta;
   42.16 :	ffffffff810e44e6:       48 03 43 20             add    0x20(%rbx),%rax
         :	                if (shrinker->nr < 0) {
    1.34 :	ffffffff810e44ea:       48 85 c0                test   %rax,%rax
         :
         :	                max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
         :	                delta = (4 * scanned) / shrinker->seeks;
         :	                delta *= max_pass;
         :	                do_div(delta, lru_pages + 1);
         :	                shrinker->nr += delta;
    2.23 :	ffffffff810e44ed:       48 89 43 20             mov    %rax,0x20(%rbx)
         :	                if (shrinker->nr < 0) {
    0.00 :	ffffffff810e44f1:       79 18                   jns    ffffffff810e450b <shrink_slab+0xab>
         :	                        printk(KERN_ERR "shrink_slab: %pF negative objects to "
    0.00 :	ffffffff810e44f3:       48 8b 33                mov    (%rbx),%rsi
    0.00 :	ffffffff810e44f6:       48 89 c2                mov    %rax,%rdx
    0.00 :	ffffffff810e44f9:       48 c7 c7 c2 d7 7a 81    mov    $0xffffffff817ad7c2,%rdi
    0.00 :	ffffffff810e4500:       31 c0                   xor    %eax,%eax
    0.00 :	ffffffff810e4502:       e8 db 85 38 00          callq  ffffffff8146cae2 <printk>
         :	                               "delete nr=%ld\n",
         :	                               shrinker->shrink, shrinker->nr);
         :	                        shrinker->nr = max_pass;
    0.00 :	ffffffff810e4507:       4c 89 6b 20             mov    %r13,0x20(%rbx)
         :	                /*
         :	                 * Avoid risking looping forever due to too large nr value:
         :	                 * never try to free more than twice the estimate number of
         :	                 * freeable entries.
         :	                 */
         :	                if (shrinker->nr > max_pass * 2)
    1.87 :	ffffffff810e450b:       4d 01 ed                add    %r13,%r13
    0.00 :	ffffffff810e450e:       4c 39 6b 20             cmp    %r13,0x20(%rbx)
    0.00 :	ffffffff810e4512:       76 04                   jbe    ffffffff810e4518 <shrink_slab+0xb8>
         :	                        shrinker->nr = max_pass * 2;
    0.00 :	ffffffff810e4514:       4c 89 6b 20             mov    %r13,0x20(%rbx)
         :
         :	                total_scan = shrinker->nr;
    6.77 :	ffffffff810e4518:       4c 8b 6b 20             mov    0x20(%rbx),%r13
         :	                shrinker->nr = 0;
    0.00 :	ffffffff810e451c:       48 c7 43 20 00 00 00    movq   $0x0,0x20(%rbx)
    0.00 :	ffffffff810e4523:       00 
         :
         :	                while (total_scan >= SHRINK_BATCH) {
    0.00 :	ffffffff810e4524:       eb 59                   jmp    ffffffff810e457f <shrink_slab+0x11f>
         :	                        long this_scan = SHRINK_BATCH;
         :	                        int shrink_ret;
         :	                        int nr_before;
         :
         :	                        nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask);
    0.00 :	ffffffff810e4526:       31 f6                   xor    %esi,%esi
    0.00 :	ffffffff810e4528:       44 89 f2                mov    %r14d,%edx
    0.00 :	ffffffff810e452b:       48 89 df                mov    %rbx,%rdi
    0.00 :	ffffffff810e452e:       ff 13                   callq  *(%rbx)
         :	                        shrink_ret = (*shrinker->shrink)(shrinker, this_scan,
    0.00 :	ffffffff810e4530:       44 89 f2                mov    %r14d,%edx
    0.00 :	ffffffff810e4533:       be 80 00 00 00          mov    $0x80,%esi
    0.00 :	ffffffff810e4538:       48 89 df                mov    %rbx,%rdi
    0.00 :	ffffffff810e453b:       89 45 c0                mov    %eax,-0x40(%rbp)
    0.00 :	ffffffff810e453e:       ff 13                   callq  *(%rbx)
         :	                                                                gfp_mask);
         :	                        if (shrink_ret == -1)
    0.00 :	ffffffff810e4540:       83 f8 ff                cmp    $0xffffffff,%eax
    0.00 :	ffffffff810e4543:       8b 4d c0                mov    -0x40(%rbp),%ecx
    0.00 :	ffffffff810e4546:       74 3d                   je     ffffffff810e4585 <shrink_slab+0x125>
         :	                                break;
         :	                        if (shrink_ret < nr_before)
    0.00 :	ffffffff810e4548:       39 c8                   cmp    %ecx,%eax
    0.00 :	ffffffff810e454a:       7d 08                   jge    ffffffff810e4554 <shrink_slab+0xf4>
         :	                                ret += nr_before - shrink_ret;
    0.00 :	ffffffff810e454c:       29 c1                   sub    %eax,%ecx
    0.00 :	ffffffff810e454e:       48 63 c9                movslq %ecx,%rcx
    0.00 :	ffffffff810e4551:       49 01 cc                add    %rcx,%r12
         :	                        count_vm_events(SLABS_SCANNED, this_scan);
    0.00 :	ffffffff810e4554:       be 80 00 00 00          mov    $0x80,%esi
    0.00 :	ffffffff810e4559:       bf 1f 00 00 00          mov    $0x1f,%edi
         :	                        total_scan -= this_scan;
    0.00 :	ffffffff810e455e:       49 83 c5 80             add    $0xffffffffffffff80,%r13
         :	                                                                gfp_mask);
         :	                        if (shrink_ret == -1)
         :	                                break;
         :	                        if (shrink_ret < nr_before)
         :	                                ret += nr_before - shrink_ret;
         :	                        count_vm_events(SLABS_SCANNED, this_scan);
    0.00 :	ffffffff810e4562:       e8 d5 f2 ff ff          callq  ffffffff810e383c <count_vm_events>
         :	                        total_scan -= this_scan;
         :
         :	                        cond_resched();
    0.00 :	ffffffff810e4567:       31 d2                   xor    %edx,%edx
    0.00 :	ffffffff810e4569:       be 1a 01 00 00          mov    $0x11a,%esi
    0.00 :	ffffffff810e456e:       48 c7 c7 1c d7 7a 81    mov    $0xffffffff817ad71c,%rdi
    0.00 :	ffffffff810e4575:       e8 ce 36 f6 ff          callq  ffffffff81047c48 <__might_sleep>
    0.00 :	ffffffff810e457a:       e8 6b 01 39 00          callq  ffffffff814746ea <_cond_resched>
         :	                        shrinker->nr = max_pass * 2;
         :
         :	                total_scan = shrinker->nr;
         :	                shrinker->nr = 0;
         :
         :	                while (total_scan >= SHRINK_BATCH) {
    1.43 :	ffffffff810e457f:       49 83 fd 7f             cmp    $0x7f,%r13
    0.00 :	ffffffff810e4583:       77 a1                   ja     ffffffff810e4526 <shrink_slab+0xc6>
         :	                        total_scan -= this_scan;
         :
         :	                        cond_resched();
         :	                }
         :
         :	                shrinker->nr += total_scan;
    0.00 :	ffffffff810e4585:       4c 01 6b 20             add    %r13,0x20(%rbx)
         :	                /* Assume we'll be able to shrink next time */
         :	                ret = 1;
         :	                goto out;
         :	        }
         :
         :	        list_for_each_entry(shrinker, &shrinker_list, list) {
    1.34 :	ffffffff810e4589:       48 8b 5b 10             mov    0x10(%rbx),%rbx
    0.00 :	ffffffff810e458d:       48 83 eb 10             sub    $0x10,%rbx
    0.00 :	ffffffff810e4591:       48 8b 43 10             mov    0x10(%rbx),%rax
    0.00 :	ffffffff810e4595:       0f 18 08                prefetcht0 (%rax)
    1.52 :	ffffffff810e4598:       48 8d 43 10             lea    0x10(%rbx),%rax
    0.00 :	ffffffff810e459c:       48 3d 50 16 a3 81       cmp    $0xffffffff81a31650,%rax
    0.00 :	ffffffff810e45a2:       0f 85 1b ff ff ff       jne    ffffffff810e44c3 <shrink_slab+0x63>
         :	                        cond_resched();
         :	                }
         :
         :	                shrinker->nr += total_scan;
         :	        }
         :	        up_read(&shrinker_rwsem);
    0.00 :	ffffffff810e45a8:       48 c7 c7 30 16 a3 81    mov    $0xffffffff81a31630,%rdi
    0.00 :	ffffffff810e45af:       e8 3a e6 f8 ff          callq  ffffffff81072bee <up_read>
         :	out:
         :	        cond_resched();
    0.09 :	ffffffff810e45b4:       31 d2                   xor    %edx,%edx
    0.00 :	ffffffff810e45b6:       be 21 01 00 00          mov    $0x121,%esi
    0.00 :	ffffffff810e45bb:       48 c7 c7 1c d7 7a 81    mov    $0xffffffff817ad71c,%rdi
    0.00 :	ffffffff810e45c2:       e8 81 36 f6 ff          callq  ffffffff81047c48 <__might_sleep>
    0.18 :	ffffffff810e45c7:       e8 1e 01 39 00          callq  ffffffff814746ea <_cond_resched>
         :	        return ret;
         :	}
    0.18 :	ffffffff810e45cc:       48 83 c4 18             add    $0x18,%rsp
    0.00 :	ffffffff810e45d0:       4c 89 e0                mov    %r12,%rax
    0.00 :	ffffffff810e45d3:       5b                      pop    %rbx
    0.18 :	ffffffff810e45d4:       41 5c                   pop    %r12
    0.00 :	ffffffff810e45d6:       41 5d                   pop    %r13
    0.00 :	ffffffff810e45d8:       41 5e                   pop    %r14
    0.00 :	ffffffff810e45da:       41 5f                   pop    %r15
    0.36 :	ffffffff810e45dc:       5d                      pop    %rbp

--------------040405040406070906010105
Content-Type: text/plain;
 name="livelock.perf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="livelock.perf"

# Events: 10K cycles
#
# Overhead          Command                       Shared Object                                      Symbol
# ........  ...............  ..................................  ..........................................
#
    62.70%          kswapd0  [i915]                              [k] i915_gem_object_bind_to_gtt
                    |
                    --- i915_gem_object_bind_to_gtt
                       |          
                       |--99.98%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                        --0.02%-- [...]

    11.05%          kswapd0  [kernel.kallsyms]                   [k] shrink_slab
                    |
                    --- shrink_slab
                       |          
                       |--99.73%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                        --0.27%-- [...]

     3.35%          kswapd0  [kernel.kallsyms]                   [k] shrink_zone
                    |
                    --- shrink_zone
                        kswapd
                        kthread
                        kernel_thread_helper

     2.85%          kswapd0  [kernel.kallsyms]                   [k] kswapd
                    |
                    --- kswapd
                        kthread
                        kernel_thread_helper

     1.90%          kswapd0  [kernel.kallsyms]                   [k] zone_watermark_ok_safe
                    |
                    --- zone_watermark_ok_safe
                       |          
                       |--79.27%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                       |--18.13%-- sleeping_prematurely.part.11
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --2.59%-- kthread
                                  kernel_thread_helper

     1.71%          kswapd0  [kernel.kallsyms]                   [k] do_raw_spin_lock
                    |
                    --- do_raw_spin_lock
                       |          
                       |--85.07%-- _raw_spin_lock
                       |          |          
                       |          |--56.79%-- mb_cache_shrink_fn
                       |          |          shrink_slab
                       |          |          kswapd
                       |          |          kthread
                       |          |          kernel_thread_helper
                       |          |          
                       |          |--42.54%-- mem_cgroup_soft_limit_reclaim
                       |          |          kswapd
                       |          |          kthread
                       |          |          kernel_thread_helper
                       |          |          
                       |           --0.68%-- __mutex_unlock_slowpath
                       |                     mutex_unlock
                       |                     i915_gem_object_bind_to_gtt
                       |                     shrink_slab
                       |                     kswapd
                       |                     kthread
                       |                     kernel_thread_helper
                       |          
                       |--12.06%-- _raw_spin_lock_irq
                       |          shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                       |--2.30%-- mem_cgroup_soft_limit_reclaim
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --0.57%-- mb_cache_shrink_fn
                                  shrink_slab
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     1.27%          kswapd0  [kernel.kallsyms]                   [k] __zone_watermark_ok
                    |
                    --- __zone_watermark_ok
                       |          
                       |--81.36%-- zone_watermark_ok_safe
                       |          |          
                       |          |--63.81%-- kswapd
                       |          |          kthread
                       |          |          kernel_thread_helper
                       |          |          
                       |           --36.19%-- sleeping_prematurely.part.11
                       |                     kswapd
                       |                     kthread
                       |                     kernel_thread_helper
                       |          
                       |--16.32%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --2.32%-- sleeping_prematurely.part.11
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     1.19%          kswapd0  [kernel.kallsyms]                   [k] global_dirty_limits
                    |
                    --- global_dirty_limits
                       |          
                       |--96.69%-- throttle_vm_writeout
                       |          shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --3.31%-- shrink_zone
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.91%          kswapd0  [kernel.kallsyms]                   [k] mutex_unlock
                    |
                    --- mutex_unlock
                       |          
                       |--67.39%-- i915_gem_object_bind_to_gtt
                       |          shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --32.61%-- shrink_slab
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.79%          kswapd0  [kernel.kallsyms]                   [k] sleeping_prematurely.part.11
                    |
                    --- sleeping_prematurely.part.11
                       |          
                       |--96.25%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --3.75%-- kthread
                                  kernel_thread_helper

     0.71%          kswapd0  [kernel.kallsyms]                   [k] zone_nr_lru_pages
                    |
                    --- zone_nr_lru_pages
                       |          
                       |--77.78%-- shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --22.22%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.68%          kswapd0  [kernel.kallsyms]                   [k] throttle_vm_writeout
                    |
                    --- throttle_vm_writeout
                       |          
                       |--98.55%-- shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --1.45%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.66%          kswapd0  [kernel.kallsyms]                   [k] find_next_bit
                    |
                    --- find_next_bit
                       |          
                       |--94.03%-- cpumask_next
                       |          zone_watermark_ok_safe
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --5.97%-- zone_watermark_ok_safe
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.62%          kswapd0  [kernel.kallsyms]                   [k] down_read_trylock
                    |
                    --- down_read_trylock
                       |          
                       |--98.41%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --1.59%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.61%          kswapd0  [kernel.kallsyms]                   [k] mutex_trylock
                    |
                    --- mutex_trylock
                        i915_gem_object_bind_to_gtt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.59%          kswapd0  [kernel.kallsyms]                   [k] mb_cache_shrink_fn
                    |
                    --- mb_cache_shrink_fn
                       |          
                       |--95.00%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --5.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.49%          kswapd0  [kernel.kallsyms]                   [k] up_read
                    |
                    --- up_read
                       |          
                       |--96.00%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --4.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.41%          kswapd0  [kernel.kallsyms]                   [k] prepare_to_wait
                    |
                    --- prepare_to_wait
                       |          
                       |--97.62%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --2.38%-- kthread
                                  kernel_thread_helper

     0.39%          kswapd0  [kernel.kallsyms]                   [k] mem_cgroup_soft_limit_reclaim
                    |
                    --- mem_cgroup_soft_limit_reclaim
                       |          
                       |--97.50%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --2.50%-- kthread
                                  kernel_thread_helper

     0.39%          kswapd0  [kernel.kallsyms]                   [k] arch_local_save_flags
                    |
                    --- arch_local_save_flags
                        __might_sleep
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.38%          kswapd0  [kernel.kallsyms]                   [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                       |          
                       |--74.36%-- _raw_spin_unlock_irqrestore
                       |          |          
                       |          |--65.52%-- prepare_to_wait
                       |          |          kswapd
                       |          |          kthread
                       |          |          kernel_thread_helper
                       |          |          
                       |           --34.48%-- finish_wait
                       |                     kswapd
                       |                     kthread
                       |                     kernel_thread_helper
                       |          
                       |--15.38%-- finish_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --10.26%-- prepare_to_wait
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.38%          kswapd0  [kernel.kallsyms]                   [k] _raw_spin_lock_irqsave
                    |
                    --- _raw_spin_lock_irqsave
                       |          
                       |--48.72%-- prepare_to_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                       |--46.15%-- finish_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --5.13%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.36%          kswapd0  [kernel.kallsyms]                   [k] zone_reclaimable_pages
                    |
                    --- zone_reclaimable_pages
                       |          
                       |--72.97%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --27.03%-- kthread
                                  kernel_thread_helper

     0.30%          kswapd0  [kernel.kallsyms]                   [k] shrink_icache_memory
                    |
                    --- shrink_icache_memory
                       |          
                       |--93.33%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --6.67%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.30%          kswapd0  [kernel.kallsyms]                   [k] zone_clear_flag
                    |
                    --- zone_clear_flag
                       |          
                       |--80.00%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --20.00%-- kthread
                                  kernel_thread_helper

     0.27%          kswapd0  [kernel.kallsyms]                   [k] cpumask_next
                    |
                    --- cpumask_next
                       |          
                       |--77.78%-- zone_watermark_ok_safe
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --22.22%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.26%          kswapd0  [kernel.kallsyms]                   [k] shrink_dqcache_memory
                    |
                    --- shrink_dqcache_memory
                       |          
                       |--92.31%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --7.69%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.25%          kswapd0  [kernel.kallsyms]                   [k] shrink_dcache_memory
                    |
                    --- shrink_dcache_memory
                       |          
                       |--92.00%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --8.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.23%          kswapd0  [sunrpc]                            [k] param_set_hashtbl_sz
                    |
                    --- param_set_hashtbl_sz
                       |          
                       |--82.61%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --17.39%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.22%          kswapd0  [kernel.kallsyms]                   [k] global_page_state
                    |
                    --- global_page_state
                       |          
                       |--40.91%-- determine_dirtyable_memory
                       |          global_dirty_limits
                       |          throttle_vm_writeout
                       |          shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                       |--27.27%-- global_dirty_limits
                       |          throttle_vm_writeout
                       |          shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                       |--27.27%-- throttle_vm_writeout
                       |          shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --4.55%-- shrink_zone
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.22%          kswapd0  [kernel.kallsyms]                   [k] need_resched
                    |
                    --- need_resched
                       |          
                       |--50.00%-- _cond_resched
                       |          shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --50.00%-- should_resched
                                  _cond_resched
                                  shrink_slab
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.20%          kswapd0  [kernel.kallsyms]                   [k] finish_wait
                    |
                    --- finish_wait
                       |          
                       |--95.00%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --5.00%-- kthread
                                  kernel_thread_helper

     0.20%          kswapd0  [kernel.kallsyms]                   [k] __might_sleep
                    |
                    --- __might_sleep
                       |          
                       |--90.00%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --10.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.19%          kswapd0  [kernel.kallsyms]                   [k] global_reclaimable_pages
                    |
                    --- global_reclaimable_pages
                        determine_dirtyable_memory
                        global_dirty_limits
                        throttle_vm_writeout
                        shrink_zone
                        kswapd
                        kthread
                        kernel_thread_helper

     0.18%          kswapd0  [kernel.kallsyms]                   [k] test_tsk_thread_flag
                    |
                    --- test_tsk_thread_flag
                       |          
                       |--66.67%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --33.33%-- try_to_freeze
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.16%          kswapd0  [kvm]                               [k] paging_free
                    |
                    --- paging_free
                       |          
                       |--93.75%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --6.25%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.15%          kswapd0  [kernel.kallsyms]                   [k] __mem_cgroup_largest_soft_limit_node
                    |
                    --- __mem_cgroup_largest_soft_limit_node
                       |          
                       |--80.00%-- mem_cgroup_soft_limit_reclaim
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --20.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.14%          kswapd0  [kernel.kallsyms]                   [k] determine_dirtyable_memory
                    |
                    --- determine_dirtyable_memory
                       |          
                       |--78.57%-- global_dirty_limits
                       |          throttle_vm_writeout
                       |          shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --21.43%-- throttle_vm_writeout
                                  shrink_zone
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.13%          kswapd0  [kernel.kallsyms]                   [k] arch_local_irq_save
                    |
                    --- arch_local_irq_save
                       |          
                       |--61.54%-- _raw_spin_lock_irqsave
                       |          |          
                       |          |--75.00%-- prepare_to_wait
                       |          |          kswapd
                       |          |          kthread
                       |          |          kernel_thread_helper
                       |          |          
                       |           --25.00%-- finish_wait
                       |                     kswapd
                       |                     kthread
                       |                     kernel_thread_helper
                       |          
                       |--23.08%-- prepare_to_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --15.38%-- finish_wait
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.12%          kswapd0  [kernel.kallsyms]                   [k] _raw_spin_unlock_irqrestore
                    |
                    --- _raw_spin_unlock_irqrestore
                       |          
                       |--58.33%-- finish_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --41.67%-- prepare_to_wait
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.09%          kswapd0  [kernel.kallsyms]                   [k] _raw_spin_lock
                    |
                    --- _raw_spin_lock
                       |          
                       |--66.67%-- mb_cache_shrink_fn
                       |          shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --33.33%-- mem_cgroup_soft_limit_reclaim
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.08%          kswapd0  [kernel.kallsyms]                   [k] kthread_should_stop
                    |
                    --- kthread_should_stop
                        kthread
                        kernel_thread_helper

     0.08%             Xorg  [drm]                               [k] drm_addmap_core
                       |
                       --- drm_addmap_core
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                          |          
                          |--58.68%-- i915_gem_object_bind_to_gtt
                          |          i915_gem_object_bind_to_gtt
                          |          i915_gem_object_bind_to_gtt
                          |          drm_gem_vm_close
                          |          kref_put
                          |          drm_gem_vm_close
                          |          drm_gem_vm_close
                          |          drm_gem_vm_close
                          |          drm_ctxbitmap_init
                          |          do_vfs_ioctl
                          |          sys_ioctl
                          |          system_call_fastpath
                          |          0x3961ed8af7
                          |          
                           --41.32%-- i915_gem_execbuffer
                                     drm_ctxbitmap_init
                                     do_vfs_ioctl
                                     sys_ioctl
                                     system_call_fastpath
                                     0x3961ed8af7

     0.07%          kswapd0  [kernel.kallsyms]                   [k] __list_add
                    |
                    --- __list_add
                       |          
                       |--85.71%-- prepare_to_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --14.29%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.07%          kswapd0  [kernel.kallsyms]                   [k] __list_del_entry
                    |
                    --- __list_del_entry
                       |          
                       |--57.14%-- finish_wait
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --42.86%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.07%          kswapd0  [kernel.kallsyms]                   [k] arch_local_irq_disable
                    |
                    --- arch_local_irq_disable
                       |          
                       |--85.72%-- arch_local_irq_save
                       |          _raw_spin_lock_irqsave
                       |          |          
                       |          |--50.00%-- prepare_to_wait
                       |          |          kswapd
                       |          |          kthread
                       |          |          kernel_thread_helper
                       |          |          
                       |           --50.00%-- finish_wait
                       |                     kswapd
                       |                     kthread
                       |                     kernel_thread_helper
                       |          
                        --14.28%-- _raw_spin_lock_irq
                                  shrink_zone
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.06%             perf  [kernel.kallsyms]                   [k] number
                       |
                       --- number
                          |          
                          |--84.53%-- vsnprintf
                          |          seq_printf
                          |          render_sigset_t
                          |          proc_pid_status
                          |          proc_single_show
                          |          seq_read
                          |          vfs_read
                          |          sys_read
                          |          system_call_fastpath
                          |          __GI___libc_read
                          |          
                           --15.47%-- seq_printf
                                     show_map_vma
                                     show_map
                                     seq_read
                                     vfs_read
                                     sys_read
                                     system_call_fastpath
                                     __GI___libc_read

     0.06%          swapper  [kernel.kallsyms]                   [k] intel_idle
                    |
                    --- intel_idle
                        cpuidle_idle_call
                        cpu_idle
                       |          
                       |--68.35%-- rest_init
                       |          start_kernel
                       |          x86_64_start_reservations
                       |          x86_64_start_kernel
                       |          
                        --31.65%-- start_secondary

     0.06%          kswapd0  [kernel.kallsyms]                   [k] _cond_resched
                    |
                    --- _cond_resched
                       |          
                       |--66.67%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --33.33%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.06%          kswapd0  [kernel.kallsyms]                   [k] _raw_spin_lock_irq
                    |
                    --- _raw_spin_lock_irq
                        shrink_zone
                        kswapd
                        kthread
                        kernel_thread_helper

     0.05%             Xorg  [unknown]                           [.] 0x3961e7a472    
                       |
                       --- 0x7f795b853753
                           0x2a1f6f0

                       |
                       --- 0x44c6ed
                           0x4d3b0e
                           0x42ec11
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x432a3e
                           0x45b729
                           0x42e9aa
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x467c10
                           0x42ea88
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x4bd248
                           0x44c7f6
                           0x4d382f
                           0x42ec11
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x43a017
                           0x43b27e
                           0x500345
                           0x4383fd
                           0x4d734b
                           0x4d80bf
                           0x4d8217
                           0x4d99d6
                           0x4d4475
                           0x42ec11
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x396b613c10

                       |
                       --- 0x3961e78bb6

                       |
                       --- 0x3f192096c5
                           0x432b8b
                           0x45b7c9
                           0x42e9aa
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x3961e7a472

                       |
                       --- 0x44c6e1
                           0x42ec11
                           0x422e1a
                           0x3961e2143d

                       |
                       --- 0x3961ed8feb

     0.04%          kswapd0  [kernel.kallsyms]                   [k] apic_timer_interrupt
                    |
                    --- apic_timer_interrupt
                       |          
                       |--50.00%-- shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --50.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.04%          kswapd0  [kernel.kallsyms]                   [k] get_reclaim_stat
                    |
                    --- get_reclaim_stat
                       |          
                       |--75.00%-- shrink_zone
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --25.00%-- kswapd
                                  kthread
                                  kernel_thread_helper

     0.04%          kswapd0  [kernel.kallsyms]                   [k] should_resched
                    |
                    --- should_resched
                        _cond_resched
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.03%             perf  [kernel.kallsyms]                   [k] arch_local_irq_restore
                       |
                       --- arch_local_irq_restore
                           single_release
                           fput
                           filp_close
                           sys_close
                           system_call_fastpath
                           __GI___close

     0.03%          kswapd0  [kernel.kallsyms]                   [k] spin_unlock_irq
                    |
                    --- spin_unlock_irq
                        shrink_zone
                        kswapd
                        kthread
                        kernel_thread_helper

     0.03%             perf  [kernel.kallsyms]                   [k] mangle_path
                       |
                       --- mangle_path
                           seq_path
                           show_map_vma
                           show_map
                           seq_read
                           vfs_read
                           sys_read
                           system_call_fastpath
                           __GI___libc_read

     0.02%              top  libc-2.13.90.so                     [.] _IO_vfscanf_internal
                        |
                        --- _IO_vfscanf_internal
                            _IO_vsscanf
                           |          
                           |--67.69%-- 0x7fff716bcfd0
                           |          
                            --32.31%-- 0x7fff716bd0c0

     0.02%             perf  [kernel.kallsyms]                   [k] format_decode
                       |
                       --- format_decode
                           vsnprintf
                           seq_printf
                           show_map_vma
                           show_map
                           seq_read
                           vfs_read
                           sys_read
                           system_call_fastpath
                           __GI___libc_read

     0.02%             perf  [kernel.kallsyms]                   [k] unlink_anon_vmas
                       |
                       --- unlink_anon_vmas
                           unmap_region
                           do_munmap
                           sys_munmap
                           system_call_fastpath
                           __munmap

     0.02%      gnome-shell  libglib-2.0.so.0.2800.6             [.] 0x19870         
                |
                --- 0x3f13262ffb

                |
                --- 0x3f13219870

                |
                --- 0x3f13232052

                |
                --- 0x3f13262fe0

                |
                --- 0x3f13231c3f

                |
                --- 0x3f13219853

     0.02%          kswapd0  [kernel.kallsyms]                   [k] try_to_freeze
                    |
                    --- try_to_freeze
                       |          
                       |--50.49%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --49.51%-- kthread
                                  kernel_thread_helper

     0.02%          kswapd0  [kernel.kallsyms]                   [k] native_write_msr_safe
                    |
                    --- native_write_msr_safe
                        paravirt_write_msr
                        intel_pmu_disable_all
                        x86_pmu_disable
                        perf_pmu_disable
                        perf_event_task_tick
                        scheduler_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.02%          kswapd0  [kernel.kallsyms]                   [k] rb_last
                    |
                    --- rb_last
                       |          
                       |--50.00%-- mem_cgroup_soft_limit_reclaim
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --50.00%-- __mem_cgroup_largest_soft_limit_node
                                  mem_cgroup_soft_limit_reclaim
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.02%          kswapd0  [kernel.kallsyms]                   [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                       |          
                       |--50.00%-- irq_enter
                       |          __irqentry_text_start
                       |          ret_from_intr
                       |          shrink_slab
                       |          kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --50.00%-- account_system_vtime
                                  __do_softirq
                                  call_softirq
                                  do_softirq
                                  irq_exit
                                  smp_apic_timer_interrupt
                                  apic_timer_interrupt
                                  shrink_slab
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.02%          kswapd0  [i915]                              [k] i915_error_work_func
                    |
                    --- i915_error_work_func
                        i915_error_work_func
                        handle_IRQ_event
                        handle_edge_irq
                        handle_irq
                        __irqentry_text_start
                        ret_from_intr
                       |          
                       |--50.01%-- kswapd
                       |          kthread
                       |          kernel_thread_helper
                       |          
                        --49.99%-- shrink_zone
                                  kswapd
                                  kthread
                                  kernel_thread_helper

     0.02%             perf  [kernel.kallsyms]                   [k] selinux_file_permission
                       |
                       --- selinux_file_permission
                           security_file_permission
                           rw_verify_area
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.02%      gnome-shell  libclutter-glx-1.0.so.0.600.14      [.] 0xd31ec         
                |
                --- 0x346ac409fa

                |
                --- 0x346ac41470
                    (nil)

                |
                --- 0x346ace1a60

                |
                --- 0x346acd31ec
                    (nil)

     0.02%              top  libc-2.13.90.so                     [.] _IO_default_xsputn_internal
                        |
                        --- _IO_default_xsputn_internal
                           |          
                           |--43.63%-- ___vsnprintf_chk
                           |          
                           |--37.31%-- ___vsprintf_chk
                           |          
                            --19.06%-- 0x396240f5c0

     0.01%      gnome-shell  i965_dri.so                         [.] 0x228d04        
                |
                --- 0x7f5b04f99a2b

                |
                --- 0x7f5b04fe707c

                |
                --- 0x7f5b050e837c

                |
                --- 0x7f5b04fd88a2

                |
                --- 0x7f5b050e9d04

     0.01%             perf  [kernel.kallsyms]                   [k] __ext4_journal_stop
                       |
                       --- __ext4_journal_stop
                           ext4_da_write_end
                           generic_file_buffered_write
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%          swapper  [kernel.kallsyms]                   [k] nr_iowait_cpu
                    |
                    --- nr_iowait_cpu
                        tick_nohz_stop_idle
                        tick_check_idle
                        irq_enter
                        smp_call_function_single_interrupt
                        call_function_single_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.01%              top  [kernel.kallsyms]                   [k] cp_new_stat
                        |
                        --- cp_new_stat
                            sys_newstat
                            system_call_fastpath
                            _xstat

     0.01%   gnome-terminal  libcairo.so.2.11000.2               [.] 0x63d86         
             |
             --- 0x3f15a16921

             |
             --- 0x3f15a60c13
                 0x6fdb40

             |
             --- 0x3f15a3c970

             |
             --- 0x3f15a164b9
                 0x6200000001

             |
             --- 0x3f15a63d86
                 (nil)

     0.01%      gnome-shell  libmozjs.so                         [.] 0x139625        
                |
                --- 0x346b8cc289

                |
                --- 0x346b959ccd

                |
                --- 0x346b8538f0

                |
                --- 0x346b939625

                |
                --- 0x346b851093
                    0xd

     0.01%       irqbalance  [unknown]                           [.] 0x3961e47990    
                 |
                 --- 0x403d88

                 |
                 --- 0x3961e47990
                     0x3961ef5591

     0.01%              top  [kernel.kallsyms]                   [k] avc_has_perm_noaudit
                        |
                        --- avc_has_perm_noaudit
                            avc_has_perm
                            inode_has_perm
                            selinux_inode_permission
                            security_inode_exec_permission
                            exec_permission
                            link_path_walk
                            do_path_lookup
                            user_path_at
                           |          
                           |--64.32%-- vfs_fstatat
                           |          vfs_stat
                           |          sys_newstat
                           |          system_call_fastpath
                           |          _xstat
                           |          
                            --35.68%-- sys_faccessat
                                      sys_access
                                      system_call_fastpath
                                      __GI___access

     0.01%             perf  [kernel.kallsyms]                   [k] __ext4_journal_get_write_access
                       |
                       --- __ext4_journal_get_write_access
                           ext4_reserve_inode_write
                           ext4_mark_inode_dirty
                           ext4_dirty_inode
                           __mark_inode_dirty
                           file_update_time
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  [kernel.kallsyms]                   [k] rw_verify_area
                       |
                       --- rw_verify_area
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  [kernel.kallsyms]                   [k] iov_iter_advance
                       |
                       --- iov_iter_advance
                           generic_file_buffered_write
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  [kernel.kallsyms]                   [k] put_bh
                       |
                       --- put_bh
                           __brelse
                           brelse
                           ext4_xattr_get
                           ext4_xattr_security_get
                           generic_getxattr
                           cap_inode_need_killpriv
                           security_inode_need_killpriv
                           file_remove_suid
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  [kernel.kallsyms]                   [k] strchr
                       |
                       --- strchr
                           mangle_path
                           seq_path
                           show_map_vma
                           show_map
                           seq_read
                           vfs_read
                           sys_read
                           system_call_fastpath
                           __GI___libc_read

     0.01%             perf  [kernel.kallsyms]                   [k] fsnotify_create_event
                       |
                       --- fsnotify_create_event
                           send_to_group
                           fsnotify
                           __fsnotify_parent
                           fsnotify_modify
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  [kernel.kallsyms]                   [k] kmem_cache_alloc
                       |
                       --- kmem_cache_alloc
                           fsnotify_create_event
                           send_to_group
                           fsnotify
                           __fsnotify_parent
                           fsnotify_modify
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  [kernel.kallsyms]                   [k] _raw_spin_lock
                       |
                       --- _raw_spin_lock
                           path_put
                           d_path
                           seq_path
                           show_map_vma
                           show_map
                           seq_read
                           vfs_read
                           sys_read
                           system_call_fastpath
                           __GI___libc_read

     0.01%             perf  [kernel.kallsyms]                   [k] SetPageUptodate
                       |
                       --- SetPageUptodate
                           __block_commit_write
                           block_write_end
                           generic_write_end
                           ext4_da_write_end
                           generic_file_buffered_write
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  perf                                [.] 0x3badc         
                       |
                       --- 0x43badc
                           0x4292d5
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             perf  libc-2.13.90.so                     [.] __memchr
                       |
                       --- __memchr

     0.01%             perf  [kernel.kallsyms]                   [k] send_to_group
                       |
                       --- send_to_group
                           fsnotify
                           __fsnotify_parent
                           fsnotify_modify
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel

     0.01%             perf  [kernel.kallsyms]                   [k] jbd2_journal_cancel_revoke
                       |
                       --- jbd2_journal_cancel_revoke
                           do_get_write_access
                           jbd2_journal_get_write_access
                           __ext4_journal_get_write_access
                           ext4_reserve_inode_write
                           ext4_mark_inode_dirty
                           ext4_dirty_inode
                           __mark_inode_dirty
                           generic_write_end
                           ext4_da_write_end
                           generic_file_buffered_write
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%          kswapd0  [kernel.kallsyms]                   [k] arch_local_irq_save
                    |
                    --- arch_local_irq_save
                        update_wall_time
                        do_timer
                        tick_do_update_jiffies64
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%          kswapd0  [kernel.kallsyms]                   [k] rcu_bh_qs
                    |
                    --- rcu_bh_qs
                        rcu_check_callbacks
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%          kswapd0  [kernel.kallsyms]                   [k] update_rq_clock
                    |
                    --- update_rq_clock
                        scheduler_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%          kswapd0  [kernel.kallsyms]                   [k] scheduler_tick
                    |
                    --- scheduler_tick
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%          kswapd0  [kernel.kallsyms]                   [k] rcu_irq_enter
                    |
                    --- rcu_irq_enter
                        irq_enter
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%          kswapd0  [kernel.kallsyms]                   [k] arch_local_save_flags
                    |
                    --- arch_local_save_flags
                        run_posix_cpu_timers
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%      kworker/1:0  [cpufreq_ondemand]                  [k] store_sampling_rate_old
                |
                --- store_sampling_rate_old
                    process_one_work
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.01%          kswapd0  [kernel.kallsyms]                   [k] sched_clock_cpu
                    |
                    --- sched_clock_cpu
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        shrink_slab
                        kswapd
                        kthread
                        kernel_thread_helper

     0.01%      kworker/1:0  [kernel.kallsyms]                   [k] worker_enter_idle
                |
                --- worker_enter_idle
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.01%             perf  [kernel.kallsyms]                   [k] ext4_da_write_begin
                       |
                       --- ext4_da_write_begin
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4293b8
                           0x429c0a
                           0x418709
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%             Xorg  [i915]                              [k] intel_dp_prepare
                       |
                       --- intel_dp_prepare
                           intel_dp_prepare
                           intel_dp_prepare
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%             Xorg  [kernel.kallsyms]                   [k] free_pages_prepare
                       |
                       --- free_pages_prepare
                           free_hot_cold_page
                           __pagevec_free
                           release_pages
                           __pagevec_release
                           pagevec_release
                           truncate_inode_pages_range
                           truncate_inode_pages
                           i915_gem_object_truncate
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           drm_gem_vm_close
                           kref_put
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%      kworker/0:0  [kernel.kallsyms]                   [k] kobject_put
                |
                --- kobject_put
                    cpufreq_cpu_put
                    __cpufreq_driver_getavg
                    store_sampling_rate_old
                    process_one_work
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.01%      gnome-shell  libpthread-2.13.90.so               [.] pthread_mutex_lock
                |
                --- pthread_mutex_lock

     0.01%      gnome-shell  libpixman-1.so.0.20.2               [.] 0x17152         
                |
                --- 0x396b617152

     0.01%      gnome-shell  [drm]                               [k] drm_addmap_core
                |
                --- drm_addmap_core
                    i915_gem_object_bind_to_gtt
                    i915_gem_object_bind_to_gtt
                    i915_gem_object_bind_to_gtt
                    i915_gem_object_bind_to_gtt
                    i915_gem_object_bind_to_gtt
                    drm_gem_vm_close
                    kref_put
                    drm_gem_vm_close
                    drm_gem_vm_close
                    drm_gem_vm_close
                    drm_ctxbitmap_init
                    do_vfs_ioctl
                    sys_ioctl
                    system_call_fastpath
                    __GI_ioctl

     0.01%             perf  [kernel.kallsyms]                   [k] _raw_spin_lock_irqsave
                       |
                       --- _raw_spin_lock_irqsave
                           __wake_up
                           jbd2_journal_stop
                           __ext4_journal_stop
                           ext4_da_write_end
                           generic_file_buffered_write
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.01%              top  [kernel.kallsyms]                   [k] _cond_resched
                        |
                        --- _cond_resched
                            kmem_cache_alloc
                            get_empty_filp
                            do_filp_open
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.01%              top  [kernel.kallsyms]                   [k] dput
                        |
                        --- dput
                            path_put
                            do_path_lookup
                            user_path_at
                            vfs_fstatat
                            vfs_stat
                            sys_newstat
                            system_call_fastpath
                            _xstat

     0.01%              top  [kernel.kallsyms]                   [k] seq_open
                        |
                        --- seq_open
                            single_open
                            proc_single_open
                            __dentry_open
                            nameidata_to_filp
                            finish_open
                            do_filp_open
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.01%             Xorg  [kernel.kallsyms]                   [k] __mutex_lock_common
                       |
                       --- __mutex_lock_common
                           __mutex_lock_interruptible_slowpath
                           __mutex_fastpath_lock_retval
                           mutex_lock_interruptible
                           i915_mutex_lock_interruptible
                           i915_gem_object_bind_to_gtt
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%   gnome-terminal  libvte2_90.so.9.2800.0              [.] 0x19565         
             |
             --- 0x3468c38582

             |
             --- 0x3468c19565
                 __GI_clock_gettime

             |
             --- 0x3468c1fb30

     0.01%              top  libc-2.13.90.so                     [.] ____strtoul_l_internal
                        |
                        --- ____strtoul_l_internal

     0.01%      gnome-shell  libgobject-2.0.so.0.2800.6          [.] 0x32790         
                |
                --- 0x3f13a32e60

                |
                --- 0x3f13a32790

                |
                --- 0x3f13a1e809

     0.01%      usb-storage  [kernel.kallsyms]                   [k] usb_hcd_link_urb_to_ep
                |
                --- usb_hcd_link_urb_to_ep
                   |          
                   |--68.61%-- ehci_urb_enqueue
                   |          usb_hcd_submit_urb
                   |          usb_submit_urb
                   |          usb_stor_transparent_scsi_command
                   |          usb_stor_transparent_scsi_command
                   |          usb_stor_transparent_scsi_command
                   |          usb_stor_transparent_scsi_command
                   |          usb_stor_transparent_scsi_command
                   |          usb_stor_transparent_scsi_command
                   |          kthread
                   |          kernel_thread_helper
                   |          
                    --31.39%-- usb_hcd_submit_urb
                              usb_submit_urb
                              usb_stor_transparent_scsi_command
                              usb_stor_transparent_scsi_command
                              usb_stor_transparent_scsi_command
                              usb_stor_transparent_scsi_command
                              usb_stor_transparent_scsi_command
                              usb_stor_transparent_scsi_command
                              kthread
                              kernel_thread_helper

     0.01%             Xorg  [kernel.kallsyms]                   [k] gen6_write_entry
                       |
                       --- gen6_write_entry
                           i915_gem_execbuffer
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           drm_gem_vm_close
                           kref_put
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%      gnome-shell  libxcb.so.1.1.0                     [.] 0xa721          
                |
                --- 0x3965e0a721

                |
                --- 0x3965e082c8

     0.01%          swapper  [kernel.kallsyms]                   [k] getnstimeofday
                    |
                    --- getnstimeofday
                        ktime_get_real
                        intel_idle
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.01%    udisks-daemon  [kernel.kallsyms]                   [k] ihold
              |
              --- ihold
                  bd_acquire
                  blkdev_open
                  __dentry_open
                  nameidata_to_filp
                  finish_open
                  do_filp_open
                  do_sys_open
                  sys_open
                  system_call_fastpath
                  0x396220ec80

     0.01%              top  [kernel.kallsyms]                   [k] dget
                        |
                        --- dget
                            path_get
                            nameidata_to_filp
                            finish_open
                            do_filp_open
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.01%   gnome-terminal  libpthread-2.13.90.so               [.] __pthread_mutex_unlock
             |
             --- __pthread_mutex_unlock

     0.01%             Xorg  [kernel.kallsyms]                   [k] kref_put
                       |
                       --- kref_put
                           drm_gem_object_unreference
                           i915_gem_object_move_to_inactive
                           i915_gem_retire_requests_ring
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%              top  [kernel.kallsyms]                   [k] expand_files
                        |
                        --- expand_files
                            alloc_fd
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.01%          swapper  [kernel.kallsyms]                   [k] menu_select
                    |
                    --- menu_select
                       |          
                       |--67.44%-- cpu_idle
                       |          rest_init
                       |          start_kernel
                       |          x86_64_start_reservations
                       |          x86_64_start_kernel
                       |          
                        --32.56%-- cpuidle_idle_call
                                  cpu_idle
                                  start_secondary

     0.01%          swapper  [kernel.kallsyms]                   [k] cpumask_clear_cpu.constprop.2
                    |
                    --- cpumask_clear_cpu.constprop.2
                        tick_check_idle
                        irq_enter
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.01%             Xorg  [kernel.kallsyms]                   [k] mutex_spin_on_owner
                       |
                       --- mutex_spin_on_owner
                           __mutex_lock_common
                           __mutex_lock_interruptible_slowpath
                           __mutex_fastpath_lock_retval
                           mutex_lock_interruptible
                           i915_mutex_lock_interruptible
                           i915_gem_object_bind_to_gtt
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%             Xorg  [kernel.kallsyms]                   [k] zone_watermark_ok
                       |
                       --- zone_watermark_ok
                           get_page_from_freelist
                           __alloc_pages_nodemask
                           alloc_pages_current
                           __get_free_pages
                           __pollwait
                           sock_poll_wait
                           unix_poll
                           sock_poll
                           do_select
                           core_sys_select
                           sys_select
                           system_call_fastpath
                           0x3961ed91d3
                           0x42e9aa
                           0x422e1a
                           0x3961e2143d

     0.01%          swapper  [kernel.kallsyms]                   [k] switch_mm
                    |
                    --- switch_mm
                        schedule
                        cpu_idle
                        start_secondary

     0.01%              top  [kernel.kallsyms]                   [k] put_dec
                        |
                        --- put_dec
                            number
                            vsnprintf
                            seq_printf
                            do_task_stat
                            proc_tgid_stat
                            proc_single_show
                            seq_read
                            vfs_read
                            sys_read
                            system_call_fastpath
                            __GI___libc_read

     0.01%      gnome-shell  [kernel.kallsyms]                   [k] may_expand_vm
                |
                --- may_expand_vm
                    mmap_region
                    do_mmap_pgoff
                    sys_mmap_pgoff
                    sys_mmap
                    system_call_fastpath
                    __mmap

     0.01%             Xorg  [kernel.kallsyms]                   [k] mutex_lock_interruptible
                       |
                       --- mutex_lock_interruptible
                           i915_mutex_lock_interruptible
                           i915_gem_object_bind_to_gtt
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%          swapper  [kernel.kallsyms]                   [k] ktime_get_real
                    |
                    --- ktime_get_real
                        cpuidle_idle_call
                        cpu_idle
                       |          
                       |--55.14%-- rest_init
                       |          start_kernel
                       |          x86_64_start_reservations
                       |          x86_64_start_kernel
                       |          
                        --44.86%-- start_secondary

     0.01%       irqbalance  [kernel.kallsyms]                   [k] sysfs_readdir
                 |
                 --- sysfs_readdir
                     vfs_readdir
                     sys_getdents
                     system_call_fastpath
                     0x3961eaa0b5

     0.01%             Xorg  [kernel.kallsyms]                   [k] do_raw_spin_lock
                       |
                       --- do_raw_spin_lock
                           _raw_spin_lock
                           drm_gem_vm_close
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.01%      kworker/2:0  [kernel.kallsyms]                   [k] get_gcwq_nr_running
                |
                --- get_gcwq_nr_running
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.01%              top  top                                 [.] 0x6b33          
                        |
                        --- 0x406b33

     0.01%              top  [kernel.kallsyms]                   [k] __strncpy_from_user
                        |
                        --- __strncpy_from_user
                            getname
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.01%          firefox  libsqlite3.so.0.8.6                 [.] 0x41060         
                    |
                    --- 0x3973e41060

     0.01%          swapper  [kernel.kallsyms]                   [k] account_system_vtime
                    |
                    --- account_system_vtime
                       |          
                       |--50.66%-- irq_exit
                       |          smp_apic_timer_interrupt
                       |          apic_timer_interrupt
                       |          cpuidle_idle_call
                       |          cpu_idle
                       |          start_secondary
                       |          
                        --49.34%-- irq_enter
                                  smp_apic_timer_interrupt
                                  apic_timer_interrupt
                                  cpuidle_idle_call
                                  cpu_idle
                                  rest_init
                                  start_kernel
                                  x86_64_start_reservations
                                  x86_64_start_kernel

     0.01%   gnome-terminal  [kernel.kallsyms]                   [k] fput
             |
             --- fput
                 poll_freewait
                 do_sys_poll
                 sys_poll
                 system_call_fastpath
                 __GI___poll

     0.01%      gnome-shell  [kernel.kallsyms]                   [k] get_unmapped_area_prot
                |
                --- get_unmapped_area_prot
                    do_mmap_pgoff
                    sys_mmap_pgoff
                    sys_mmap
                    system_call_fastpath
                    __mmap

     0.01%              top  [kernel.kallsyms]                   [k] link_path_walk
                        |
                        --- link_path_walk
                            do_path_lookup
                            user_path_at
                            vfs_fstatat
                            vfs_stat
                            sys_newstat
                            system_call_fastpath
                            _xstat

     0.01%          swapper  [r8169]                             [k] rtl8169_interrupt
                    |
                    --- rtl8169_interrupt
                        handle_IRQ_event
                        handle_edge_irq
                        handle_irq
                        __irqentry_text_start
                        ret_from_intr
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.01%      gnome-shell  libc-2.13.90.so                     [.] __GI_vfprintf
                |
                --- __GI_vfprintf
                    __vasprintf_chk
                    0x7fff7b7d6f70

     0.01%      gnome-shell  [kernel.kallsyms]                   [k] dput
                |
                --- dput
                    audit_free_names
                    audit_syscall_exit
                    sysret_audit
                    __GI___poll

     0.01%      gnome-shell  libc-2.13.90.so                     [.] malloc_consolidate.part.3
                |
                --- malloc_consolidate.part.3

     0.01%      gnome-shell  [i915]                              [k] intel_dp_prepare
                |
                --- intel_dp_prepare
                    intel_dp_prepare
                    intel_dp_prepare
                    i915_gem_object_bind_to_gtt
                    i915_gem_object_bind_to_gtt
                    i915_gem_object_bind_to_gtt
                    i915_gem_execbuffer
                    drm_ctxbitmap_init
                    do_vfs_ioctl
                    sys_ioctl
                    system_call_fastpath
                    __GI_ioctl

     0.01%      gnome-shell  libstartup-notification-1.so.0.0.0  [.] 0x45cb          
                |
                --- 0x3f00e045cb
                    0xa3d5

     0.01%      gnome-shell  [kernel.kallsyms]                   [k] scm_destroy
                |
                --- scm_destroy
                    unix_destruct_scm
                    skb_release_head_state
                    __kfree_skb
                    consume_skb
                    unix_stream_recvmsg
                    sock_aio_read.part.7
                    sock_aio_read
                    do_sync_read
                    vfs_read
                    sys_read
                    system_call_fastpath
                    __read

     0.01%          swapper  [kernel.kallsyms]                   [k] __switch_to
                    |
                    --- __switch_to

     0.01%          swapper  [kernel.kallsyms]                   [k] arch_local_irq_restore
                    |
                    --- arch_local_irq_restore
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%   gnome-terminal  [kernel.kallsyms]                   [k] _raw_spin_lock_irqsave
             |
             --- _raw_spin_lock_irqsave
                 __pollwait
                 n_tty_poll
                 tty_poll
                 do_sys_poll
                 sys_poll
                 system_call_fastpath
                 __GI___poll

     0.00%      gnome-shell  libxklavier.so.16.1.0               [.] 0xf33b          
                |
                --- 0x7f5afa8d933b

     0.00%  gnome-settings-  libORBit-2.so.0.1.0                 [.] 0x4b374         
            |
            --- 0x3f1964b374

     0.00%      gnome-shell  [kernel.kallsyms]                   [k] __mutex_fastpath_lock_retval
                |
                --- __mutex_fastpath_lock_retval
                    unix_stream_recvmsg
                    sock_aio_read.part.7
                    sock_aio_read
                    do_sync_read
                    vfs_read
                    sys_read
                    system_call_fastpath
                    __read

     0.00%          swapper  [kernel.kallsyms]                   [k] do_raw_spin_lock
                    |
                    --- do_raw_spin_lock
                        _raw_spin_lock
                        get_next_timer_interrupt
                        tick_nohz_stop_sched_tick
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%          swapper  [kernel.kallsyms]                   [k] hrtimer_start_range_ns
                    |
                    --- hrtimer_start_range_ns
                        tick_nohz_restart_sched_tick
                        cpu_idle
                        start_secondary

     0.00%      gnome-shell  libc-2.13.90.so                     [.] __GI___poll
                |
                --- __GI___poll

     0.00%      gnome-shell  libc-2.13.90.so                     [.] __strlen_sse42
                |
                --- __strlen_sse42

     0.00%          swapper  [kernel.kallsyms]                   [k] apic_timer_interrupt
                    |
                    --- apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%              top  [kernel.kallsyms]                   [k] alloc_fd
                        |
                        --- alloc_fd
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.00%             Xorg  [kernel.kallsyms]                   [k] ktime_get_ts
                       |
                       --- ktime_get_ts
                           poll_select_copy_remaining
                           sys_select
                           system_call_fastpath
                           0x3961ed91d3
                           0x42e9aa
                           0x422e1a
                           0x3961e2143d

     0.00%              top  [kernel.kallsyms]                   [k] number
                        |
                        --- number
                            vsnprintf
                            seq_printf
                            do_task_stat
                            proc_tgid_stat
                            proc_single_show
                            seq_read
                            vfs_read
                            sys_read
                            system_call_fastpath
                            __GI___libc_read

     0.00%   gnome-terminal  libgthread-2.0.so.0.2800.6          [.] 0x22b5          
             |
             --- 0x3f136022b5

     0.00%      kworker/0:0  [kernel.kallsyms]                   [k] process_one_work
                |
                --- process_one_work
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.00%          swapper  [kernel.kallsyms]                   [k] arp_process
                    |
                    --- arp_process
                        NF_HOOK.constprop.6
                        arp_rcv
                        __netif_receive_skb
                        netif_receive_skb
                        napi_skb_finish
                        napi_gro_receive
                        rtl8169_rx_interrupt
                        rtl8169_poll
                        net_rx_action
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        __irqentry_text_start
                        ret_from_intr
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%             Xorg  [kernel.kallsyms]                   [k] arch_local_irq_save
                       |
                       --- arch_local_irq_save
                           _raw_spin_lock_irqsave
                           add_wait_queue
                           __pollwait
                           sock_poll_wait
                           unix_poll
                           sock_poll
                           do_select
                           core_sys_select
                           sys_select
                           system_call_fastpath
                           0x3961ed91d3
                           0x42e9aa
                           0x422e1a
                           0x3961e2143d

     0.00%   gnome-terminal  [kernel.kallsyms]                   [k] __inc_zone_state
             |
             --- __inc_zone_state
                 zone_statistics
                 get_page_from_freelist
                 __alloc_pages_nodemask
                 alloc_pages_current
                 __get_free_pages
                 __pollwait
                 n_tty_poll
                 tty_poll
                 do_sys_poll
                 sys_poll
                 system_call_fastpath
                 __GI___poll

     0.00%          swapper  [kernel.kallsyms]                   [k] tick_check_oneshot_broadcast
                    |
                    --- tick_check_oneshot_broadcast
                        tick_check_idle
                        irq_enter
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.00%              top  libc-2.13.90.so                     [.] __GI_____strtoll_l_internal
                        |
                        --- __GI_____strtoll_l_internal

     0.00%      gnome-shell  [kernel.kallsyms]                   [k] _copy_from_user
                |
                --- _copy_from_user
                    do_sys_poll
                    sys_poll
                    system_call_fastpath
                    __GI___poll

     0.00%              top  libc-2.13.90.so                     [.] __GI_vfprintf
                        |
                        --- __GI_vfprintf
                            ___vsprintf_chk

     0.00%          swapper  [kernel.kallsyms]                   [k] __rcu_pending
                    |
                    --- __rcu_pending
                        rcu_check_callbacks
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%      gnome-shell  [kernel.kallsyms]                   [k] cpumask_next_and
                |
                --- cpumask_next_and
                    find_busiest_group
                    load_balance
                    schedule
                    schedule_hrtimeout_range_clock
                    schedule_hrtimeout_range
                    poll_schedule_timeout
                    do_sys_poll
                    sys_poll
                    system_call_fastpath
                    __GI___poll

     0.00%      gnome-shell  libmutter.so.0.0.0                  [.] 0x3c766         
                |
                --- 0x3f0063c766

                |
                --- 0x3f0062fab8

     0.00%   gnome-terminal  libc-2.13.90.so                     [.] __memmove_ssse3
             |
             --- __memmove_ssse3

     0.00%             Xorg  [kernel.kallsyms]                   [k] get_page_from_freelist
                       |
                       --- get_page_from_freelist
                           __alloc_pages_nodemask
                           alloc_pages_current
                           __page_cache_alloc
                           do_read_cache_page
                           read_cache_page_gfp
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%   NetworkManager  [kernel.kallsyms]                   [k] kstrdup
             |
             --- kstrdup
                 security_inode_init_security
                 ext4_init_security
                 ext4_new_inode
                 ext4_create
                 vfs_create
                 do_last
                 do_filp_open
                 do_sys_open
                 sys_open
                 system_call_fastpath
                 0x396220ec9d

     0.00%   NetworkManager  [kernel.kallsyms]                   [k] avtab_search_node
             |
             --- avtab_search_node
                 cond_compute_av
                 context_struct_compute_av
                 security_compute_av
                 avc_has_perm_noaudit
                 avc_has_perm
                 inode_has_perm
                 selinux_inode_permission
                 security_inode_exec_permission
                 exec_permission
                 link_path_walk
                 do_path_lookup
                 do_filp_open
                 do_sys_open
                 sys_open
                 system_call_fastpath
                 0x396220ec9d

     0.00%          swapper  [kernel.kallsyms]                   [k] cpuidle_idle_call
                    |
                    --- cpuidle_idle_call
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%              top  libc-2.13.90.so                     [.] __mpn_mul_1
                        |
                        --- __mpn_mul_1

     0.00%      usb-storage  [kernel.kallsyms]                   [k] schedule
                |
                --- schedule
                    schedule_timeout
                    wait_for_common
                    wait_for_completion_interruptible_timeout
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    kthread
                    kernel_thread_helper

     0.00%             Xorg  [kernel.kallsyms]                   [k] __mod_zone_page_state
                       |
                       --- __mod_zone_page_state
                           __add_page_to_lru_list
                           ____pagevec_lru_add
                           __lru_cache_add
                           add_to_page_cache_lru
                           do_read_cache_page
                           read_cache_page_gfp
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%          swapper  [kernel.kallsyms]                   [k] __kprobes_text_start
                    |
                    --- __kprobes_text_start
                        paravirt_read_tsc
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%          swapper  [kernel.kallsyms]                   [k] ehci_work
                    |
                    --- ehci_work
                        ehci_irq
                        usb_hcd_irq
                        handle_IRQ_event
                        handle_fasteoi_irq
                        handle_irq
                        __irqentry_text_start
                        ret_from_intr
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%      gnome-shell  libc-2.13.90.so                     [.] free_check
                |
                --- free_check

     0.00%          swapper  [kernel.kallsyms]                   [k] tick_nohz_restart_sched_tick
                    |
                    --- tick_nohz_restart_sched_tick
                        cpu_idle
                        start_secondary

     0.00%             perf  [kernel.kallsyms]                   [k] do_raw_spin_lock
                       |
                       --- do_raw_spin_lock
                           ext4_da_get_block_prep
                           __block_write_begin
                           ext4_da_write_begin
                           generic_file_buffered_write
                           __generic_file_aio_write
                           generic_file_aio_write
                           ext4_file_write
                           do_sync_write
                           vfs_write
                           sys_write
                           system_call_fastpath
                           __write_nocancel
                           0x4191c6
                           0x40f7a9
                           0x40ef8c
                           __libc_start_main

     0.00%              top  libc-2.13.90.so                     [.] _IO_setb_internal
                        |
                        --- _IO_setb_internal

     0.00%             Xorg  [kernel.kallsyms]                   [k] page_cache_get_speculative
                       |
                       --- page_cache_get_speculative
                           find_get_pages
                           pagevec_lookup
                           truncate_inode_pages_range
                           truncate_inode_pages
                           i915_gem_object_truncate
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           drm_gem_vm_close
                           kref_put
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%      gnome-shell  libGL.so.1.2                        [.] 0x54160         
                |
                --- 0x346a854160

     0.00%   gnome-terminal  libc-2.13.90.so                     [.] _int_free
             |
             --- _int_free

     0.00%          swapper  [kernel.kallsyms]                   [k] task_rq_unlock
                    |
                    --- task_rq_unlock
                        try_to_wake_up
                        wake_up_process
                        wake_up_worker
                        insert_work
                        __queue_work
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%             Xorg  [kernel.kallsyms]                   [k] __mem_cgroup_uncharge_common
                       |
                       --- __mem_cgroup_uncharge_common
                           mem_cgroup_uncharge_cache_page
                           remove_from_page_cache
                           truncate_inode_page
                           truncate_inode_pages_range
                           truncate_inode_pages
                           i915_gem_object_truncate
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           drm_gem_vm_close
                           kref_put
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_gem_vm_close
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%              top  [kernel.kallsyms]                   [k] __lock_text_start
                        |
                        --- __lock_text_start
                            __rcu_process_callbacks
                            rcu_process_callbacks
                            __do_softirq
                            call_softirq
                            do_softirq
                            irq_exit
                            smp_apic_timer_interrupt
                            apic_timer_interrupt
                            do_lookup
                            link_path_walk
                            do_path_lookup
                            do_filp_open
                            do_sys_open
                            sys_open
                            system_call_fastpath
                            __GI___libc_open

     0.00%              top  [kernel.kallsyms]                   [k] do_sigaction
                        |
                        --- do_sigaction
                            sys_rt_sigaction
                            system_call_fastpath
                            __GI___libc_sigaction

     0.00%      gnome-shell  libgnome-shell.so                   [.] 0x60dff         
                |
                --- 0x38aee60dff

     0.00%          swapper  [kernel.kallsyms]                   [k] atomic_notifier_call_chain
                    |
                    --- atomic_notifier_call_chain
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%          swapper  [kernel.kallsyms]                   [k] _raw_spin_lock_irqsave
                    |
                    --- _raw_spin_lock_irqsave
                        delayed_work_timer_fn
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%          swapper  [kernel.kallsyms]                   [k] ns_to_timespec
                    |
                    --- ns_to_timespec
                        menu_select
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%             Xorg  [kernel.kallsyms]                   [k] arch_local_save_flags
                       |
                       --- arch_local_save_flags
                           __might_sleep
                           mutex_lock_interruptible
                           i915_mutex_lock_interruptible
                           i915_gem_object_bind_to_gtt
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%             Xorg  [kernel.kallsyms]                   [k] __kmalloc
                       |
                       --- __kmalloc
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%             Xorg  [i915]                              [k] i915_gem_retire_requests_ring
                       |
                       --- i915_gem_retire_requests_ring
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%              top  [kernel.kallsyms]                   [k] __d_lookup
                        |
                        --- __d_lookup
                            d_lookup
                            proc_fill_cache
                            proc_pid_readdir
                            proc_root_readdir
                            vfs_readdir
                            sys_getdents
                            system_call_fastpath
                            __getdents64

     0.00%             Xorg  [kernel.kallsyms]                   [k] skb_has_frag_list
                       |
                       --- skb_has_frag_list
                           __kfree_skb
                           consume_skb
                           unix_stream_recvmsg
                           sock_aio_read.part.7
                           sock_aio_read
                           do_sync_read
                           vfs_read
                           sys_read
                           system_call_fastpath
                           0x396220e4d0
                           0x45fd01
                           0x42ea88
                           0x422e1a
                           0x3961e2143d

     0.00%          swapper  [kernel.kallsyms]                   [k] rb_next
                    |
                    --- rb_next
                        timerqueue_del
                        __remove_hrtimer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%   gnome-terminal  libXrender.so.1.3.0                 [.] 0x4de5          
             |
             --- 0x3f14604de5

     0.00%          swapper  [kernel.kallsyms]                   [k] find_busiest_group
                    |
                    --- find_busiest_group
                        load_balance
                        rebalance_domains
                        run_rebalance_domains
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_call_function_single_interrupt
                        call_function_single_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%              top  [kernel.kallsyms]                   [k] proc_fill_cache
                        |
                        --- proc_fill_cache
                            proc_pid_readdir
                            proc_root_readdir
                            vfs_readdir
                            sys_getdents
                            system_call_fastpath
                            __getdents64

     0.00%          swapper  [kernel.kallsyms]                   [k] task_waking_fair
                    |
                    --- task_waking_fair
                        wake_up_process
                        hrtimer_wakeup
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%          swapper  [kernel.kallsyms]                   [k] native_read_tsc
                    |
                    --- native_read_tsc
                        paravirt_read_tsc
                        read_tsc
                        timekeeping_get_ns
                        ktime_get
                        tick_check_idle
                        irq_enter
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.00%          swapper  [kernel.kallsyms]                   [k] notifier_call_chain
                    |
                    --- notifier_call_chain
                        atomic_notifier_call_chain
                        exit_idle
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.00%          swapper  [kernel.kallsyms]                   [k] rcu_check_callbacks
                    |
                    --- rcu_check_callbacks
                        update_process_times
                        tick_sched_timer
                        __run_hrtimer
                        hrtimer_interrupt
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%      usb-storage  [kernel.kallsyms]                   [k] wait_for_common
                |
                --- wait_for_common
                    wait_for_completion_interruptible_timeout
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    usb_stor_transparent_scsi_command
                    kthread
                    kernel_thread_helper

     0.00%             Xorg  [kernel.kallsyms]                   [k] __vm_enough_memory
                       |
                       --- __vm_enough_memory
                           selinux_vm_enough_memory
                           security_vm_enough_memory_kern
                           shmem_getpage
                           shmem_readpage
                           do_read_cache_page
                           read_cache_page_gfp
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%             Xorg  [kernel.kallsyms]                   [k] clear_page_c
                       |
                       --- clear_page_c
                           shmem_readpage
                           do_read_cache_page
                           read_cache_page_gfp
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_object_bind_to_gtt
                           i915_gem_execbuffer
                           drm_ctxbitmap_init
                           do_vfs_ioctl
                           sys_ioctl
                           system_call_fastpath
                           0x3961ed8af7

     0.00%          firefox  libc-2.13.90.so                     [.] _int_malloc
                    |
                    --- _int_malloc

     0.00%          firefox  [kernel.kallsyms]                   [k] copy_user_generic_string
                    |
                    --- copy_user_generic_string
                        do_sys_poll
                        sys_poll
                        system_call_fastpath
                        __GI___poll

     0.00%          swapper  [kernel.kallsyms]                   [k] find_next_bit
                    |
                    --- find_next_bit
                        tick_nohz_stop_sched_tick
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%             Xorg  [kernel.kallsyms]                   [k] poll_freewait
                       |
                       --- poll_freewait
                           do_select
                           core_sys_select
                           sys_select
                           system_call_fastpath
                           0x3961ed91d3
                           0x42e9aa
                           0x422e1a
                           0x3961e2143d

     0.00%      gnome-shell  libc-2.13.90.so                     [.] __memset_sse2
                |
                --- __memset_sse2

     0.00%      kworker/2:0  [kernel.kallsyms]                   [k] rb_erase
                |
                --- rb_erase
                    set_next_entity
                    pick_next_task_fair
                    pick_next_task
                    schedule
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.00%      gnome-shell  libgthread-2.0.so.0.2800.6          [.] 0x22b7          
                |
                --- 0x3f136022b7

     0.00%              top  [kernel.kallsyms]                   [k] find_pid_ns
                        |
                        --- find_pid_ns
                            find_ge_pid
                            next_tgid
                            proc_pid_readdir
                            proc_root_readdir
                            vfs_readdir
                            sys_getdents
                            system_call_fastpath
                            __getdents64

     0.00%          swapper  [kernel.kallsyms]                   [k] virt_to_head_page
                    |
                    --- virt_to_head_page
                        kfree
                        nf_conntrack_free
                        destroy_conntrack
                        nf_conntrack_destroy
                        nf_conntrack_put
                        death_by_timeout
                        run_timer_softirq
                        __do_softirq
                        call_softirq
                        do_softirq
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        rest_init
                        start_kernel
                        x86_64_start_reservations
                        x86_64_start_kernel

     0.00%      kworker/0:0  [kernel.kallsyms]                   [k] schedule
                |
                --- schedule
                    worker_thread
                    kthread
                    kernel_thread_helper

     0.00%             Xorg  [kernel.kallsyms]                   [k] evdev_read
                       |
                       --- evdev_read
                           vfs_read
                           sys_read
                           system_call_fastpath
                           0x396220e4d0

     0.00%          swapper  [kernel.kallsyms]                   [k] rcu_needs_cpu_quick_check
                    |
                    --- rcu_needs_cpu_quick_check
                        tick_nohz_stop_sched_tick
                        irq_exit
                        smp_apic_timer_interrupt
                        apic_timer_interrupt
                        cpuidle_idle_call
                        cpu_idle
                        start_secondary

     0.00%   gnome-terminal  libc-2.13.90.so                     [.] __malloc
             |
             --- __malloc



#
# (For a higher level overview, try: perf report --sort comm,dso)
#

--------------040405040406070906010105
Content-Type: text/plain;
 name="sysrq-m.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="sysrq-m.txt"

SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 184
CPU    1: hi:  186, btch:  31 usd: 176
CPU    2: hi:  186, btch:  31 usd: 184
CPU    3: hi:  186, btch:  31 usd:  79
Node 0 Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
active_anon:88199 inactive_anon:28952 isolated_anon:0
 active_file:40195 inactive_file:308143 isolated_file:0
 unevictable:0 dirty:47117 writeback:0 unstable:0
 free:206443 slab_reclaimable:15457 slab_unreclaimable:10558
 mapped:11745 shmem:27793 pagetables:6649 bounce:0
Node 0 DMA free:12052kB min:352kB low:440kB high:528kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:3700kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:116kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 2901 2907 2907
Node 0 DMA32 free:813712kB min:67092kB low:83864kB high:100636kB active_anon:352796kB inactive_anon:115808kB active_file:160780kB inactive_file:1228872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2971428kB mlocked:0kB dirty:188468kB writeback:0kB mapped:46980kB shmem:111172kB slab_reclaimable:61696kB slab_unreclaimable:42128kB kernel_stack:2568kB pagetables:26596kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 5 5
Node 0 Normal free:8kB min:136kB low:168kB high:204kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:104kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 3*4kB 3*8kB 1*16kB 1*32kB 1*64kB 3*128kB 3*256kB 1*512kB 2*1024kB 2*2048kB 1*4096kB = 12052kB
Node 0 DMA32: 386*4kB 319*8kB 603*16kB 391*32kB 172*64kB 2134*128kB 648*256kB 191*512kB 74*1024kB 28*2048kB 26*4096kB = 813712kB
Node 0 Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8kB
376149 total pagecache pages
17 pages in swap cache
Swap cache stats: add 17, delete 0, find 0/0
Free swap  = 1507256kB
Total swap = 1507324kB
787952 pages RAM
55736 pages reserved
422306 pages shared
159440 pages non-shared

SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 179
CPU    1: hi:  186, btch:  31 usd: 172
CPU    2: hi:  186, btch:  31 usd: 183
CPU    3: hi:  186, btch:  31 usd: 115
Node 0 Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
active_anon:88210 inactive_anon:29624 isolated_anon:0
 active_file:40284 inactive_file:307344 isolated_file:0
 unevictable:0 dirty:32 writeback:0 unstable:0
 free:206370 slab_reclaimable:15462 slab_unreclaimable:10552
 mapped:11747 shmem:28453 pagetables:6649 bounce:0
Node 0 DMA free:12052kB min:352kB low:440kB high:528kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:3700kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:116kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 2901 2907 2907
Node 0 DMA32 free:813420kB min:67092kB low:83864kB high:100636kB active_anon:352840kB inactive_anon:118496kB active_file:161136kB inactive_file:1225676kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2971428kB mlocked:0kB dirty:128kB writeback:0kB mapped:46988kB shmem:113812kB slab_reclaimable:61716kB slab_unreclaimable:42104kB kernel_stack:2592kB pagetables:26596kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 5 5
Node 0 Normal free:8kB min:136kB low:168kB high:204kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:104kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 3*4kB 3*8kB 1*16kB 1*32kB 1*64kB 3*128kB 3*256kB 1*512kB 2*1024kB 2*2048kB 1*4096kB = 12052kB
Node 0 DMA32: 305*4kB 215*8kB 313*16kB 419*32kB 208*64kB 2140*128kB 652*256kB 192*512kB 74*1024kB 28*2048kB 26*4096kB = 813420kB
Node 0 Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8kB
376098 total pagecache pages
17 pages in swap cache
Swap cache stats: add 17, delete 0, find 0/0
Free swap  = 1507256kB
Total swap = 1507324kB
787952 pages RAM
55736 pages reserved
422004 pages shared
159789 pages non-shared

SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 160
CPU    1: hi:  186, btch:  31 usd: 177
CPU    2: hi:  186, btch:  31 usd:  52
CPU    3: hi:  186, btch:  31 usd: 169
Node 0 Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
active_anon:88229 inactive_anon:30769 isolated_anon:0
 active_file:40449 inactive_file:305875 isolated_file:0
 unevictable:0 dirty:11 writeback:0 unstable:0
 free:206641 slab_reclaimable:15383 slab_unreclaimable:10537
 mapped:11772 shmem:29634 pagetables:6689 bounce:0
Node 0 DMA free:12052kB min:352kB low:440kB high:528kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:3700kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:116kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 2901 2907 2907
Node 0 DMA32 free:814504kB min:67092kB low:83864kB high:100636kB active_anon:352916kB inactive_anon:123076kB active_file:161796kB inactive_file:1219800kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2971428kB mlocked:0kB dirty:44kB writeback:0kB mapped:47088kB shmem:118536kB slab_reclaimable:61400kB slab_unreclaimable:42044kB kernel_stack:2584kB pagetables:26756kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 5 5
Node 0 Normal free:8kB min:136kB low:168kB high:204kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:104kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 3*4kB 3*8kB 1*16kB 1*32kB 1*64kB 3*128kB 3*256kB 1*512kB 2*1024kB 2*2048kB 1*4096kB = 12052kB
Node 0 DMA32: 63*4kB 158*8kB 138*16kB 395*32kB 167*64kB 2155*128kB 668*256kB 197*512kB 74*1024kB 28*2048kB 26*4096kB = 814380kB
Node 0 Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8kB
375974 total pagecache pages
17 pages in swap cache
Swap cache stats: add 17, delete 0, find 0/0
Free swap  = 1507256kB
Total swap = 1507324kB
787952 pages RAM
55736 pages reserved
420622 pages shared
161373 pages non-shared

--------------040405040406070906010105--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
