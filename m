Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 084E66B004D
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 23:45:54 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so7314782pbc.14
        for <linux-mm@kvack.org>; Sun, 15 Apr 2012 20:45:54 -0700 (PDT)
Content-Type: multipart/mixed; boundary=----------NRwzAEg3RIICRRbWvX2RpJ
Subject: Re: question about memsw of memory cgroup-subsystem
References: <op.wco7ekvhn27o5l@gaoqiang-d1.corp.qihoo.net>
 <20120413144954.GA9227@tiehlicka.suse.cz>
Date: Mon, 16 Apr 2012 11:43:56 +0800
MIME-Version: 1.0
From: gaoqiang <gaoqiangscut@gmail.com>
Message-ID: <op.wct9zibjn27o5l@gaoqiang-d1.corp.qihoo.net>
In-Reply-To: <20120413144954.GA9227@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

------------NRwzAEg3RIICRRbWvX2RpJ
Content-Type: text/plain; charset=gbk; format=flowed; delsp=yes
Content-Transfer-Encoding: Quoted-Printable

=D4=DA Fri, 13 Apr 2012 22:49:54 +0800=A3=ACMichal Hocko <mhocko@suse.cz=
> =D0=B4=B5=C0:

> [CC linux-mm]
>
> Hi,
>
> On Fri 13-04-12 18:00:10, gaoqiang wrote:
>>
>>
>> I put a single process into a cgroup and set memory.limit_in_bytes
>> to 100M,and memory.memsw.limit_in_bytes to 1G.
>>
>> howevery,the process was oom-killed before mem+swap hit 1G. I tried
>> many times,and it was killed randomly when memory+swap
>>
>> exceed 100M but less than 1G.  what is the matter ?
>
> could you be more specific about your kernel version, workload and cou=
ld
> you provide us with GROUP/memory.stat snapshots taken during your test=
?
>
> One reason for oom might be that you are hitting the hard limit (you
> cannot get over even if memsw limit says more) and you cannot swap out=

> any pages (e.g. they are mlocked or under writeback).
>

many thanks.


The system is a vmware virtual machine,running centos6.2 with kernel  =

2.6.32-220.7.1.el6.x86_64.

the attachments are memory.stat, the test program and the /var/log/messa=
ge  =

of the oom.

the workload is nearly 0,with searal sshd and bash program running.

I just did the following command when testing:

./t
# this program will pause at the "getchar()" line and in another  =

terminal,run :

cgclear
service cgconfig restart
mkdir /cgroup/memory/test
cd /cgroup/memory/test
echo 100m > memory.limit_in_bytes
echo 1G > memory.memsw.limit_in_bytes
echo 'pid' > tasks

# then continue the t command


-- =

=CA=B9=D3=C3 Opera =B8=EF=C3=FC=D0=D4=B5=C4=B5=E7=D7=D3=D3=CA=BC=FE=BF=CD=
=BB=A7=B3=CC=D0=F2: http://www.opera.com/mail/
------------NRwzAEg3RIICRRbWvX2RpJ
Content-Disposition: attachment; filename=memory.stat
Content-Type: application/octet-stream; name="memory.stat"
Content-Transfer-Encoding: Base64

Y2FjaGUgMA0KcnNzIDUyNDczODU2DQptYXBwZWRfZmlsZSAwDQpwZ3BnaW4gMzky
OTYNCnBncGdvdXQgMzg3NDkNCnN3YXAgMA0KaW5hY3RpdmVfYW5vbiA1MjQ3Mzg1
Ng0KYWN0aXZlX2Fub24gMA0KaW5hY3RpdmVfZmlsZSAwDQphY3RpdmVfZmlsZSAw
DQp1bmV2aWN0YWJsZSAwDQpoaWVyYXJjaGljYWxfbWVtb3J5X2xpbWl0IDEwNDg1
NzYwMA0KaGllcmFyY2hpY2FsX21lbXN3X2xpbWl0IDEwNzM3NDE4MjQNCnRvdGFs
X2NhY2hlIDANCnRvdGFsX3JzcyA1MjQ3Mzg1Ng0KdG90YWxfbWFwcGVkX2ZpbGUg
MA0KdG90YWxfcGdwZ2luIDM5Mjk2DQp0b3RhbF9wZ3Bnb3V0IDM4NzQ5DQp0b3Rh
bF9zd2FwIDANCnRvdGFsX2luYWN0aXZlX2Fub24gNTI0NzM4NTYNCnRvdGFsX2Fj
dGl2ZV9hbm9uIDANCnRvdGFsX2luYWN0aXZlX2ZpbGUgMA0KdG90YWxfYWN0aXZl
X2ZpbGUgMA0KdG90YWxfdW5ldmljdGFibGUgMA==

------------NRwzAEg3RIICRRbWvX2RpJ
Content-Disposition: attachment; filename=oom_message.txt
Content-Type: text/plain; name==??Q?oom=5Fmessage.txt?=
Content-Transfer-Encoding: 7bit

Apr 16 11:34:50 localhost kernel: t invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
Apr 16 11:34:50 localhost kernel: t cpuset=/ mems_allowed=0
Apr 16 11:34:50 localhost kernel: Pid: 15462, comm: t Not tainted 2.6.32-220.7.1.el6.x86_64 #1
Apr 16 11:34:50 localhost kernel: Call Trace:
Apr 16 11:34:50 localhost kernel: [<ffffffff810c2c61>] ? cpuset_print_task_mems_allowed+0x91/0xb0
Apr 16 11:34:50 localhost kernel: [<ffffffff811139e0>] ? dump_header+0x90/0x1b0
Apr 16 11:34:50 localhost kernel: [<ffffffff811693b5>] ? task_in_mem_cgroup+0x35/0xb0
Apr 16 11:34:50 localhost kernel: [<ffffffff8120d7ac>] ? security_real_capable_noaudit+0x3c/0x70
Apr 16 11:34:50 localhost kernel: [<ffffffff81113e6a>] ? oom_kill_process+0x8a/0x2c0
Apr 16 11:34:50 localhost kernel: [<ffffffff81113d5e>] ? select_bad_process+0x9e/0x120
Apr 16 11:34:50 localhost kernel: [<ffffffff81114602>] ? mem_cgroup_out_of_memory+0x92/0xb0
Apr 16 11:34:50 localhost kernel: [<ffffffff81169357>] ? mem_cgroup_handle_oom+0x147/0x170
Apr 16 11:34:50 localhost kernel: [<ffffffff81090a90>] ? autoremove_wake_function+0x0/0x40
Apr 16 11:34:50 localhost kernel: [<ffffffff8116a61b>] ? __mem_cgroup_try_charge+0x3bb/0x420
Apr 16 11:34:50 localhost kernel: [<ffffffff81123851>] ? __alloc_pages_nodemask+0x111/0x940
Apr 16 11:34:50 localhost kernel: [<ffffffff8116b917>] ? mem_cgroup_charge_common+0x87/0xd0
Apr 16 11:34:50 localhost kernel: [<ffffffff8116bae8>] ? mem_cgroup_newpage_charge+0x48/0x50
Apr 16 11:34:50 localhost kernel: [<ffffffff8113beca>] ? handle_pte_fault+0x79a/0xb50
Apr 16 11:34:50 localhost kernel: [<ffffffff810471c7>] ? pte_alloc_one+0x37/0x50
Apr 16 11:34:50 localhost kernel: [<ffffffff81171ad9>] ? do_huge_pmd_anonymous_page+0xb9/0x370
Apr 16 11:34:50 localhost kernel: [<ffffffff8100bc0e>] ? apic_timer_interrupt+0xe/0x20
Apr 16 11:34:50 localhost kernel: [<ffffffff8113c464>] ? handle_mm_fault+0x1e4/0x2b0
Apr 16 11:34:50 localhost kernel: [<ffffffff81042b79>] ? __do_page_fault+0x139/0x480
Apr 16 11:34:50 localhost kernel: [<ffffffff811424ea>] ? do_mmap_pgoff+0x33a/0x380
Apr 16 11:34:50 localhost kernel: [<ffffffff814f253e>] ? do_page_fault+0x3e/0xa0
Apr 16 11:34:50 localhost kernel: [<ffffffff814ef8f5>] ? page_fault+0x25/0x30
Apr 16 11:34:50 localhost kernel: Task in /test killed as a result of limit of /test
Apr 16 11:34:50 localhost kernel: memory: usage 102400kB, limit 102400kB, failcnt 756
Apr 16 11:34:50 localhost kernel: memory+swap: usage 206240kB, limit 1048576kB, failcnt 0
Apr 16 11:34:50 localhost kernel: Mem-Info:
Apr 16 11:34:50 localhost kernel: Node 0 DMA per-cpu:
Apr 16 11:34:50 localhost kernel: CPU    0: hi:    0, btch:   1 usd:   0
Apr 16 11:34:50 localhost kernel: CPU    1: hi:    0, btch:   1 usd:   0
Apr 16 11:34:50 localhost kernel: CPU    2: hi:    0, btch:   1 usd:   0
Apr 16 11:34:50 localhost kernel: CPU    3: hi:    0, btch:   1 usd:   0
Apr 16 11:34:50 localhost kernel: Node 0 DMA32 per-cpu:
Apr 16 11:34:50 localhost kernel: CPU    0: hi:  186, btch:  31 usd:  88
Apr 16 11:34:50 localhost kernel: CPU    1: hi:  186, btch:  31 usd:   0
Apr 16 11:34:50 localhost kernel: CPU    2: hi:  186, btch:  31 usd:   0
Apr 16 11:34:50 localhost kernel: CPU    3: hi:  186, btch:  31 usd:  53
Apr 16 11:34:50 localhost kernel: active_anon:14198 inactive_anon:66406 isolated_anon:0
Apr 16 11:34:50 localhost kernel: active_file:62480 inactive_file:88538 isolated_file:0
Apr 16 11:34:50 localhost kernel: unevictable:0 dirty:0 writeback:12822 unstable:0
Apr 16 11:34:50 localhost kernel: free:27898 slab_reclaimable:8884 slab_unreclaimable:9427
Apr 16 11:34:50 localhost kernel: mapped:2723 shmem:68 pagetables:1747 bounce:0
Apr 16 11:34:50 localhost kernel: Node 0 DMA free:15704kB min:592kB low:740kB high:888kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15308kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Apr 16 11:34:50 localhost kernel: lowmem_reserve[]: 0 1120 1120 1120
Apr 16 11:34:50 localhost kernel: Node 0 DMA32 free:95888kB min:44460kB low:55572kB high:66688kB active_anon:56792kB inactive_anon:265624kB active_file:249920kB inactive_file:354152kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1147232kB mlocked:0kB dirty:0kB writeback:51288kB mapped:10892kB shmem:272kB slab_reclaimable:35536kB slab_unreclaimable:37708kB kernel_stack:2216kB pagetables:6988kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Apr 16 11:34:50 localhost kernel: lowmem_reserve[]: 0 0 0 0
Apr 16 11:34:50 localhost kernel: Node 0 DMA: 2*4kB 4*8kB 3*16kB 2*32kB 1*64kB 1*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15704kB
Apr 16 11:34:50 localhost kernel: Node 0 DMA32: 124*4kB 882*8kB 579*16kB 337*32kB 171*64kB 42*128kB 3*256kB 32*512kB 32*1024kB 1*2048kB 0*4096kB = 95888kB
Apr 16 11:34:50 localhost kernel: 211205 total pagecache pages
Apr 16 11:34:50 localhost kernel: 60108 pages in swap cache
Apr 16 11:34:50 localhost kernel: Swap cache stats: add 1240384, delete 1180276, find 400/507
Apr 16 11:34:50 localhost kernel: Free swap  = 1720104kB
Apr 16 11:34:50 localhost kernel: Total swap = 2064376kB
Apr 16 11:34:50 localhost kernel: 294896 pages RAM
Apr 16 11:34:50 localhost kernel: 7632 pages reserved
Apr 16 11:34:50 localhost kernel: 100154 pages shared
Apr 16 11:34:50 localhost kernel: 171738 pages non-shared
Apr 16 11:34:50 localhost kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 16 11:34:50 localhost kernel: [15462]   500 15462    58346    12903   3       0             0 t
Apr 16 11:34:50 localhost kernel: Memory cgroup out of memory: Kill process 15462 (t) score 1000 or sacrifice child
Apr 16 11:34:50 localhost kernel: Killed process 15462, UID 500, (t) total-vm:233384kB, anon-rss:51228kB, file-rss:384kB
------------NRwzAEg3RIICRRbWvX2RpJ
Content-Disposition: attachment; filename=test.c
Content-Type: application/octet-stream; name="test.c"
Content-Transfer-Encoding: Base64

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8dW5pc3RkLmg+DQojZGVmaW5l
IEJVRl9MRU4gKDEwMjQqMTAyNCozMikNCmludCBtYWluKCkNCnsNCglwcmludGYo
InBpZD0gJWQgXG4iLGdldHBpZCgpKTsNCglnZXRjaGFyKCk7DQoJaW50IGNudD0w
Ow0KCXdoaWxlKDEpDQoJew0KCQljaGFyKnA9bWFsbG9jKEJVRl9MRU4pOw0KCQlp
ZihwPT1OVUxMKQ0KCQl7DQoJCQlwcmludGYoInA9TlVMTFxuIik7DQoJCQlyZXR1
cm4gMDsNCgkJfQ0KCQltZW1zZXQocCwwLEJVRl9MRU4pOw0KCQljbnQrPUJVRl9M
RU47DQoJCXByaW50ZigidXNhZ2U6ICVka1xuIixjbnQvMTAyNCk7DQoJCS8vc2xl
ZXAoMSk7DQoJfQ0KCXJldHVybiAwOw0KfQ==

------------NRwzAEg3RIICRRbWvX2RpJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
