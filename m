Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 928B16B00EF
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 04:11:28 -0400 (EDT)
Message-ID: <4DF0801F.9050908@redhat.com>
Date: Thu, 09 Jun 2011 10:11:11 +0200
From: Igor Mammedov <imammedo@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>	<20110601123913.GC4266@tiehlicka.suse.cz>	<4DE6399C.8070802@redhat.com>	<20110601134149.GD4266@tiehlicka.suse.cz>	<4DE64F0C.3050203@redhat.com>	<20110601152039.GG4266@tiehlicka.suse.cz>	<4DE66BEB.7040502@redhat.com>	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>	<4DE8D50F.1090406@redhat.com>	<BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>	<4DEE26E7.2060201@redhat.com> <20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, stefano.stabellini@eu.citrix.com, keir.xen@gmail.com

On 06/08/2011 05:35 AM, KAMEZAWA Hiroyuki wrote:
> On Tue, 07 Jun 2011 15:25:59 +0200
> Igor Mammedov<imammedo@redhat.com>  wrote:
>
>> Sorry for late reply,
>>
>> On 06/03/2011 03:00 PM, Hiroyuki Kamezawa wrote:
>>> 2011/6/3 Igor Mammedov<imammedo@redhat.com>:
>>>> On 06/02/2011 01:10 AM, Hiroyuki Kamezawa wrote:
>>>>>> pc = list_entry(list->prev, struct page_cgroup, lru);
>>>>> Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
>>>>> before completion of
>>>>> create() is not populated to userland and you never be able to rmdir()
>>>>> it because you can't
>>>>> find it.
>>>>>
>>>>>
>>>>>    >26:   e8 7d 12 30 00          call   0x3012a8
>>>>>    >2b:*  8b 73 08                mov    0x8(%ebx),%esi<-- trapping
>>>>> instruction
>>>>>    >2e:   8b 7c 24 24             mov    0x24(%esp),%edi
>>>>>    >32:   8b 07                   mov    (%edi),%eax
>>>>>
>>>>> Hm, what is the call 0x3012a8 ?
>>>>>
>>>>                  pc = list_entry(list->prev, struct page_cgroup, lru);
>>>>                  if (busy == pc) {
>>>>                          list_move(&pc->lru, list);
>>>>                          busy = 0;
>>>>                          spin_unlock_irqrestore(&zone->lru_lock, flags);
>>>>                          continue;
>>>>                  }
>>>>                  spin_unlock_irqrestore(&zone->lru_lock, flags);<---- is
>>>>    call 0x3012a8
>>>>                  ret = mem_cgroup_move_parent(pc, mem, GFP_KERNEL);
>>>>
>>>> and  mov 0x8(%ebx),%esi
>>>> is dereferencing of 'pc' in inlined mem_cgroup_move_parent
>>>>
>>> Ah, thank you for input..then panicd at accessing pc->page and "pc"
>>> was 0xfffffff4.
>>> it means list->prev was NULL.
>>>
>> yes, that's the case.
>>>> I've looked at vmcore once more and indeed there isn't any parallel task
>>>> that touches cgroups code path.
>>>> Will investigate if it is xen to blame for incorrect data in place.
>>>>
>>>> Thanks very much for your opinion.
>>> What curious to me is that the fact "list->prev" is NULL.
>>> I can see why you doubt the initialization code ....the list pointer never
>>> contains NULL once it's used....
>>> it smells like memory corruption or some to me. If you have vmcore,
>>> what the problematic mem_cgroup_per_zone(node) contains ?
>> it has all zeros except for last field:
>>
>> crash>  rd f3446a00 62
>> f3446a00:  00000000 00000000 00000000 00000000   ................
>> f3446a10:  00000000 00000000 00000000 00000000   ................
>> f3446a20:  00000000 00000000 00000000 00000000   ................
>> f3446a30:  00000000 00000000 00000000 00000000   ................
>> f3446a40:  00000000 00000000 00000000 00000000   ................
>> f3446a50:  00000000 00000000 00000000 00000000   ................
>> f3446a60:  00000000 00000000 00000000 00000000   ................
>> f3446a70:  00000000 00000000 f36ef800 f3446a7c   ..........n.|jD.
>> f3446a80:  f3446a7c f3446a84 f3446a84 f3446a8c   |jD..jD..jD..jD.
>> f3446a90:  f3446a8c f3446a94 f3446a94 f3446a9c   .jD..jD..jD..jD.
>> f3446aa0:  f3446a9c 00000000 00000000 00000000   .jD.............
>> f3446ab0:  00000000 00000000 00000000 00000000   ................
>> f3446ac0:  00000000 00000000 00000000 00000000   ................
>> f3446ad0:  00000000 00000000 00000000 00000000   ................
>> f3446ae0:  00000000 00000000 00000000 00000000   ................
>> f3446af0:  00000000 f36ef800
>>
>> crash>  struct mem_cgroup f36ef800
>> struct mem_cgroup {
>> ...
>> info = {
>>       nodeinfo = {0xf3446a00}
>>     },
>> ...
>>
>> It looks like a very targeted corruption of the first zone except of
>> the last field, while the second zone and the rest are perfectly
>> normal (i.e. have empty initialized lists).
>>
> Hmm, ok, thank you. Then, mem_cgroup_pre_zone[] was initialized once.
> In this kind of case, I tend to check slab header of memory object f3446a00,
> or check whether f3446a00 is an alive slab object or not.
It looks like f3446a00 alive/allocated object

crash> kmem f3446a00
CACHE    NAME                 OBJSIZE  ALLOCATED     TOTAL  SLABS  SSIZE
f7000c80 size-512                 512       2251      2616    327     4k
SLAB      MEMORY    TOTAL  ALLOCATED  FREE
f3da6540  f3446000      8          1     7
FREE / [ALLOCATED]
   [f3446a00]

   PAGE    PHYSICAL   MAPPING    INDEX CNT FLAGS
c1fa58c0  33446000         0        70  1 2800080


However I have a related crash that can lead to not initialized lists of 
the first entry
(i.e. to what we see at f3446a00), debug kernel sometimes will crash at
alloc_mem_cgroup_per_zone_info:

XXX: pn: f208dc00, phy: 3208dc00
XXX: pn: f2e85a00, phy: 32e85a00
BUG: unable to handle kernel paging request at 9b74e240
IP: [<c080b95f>] mem_cgroup_create0x+0xef/0x350
*pdpt = 0000000033542001 *pde = 0000000000000000
Oops: 0002 [#1] SMP
...

Pid: 1823, comm: libvirtd Tainted: G           ---------------- T
(2.6.32.700565 #21) HVM domU
EIP: 0060:[<c080b95f>] EFLAGS: 00210297 CPU: 3
EIP is at mem_cgroup_create+0xef/0x350
EAX: 9b74e240 EBX: f2e85a00 ECX: 00000001 EDX: 00000001
ESI: a88c8840 EDI: a88c8840 EBP: f201deb4 ESP: f201de8c
  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process libvirtd (pid: 1823, ti=f201c000 task=f3642ab0 task.ti=f201c000)
Stack:
  c09579b2 f2e85a00 32e85a00 f3455800 00000000 f2e85a00 f2c14ac0 c0a5a820
<0>  fffffff4 f2c14ac0 f201def8 c049d3a7 00000000 00000000 00000000 000001ed
<0>  f2c14ac8 f5fa4400 f24fe954 f3502000 f2c14e40 f24f5608 f3502010 f2c14ac0
Call Trace:
  [<c049d3a7>] cgroup_mkdir+0xf7/0x450
  [<c05318e3>] vfs_mkdir+0x93/0xf0
  [<c0533787>] ? lookup_hash+0x27/0x30
  [<c053390e>] sys_mkdirat+0xde/0x100
  [<c04b5d4d>] ? call_rcu_sched+0xd/0x10
  [<c04b5d58>] ? call_rcu+0x8/0x10
  [<c047ab9f>] ? __put_cred+0x2f/0x50
  [<c0524ded>] ? sys_faccessat+0x14d/0x180
  [<c0523fb7>] ? filp_close+0x47/0x70
  [<c0533950>] sys_mkdir+0x20/0x30
  [<c0409b5f>] sysenter_do_call+0x12/0x28


static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
{
...
         memset(pn, 0, sizeof(*pn));

         for (zone = 0; zone<  MAX_NR_ZONES; zone++) {
                 mz =&pn->zoneinfo[zone];
                 for_each_lru(l)
                         INIT_LIST_HEAD(&mz->lists[l]);<- crash here
                 mz->usage_in_excess = 0;
                 mz->on_tree = false;
                 mz->mem = mem;
         }
...


crash>  dis 0xc080b93e 15
0xc080b93e<mem_cgroup_create+206>:     movl   $0x0,-0x18(%ebp)
0xc080b945<mem_cgroup_create+213>:     mov    %esi,-0x1c(%ebp)
0xc080b948<mem_cgroup_create+216>:     imul   $0x7c,-0x18(%ebp),%edi
0xc080b94c<mem_cgroup_create+220>:     xor    %ecx,%ecx
0xc080b94e<mem_cgroup_create+222>:     xor    %edx,%edx
0xc080b950<mem_cgroup_create+224>:     lea    (%edi,%edx,8),%esi
0xc080b953<mem_cgroup_create+227>:     add    $0x1,%ecx
0xc080b956<mem_cgroup_create+230>:     lea    (%ebx,%esi,1),%eax
0xc080b959<mem_cgroup_create+233>:     add    $0x1,%edx
0xc080b95c<mem_cgroup_create+236>:     cmp    $0x5,%ecx
0xc080b95f<mem_cgroup_create+239>:     mov    %eax,(%ebx,%esi,1)
0xc080b962<mem_cgroup_create+242>:     mov    %eax,0x4(%eax)
0xc080b965<mem_cgroup_create+245>:     jne    0xc080b950
0xc080b967<mem_cgroup_create+247>:     mov    -0x14(%ebp),%eax
0xc080b96a<mem_cgroup_create+250>:     movl   $0x0,0x6c(%eax)

EDI on the first iteration should be 0 however it is a88c8840 according to Oops
dump and looking at -0x18(%ebp) in core shows 0 as it should be:

crash>  x/xw 0xf201deb4-0x18
0xf201de9c:     0x00000000

so it looks like EDI is incorrectly restored by Xen or at the moment when 0xc080b948
was executed -0x18(%ebp) had that weird value.

It is possible that invalid EDI value and following

0xc080b950<mem_cgroup_create+224>:     lea    (%edi,%edx,8),%esi

<https://bugzilla.redhat.com/show_bug.cgi?id=700565#c36>lead to some 
accessible page and writes

0xc080b95f<mem_cgroup_create+239>:     mov    %eax,(%ebx,%esi,1)
0xc080b962<mem_cgroup_create+242>:     mov    %eax,0x4(%eax)

silently go to that page. Than after init lists loop it uses correct pn offset from
-0x14(%ebp) and initialises the rest fields of structure on the correct page.

                 mz->usage_in_excess = 0;
                 mz->on_tree = false;
                 mz->mem = mem;

0xc080b967<mem_cgroup_create+247>:     mov    -0x14(%ebp),%eax<-
0xc080b96a<mem_cgroup_create+250>:     movl   $0x0,0x6c(%eax)
0xc080b971<mem_cgroup_create+257>:     movl   $0x0,0x70(%eax)
0xc080b978<mem_cgroup_create+264>:     movb   $0x0,0x74(%eax)
0xc080b97c<mem_cgroup_create+268>:     mov    -0x1c(%ebp),%edx
0xc080b97f<mem_cgroup_create+271>:     mov    %edx,0x78(%eax)
0xc080b982<mem_cgroup_create+274>:     add    $0x7c,%eax
0xc080b985<mem_cgroup_create+277>:     addl   $0x1,-0x18(%ebp)
0xc080b989<mem_cgroup_create+281>:     cmpl   $0x4,-0x18(%ebp)
0xc080b98d<mem_cgroup_create+285>:     mov    %eax,-0x14(%ebp)
0xc080b990<mem_cgroup_create+288>:     jne    0xc080b948

which could lead to the 0-ed list entries of the first zone
and the originally reported Oops in mem_cgroup_force_empty.
Afterwards it looks like:

0xc080b985<mem_cgroup_create+277>:     addl   $0x1,-0x18(%ebp)

-0x18(%ebp) is read correctly and the rest of 3 mz entries are initialized as
expected.

So question is why and how
0xc080b948<mem_cgroup_create+216>:     imul   $0x7c,-0x18(%ebp),%edi
may be screwed up

PS:
However, memory search for the went astray writes of the first entry
i.e. sequesnce f3446a00 f3446a00 in a couple of vmcores didn't give
any positive results.


> Thanks,
> -Kame
>> PS:
>> It most easily reproduced only on xen hvm 32bit guest under heavy
>> vcpus contention for real cpus resources (i.e. I had to overcommit
>> cpus and run several cpu hog tasks on host to make guest crash on
>> reboot cycle).
>> And from last experiments, crash happens only on on hosts that
>> doesn't have hap feature or if hap is disabled in hypervisor.
>>
>>> Thanks,
>>> -Kame
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
