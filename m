Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 856BF2806CB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 23:37:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b78so4257362wrd.18
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 20:37:11 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j1si6985138wrb.166.2017.04.19.20.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 20:37:09 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id z129so8300193wmb.1
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 20:37:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170418195435.GB20671@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org> <20170411170317.GB21171@dhcp22.suse.cz>
 <CAA9_cmdrNZkOByvSecmocqs=6o8ZP5bz+Zx6NrwqjU66C=5Y4w@mail.gmail.com>
 <20170418071456.GD22360@dhcp22.suse.cz> <CAA9_cmfxa8QO=8-FeXWAg7iBrGh0LrZM4C=vWA5xb2ADLtO4Rw@mail.gmail.com>
 <20170418195435.GB20671@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Apr 2017 20:37:08 -0700
Message-ID: <CAA9_cmdJVaYg_KYPqRrnLe2V4rw7xPhzyCtVOp2pd+65hMX1Wg@mail.gmail.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Tue, Apr 18, 2017 at 12:54 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 18-04-17 09:42:57, Dan Williams wrote:
>> On Tue, Apr 18, 2017 at 12:14 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Mon 17-04-17 14:51:12, Dan Williams wrote:
>> >> On Tue, Apr 11, 2017 at 10:03 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> > All the reported issue seem to be fixed and pushed to my git tree
>> >> > attempts/rewrite-mem_hotplug branch. I will wait a day or two for more
>> >> > feedback and then repost for the inclusion. I would really appreaciate
>> >> > more testing/review!
>> >>
>> >> This still seems to be based on 4.10? It's missing some block-layer
>> >> fixes and other things that trigger failures in the nvdimm unit tests.
>> >> Can you rebase to a more recent 4.11-rc?
>> >
>> > OK, I will rebase on top of linux-next. This has been based on mmotm
>> > tree so far. Btw. is there anything that would change the current
>> > implementation other than small context tweaks? In other words, do you
>> > see any issues with the current implementation regarding nvdimm's
>> > ZONE_DEVICE usage?
>>
>> I don't foresee any issues, but I wanted to be able to run the latest
>> test suite to be sure.
>
> OK, the rebase on top of the current linux-next is in my git tree [1]
> attempts/rewrite-mem_hotplug branch. I will post the full series
> tomorrow hopefully.
>
> [1] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git


I'm hitting the following with the "device-dax" unit test [1]. Does
not look like your changes, but I'm kicking off a bisect between
v4.11-rc7 and this branch tip.

[1]: https://github.com/pmem/ndctl/blob/master/test/device-dax.c

---

[  547.047430] BUG: unable to handle kernel paging request at ffff880001000000
[  547.048954] IP: native_set_pte_at+0x1/0x10
[  547.049967] PGD 3197067
[  547.049968] P4D 3197067
[  547.050779] PUD 3198067
[  547.051589] PMD 33ff00067
[  547.052401] PTE 8000000001000161
[  547.053237]
[  547.054819] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
[  547.055907] Dumping ftrace buffer:
[  547.056864]    (ftrace buffer empty)
[  547.057815] Modules linked in: nd_blk(O) ip6t_rpfilter ip6t_REJECT
nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_n
at_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_mangle iptable_raw iptable_security ebtable_filter
 ebtables ip6table_filter ip6_tables crct10dif_pclmul crc32_pclmul
crc32c_intel ghash_clmulni_intel dax_pmem(O) nd_pmem(O) dax(O)
nd_btt(O) nfit(O) nd_e820(O) tpm_tis libnvdimm(O) serio_raw
tpm_tis_core tpm nfit_test_iomap(O) nfsd nfs_acl [last unloaded: nfit_test]
[  547.069034] CPU: 17 PID: 9526 Comm: lt-ndctl Tainted: G           O
   4.11.0-rc7-next-20170418+ #34
[  547.071122] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.9.3-1.fc25 04/01/2014
[  547.073163] task: ffff880322f518c0 task.stack: ffffc90002f08000
[  547.074433] RIP: 0010:native_set_pte_at+0x1/0x10
[  547.075523] RSP: 0018:ffffc90002f0bb90 EFLAGS: 00010246
[  547.076703] RAX: 0000000000000000 RBX: ffff880200000000 RCX: 0000000000000000
[  547.078129] RDX: ffff880001000000 RSI: ffff880200000000 RDI: ffffffff820892e0
[  547.079549] RBP: ffffc90002f0bba8 R08: 0000000000000000 R09: ffffffff81ec7264
[  547.080969] R10: ffffc90002f0bb28 R11: ffff880322f518c0 R12: ffff880200200000
[  547.082389] R13: ffff88033ff00000 R14: ffff880200001000 R15: ffff880200000000
[  547.083816] FS:  00007fc08d585380(0000) GS:ffff880336040000(0000)
knlGS:0000000000000000
[  547.085777] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  547.087013] CR2: ffff880001000000 CR3: 000000019fe1f000 CR4: 00000000000406e0
[  547.091667] Call Trace:
[  547.092466]  ? pte_clear.constprop.18+0x26/0x2b
[  547.093563]  remove_pagetable+0x4af/0x783
[  547.094582]  arch_remove_memory+0xa2/0xc0
[  547.095598]  devm_memremap_pages_release+0xde/0x330
[  547.096726]  release_nodes+0x16d/0x2b0
[  547.097702]  devres_release_all+0x3c/0x50
[  547.098726]  device_release_driver_internal+0x16d/0x210
[  547.099900]  device_release_driver+0x12/0x20
[  547.100949]  unbind_store+0x10f/0x160
[

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
