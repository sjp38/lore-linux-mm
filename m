Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC4BD6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 21:31:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e11so1266373pgv.15
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 18:31:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z188si2173000pfz.336.2018.04.18.18.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 18:31:36 -0700 (PDT)
Date: Thu, 19 Apr 2018 09:31:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: c9e97a1997 BUG: kernel reboot-without-warning in early-boot stage,
 last printk: early console in setup code
Message-ID: <20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="fl6aawq5ck6ju622"
Content-Disposition: inline
In-Reply-To: <20180418233825.GA33106@big-sky.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, Dennis Zhou <dennisszhou@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josef Bacik <jbacik@fb.com>


--fl6aawq5ck6ju622
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 18, 2018 at 06:38:25PM -0500, Dennis Zhou wrote:
>Hi,
>
>On Wed, Apr 18, 2018 at 09:55:53PM +0800, Fengguang Wu wrote:
>>
>> Hello,
>>
>> FYI here is a slightly different boot error in mainline kernel 4.17.0-rc1.
>> It also dates back to v4.16 .
>>
>> It occurs in 4 out of 4 boots.
>>
>> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 128873
>> [    0.000000] Kernel command line: root=/dev/ram0 hung_task_panic=1 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 net.ifnames=0 printk.devkmsg=on panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 drbd.minor_count=8 systemd.log_level=err ignore_loglevel console=tty0 earlyprintk=ttyS0,115200 console=ttyS0,115200 vga=normal rw link=/kbuild-tests/run-queue/kvm/x86_64-randconfig-a0-04172313/linux-devel:devel-hourly-2018041714:60cc43fc888428bb2f18f08997432d426a243338/.vmlinuz-60cc43fc888428bb2f18f08997432d426a243338-20180418000325-19:yocto-lkp-nhm-dp2-4 branch=linux-devel/devel-hourly-2018041714 BOOT_IMAGE=/pkg/linux/x86_64-randconfig-a0-04172313/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1 drbd.minor_count=8 rcuperf.shutdown=0
>> [    0.000000] sysrq: sysrq always enabled.
>> [    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
>> [    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
>> PANIC: early exception 0x0d IP 10:ffffffffa892f15f error 0 cr2 0xffff88001fbff000
>> [    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G                T 4.17.0-rc1 #238
>> [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>> [    0.000000] RIP: 0010:per_cpu_ptr_to_phys+0x16a/0x298:
>> 						__section_mem_map_addr at include/linux/mmzone.h:1188
>> 						 (inlined by) per_cpu_ptr_to_phys at mm/percpu.c:1849
>> [    0.000000] RSP: 0000:ffffffffab407e50 EFLAGS: 00010046 ORIG_RAX: 0000000000000000
>> [    0.000000] RAX: dffffc0000000000 RBX: ffff88001f17c340 RCX: 000000000000000f
>> [    0.000000] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffffacfbf580
>> [    0.000000] RBP: ffffffffab40d000 R08: fffffbfff57c4eca R09: 0000000000000000
>> [    0.000000] R10: ffff880015421000 R11: fffffbfff57c4ec9 R12: 0000000000000000
>> [    0.000000] R13: ffff88001fb03ff8 R14: ffff88001fc051c0 R15: 0000000000000000
>> [    0.000000] FS:  0000000000000000(0000) GS:ffffffffab4c5000(0000) knlGS:0000000000000000
>> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [    0.000000] CR2: ffff88001fbff000 CR3: 000000001a06c000 CR4: 00000000000006b0
>> [    0.000000] Call Trace:
>> [    0.000000]  setup_cpu_entry_areas+0x7b/0x27b:
>> 						setup_cpu_entry_area at arch/x86/mm/cpu_entry_area.c:104
>> 						 (inlined by) setup_cpu_entry_areas at arch/x86/mm/cpu_entry_area.c:177
>> [    0.000000]  trap_init+0xb/0x13d:
>> 						trap_init at arch/x86/kernel/traps.c:949
>> [    0.000000]  start_kernel+0x2a5/0x91d:
>> 						mm_init at init/main.c:519
>> 						 (inlined by) start_kernel at init/main.c:589
>> [    0.000000]  ? thread_stack_cache_init+0x6/0x6
>> [    0.000000]  ? memcpy_orig+0x16/0x110:
>> 						memcpy_orig at arch/x86/lib/memcpy_64.S:77
>> [    0.000000]  ? x86_family+0x5/0x1d:
>> 						x86_family at arch/x86/lib/cpu.c:8
>> [    0.000000]  ? load_ucode_bsp+0x42/0x13e:
>> 						load_ucode_bsp at arch/x86/kernel/cpu/microcode/core.c:183
>> [    0.000000]  secondary_startup_64+0xa5/0xb0:
>> 						secondary_startup_64 at arch/x86/kernel/head_64.S:242
>> [    0.000000] Code: 78 06 00 49 8b 45 00 48 85 c0 74 a5 49 c1 ec 28 41 81 e4 e0 0f 00 00 49 01 c4 4c 89 e2 48 b8 00 00 00 00 00 fc ff df 48 c1 ea 03 <80> 3c 02 00 74 08 4c 89 e7 e8 63 78 06 00 49 8b 04 24 81 e5 ff
>> BUG: kernel hang in boot stage
>>
>
>I spent some time bisecting this one and it seemse to be an intermittent
>issue starting with this commit for me:
>c9e97a1997, mm: initialize pages on demand during boot. The prior
>commit, 3a2d7fa8a3, did not run into this issue after 10+ boots.

Dennis, thanks for bisecting it down!

Pavel, here is an early boot error bisected to c9e97a1997 ("mm:
initialize pages on demand during boot"). Reproduce script attached.

3a2d7fa8a3  mm: disable interrupts while initializing deferred pages
c9e97a1997  mm: initialize pages on demand during boot
48023102b7  Merge branch 'overlayfs-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/vfs
238879f45b  Add linux-next specific files for 20180413
+-------------------------------------------------------+------------+------------+------------+---------------+
|                                                       | 3a2d7fa8a3 | c9e97a1997 | 48023102b7 | next-20180413 |
+-------------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                        | 51         | 9          | 10         | 3             |
| boot_failures                                         | 1          | 12         | 11         | 9             |
| Mem-Info                                              | 1          |            |            |               |
| BUG:kernel_reboot-without-warning_in_early-boot_stage | 0          | 12         | 11         | 9             |
+-------------------------------------------------------+------------+------------+------------+---------------+

early console in setup code
BUG: kernel reboot-without-warning in early-boot stage, last printk: early console in setup code
Linux version 4.16.0-07313-gc9e97a1 #2
Command line: root=/dev/ram0 hung_task_panic=1 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 net.ifnames=0 printk.devkmsg=on panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 drbd.minor_count=8 systemd.log_level=err ignore_loglevel console=tty0 earlyprintk=ttyS0,115200 console=ttyS0,115200 vga=normal rw link=/kbuild-tests/run-queue/yocto-ivb41/x86_64-randconfig-r0-04141244/linux-devel:devel-spot-201804141202:c9e97a1997fbf3a1d18d4065c2ca381f0704d7e5:bisect-linux-20/.vmlinuz-c9e97a1997fbf3a1d18d4065c2ca381f0704d7e5-20180414175501-14:yocto-ivb41-130 branch=linux-devel/devel-spot-201804141202 BOOT_IMAGE=/pkg/linux/x86_64-randconfig-r0-04141244/gcc-6/c9e97a1997fbf3a1d18d4065c2ca381f0704d7e5/vmlinuz-4.16.0-07313-gc9e97a1 drbd.minor_count=8 rcuperf.shutdown=0


                                                           # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start f6604fa7518c1cda05b95590a7965fd7ab502d16 0adb32858b0bddf4ada5f364a84ed60b196dbcda --
git bisect  bad 036ea404fd8d46c7b2b6290f820212df3be70553  # 13:45  B      1     5    0   0  Merge 'linux-review/Daniel-Mack/wcn36xx-pass-correct-BSS-index-when-deleting-BSS-keys/20180413-220635' into devel-spot-201804141202
git bisect  bad 0f85c8e00aecc556114d75a182a26bfe1ccadef0  # 14:00  B      0     8   22   0  Merge 'nfsd/nfsd-next' into devel-spot-201804141202
git bisect  bad 7342865df7cb1e1f2120493de329665744fa8946  # 14:11  B      0    10   24   0  Merge 'linux-review/Hern-n-Gonzalez/Move-ad7746-driver-out-of-staging/20180414-090557' into devel-spot-201804141202
git bisect good 895a25a4c71353fa48cf389d8003f5b30ecc30cc  # 14:22  G     17     0    1   1  Merge 'thermal/thermal-soc-v2' into devel-spot-201804141202
git bisect  bad d5111e404f5518298cf50ba910ac3a3362572d0d  # 14:35  B      2     7    1   3  Merge 'linux-review/Hans-de-Goede/ACPI-LPSS-Only-call-pwm_add_table-for-Bay-Trail-PWM-if-PMIC-HRV-is-2/20180414-092906' into devel-spot-201804141202
git bisect  bad 1fb7bf52382687618e345cc587abdf301c3d485a  # 14:59  B      0     3   17   0  Merge 'linux-review/Christian-Brauner/statfs-handle-mount-propagation/20180414-104639' into devel-spot-201804141202
git bisect good f9ca6a561d40115696a54f16085c4edb17effc74  # 15:19  G     17     0    0   0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect good b240b419db5d624ce7a5a397d6f62a1a686009ec  # 15:30  G     17     0    2   2  Merge tag 'armsoc-dt' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect  bad 49a695ba723224875df50e327bd7b0b65dd9a56b  # 15:41  B      0     3   17   0  Merge tag 'powerpc-4.17-1' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect  bad 28da7be5ebc096ada5e6bc526c623bdd8c47800a  # 15:50  B      0     6   20   0  Merge tag 'mailbox-v4.17' of git://git.linaro.org/landing-teams/working/fujitsu/integration
git bisect good 38c23685b273cfb4ccf31a199feccce3bdcb5d83  # 16:03  G     17     0    1   1  Merge tag 'armsoc-drivers' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect good 3fd14cdcc05a682b03743683ce3a726898b20555  # 16:18  G     17     0    3   3  Merge tag 'mtd/for-4.17' of git://git.infradead.org/linux-mtd
git bisect  bad e92bb4dd9673945179b1fc738c9817dd91bfb629  # 16:30  B      1    10    0   3  mm: fix races between address_space dereference and free in page_evicatable
git bisect good d5f866550df237861f9d59ca0206434b0dea9701  # 16:46  G     17     0    2   2  slab: make size_index[] array u8
git bisect good 613a5eb5677923fdaecfa582738c7bcf80abe186  # 16:56  G     17     0    1   1  slab, slub: remove size disparity on debug kernel
git bisect  bad ba325585230ed17079fd5b4065c359ebba117bbe  # 17:11  B      0     9   23   0  mm/memory_hotplug: enforce block size aligned range check
git bisect good 310253514bbf179c5f82e20a7a4bbf07abc7f5ad  # 17:22  G     17     0    1   1  mm/migrate: rename migration reason MR_CMA to MR_CONTIG_RANGE
git bisect good 3a2d7fa8a3d5ae740bd0c21d933acc6220857ed0  # 17:35  G     17     0    3   3  mm: disable interrupts while initializing deferred pages
git bisect  bad f0849ac0b8e072073ec5fcc7fadd05a77434364e  # 17:44  B      0     9   23   0  mm: thp: fix potential clearing to referenced flag in page_idle_clear_pte_refs_one()
git bisect  bad c9e97a1997fbf3a1d18d4065c2ca381f0704d7e5  # 17:55  B      0     1   15   0  mm: initialize pages on demand during boot
# first bad commit: [c9e97a1997fbf3a1d18d4065c2ca381f0704d7e5] mm: initialize pages on demand during boot
git bisect good 3a2d7fa8a3d5ae740bd0c21d933acc6220857ed0  # 18:00  G     51     0    2   5  mm: disable interrupts while initializing deferred pages
# extra tests with debug options
git bisect  bad c9e97a1997fbf3a1d18d4065c2ca381f0704d7e5  # 18:09  B      2     5    0   0  mm: initialize pages on demand during boot
# extra tests on HEAD of linux-devel/devel-spot-201804141202
git bisect  bad f6604fa7518c1cda05b95590a7965fd7ab502d16  # 18:09  B      3    10    0   0  0day head guard for 'devel-spot-201804141202'
# extra tests on tree/branch linus/master
git bisect  bad 48023102b7078a6674516b1fe0d639669336049d  # 18:21  B      1     9    1   2  Merge branch 'overlayfs-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/vfs
# extra tests with first bad commit reverted
git bisect good 4fed2454050629cde24d5b66649a136d07c89f1b  # 18:41  G     17     0    2   2  Revert "mm: initialize pages on demand during boot"
# extra tests on tree/branch linux-next/master
git bisect  bad 238879f45b80794d457ca553ff26986a833f1d2c  # 19:08  B      2     9    1   1  Add linux-next specific files for 20180413

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--fl6aawq5ck6ju622
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-ivb41-130:20180414175602:x86_64-randconfig-r0-04141244:4.16.0-07313-gc9e97a1:2.gz"
Content-Transfer-Encoding: base64

H4sICCnh0VoAA2RtZXNnLXlvY3RvLWl2YjQxLTEzMDoyMDE4MDQxNDE3NTYwMjp4ODZfNjQt
cmFuZGNvbmZpZy1yMC0wNDE0MTI0NDo0LjE2LjAtMDczMTMtZ2M5ZTk3YTE6MgDFVU2P2zYQ
PYu/gkhz6IdpkbJs7xoQ0KYINgVa5ND2FBQCLY61hClSS1J2nKL/vSPLG3tjL7L1pReReuSb
D3I4D6Q3O1o5G5wBqi0NELsWAQXkzZ93C7oGb8FQD0vnItvqeO86HKW32tY9AXoLrF+lIcoa
RtTIEGnrtY3rxbD8jINfte0+0g34oJ2l+VjMxpzx+URMWF3dwu1cCvpNRn52TSOtokZbWFCP
nopUwSb1suH0vrN1GWVYl620uioEVbDsaipb/BmmYRf8QynNVu5CCVYuDSjqq65VMsIYJ2XV
diUGb0wZdQOYYCE4pxbiWK+sbCAU/JDQGB2vm1AXGPDgkAka3CoaV6279nMQttHlVsbqXrm6
2IPUuTYcpsZJVWL4Sod1kaFp17TxM8Cp8ks1brR1vqxcZ2Nx0ycRoVFj4+rSwAZMAd5TXeMe
KBHcY4/nXMS448PRD2H3wO98JMQ0w8ROdh3BTS0LNNZIvOxtf9brIl0vO20UixBiSH1n2UMH
HaQ7V0XH9GaZi/Tjzayc5czjBaHZla6ZxzvMRS6yPE9Nf8NM9bEt9l8WWiyjjIubYQ/PFoeb
vr2dr5ariRRK3Kicz6ZVVsnJjVjxOc/VHKaLpQ5QRTbYzHg63jT9/BN7qYWj3/l0ygUT+eIk
FSYmnC4xkeq+OIk7fSZu+ub9+z/KX3776e5tkbbresj1K+dRVxWbpS+NN31M8PLTuFAlfVWD
X43DfReV29qCE/LWyDZgxfelvaACkQdoOqabmlYe8AlQtqIPldtmtC8/9sWRME6z6ezuP5LE
NaTsGtLkGlJ+DWl6DWk2kMh60xTfkmRPHt4yG0qFJGzoSQy34A/2IvpOhi0YM/ohNND2X9ni
yqEVvx5GBLTV0SuauqAb7LzDuzy8zuj71d3BybiqPyGhoVOR4RialgocsbR1BRSw2/ERtjv8
L3DguDT80S6AH2n1iO7bvPMKfGGrfpdjgzLg/LHdUT2bcA5heYIxWcW+x+8bMuI+VnQpAxTY
NqXpK7OPxusN0JXGznS5EEcNKC33iyO9Kjbao9EXEMW1xOxa4uRaYn4tcXotcfYcEW9eoxiE
qAY7OrRG7qh1tr+sxmF5OU9tZwz5jhDZtmBVX+JPBZokZwpNkkMZHDWaJJdEGm19VaVJ8kSm
SXKm0wgdhBq9nCk18s+kmiRHrSbJU7HuHTxVa0znrBHv8znXa5J8IdgkOVVskjwn2U/2naBH
0caz2pLk5fJFkv9bvy6f2wUFw+p69fpv7I4ffvzrn1eUDaVGERtmH75HmPwL6UzCsMoKAAA=

--fl6aawq5ck6ju622
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-ivb41-114:20180414173506:x86_64-randconfig-r0-04141244:4.16.0-07312-g3a2d7fa:2.gz"
Content-Transfer-Encoding: base64

H4sICCfh0VoAA2RtZXNnLXlvY3RvLWl2YjQxLTExNDoyMDE4MDQxNDE3MzUwNjp4ODZfNjQt
cmFuZGNvbmZpZy1yMC0wNDE0MTI0NDo0LjE2LjAtMDczMTItZzNhMmQ3ZmE6MgDsXFtzo8iS
ft9fkXHmYexdI1OAAHFCJ1a21d0Kty9juXtmj6NDgaCQOUag4SLbE/3jN7PQBQmwhEc9T0NH
GwlVfpWVlZmVWVQVt+PgFZwoTKKAgx9CwtNshg9c/l8PgJfcksX1DT77YfYCcx4nfhSC1mJ6
S5ZkQ2WKNFFtxTU8G46expkfuP8bPM2k52Qq8ZlyDEcTx1nR6S2tJYMiM4PJig5HF3zs24vH
Uuf4GH5SYGin0JvFwDRghqUySzbgfHhPVOY2V+fRdGqHLgR+yC2Ioyjtnrp8fhrbUxkes3Ay
Su3kaTSzQ9/pMnD5OJuAPcMv+cfkNYl/H9nBs/2ajHhojwPuQuxkM9dOeQs/jJxZNkpSOwhG
qT/lUZZ2mSxDyNOW74X2lCddGWaxH6ZPLaz4aZpMutjOvEKJQRJ5aRA5T9lsxUQ49UfPduo8
utGkKx5CFM2Sxccgst0Rsu/6yVNXQehoOktXD2Rw47HbmvphFI+cKAvTrkmNSPnUbQXRZBTw
OQ+6PI7Bn2AZPsKH4tmyl7tp+ioDp47P2aYHQ/mEsbaCDSuUWj+cT+wugk3tAOJnkvVT9zTv
ainlSZqcxlko/Z7xjJ++Rk4aSf58rLHTF1Mf6ZoUYwchrOdPpBhVRmMaUzTtNCCFklzizRJ/
pWQWpRL1cl5GVqyFYpm26rZtbmjy2JUdhbkdVbUdR1cU2Wwb3JWtsZ9wJ5VyTEU+bc2n9PkP
aV+Edb2GqrK2pFuFlkgMdXGM7XAeuwW2T2vYhrObm/vR4Kr3sd89nT1N8qbuEAdaiaSf7svu
6bJ91YZYoSSk1Dz2WsljlrrRc9iVt20J+Tv1ZpkFw2w2i+LUDyfw27D3tQ8et9Ms5iC/yDKz
4OcX0wAPFVUUmUWoRRDziY9aGCc/vw9WQdjhsP+ncTTE6X39bR+cFzTrlI8iz0Ov96B8swDa
hn6yfJ74f/Akf6y09VqU/sJp5FRLXhJkxjgha0r5SwqEBX4CpqrA+BVt5gSyhBrwM1KFrh27
P4NHBpa2tivipiJbcDa4GUroC+a+i3XNHl8T30FrvOtdwdSeWdtEonhO+TDlUyGZzUvaeNTx
xp73DXmitjQC63hOGcwjMBQCj+fcbQTnlXnz3g/HtpvKPM9l3nuaSpRKCezdvHncI8EV4ejR
u+FytA24ndyJEdDKxwnSxdVIgeZA1lVSxevf4Kj/wp0M9fzCFwI8pgEqRdeLg7sFNt7nJaF+
ekXHM/eTKMYqqSx3Lbj8elWt6fnQu93AZcMKfQfd7r9q25ZjxXwazYtY9hprIZxqPcjJAztJ
RzMvhC5SCwVAY3sZ2bHzuHqsLTmschC3vXsLQxTy9Vlsk4zgQZYMdCm/ngH8eg/w5VzC/1D6
vo02dDBKQg8Bw6tbitNqxKNik/YnLdhubrP7kxbs1Ksk9XDYcQXd1a2Uiv7CsK4AoNv6EgA/
Yk+gH5uhb6NSsLiOZmk8t4PjEjrAdOZYgJSGLHn62CgFhmd2wgFri+JXSDF6mkUUIlajQ6eD
NLmTVjQcA0pgd5fYcS+ywRUDH5zA4rPQoNuP972zz/03aMwCjbknTadA09mTxi7Q2G/R4LBx
MRhertwIQ/ffyTsU1dyp7NDe+e0ARzuRMOT96Txy5ynJphTc+x6OR0LB3dwxlCwyp78bXtxu
evwPutmRgT5hjHU0x344uzn/NITjWoD7olv+8KHP2ud9AaDKBMAWAHD22+15XnxRVjxZfaup
4APetivQlJ4gM7RSBXnxJhVclFuAYQuJgKn9XqmCi/e0YFiqQM5lrJX8VE7Tux2cl8TKcrEa
ZompvHgTpj7d9sv91tHzfitXkBdvUsHniAIiwZjtujguUAjmcS4KbZMsfI0onUbgra6255Ko
jpY+YglQqvRpPpUcSuwswAwR0O6mSQyyRcMEcXlCSeHURu9DP4uSb0B8EcEgIiSgjdu65mKj
Ka1dfCnxXyDN48gEjdGFPJTFG+bOpqyqGuswcF6dgCfbCII6ibLYwby5ADfFdNkiyW1dYuTL
oehn5riawjXX88Yn4iffDfgoxN9ME/tVbneQAxXCUr3/jtALYwo0QZyyV7+46mGEjFdF1ErB
XFUoV0a5zlNVAI6p8+v271fRXLivP4gTDL/jVAxx3HYeIayY+Mhd3mIooQIL9sv1ih/xUWXQ
vcU+Xh1ezf4bMPUB7TbMIPRTos4ndASk/GekehMuQdIotYOZTR0ITJU7SmnsXfYjSdgCRdZM
EOVRV1FJSdjIB5rgDjq2oKqL8TaL56zkJCfwefDhBsY0yWKprDT8LQBhnKWQhfbc9gNSCQs6
C4BqF3N7Jd37Ux7D4AZuMQMlQ9DlUvPf4Y8WJFR6dH01gCPbmfloUw9kiBipe4H4jyFMio/Y
t5I7GtwQ7YOMoSXNbiEpuaTlrBvDVLTIhMgV8PePwwHIkqJWszO4vh8N785HN1/v4GicISkK
LBn58e/4aRJEYzsQX5Qlf2WuQpRRiuE/MYMRGN3S2J/QXQDifXD3i7gLSQ0uYPXxGgcApTFn
7SJnbXj0J48gsprdzLEFc+oWc+0a5tqNmesUmeschLlODXOdxsyxjU7Fb4dgz65hz27OHttg
jx2EvXENe+Ma9u5+kXMnNn4FzCzj2Hd5KU3eW+tZTe0lh7U3olqDWLLwvRG1GkStVkLtA0pI
r6m9lKHtjWjUIBrvRjRrEGvGBaTp7JbQqizbQ+HWhdkBZe/UtMt5N6Jbg1ga2fdG5DWIpSBu
b0SvBtHbRsxDdhI9HF31Lu6PVxMlzsaEjx/mE7v4+Y3MyHcpmDBlU7cVjP3HdsJFFM7dynhh
kb/ko/52BkOjOxwtR/mSc7z8erWICu3kNXTg9oPgXGQxVXlGknI7oHdfG5mOzm23IpvcmJ1U
8qcUX9Lk5lhMSayiLVHr7fkAXD73nXLMdRZF+fsFO7bnfpxmduD/gY1+4nHIA0DRVswhbqQ1
Mff8kLvSf3zP8ylc3U5utpKa5eOtjAaTKKbosqbpitGmairSGnqpE00t8OwkxS73U3AxKt0u
NUMBSnaAPFqQyBDL4KqKoZuQ5TfxU5f9t/j2FjEGejg0liSW+UEKTATEgZ+kGAdPo7Ef+Okr
TOIom5E4o7AFcE8xPCyDeMU026V44TIXs/P3C9a/X7D+/YL1IC9YhS1Y+Q1yk4CFSZSG6Qse
pjR5ZDuPHB7t5HEx6UqPhS/T221Vh6ModnlsAYY1bUVDQ85fL1ZExJi8S/Vouf9ZomHYpegK
07QatCsxGWKBZrR1Vb88bSuqwZTLgm8/YrKimZdLZ00LShDTUDuXqOBo+pgXKKqMBeIo/2aY
+IUc5wn6I4XAxgn6L82UDf1yNQVwAvIlOFNbWj5Ys8Zy1q7vRjiOD5E3ta2cQBhTuoAN1Eya
kePCf6LncSF/zPRtgOVimAdhoN+WHbRdDNP7J/R2Mx66PHReYY6jE7YkiumFz+wVQ4vHFI6c
Y0Dz1uEOK/xkY9sGodOiv5MIrqIgtONt3FarBVe930afb84vL/q3o+GXs/PPveGwj00C863S
Iyx+/8mC1aW9WZzAL/v/N1wRmDjOVRGI6j/1hp9Gw8G/+0V8uVOS3nYN/ev7u0F/UcnmsFZD
cf6pN7heciWUvJIpKlXFVGUdy9m7ZXAcbHUexWhoQ6bB4OmsRIxWDTTIYSQUZ066BPNwLBQO
3kJjWRreNrFUc22X+y4USkSUGFAKn5/5Kbf2xXvPVWrorus7JBhCwPdnIb/vcX6bZil/wd+e
Ewz6vkMsbmXsv5jvntTDHrZdMavtoVvi7vfFDSB6wsZsPty87ayiJ53hvx9WRQ5/jv9+aBUI
T39/RBXrFlzgvx/SirwFF/j3L6ji/EdVUbjcKKOxMwvzVzE56P633VXQ+OqLNAoeeeAeooq/
yqxj7mRx4s85frJdaSGhwrXmtPhwt/QrgOEn5TDYMPVfKN0h4OcY/XkV3ysdehd2Dlsnk2bY
BW4J65T+5HxD7+ys9+f4rgSnr1XYjeRdFMTB+f7B+v1ox65EoaiEOe3/UFAqJbbHpd4pU6qd
TCUMJcEHgKnnRmEH4aYRDAKtSaH7L3hcYDZrVD1MQ24W8lkAiXa9h5uFfP48TDU3jRtVzU0T
mE1GslB8PIOfGLZJ3R9mk5F3w7zBjdpAxG9w0wSmnhuFHUQ2jWDe4EZt0OFvcNMEpp4btYkx
1HPTCOYNbpoYwxvcHMKmlMPYVEOYN7g5hE01hKnn5iA21RDmDW4OYVMNYeq5OYhNNYR5g5tD
2FRDmHWAI2aAJD9cLJBpZgzrAOdPwtRy08QY3uCmGUwdN42MoZ6bhjC13DQxhje4aQZTx00j
Y6jnpiFMLTfNjKGWm3falMjtFun0whj2q78pYW2NqvLOGncR1tVISv2uGncS1taIivu+GncR
1tVIyvmuGncS1taovLONbxL+yEz+O/xK+11On20/zWfv9+Zg96zd8zO9UAeyRdpZWD1rtwMG
MRZ7EROaL/HDibWPbS8uzw/95JHeTqxx3pw83MFNsHjXMfWTKb2nf2ejAPoX/d7F50vUpNAN
qFGNZzSb1ktvQMQcYYi9vJiq5e6Bta75m5lx/i4G6J0xfF900V/PzlI3NnVr7/np4oUt2YJp
MJO+vMbFyfp3wix7fD+Ydwm4QsasrUKUib0ciq4In+LYCU8gr/cE7AT4y0zspmyVZXsIFm4u
+mdfPlqQ8MCj+mFmJ0n5TXi+iu08imkGfe6LBedisYbK1O2yG8uzHmc8/fNrsoziaqxFNYSc
18XnvLA5fZN51fwmFvhZMHz20QvROrrkdTrlaew7MDi9gSnteBBr5Qp0pqGsVgVA/yWl5YHY
5PPbLz+tV3xgDKOo36B/3Tv7PLj+CIMbKV9LePdLgVvFbLe/5cvFBjejigIqjqGomrSeCmSg
l68yhFFKdhaKri8U7WhsYx/AEGUQowqRo80XkxzJEgPpXyhV7tGdFjwyuMJGWjL0xN5d/HCB
XW0VdlmxNmtru5GVHFmVl8jybmRdbau7kdVtntXdyEZ7H2RtG1nbjWwa+yC3t5HbOTKrR1Zy
3d2FrG8j6zt53hPZ2EY2DoVsbiObh0LubCN3DiVnJpdMRT4YdtkM2cGwlRK2cihps5Ipst22
uC92yRjZbmvcF7tkjqy9L3bR+TK9xvtWlTUalDUblO3sX1apGy2qyrIGZZUGZdW3y7Za94Or
/p0Fc/w5irtiCCF61hUArKuIrwot9sXvdN/GSBPHwv7Lz5bAeKmjttoy+phPf9DyXocnSRRv
02yEIgggiRW7e2+AVXRX1TrcVLTOVmiiabLRaSumiZFCMTZZ1HtuB/44zo/OcXlg02q0aAZH
yZNPa/rpQA1Om3jndpDxVgvaqmm0aA90NImuBrdDOApm/+lSG7GJckldZ747QnYsxPbsLEiX
SzunGGVMsyl+lUviu6IVrG8sDqW1nKu1oeyEVgoq2ytDi1DiRKDD4E2pdzC0giQ/9CcRXvi8
D2M7fCrJ9jOtvs8XY/v3n8/WNWqXZ7RxQbkSN41uRVq2Sevuoj0B9nEDgsk6BgXIp0U7TRBC
hMO3S92Do0928syD4BiOPHvqk57JL/qJCDAD+qw6J4AR6mwmklj5RStIQmkryN+QYn0E/aqA
BV+zIORxvmf1inrWDmDC8RGaXW94hQFvmh94sUZp61rnG9zyWGxHCR0OfYqNsYFZuBAunSyk
C2kLvkAn9wG3V1/AjdFHxidi4uXZRi5EXJ1g3Bu8rpcuK6ahYgxKG1iXy+8tUWNeHJyY09Eu
ebCM7iFPZQCD70eQ1ls9lY6pqZUwxUe0LBPbgbjBa/nQCdRyCtPvh4vFbXT2Ryr27m6v51Xl
ThsTgdnEJZv0UxmOOsf5StGJ4BfVIkntfMFo+mhRZtZeqCvqi5eukZS2JtOxOvN0OvNQsOvl
VoXqtLa+7X1+5P4UVccw+xt4YpFmlTGiYqxsUTnJzz/ZNkbV0CgPwTQqC2iNs+Rm0ynqMGoH
7c7BjInHhSoxQ8KE4bp/b8HdKvMSBwVFThRAbgHFpdfawiXPMmrU8kyDCe1hC9F6AttF9gql
NbOzzDtp85bY10U7iSryPA1zKITGX5enLGxuzxK0TOxFok1XYDtksityTCMYpmifsgknp7Cu
AJQWCvrKPxO7aMTZMWKBubReYS5v7SXXSbOxlfHrLHWtvG9n2ej3gItzFyn9pPx1XR5zTXN1
QIdLB3+NboaDIwxcMuzBC7Ft6rhQ3NDkiuJrL1SiUDS5ikJtyTAant9SdstDSugLuqCrjCTy
RjW9CRrOhPSkXCNmqVXE4nBJ6QI9pPTVd3lUoOh09BWPLN9v17v6nGtxgsOC6C8vC1CjbOf3
zKe+ERuWItst6IHRkWV9tVUSfXSMnZVW+AOjY5Ku5wWPVsPOUIahCsP2mjNTlpUVYq5ai/14
pEw+VRFns1U0uqbDTjY3NPIxQh8zjn0XFenZD93oOQEvjqYC+5/ge4ChE7bSjl/p3DgO/5g5
fjeMnDj5h2hrzIlJsNEaCvWo6lpyy1PqFPh420/oLKd8xlCm8xxA/rCkwoGsoxqrAw/Qpu4i
jN7OcuYe8AFCHrnR1Ka5CPI1D/n2Scnz1qcSoOIqNGdApxjA7fWt3JNVS5Yt6uxzC26G6+H8
YcgnUxpLvq2JO4qh1hAvx4yjXn90fXM/+nDz5fri+J+LAUCsnx/ernYFMob+lglZbwgZm5xz
jbBrg2NYvEMhlOOPCj/nu94EAUZmwmXDgx/B4iANOjzD8YxFx61bwRT0xo3A3HynJPn9Epiq
GcZ+YFVnnY2rQTWD/Mv+oBv7OcdeNagudzr7ga4VZ01tsI4qqFeUMqqyBQ+0NdZiCulmvo1X
xjHUFudZoGMtuE2myKxtbmGwNYaRZwxlDFbEUHSjjMHWGKwKg9Gs5wpDY+aiz7Yw0DkKYVrL
nncUIVO8FUTRZiZrV5EH6FudVxhc9IHc3dMSkK0BZeaJnmeeUQBUmSw3AtTWgKqnF5A0Yd0N
kMwCa8b/s/e0y23jSP73U+DqtmqcWUsiQAAkVZutTexk1jux47KcmWxtpVSURMVaS6JOlOzk
nv66GyQB8UO2J5qdub1LMbJEoBtAo9FoNBoNU7XArZoiFfcZCMdO1QK3aqHf0HF+2XEwkpo6
P3QZCFgh1E048ioUBWszvLQ/RX0uBu2SDhddnZ9/lCRALUYMhvQEjIHBGHhNGAcXry1CXyte
QSiIx2GIyD5IMt7QTH9nnARS8GozCYfDTmbcTyd23E9yzRRmT4dZI4+LKq+7uEKLCwSHI0M8
N9aQ4IESVcZy0PieiyaxaJJ6lYTwVG38+I4o8bykgUTCJZEQoRKNOOokSkZjW5/JTgQ9gYG4
qr3lorHjLA8JOobxZsE1CP8qT/ttVAltLUYNVNEKZFcFlzSME08lUqWJcfgOVQIZqSpVZIUq
RXOkaU7gVCFU3Ks2R1aoYXmFW17ZiUuFwqzGcg4a4VLFmbYoRuaUaTmabXZp48Nw8KrtUs+j
Daw1SCms42igTWhoM3KqIBsapVppIyxtxA5ttAyDai+rVtpIS5ugjTaBlkFUwaifSZtQ+bpK
G91Cm7GhjduoKPRr85dupY1vaeO7tJFChrqxJY20CS1tRi20kSCLZVW6B8+jjZRA3uqgCJpp
w42I4I6IkOoR8F3aSEsbuUMbXNI0tqSRNmNLm2kbbSIYU9WKhc+jDZo0RJWbwxbaGHnDHXmj
+CPgu7RRljbKpY3yQepV+SZsow238oa3yRsltV9TVKNn0kbJUFRrFbXQxsgb7sgbtAl6Yg/4
Lm20pY3eoU0YabUHTYU2Vt7wNnkDKpiqzXnx82ij4ZesdnzcQhsjb7jTKC0aRHncSpvA0iZw
aaMlSL09tajQxsob3iZvtNI6rGpJI6vZCBWPGmgTujquhq6sadyjNs1mGtrGwVenKqHgUjSs
9tIlu/xw8SoPGWmzKy+IXOPCeWkleTdb3rF/vLv88dUndoxOEEyx77nHuN2R06FWkfcI+Os9
4KGnxSPgpxYcoL/fAY+UDh8BP2sHh4Hm+4+ADwrw7yMH0K+vtkgpvv8cx+tRvwjXjh5BI1xl
//TDqzymksUhfVkdoDs4LAwGikSHtkmCQTuyl7P0j8AIJ+nDsvxOtuuXSyfAkY4UdM6+AnLL
CzqIrdM5W6VZNnMCr+sIugdaWWTftd5pmPtxvZPfQYMWQjaOV3TpAxnapjHa0e/RJmthkHBQ
pVU2HKdrSCboq6sBhVi4T9ZdxhssxjiQvciFGxSbHgSjun5Xs44T5QMEherAR8Cu00k6n6bs
h1m6wE5hf/qcf/sLRajpzjZ/tuXAKg5afHVzZXYDCptYY52EUrs2QzKEoqERd7MrJsbA833B
8+w4NmkrboibIHSrRWFt1nI3aEXgSY0kK4LnU4gVumNitJ1Ok/VTQscHngq4fByHc59CeY+C
xRFyP6pskhgfLVgQQ8WdBBu72EJHIgJm/+ntoI/XFNzBKjvdwOCY4N+h7oK2V+bNHcZMXkzf
s22puMh3Smgj0Iuq+yQFtreDziliwSCwLhsX6avlCkTA8sp0Iu4SNeRguSi9mmNAreUEvsRf
DYQZqCfs/CwjA+kI472ZuxdqdSkw8Sdh8j3/UUziSZim/HFMaJaZLGImPu3J8YSygsb2c07D
P8ckn4RJNmISitYtOSb1JEzK4w2YJDkdFpj0N2BCo0CFk/r5pQtBNaJeADOP51fGE0UYXi2q
m46NW46VDUeKkeXRLv7SKURGstGcXBh85RPM5oHQnmjSKEos6gn28kCACGm0lxdY9DMM5YEA
HXsvtuAZFvJARCFajx/bHi33w4N8h/ohXd9RCDg0pkM/d9bpaGa20rNkbq5gwRlhjN7BxjUY
98jL7f7ZYgVcZLGCVgFcvRmvhhgrMFkOcfLBKNFDEn5P2SsWSlQDjgW+HyGxbk6vWJIh/CxD
qd2EjkRogc8/yT1VqvigmsLgg+Y+AZHOEXk1TMAUmjD12V9LLFm5IYzbSm6VjYTHMvGbgyeU
OHF/OLt6lEjQKFgCq6p3S+BHpMkCis47DFPxS/FgxfQTttotAIaq+sSur053ADDO4oR9uDz/
yDL0mt7gnSnLjNSRBW03dy0Knzxgqyi2k9U+IKkiVQcC7tsHpKTfUFkEunw7uJddDJQ6vhvf
xksMMrcHESwcqks52lZ6N1vMjCfWbI3jBTSmHurmhGrqODUEMtBBfVMA5+fz849+vsGKmK5g
vYXRZK5hTMZZYhGEgd+4LUUOiMYf7HzwCmPa43GWzzTeYxrpTi2iqNlmT7vmhQZPDjXZbQxi
B8h1/f5i9+od56aoXUN1oLhCJZz0xtN3A+YVl5XlzmSgMdq8glahH5YgVegwD+ox63gxzbrd
nPKcNuM4aHJv10lS5pnkEdSArUFF/9HmhZUtaK2vfvooGLoRvBl0LlE9MmHX0AuBoRaO3oTF
PVJOQYHG2Wc93nY2wAIwmvudTocN6H6HdEoHKPpsiQfGoFsxSOg0vksoSAz8lOjisxnSWuI+
nr/UHir7ozRLICeCDpepmf9u/xveZLegy8KPMr8P8NsN/HipMIKGKQUyTv8rG05yV5OXHv28
TeeTdDrNfxVgvikF1m/Z5iXvec5PW0rgvi3RSlZEnBxmyRijpZpoquPV1v1eFszdlxjuw9Rm
ORzFa5A86+F4hEjSJby3ZRcvyuqXlIe1hqhQnp2i5xR2OAZ4zd8ODbEplJ4FliLiTwG2vVVB
oHw0ZOwgaCnUXPZRqOMIq4UOKrA/XNHcOTFiIV+uoscBOWTg+rqXfc2mGa29ANJyoA+j0zSl
Unif3UC35egQcbqM51BQ5sCGiof7YfNaQU12ISOajPZBUpjn2zX0HygvO8DSM35de4DzqLS7
YNDWKt2e1WlSyBqCPXC1jpPo+/pNFYDpqMp2z6qA0kJ+UwV0wPex7aMVCAL5pHFjRFGl8DBA
B7pfXjhosE8iPwrVbLds6DhdhW2pb61cGCNBtd5luWWZRjZXShVhuK9UW9F6oaDutVLawpMY
rxQqQ3R224FsqmW9SBUEVcBG+o5H03maTirFwrxcHVxN9awXG0bopfBj8tVYj0dzmNlxbVCz
SHF0aeC1EdBWtVpJWggc/6jhQJMyPAaIzrmQbbEajmYbmJA1LTlJ/X3JAzbaolaa/y7nHgGL
Y3TzHa/HeIL/9Pp0+O7N8PX5zYC9RMdyfPH6DSteOGCR0iUYnm/MD22bE44nxakBdJgTKiri
IDM6qiGDKAjRxzYZlwiFr7BBhHBcq4jNJoUvbLZnFRyi1KMTBUW5Av1AOG5m0vmHaxPtnnye
XQPZuDhwgDd05mcjFJ6NsFikRPW4eiLieWch9FQHeN1L01kIpWCeLm0Foiu4z2XRAcNxuhhR
dPnQD/w6UQqgCOguCqDxk6FAVKE9EhWZ+dC4F1+RZp57frKLn1+d3yCF8XpVNnhz8+HKAgty
Bp2tFjNQWrMMXX3prDmMoeJyJT/qCgvgK7Q9nl9dnLPB4PytsfKjeTr3obc5gehBnvPn0s3d
ZKp7jiOA9tD7bbZcbWG8XIFuv2avYThDFeKM9XKbT+/d5cfB3wc3F7A2wO9XP1+/vsTvBGc+
PYsT1jW83JRwUf4DAN9+shmjSOF85UcaLWm3s/lslZmf7MzU+Q/X+enfPg5xj/2hBI68CN2u
Bska2gQdJpTX41oprzxXIBl5g5o7OGDlsjbHtxzPXL/rSVjughDPbXAUnhsXNnhQ1/viT0N2
jCEhXjJ5Qq7coM9uJzj8KMT+C7x+OWZU7KsSJchZlJW5MQ5RcotSWJT+01GGvkDWvkPhlqx7
W9Hn7Bimvf1nCmCpK2tnChCb1BxNTyvoXvSLT9adbIXchH73oJfOiXA7vIVQSqGcyRbxatbv
05+hia3+5vr6/TXwEIUrB3wDTDs/s5Ba4tS+eIjvUQisfBB1gMJ8OR+el3z5Oo3Xk7N4E8PS
d73GsOeDC9xXAZLgAs1Ggkcf+1t4u4jHt+WBFCwpiHDHKC+J/kwm/T59ocqWiN8al99N6sav
HWH5DGPHW4wRCcNfiLFEE3kC95r+CmtwuuG0b6YvctQu3uVnSbxu1IXe3czgDTSRw7QA0hmU
fLx5I15/BqECr3X59kXXlgKLJjwsggcpMJQJHaZA7v8MPYlXdHwACQXvX15aEOgDqFiCNvL8
nNHx9Qt2df2+h6/YZbJBpivGY6eUUEHXB5HbuQs7l68Kr0TEp8jWnuPbjVrPoyjqUOj68jwT
MBpNImUbJMCjwtC+lVqckschRYdcC9BI8whPTFHZO15tLNncQm2O0Qbh+zBL9X3RAZXgBVOi
ryRm46Lvy35xJTsi87kX7EHWTqpTcyqxvJsHkcmQHJjjJZ7Moj+FVEbG/prU1SGE0ho1ilno
SdwfubyCj0FPYAFmAbkGiWo2WPo/vj47ybdI+hfvP3xC8uBFgifwIRndbnbChUUN9YEhCUN/
lvZNCQxQmIFfB7VwEamfO3CvPnxsg7MFBjAEgM9mYkyzSmGRrAgZmIxDZJ98Pnp1w27QaDan
oy94Clewu+SrGabu/LSCHGiT7lGNelS9ndnJtgAajnrw/WwhFuYTTV3mTIl7FCdH36ONYa8E
h2kH1Zp8OOB6nXceZuuEnYHkBJhlzgSFtbRrIXmEW+4PfDj1JiQ6jl/YRF8G0O4UwKYze1oJ
z6YZqVAe/XAQwlhRT7DTOpXXHCfc/HQEu86PNJNp7/zqXjsZQ9wwyVC8YcIJfkraU7q4ejeg
i8DMq80WzaRk7dztSZjb0aET71XI777KQybnuxkeOy4Omkq8A0T42sn905vrwfn7S1AEOajj
HpdOzhDb4H3jv0PiswesJEaJ8HHQLreLEdAonQLBjAJCOjCerFNdJ3OEFmybuQjp8Z9eyYto
tZcOSKgRZJObUja3Cd4cikDd5n8WEmSz/lTkhiJq6cBS1AfdsnDIBaOjRjSB58hMVswN/0Cq
3X7NZuX1pHT3mAPARagrAGfAN8AxX9kNLAz7zM0cobPETuZ3sOop/+1kFgrPh1ZrzbF4HsB/
brPCAiHcwcvoxBzAGVM9zmv2QHHgAEaKVwGvoFNni9U8wbGEzi1OnUDBquUv6J5PoH3m1kwJ
nPSqjRBNpFeh1lXc8XqEdnKzHHMygyot8n4yPh1OQ2lnqF9mlR4dkMpPm3lugkbjCh6Txwvt
ilOxJyxB35sTujLzhP10DLorqtrXx/h3QJ8FS5ywM5N84Y55UAqRkwkxrKuLeb2GWIga4nn6
mViNEPMaYp+j9CLEYg9iv17jRxBLvySFf1BSKNojIcTyoIh1iJxLiNVBEYceeq4SYn1QxJHv
FaQIDokYhJ9XdF54UMSgohfsFrnsRgf/HT5+Lrtpc+yNEMeHrLEOaCYgxKODIjZqJSEe7xvS
/JmkCGCIFDWeHLLGAY9EIYSSgyL2ZSkrpgdFrDw0fFAYk4PK40ArkbMb5wdFHNDxX0IsDoo4
8nWB+KDyOPS0n3MFP6g8Dnkkc1nBDyqPQ1/4RecdVB6HMuAFjQ8qj0PN0QcH1ZJNSlF98AJa
NN33nTwBWo7oimwMttQXNimgkAF4QbFJ4k6SwgNPkGRCS/V9JylCcy8kmchQfbuwCEMK6kCX
TVOScpICYZJMoLS+tkkRRy84SDKRzvqBk6SwSyDJhCrrh2VS5HnSJJlYY/3ISVIyb1feZm71
OShMGThetJo7iUqbZufhuvrckisSXpAn5kThvpOocXGOiTlZnAUXzMdamsScMFw5iYpbbXTv
P7q81q42IikxskSG7rfDsblm6CKmvRuWGa+lY4mEgiHuwxj0XnT+fKy4D32BG8wnrMNBCcF4
BEFomQrjLOg8HEa6+Lwewmp4hDdHquARWynojDVbKSKERbt0969mn4d38KNqrpFdWAVq1MzL
rMmSqkEXFNUzC3JNp+2BN2dnsFgfmzt17/EkLrp/y87ftsuOACnhFb6XxhfT4pAeLpoR3LkQ
etdUWhIcAxHgnmPhNbNdEjnyuzQL5xm8MdOBCNCh7Ge69AjNCrhyyNecORzFSsaAPWQ1xasv
/VDeWQzBjqdOc5nCKx12JO6C+96j1eQ79QwCOlH7JdS9xaLPTtGYCjA///GjFSnlZtgypQSK
omLoaUkUhAqPHJnrQ4fGuyeez/M9oAfoQCc2SAkVRho11gVGqQJOCx6zyoN+63JaL9mMe+vx
oDvpDTxvOqLQoH26G5n5fdbLRrNlb5FOiJP71Ls7bACs4qO4s8BYCfFIJYSobw0gLl9w2udF
HOoRHFx7Lo6jfAsM41X3yasFKI8GhkFh6t4CH++219/SHgQ1NoDl7jheflfGdOrhxiV6xvRM
9/du081qvv2MRFgmX8jBdJN72QFblI1QHh2NRtQTaEcYPtaOhm0SQBPCeiFHE08WgCjijyAq
vfcNorLdeOs46LcwRoB/l4Y28HtC7aXhmsf3Yass2U5S3DTqs8sUue2WoUEQfddsQwv4knM1
51rbfbzzxZsvZCn+IQ/f9ebLap6ukzWGUsN4RI+YTrlrOvWPTnNfVnLdye2b5QkZ9MxjR7cP
uQg3HZiukiX7juyni1kG3b0Zf7evQdfb5ZKuZU/RqgWENUyyWnSKNxna2JGZHqbQ/xjXDq88
RiIc5ZeK0yDtE63Z+x//4yhDm0xvPhv1jOdm1mu8dblI7UIv7qvil3iNYsQOxPaseK/2Croe
slM7DPfml257vFPgYMDDmyJWGR6MYlwER3WQyOts1mgw/pqPFAx90NtmayMb0A0r3biS4Sko
gv0obkxuxrshY2fxfcL+BmMuY3+awPd//gVrC6wMM2E3XX/ubu/+fJTdLvrel2A6HQkRePkx
HPo5FdNkggZfacQuTNcY6ucTOwOUuOlItm6g75aC9nSL5HxjkOHd2+mCZQn2KBeRQhto4B8V
6gKKaGAG0DTnGYWwLq+/NnjMZk+Zpc9gjiozMaZlNdn3LY6zV5c/YCTJ6w+Xlxh0+dWAXb9/
f9M9+rAErsnY13RLHqTrnIVBj43Z/Wy92ULN8/3JE7NbOU638wmMEByCNM62GU6rUM4iM7wE
lUfTOvpJIa7Ti/eDkq5xDBremBd0jWOuJqNJI11LPco0iX1ONkMoZ5ttyC2fHdMJ0L4IJNAG
v8GAeIGFYwyjpNTxu9/ST0L7WodCReGT++msjLdU5loAqNmMKSqFsUvG6WJB4biQk9MVufG6
bYdcu51apwC0nVo8SWLjKu3UI0exyzZ1FAXRmlA0sFzJUyeMWxI3sp9ozPrbsyJIuWy2AMVy
zR5uZ+PbHM0qxYkYOADUwEV8l+zszYMGh9MVKfQo6DD+fAxCc72g448Ul7R79Heo+oI2ih/i
JZ0jNFvimLtojgnp2Jms09VqPbvP2PF4u16bWI3oyLqeIVvG8xfdo6PxZj3vjEGePeB1CgVx
6Kr2r+wOXz/cxpuSYpMUVZXfSS1yFqLoin1Q/tMHmMT7XvH+Or+lvuf48zBlsid2UNLUb7z7
aIaaJNl4PYNV0bocKiZWnq8oA57WyCPE4bxd5DEHQ/MAsOi0Yq5C/z1V0eSBZbhXz4YaZD1f
+IR8MGB1LRsM0iOPM/IIwEd79jtg9bxDPKOW96r2RtvvwUGKrjzjXwHnb/iI37oCz3yO3C6X
h2Iv99HN70cBi6Zsqg/H09gYZ9woNy0+UBn18WGe3W7nHgtjbFgcs2BavOffUO7/7eeolXby
QGW0yEPJmR+wGEqf/Aot2eFQvxlASxaHTCvko8jhYtUmNw9U0d/PM4pY5ONnpWnTqX2+BT9o
wqJNPDRJ84myTxvO9m6ODkSXAwmT6diho7akPGoT2wd72gjRMg7+//kXPDu9fkBloF1+B9+A
t41D/7fMs206+L/jCNhd0bic1dJb06T5fXIoTW5/FXeeb2aosW7SQFumrYnPxIjxcVUxFrKd
5Z/z+GM2gj7wmeYsVGxUsmEbP+5/fpcLHiWfpxhMxvkDapV03rcvxL9FcB3oOfrV1+aVObpF
tVRE7zg45ErukM/voKv+9c+vb0JqLfjX5spGIdjCm+GUjSQb6V8q3X7V599xon/0+R/yzvw3
jmO547+/v2KC/PAoxqL6PjYwHmRZsgVbByQbSWAYmyW5K21EchkeOoL88alv9Vx7z8zOyALi
9wDtDLtrunv6qP5MddVSxzQNNIGvUQ43xKBY12C26C4zn81UNm3cSeVfxExnkl9Yw0J+S4vB
9k7X1/+/4bG8VPmlGbmvQm9jTt9wozRquPxjzRN8gYTJyQw+1XI/Y+xuE99uTnAwrvzKlMxl
pDuxGpEU/+Tko8I9QvafuYXEQ0j+Ow7ZpkN4i9PbxcX0jj2cIsfi+i57+2r8w9sfn7x68frx
b3/7yxuj13bNm8gn52r1NoHx023VHEevn42fv3z623dvXz35Zfz68ZNfnv72YO29sClQ/l6O
lBnFkXxwgm9sN2jz/Iwi7E6qeIGnX8pDjHvF6ZHqU5wciX5L9/+osrLfytp+Sxd7bDvtqXS2
T3FyZPotXa+VlSPdr7he267nytp+K2t7HBXcdv2NCil7fbMsrr/Ksrj+OgqL62+QsTj3Tbdd
f6PiW3mzyS78PLM6l1XaCRWhKKV5JE02Yy8I8Nxwc3tS93s0kqa0PmK3LVwwPtNwMzmjf8eL
q2yXaW+etypAWSa48jmHYxocxUjmQmva6FcvbdLlXDAaTituv1zdvc/uOW7yKHt0en/7CA67
EawZxmhX+Z+ySTogfgvd793f/jh7P7841yOPg8Sn1zOahpR8gGjQ9zdwDfb05au3//GWfdN8
yCNGzK+Sa/GTPLOizHB/8mH6Zcym7iRDi3YyqAA4LnY7vXw3ZQvWTtnni/H5lCq2+EJKgfDt
ZEiqhkUsZqi/42Q3jnMSrlNr3H6aXFMrH0nXvhhwcnQ1u4WV3dndBc44dGhNuGSav6Ot0XSc
TsMcKduyKoWYxcdKho+dqjOb0PCfz76MkZT6h2jZx3Ixv93MKX1YNcDleORVVN+Tmq0xbHtX
UtfeFE503b5PfU61rFme/ZLdfR8p3fI9F9n/e0xPp73n5O7uBqqs7SSGej6JyUOsU98P3Qpz
+447nG8/A3C4A8wAl/lRMkwkLVsU/S12LwVlh5cdmkM4u2vf25H9cnL+cX5LI1+1bEPkV4dP
gxyDvs9uTkMHDvuoo6UhiE7WcnqtRMBdEa3qZ1P4KydBupMgekWLa3pDLft6lbvTC66yd1pj
8uw5Txp/vEyOjz/iqED72azenrdTnkGMat9ZNEu5v7qACzUS0WHIaB5xtyiCaz5gk+4RgpeY
l28mn8aoBQkalVDpTMOD1rsFm9ojftDjRJROsmfzz9n87p9WCjG9zN2JY+porwBAxiwNXmeo
LdqqMbmID9PP07MxgkmhPTvMIfrwiTDvHziTQq1yvbiYn2HY6m5iaIHj8aI791LW76k1Ws5m
hYAOM2revaJnB6afJjdQjDfA3DP593RoE6eWz6fXNDWxvo5J8I7PI91NLzM+4cNHO1ZaJqU6
km01o6JmBypYhZgDFSzIIAUgPx2sRLdSUDNezE+pMXSHidEdOHByGfPF9U2qCVqzQ391NVUT
PQSqZode6w6bVnMRtaUCJ+l5pehWGFqzeKXAqqlUNxndNndFAbCdmc2wn2mpFuUCJmeYCaXr
oDC4AxYouEBmn7GXk+vayiRJu8TGjj951KaNmymlG2Orncbj0YNCnTrJ3k6n2Y+LMz4dya4Y
Hn28fLSa4eTu891anz5sUwqndlT/pLO0b3xk7zy0BeX3vXTkXBIG9/3pJQamEu1nOhMOHwuQ
ceg8w+Xovqwi+0Eb/KopOurRHHatH02W++cBm4u8Zxyq7ORiDtSpcymHQqCqtx+yK1+pUvdt
Vy6o4xyMbblHZ1t5Qe33xyzm/eU5ZrKWE2GemzXr2Q1NxbS5bq/guwOnIBIRbPfpuMh+4E4H
MvIZLJEr237nCBn0KiasIbWmPXBvdaielYs5rBA94DOIoZY8Q8RDmotV25WtqkfHfh3swRvX
1CMOrsOhlLZszQP6ZvViO+46i/fRdW9XdYmuG6qiCt3JsDnkC0I9fyeVvRBw+IQPGNKBr0N3
Dwi5JeEBrdTaFWntJu720qSNXPLStM5l2q8eVBwlTrS1Cu7ONm0itheHVIdV71NKnagYtC4D
yz+ZJLduiEr5bpo9z0Nt/PT66aNn888oHn+4Q8Sp+/KbqBTC2gwRt3gzcnuS/fFs5KII2duR
FlZkPz8fIcBcCsii1YmjKoPSs5+G8afJhymNsCVal3z2A9a9n8/wVRdfaR9KIdW/ZrP55+T4
g7TGdzeTy6oYKqwVwyuhuRhCcjEQubTIQKMputUM0jgjKYcNUXEOL10tB1z2rObQ0aOqTnrO
AafcqapWwNWbDsuvan71cQG3L4vF5cMPc0RXGGXvZtdjxCv6XnyWRgh1po5+evZ6/MvTNy+f
/vq/4zEufn7+088vnr7Ir16++rfHb14+gJ+58ylnPbq6v7igG3mYqe/wgPEtosCPJ+f/9b3N
3XWjUAj0Q/P0k9e/w6nGa7jMp+4asycL+LWrlfUlkOkEPrjOs41erbJ/VpVUw/GGngBx/XaD
oPbVn6xiv9Pn95fX4/ccJe1fxGcnHyH+kqslo00yJUPJ0TTjfGNAabVTlNjpWiWchWPO7B9w
mzJezMbJaR/Sak1pjaql9RI+CddSynC2ltLDLWY2Tl9O0l56fHux+HQ9uXtPWajelOW0ngUV
X8tSvBc8ZYqnKFnLEpVMWT5epkxIPr7BqEMGjwqoWT1DVLqegVIZQYlslSYKDjZMDUIzyBNW
hvJ9AyU+R1tLX0stJUJLNUzrEfAkO6eVKEGIsTOUMCKhqdWLCslN8Q8qKCVGS4w5+ColPg0o
rqsl1hyBhT3hfxmjHI9//ZUEjyczGmHj959mNLpRHo0Wn6haxghHiG+ev4YTeq1HVAjraZxV
KYyBq+w3bzmFOh3Btb2fzaZnkl7GqQ7Z02e/Pv7pbe73noZs9urN85/Gbx7/e+UKP/03mVVS
rUVgbk60HFPsfJK9+WFD1uzNk6W7q8V0HrFf3vy4llUIKvzz6q4s7/6Y302OusSkDArBAn2A
W9I3P7wuEhVVnlJWESqB1qf/0d1Y3S3qUwkM0SBeshQrJZQoi5Qrd9GQb6Raq0357uCuzbFA
Xa+GPKWFItBdU8sqhZkEjcfY1bRVlRGjF2zrxfTy4fOr2WJU+wP7uk9r55j0yauRCkH5cj1N
96xFoKD57YKDv6R7YlVIIYVjpohKQnFd5E7Xa7nvr+AEMQVCsJaWkPP5zd0Xysi0A2Gg6ff9
VXJHuyH/7cXkdEyb7ovJ/DIlSbfur5ZuruWDV1KY91gdArSf6SUp6KTGshu3FEB8pHXMThf3
pK5vEAANZeRC5B/j67NrWknT77PLST19ilH9Er4FxVKTS3q4CB9+WGl1pdBZ6PZSQ9aTlXfq
jUc7Eq2QKm/wIwh7kDIWt5Ax3cqr7yTpS3SZNzr9qjU7XaWGoVUtuvJyfPeeNJLq8vryPJfG
N/HYKkkpbnx3eZ2XuXiXSEzT5dKb+gct2mXTSRrENAf8+OKxVqm9lbcOpZ9fFT9p9RlpY9Be
cIM9MqkVhm9nrhltfs7xzQuJruFH7epuZGkvIRW38RX1pfORCYbGIW7APyc6nRPIkLxDjlkX
HUWuQq3zSc31K/of/Sw7mlSCa06rTe266nsffqiaELFV/0Qr4VXdJKdgf/wJ3UZkopaM1va8
pUeZ8ccozNGLB1mwx2i5o9/ptzLH0uX3/TE3At8Px86UaY6lqjIcK1tkEMeWG0Ucy9Tq4lgJ
E/gHnLbSj++z9E6rUnmOnJEPnff376ZJf7hb3HHk6uoO6r504/b+5nr5xvx/pt+nJ1byo0To
dtLyPenVEMovgI0FkzvHWlJvaW6WWkQVcs/Fbx6/KP+uhILjfpH/6WfqijTtPnqx+Ii3+erq
4kstacDn0ki6UZ46fy3nVRKpdU0avdRNaQLCcxdp3n+6XtA4v6qnUBqOwf+A67iMZqzsnv7N
7t7Nz1NlSV/K+L+bW9oxvEv9bpz2QdiXMhBd0pQzOGKr5Gv2DP8H9oHwe0//Cd4URv6tpFFJ
vjEe/9ACb0yW/yeKH9i70ILJnoIr0SaChdKlZs/3eQa6yEVbl4tWsa1oJxFiiUWHuuiwKtq4
tqI9x+ymS6trpaYL/k3zkM9FO5ZoorRqXXS6ujmr5AaH+EqQC0fopdy8XDW5iu9YrUzYVuS3
MT68OTvh2aN6Qozo3vwEW3+CXX0CrdD7nlD63i3F0wJi8obhUDiFeCs7VKDyo1vJV9a7XL6r
y+c3iHDoSYgnDQM3EFdwQ8Mn+fXjVtUTSDcN+RPqrzYVHNHqTfEExY/U2ol2T7AKejmewBu9
4gm5GIRlTjK03dV50hNuL6bT60q0M4id8EcmReC3KyONGlykwhuXmt/GwANYR+U2dHkIEzUU
Ucn3XnHRpQQvQYwvTcoQX6YXULxgC3+33F7SbXjB258QhU5PUAhLJmls0lMFios76SEupvag
nYhsXg1ZPgTdRKeHYPtHDenhxtxnfCM1VdCp2Ja0uuYVqXR8EmfzZ+RvGWMAF6kOOo0viUhx
+Be+/Df0oxX51UJutPA80iSjK4gOGV+k8juRRrTxITQvf02+0cAjkG9S+dHEuEjl51eS8dDT
ndrHepOX31RrChOYJC4ft5o6NW6QdhNavWOvUO5X93cI9VfEMvhlfnFRmi3xyziq6v4g4/WP
upWBaf/t5OxmPkOkSoaWleTAMdoganq+QxgvvQ8/Xo5oYYEO9R1rzA9pDSY9zoSAO1A8+U6M
nIIVbb6hvBZ1/S5QB9XfGENTpJgA5PbL0FQwCkNnA0OjP3mOvLOboalgjWjK0GjNlVjMmzA0
Shs4rtlehkYNY1nraM7QaGOuEXi6BUOjLIHL3pShqRA1gknuYmiUxjnTlKGpKCTHN2uW1kIP
38vQKGHUtiFDU6TcI9xOa4ZGGSOUzu0MTUXFoaT7ZWgKUX50jwyNBAYle2RoKhqLM/u9MTRF
Wic+HvXH0KJjcNofQ4su6I0MDeGU1SpDoyGyytCkJ1V2G0PLhXRkaEXurgytyN+WoRX5Coam
Y9Q1hqaWGJrcwNAKAesMDdrCOkSjN2KM3AbRAuOHFbgjHK+dXwOiWRt9Q4gWvhJE+1KhC00z
GBanHijaAA09OEVTfhtFc/zSKoqWrjdRNJqXFTY4eyia5mihJUXTKh6XXMybiqNJXXE0k3M0
+ulqGE2WGA3kLFG0DgSNNgMRmthQBI06FqlJiaDZ3QQN4MyH7QSNbtuoGxE0jTXJ7SRolEQj
jNguggYIgG9l2wmalpKjuw1F0Eh+1GIQgkazDR9SG4CgadpF5qXum6Bp2tgH0T9B05QKYXyH
I2haOiXMYASNXpuIAxI0kh+DH5KgUe8IxSsYhqCRpsG7sAEImlYpruRQBE3TmLFxSIKmlTLe
DkzQtKKBroYlaNSvtQ/DES6trMpf9SCESyt8cx2OcGnlhZVJfm2mwEVe/nwkq6B4bAcZVbtx
pny0YQ9Dw8iosJcuGRrVcjtDY5dwZp2hrQmrGJoOLiwxNB21W0JotISbsAzRotN1JckHCyXm
m2JoOgjaVfTN0HQgFVpsZGhABej3exgaJfNQiRoxNBrrbGvUhKGBc7PR1V6GRimdEq0Ymg60
urSzQ6OOJXidasrQKAO7Z9nF0HTwiqOlN2JolDpy8zVKGyw3yj6GpkOUUjVkaJSYP1e0Zmg6
CgfUup2h6UjDunc7NA0yZ3pkaDSdaAyL3hiapi2q1j0yNB2TiUdvDI0ERhwX642hadjybWJo
9Ifo3CpDM7SurjM0v42hFUK6MbQydx1OOOGaMrQyf0uGVuYrGJqhzWiNoYVlOzS5xtBKATlD
8zU7tE0IjZYsja3PRoRG86PaSHbwOaot2THKtkdoTgXRCKExa/rKCM0IUsZWDdGYvLRFaEM0
9AEIzSTrv2WEximWDNGYNm00RLPLCC1db0JoRjgJErUHoVEy1sVyhCZzgPYg0zLxM1iVqQqf
SVuzQ5OqRtD0gYZodcxFYzO6ATGaAUYTjNGC3I3RDOiZ2I7RDDBaaITRSCkQ+Ha8A6MZ8C+x
G6MZqOdqF0YzMn2JGwqjGdrYRz0IRqNBrNNuqneMZmhPn5sU9Y3RjKRd9wAYjeQGG4bEaEY6
9mY3EEbD9GfdcBjNkCZmzZAYjfZBQg6K0egJ0fpBMJpRMki5E3M5nTo9dXamHy1BmlHK56Zu
w2EuA0sxMyzmorXdxgENuYzypaHYEJjLKJwrGw5zGU1DKe7AXDK9bBrI3nZpH62EzDGgtXX5
tii/LOT7bPtI3tpRaV2Jew3RqA4V95IVRAs7IJrRVii7wRBtVVgF0YJfg2g4UbAM0eyKJVpU
UKOKp1ra4blvzRCN+ljsH6KBDwi7EaJZb9L3gd0QDTaO3jSEaJQ4qoYQzdJWBCrdfohmPc2L
sRVEoyxe61YQzcIwuI0hGmXwjLx2QDTrAx/baAbRKLVlpbBR2ij43Ow+iEYJjWp6mJMSB3zc
aQ3RbBD8NXQ7RKMUAQXuF6LZoBh99gbRLCwYTY8QzQbT72FOG5zEMtUbRKM51UB76g2i2RDY
Mc4aRKPeLcFolyGalXYVoilJas8WiFYI6QbRytxLhmialqlmEK3M3xKilflKiGZ8rCBa8EsQ
zawbopUCNhiikYK+TtFs1ArL9kaKZoQTG+BOWl3bwh0opa0pmo9MRvZRNFK7/wJDNBudhO/m
ww3RhmjoAyhacOt2aHxrCaLFrXZocsUOTW6DaDbieP9eiEbJ2JFKYYd2XINiNSRWQTRXGaFJ
t4mh8e8cof3e7TCnw2F0MRxDc0Kx9TQtNUrsZmiU1OAI9zaGRn/3sdlhTkerMpSzHQyNkkSo
i7sYmqP9JA6Jb2dolCKoOBxDw8fO6AdhaE44r9wgDM3RxtvHQRiaE8GoAQ5zOupz2g/J0JwU
PNIGYmiO5l/lh2NoNP1pNShDoy2SsoMe5iRlsnwFPTM0J61JhoY7GFp60ZZ2M1l7huak02pg
Ky44hLK78FbIh5lNDdQW3zgZpAmN8FbsgrccPAoNaMVF8mPdiuuhkkqRAm/Vsi2XT61krGhR
i6qVFG2sZA1yYe1ehlxFK8kWEK3qSQpmpUm+c7VWcvlQljIJ0TE3amwE0apWUsoBku6EaBgW
Gy3RdkE0p6gN9DpEWxNWg2g0LlcgWkJmOyHa0mlOZ7Wz35pHNGetwBrbL0QjqbT32gjR8AUY
ru73QDRKZht7RKOkMTb0iOas5wVuP0SjlHw4rAVEczZotc7ddkE0yhLU0uHMPRCN+pAWe05z
wimRbQzRHGnvTS3RKK3lw6f7IBoOy2jfEKI5WvfYLVxbiOZoEoLzjO0QjVIwje0Xojmn2ZtA
bxDNOWNVnxDN0RjkevcF0Zxz7AeiN4hG8kzo0xLNucDUew2i0R8sNmnLEE04sQbR4C1zC0Qr
hHSDaGXuJYhmSBVtBtHK/C0hWpmvhGik/dUgWlyCaKSlrUK0UsAGiKbkBojmvAww/dwI0ZQy
G9kODYcObMfD0LstRFNsjLUfojEP+coQzXmarXo5zTlEQx9ymlOxi7Z9FI2FbKJoJHCJoqXr
TRTN+WQitYeiUbIYKp9oyuvSKZqtHeYsznIyU6tbo5kcpNVPc7446DSnoz2NGhKh4ey2SwhN
7UFoNNXC49JWhBZo3+abITTqCfiWtguhBeOwT9mJ0GgSCrsRWrA27TkHQmiBXtAw/tBcCFy5
IRBaiCodDOsfodHmMm+QfhEaTjCIQRFaVOxWZyiEFmmfpwZEaNFEowZFaDSFljUYBqFFb3PL
y94RWoTDmb2AKwdQ3QCXF6Q8uuEAlxeUvJkjrk6Aywtl00nsYQCXF9oKMTTg8sKYAjMOAbg8
trqxAeAyqk35a61E2l5CsdqbmnxvivZJk7N2kXupomHj2pQ/OX/fbYVGQ6JiXqoCaG4HQIPJ
JVaqNSu0VWEVQLP5Oc0SoMGN1X6AFmsaklfeqG8NoHmF6b5vgOZpD+w2hxSgPwWzH6BBsmp6
lJMSc+D1JgDN47B5Iys0Ssn22C0AmtfUdOtRCHYBNFJYhIgtABplYDPuXQDN07zNDs4aATTa
HilosA3TRt/ECs1r75nzNQFoXsNmqgNA8zpqv9MKjVIEEOJ+AZqn5mX40xdA80Ya0ydAo7lG
xj6t0DB5Jd7VE0DzBkc2egRo3liJr49rAI3+wG4ZlgEaqZVrRzlpMtwG0Aoh3QBamXsJoMFd
RjOAVuZvCdDKfCVAw6pfAjRSv5as0PQaQCsFJIBGelxlG7QppIA3IULr2MzPjNrg6p70KNMF
6yQQ0fIopzFNjnLSgvIXHOX01NTWLPMz142fDdDQB/Azy7Rp30lOvw2fJRhY4bN0vQmf0SzG
DgT24DNMd6JmhGZdic+cKM9y+poVWqhZoRVGaOBliZ2142auzs28DQFxJIbiZt5GF0PiZm43
N/Mwg5PbuRn93WjZiJt5WCjt9oLmHW3Lwm5u5mFQspObUYoQ5HDczDvlwzDczDvtvB6Em3l8
jvODcDPv7P81dy49iiNJAD4Xv8IazWEfRZHvR6+QdleanZnDag6zt1YLucBFoQJMg6nqmtX+
941I22DjN0P29KUoTGbk0+nIzxGR3PDbczOtQAnlPrmZVrA2+ONmWuHbCX/cDORn9jC+uJmG
hYJ6NT2DLYHmfkzPtAZlknpkWpoJbT0yLdwIUo9MS6NXonempSWTxCPT0qkrzJlpUV5iWqf6
a8b6yy/0kiY5k6tlWifPTWL0VfXXNq+/Tm+xMXfys1ss95wFVVz2H+XCLIIHrs7km2L9Tbn+
DDbF+IlvQQZ4hkL1NTK/ViaHt8RwJocxxUiVyVWEnZmc4qxs1AazuRJe7ZLJwcqB6tupWMvd
cYrfFpSzQiIjuzGUswgx66GcxRg33VDOoqlVXyhnQQlRPaGcVc7oogeUs/AAqQZLa4VyFmbt
MNdQbWFrLIdAOWvg6dkB5aylrD+Us9a94+iT1iARsT2gHGootK9VGyQ2bgCHQjlDcB1ug3KI
393xlDeFcoYwp3ndDMoZqLu8JZQzRKQ2Y7eCcrBoutO3bgblDPrD0BtCOdjcGloXX80Qw2gV
ylWt2qiFR2EDlMuFXAflTrlLUI6qvlDulH8glDvlO51RIFQzlMPTyC+g3ElAFcpRbWuonKHp
yd31VE7VGluBxkiGwyKSAqthVA7ja36zVM7Aas/4Taich47+XVZtVSpXMWpjqim+mqaqROXS
73VUzjDiXOw7qBwkM8J+E1TOwN7I59kEhnH3dqYHlYOkCoMqNVE5NBrm/c4mMBieut0hFJJo
LtqpnIEtnmk9mwBSiNSIxQ+VM0zxLFTWramcwRhNxguVMwzWbT9nE6AptKG3p3LwMDK5v6Mf
KudsNa03KmfguZcf2uCDyhnOFJE+qZwBHZR7DaoGi5DIz2+4MZUzWHePVM5wUH+ZP2oG1csO
PvVJzQyGPrf+qJmBMdDaHzUD7Y3kxx74oGYg36YxNP1QM1CMLJH+qJkRzLBOaiYbDiWQLdTM
CK7Q9rpCzS6FnamZcMGMS9SMVlxBFbmwZNOmoL1Y6GYcj5e3eA/q4+TIPvA+2IzMSQGbDWBj
5FyyZLQSNM2wjIyVKjSEjVmh3MytYWPwk8bYHR1szILeRHhPNgaJLSX92JgVJnUu7GRjVlh3
Gw5gY5BFiWqWNjZmJaE8deWKH2fb6C3Ng7QJEupiOuVi+b+gzu8U29mJjElIagpJ06OsAth2
oJo3S/ckrjeQdBULpwLNFQPHuI6gl26gqs/RehftZ9GXaD4LD+9bLCJCmkVVIScs5GlUtOPm
eTaPN7t1lCC9UojpSgmFY6H7KAHlHkbzCSYV1gUrLYrpDL5OrIANK7mLs1fc5HFQMy6tjQQ6
hTSBjVzIdWDjlPtKsHHKPxBsnPKdrI0YkwWwUY55xarWRicBGdhQhcDxdVzDokFPg7ce7BFI
1QiGWgyY/pW4hrKkH9cwf0DIKzzSDslciWu4TfRAruGlo71zDdtkbURlmWuk3+u4hlWM8W6u
AckUO8eN57rANQpBr2QN2EjjWakUWlxFNYovu6wCRZD6oxr4LCEp1eAdYa6skoy1hIqH390r
sB5UA5Ja2R4q3irFrG6nGpBGtdsaQQqbqrl+qIZV2ig/tkZWGc2kF6phlZVGeKEaVhPB2e2p
hoUFRHr10bOaUSW9UQ18Cao8hooH+VYRn1TDamG0V1sjq09B425NNaxWKrdy8UE1rNZSeIxP
DquY4MY31bDacsv8UQdriAt3mlMHCvotegDQsg9aFgrMDIm0zs9lpF6YvsiDNYzSvA3FkdY2
r3/mQycdcOjpQ1eQzwnNRtpkCwVzMzQd49NMAhXqmkjx1qGlLrKhxfAgV9YIrWqOW6wIK9oD
pSCjQDZEp48eemufVDr6QEBnxUjGXxttYMnCPexuizZQbmqSV0Eb7qcsGlIL2nDJLL6B6oE2
MLHiUvdBGy6tNj2OVcSUmlo2AG24LMroAWgDsxjqbG5a0YZL59b/TrSBSS1xhyp2oA2XUrhb
dCDagJwUjWw60YZLKJzvZSvacOkMWpVcoA38AX6xF2gDlj57iTaUNA02G2ch16CNQu6r0EYh
/yC0UciXow1YiUkT2mD20majICBFG7posyGq4bwxA6j5tJ5t4JH2qrrlNhjX6yuxDbi9vlW2
gX2nOULKEtuwV9hseOnoG7MN14Ii26CmyWZD6nI47/R7lW1ADzLCOm02XDIlG9iG9s02zt71
WBF42itfbAPlM4PPyk62gUk5M41+VO53dzBGJ9vApMKdnNvINlwSo3gb28A0KW1pYhsuhSbe
jsFD+ZpkG+Lbsg0UbbjxwTZQtFXGR/whEA2Tw97cYgPlMpYHv/HBNrCENBCsF7aB4mGrwX2x
DZQPa7fyxzawBK2ZR7aBJdhT8Kqbsg0QDe2n3mIDoXzqXqf6YRson1Nq/bINLEXI3E/o9mwD
5UvLWAt3gIUm7SXBTP9eOm8KRepG4Yc7oHyjNOnFHeyA4Nr8JB/XCNnFHUrxsMmZO4hG7oCS
YSrSGu5wKaw9NpDo4g640yxoFxhP7I/BDujYqDxgB50GXq3DDtpY9ALtwg4aD4/vix2cS0lP
7GBIGhm7GzsYKtRA7GBYWpEB2AFN/nkP7AC1xriWfbCDEZz1sKhwKZ1H4hXYwUiTBRnqwA5G
uY1sJ3YwmqAxShU7GC1QpyljB0YuTxETSsL61YQdMiFXYoc8d/kUMaP7Yoc8/1DskOc7YQdc
EM/YgZaxA6tih1xAZlFhCvFbWB11wOiSTdSBGVZ1YMDNsNvdDQ0rIt2ObiB1ID0tKty+8mtT
B4tBwS+og9thD6UOPjr6d1AHlvZ6F3ZwJ5zVB3AxL+UALqYBO4BCanGN68AOlECjzq4icFOc
sIORhXPECgeJMXIz7qBZscJcaOaPO1BQ1UzmKSLauQMl0gWGbeIO8Lt759qDO1DYrGO0gBbu
AAqbcwZu4w6QRvIWmwpMYQjzyB0osTz1RLk5d4CHqKLEC3egoM8rH54iKJpTfvO4xyhXcOWV
O6AEor1xBzwBkHrkDjCkLnCIP+4A+173xssfd6CgteYGOTfmDrhLz9/m++ACFLIx5ZsLoHrG
uT8uQE+Ob364AGXabTF8cQEKY5z70zRwgfzk+iyy9TAuAL2dnc9HXZSqU/0NT+UrkvYGUtL+
/XMeX1DA8IHWzh1gsEuH2WfcgdsW7gA6nxU1h3pVhBXtHYjpsncQVJW5g5JMFLQLCYtZV4xl
vDnqOAo8MVraI6V7c1H1TKFNHKWuPZ0cRTq347xU9NrtHh9Da+1ReLOnDUo2LiBxpT2Xwkqe
NqLcHsM67VGEkcX2CK7R0qDDvkbXxtthzfY1KFmyWs51KazYHntpX9N9iBwGxiq0Rwtruttj
r2iPBuW2bnwuhZXmW2V8SGd7rCDF9mDslU9OAd1HoI3uPwTus6UGCOnezoWWSyStpVniIoh3
zO763gOdqKX3LHXrZnV29+89Rull9CWW3tCF2S2IKLaHyc7eM629B0/xyyFjab2aCxUKHbw7
QljZ2iWctS4RFjbatSGsbNMSLpgxl1Owc8lzJ4nnhXKFx8R39OFFBYbMwEJh/EEq6d5sPx2T
6MvsLXyJZvGuFJAK/oWNWRKDhNUTdPAueHzHCqi/QQlfguR5dcB6LffhZvQRVctPAaz61gar
JNqHySreHh6Cj/+CccWd568fjLYi+OnnD3gY6Ke0GvrBwhCjqn543ybPwTF6RYoRTB6Ph0k4
360+BMftC7Rwm/3keEm8DQ5Yz+VZCHV+XtcJGf2wDncH6ORktYk+BIqMRp+jzXG82iyDOfR/
EgXjp+DzPH5jwWJ1eBm/x/MkHq9eHwUdw15pTAIm1Y8DM9FrMrFrMvFrMolrMslrMqk00+jl
dTP90+jOZT68HxKYtF+MmikxuhtHW2QFY0gCX+a7Y/BTeHiL1uv7vx420Q7/hjv4JYVawffp
J1zAubxfBJP4sNqEy2jiyk7/5nu6rJCH+fI3yLCB+5DB52GzCyh8LpC9RUGEm5z7bZTA9yl8
EPgp/RYgZr9fLfKrj3GcZC9qtnNMFY/3EV6E/9/CZP68iJfBChZcEh0eC9fG2ZxcRI/HJVzf
J/PgMTxEU7dvxpmJtdmvXiN3e0/rJ+L9JlqsQvfj/epp+rrag9AeGem1Gdm1Gfm1GcW1GeW1
GVVTRhj5VbiGZWSRylkdduvwHRbkLQ7WJobpBU8YfHk3+vNohJx6u8ApvofpMJ3A5JnA0gmT
5vm4Xc6S8PAy24Xb1XwKEy+bBuEOvmb/wz2x/zwL12/h+2GW3hALkDU/7hZwkz3APzO4M5Do
rtcznDDxMZnCvB3dwdR8WD0hSjtM4esOJn7y8gDlv2wOy2m8hUuu3DEUfIifEiTFx925MtvN
apbP06m7OrqL490h/38dh4sZNAU7aMqwgHizS05XoMjF/nHxsFlt4/1sHh+3ydS49sA9vnhY
x8vZGtbl9TTa70d3q+UW4R9cdRdHd3N4jsQwNknyDpKicL9+T1uAV34l95TiYZmldIWrr8tw
CgI3IUjav43uHvfhdv48Xa+2xy94d0frifs7PuziZMwINfA8EqCJQDv++csv/5n9/O9//PjD
dLJ7WU5cpkm6XoxBzgKKfFotx3syTjMJMVnO52M1yd6hmpAvZBhpQR4XZM7ownIezueKgTIl
dbQgk9cNCv1tXPsKtr7fcMSj/dPD4fmYLOChBv0Ls+u77/8Lq+PHv3/633fBOJ1qAVxL//v4
F7g8+j89yjJTrKsBAA==

--fl6aawq5ck6ju622
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-yocto-ivb41-130:20180414175602:x86_64-randconfig-r0-04141244:4.16.0-07313-gc9e97a1:2"

#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-m 512
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--fl6aawq5ck6ju622
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.16.0-07313-gc9e97a1"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.16.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=y
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TINY_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_DEBUG=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
# CONFIG_ADVISE_SYSCALLS is not set
# CONFIG_MEMBARRIER is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_SLAB_MERGE_DEFAULT is not set
CONFIG_PROFILING=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
CONFIG_GCC_PLUGIN_SANCOV=y
# CONFIG_GCC_PLUGIN_LATENT_ENTROPY is not set
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
CONFIG_CC_STACKPROTECTOR_STRONG=y
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_ISA_BUS_API=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
CONFIG_REFCOUNT_FULL=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
CONFIG_TRIM_UNUSED_KSYMS=y
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
CONFIG_GOLDFISH=y
CONFIG_RETPOLINE=y
CONFIG_INTEL_RDT=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=m
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT is not set
CONFIG_ARCH_USE_MEMREMAP_PROT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZPOOL=m
CONFIG_ZBUD=m
CONFIG_Z3FOLD=m
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_PERCPU_STATS=y
CONFIG_GUP_BENCHMARK=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_X86_INTEL_UMIP is not set
CONFIG_X86_INTEL_MPX=y
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_KEXEC_FILE=y
# CONFIG_KEXEC_VERIFY_SIG is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_RANDOMIZE_MEMORY is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_PM_SLEEP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_TAD is not set
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPU frequency scaling drivers
#
# CONFIG_CPUFREQ_DT is not set
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_PCI_LOCKLESS_CONFIG=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# Cadence PCIe controllers support
#
# CONFIG_PCIE_CADENCE_HOST is not set

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
CONFIG_ISA_BUS=y
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
CONFIG_CMA_SIZE_SEL_MAX=y
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_SIMPLE_PM_BUS=m
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_KOBJ=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=m
CONFIG_PARPORT_AX88796=m
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# NVME Support
#

#
# Misc devices
#
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=m
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=m
# CONFIG_DS1682 is not set
CONFIG_USB_SWITCH_FSA9480=m
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=m
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=m
CONFIG_EEPROM_IDT_89HPESX=m
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set
CONFIG_ALTERA_STAPL=m
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_MISC_RTSX_PCI is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
# CONFIG_FIREWIRE_NET is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=m
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_GEMINI_ETHERNET is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_EZCHIP_NPS_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=m
CONFIG_E1000E_HWTS=y
CONFIG_IGB=m
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=m
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_PCMCIA_RAYCS is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=m
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=m
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=m
# CONFIG_SERIO_APBPS2 is not set
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_GOLDFISH_TTY=y
CONFIG_GOLDFISH_TTY_EARLY_CONSOLE=y
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_DMA is not set
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_MEN_MCB=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_ASPEED_VUART=m
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=m
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=m
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=m
CONFIG_SERIAL_SC16IS7XX=m
# CONFIG_SERIAL_SC16IS7XX_I2C is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
CONFIG_SERIAL_ALTERA_UART=m
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_XILINX_PS_UART=y
# CONFIG_SERIAL_XILINX_PS_UART_CONSOLE is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=m
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
CONFIG_SERIAL_MEN_Z135=y
# CONFIG_SERIAL_DEV_BUS is not set
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=m
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PROC_INTERFACE=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=m
CONFIG_IPMI_SSIF=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=m
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=m
# CONFIG_NVRAM is not set
CONFIG_R3964=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_SCR24X is not set
# CONFIG_IPWIRELESS is not set
CONFIG_MWAVE=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_OF=m

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPMUX=m
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
CONFIG_I2C_DESIGNWARE_SLAVE=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_KEMPLD=m
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_RK3X is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=m
CONFIG_I2C_STUB=m
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=m
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_KVM=y
# CONFIG_PINCTRL is not set
# CONFIG_GPIOLIB is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2405=m
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=m
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=m
CONFIG_W1_SLAVE_DS2805=y
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2438 is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_DS28E17=y
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
# CONFIG_POWER_RESET_SYSCON is not set
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
CONFIG_REBOOT_MODE=m
CONFIG_SYSCON_REBOOT_MODE=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_ACT8945A is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_BATTERY_MAX1721X is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_DETECTOR_MAX14656 is not set
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_MAX8998 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_CHARGER_TPS65217 is not set
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_GOLDFISH is not set
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=m
# CONFIG_SENSORS_DA9052_ADC is not set
CONFIG_SENSORS_DA9055=m
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_GL518SM=m
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
CONFIG_SENSORS_HIH6130=m
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_POWR1220=m
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=m
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4222=m
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4260=m
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_MAX16065=m
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
CONFIG_SENSORS_MAX6621=m
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=m
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=m
CONFIG_SENSORS_MAX31790=m
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_TC654 is not set
CONFIG_SENSORS_MENF21BMC_HWMON=m
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM73=m
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_NCT7802=m
CONFIG_SENSORS_NCT7904=m
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=m
CONFIG_SENSORS_IBM_CFFPS=m
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
CONFIG_SENSORS_LTC2978_REGULATOR=y
CONFIG_SENSORS_LTC3815=m
# CONFIG_SENSORS_MAX16064 is not set
# CONFIG_SENSORS_MAX20751 is not set
CONFIG_SENSORS_MAX31785=m
# CONFIG_SENSORS_MAX34440 is not set
CONFIG_SENSORS_MAX8688=m
CONFIG_SENSORS_TPS40422=m
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=m
# CONFIG_SENSORS_UCD9200 is not set
CONFIG_SENSORS_ZL6100=m
CONFIG_SENSORS_PWM_FAN=m
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SHT3x=m
CONFIG_SENSORS_SHTC1=m
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_STTS751=m
CONFIG_SENSORS_SMM665=m
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=m
CONFIG_SENSORS_THMC50=m
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP103=m
CONFIG_SENSORS_TMP108=m
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=m
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83773G=m
CONFIG_SENSORS_W83781D=m
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=m
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM831X=m
CONFIG_SENSORS_WM8350=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_OF=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_QORIQ_THERMAL is not set
# CONFIG_DA9062_THERMAL is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=m
CONFIG_MFD_AS3711=y
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_ATMEL_FLEXCOM=y
CONFIG_MFD_ATMEL_HLCDC=y
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_BD9571MWV=y
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=m
CONFIG_MFD_DA9063=y
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=m
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
# CONFIG_PCF50633_GPIO is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RT5033 is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=m
# CONFIG_MFD_RN5T618 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=m
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_TI_LMU=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65086 is not set
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
CONFIG_MFD_TI_LP87565=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=m
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=m
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
# CONFIG_REGULATOR_88PG86X is not set
# CONFIG_REGULATOR_ACT8865 is not set
# CONFIG_REGULATOR_ACT8945A is not set
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_BD9571MWV=y
CONFIG_REGULATOR_DA9052=m
CONFIG_REGULATOR_DA9055=m
# CONFIG_REGULATOR_DA9062 is not set
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=m
CONFIG_REGULATOR_FAN53555=m
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=m
CONFIG_REGULATOR_LM363X=m
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP873X=m
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP87565=m
CONFIG_REGULATOR_LP8788=m
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_LTC3676=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77686 is not set
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MAX77802=m
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=m
# CONFIG_REGULATOR_MT6397 is not set
# CONFIG_REGULATOR_PCF50633 is not set
CONFIG_REGULATOR_PFUZE100=m
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_RC5T583=m
CONFIG_REGULATOR_RK808=m
CONFIG_REGULATOR_SKY81452=m
CONFIG_REGULATOR_TPS51632=m
# CONFIG_REGULATOR_TPS6105X is not set
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=m
# CONFIG_REGULATOR_TPS65090 is not set
CONFIG_REGULATOR_TPS65217=m
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_TPS65912=m
CONFIG_REGULATOR_VCTRL=y
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=m
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_CEC_CORE=m
# CONFIG_RC_CORE is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_CEC_SUPPORT=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_DVB_CORE=y
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
# CONFIG_DVB_DYNAMIC_MINORS is not set
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set
CONFIG_DVB_ULE_DEBUG=y

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
# CONFIG_VIDEO_CAFE_CCIC is not set
CONFIG_SOC_CAMERA=y
# CONFIG_SOC_CAMERA_PLATFORM is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=m
# CONFIG_VIDEO_VIVID_CEC is not set
CONFIG_VIDEO_VIVID_MAX_DEVS=64
CONFIG_VIDEO_VIM2M=y
# CONFIG_DVB_PLATFORM_DRIVERS is not set
CONFIG_CEC_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
# CONFIG_RADIO_SI470X is not set
CONFIG_RADIO_SI4713=y
# CONFIG_PLATFORM_SI4713 is not set
CONFIG_I2C_SI4713=m
# CONFIG_RADIO_MAXIRADIO is not set
CONFIG_RADIO_TEA5764=m
CONFIG_RADIO_SAA7706H=m
# CONFIG_RADIO_TEF6862 is not set
CONFIG_RADIO_WL1273=m

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=m
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEO_V4L2_TPG=m

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#
CONFIG_VIDEO_MT9M111=m

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#

#
# soc_camera sensor drivers
#
# CONFIG_SOC_CAMERA_MT9M001 is not set
CONFIG_SOC_CAMERA_MT9M111=m
CONFIG_SOC_CAMERA_MT9T112=y
CONFIG_SOC_CAMERA_MT9V022=m
# CONFIG_SOC_CAMERA_OV5642 is not set
CONFIG_SOC_CAMERA_OV772X=y
CONFIG_SOC_CAMERA_OV9640=y
CONFIG_SOC_CAMERA_OV9740=y
# CONFIG_SOC_CAMERA_RJ54N1 is not set
CONFIG_SOC_CAMERA_TW9910=m
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Common Interface (EN50221) controller drivers
#

#
# Tools to develop new frontends
#

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
CONFIG_DRM_DEBUG_MM_SELFTEST=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=m
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_VGEM is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_DRM_RCAR_DW_HDMI=m
# CONFIG_DRM_RCAR_LVDS is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_VIRTIO_GPU=m
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_ARM_VERSATILE is not set
CONFIG_DRM_PANEL_LVDS=m
# CONFIG_DRM_PANEL_SIMPLE is not set
CONFIG_DRM_PANEL_INNOLUX_P079ZCA=m
CONFIG_DRM_PANEL_JDI_LT070ME05000=m
CONFIG_DRM_PANEL_ORISETECH_OTM8009A=m
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=m
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
# CONFIG_DRM_PANEL_RAYDIUM_RM68200 is not set
# CONFIG_DRM_PANEL_SAMSUNG_S6E3HA2 is not set
# CONFIG_DRM_PANEL_SAMSUNG_S6E63J0X03 is not set
CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0=m
# CONFIG_DRM_PANEL_SEIKO_43WVF1G is not set
CONFIG_DRM_PANEL_SHARP_LQ101R1SX01=m
CONFIG_DRM_PANEL_SHARP_LS043T1LE01=m
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=m
CONFIG_DRM_DUMB_VGA_DAC=m
# CONFIG_DRM_LVDS_ENCODER is not set
CONFIG_DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW=m
CONFIG_DRM_NXP_PTN3460=m
CONFIG_DRM_PARADE_PS8622=m
# CONFIG_DRM_SII902X is not set
CONFIG_DRM_SII9234=m
CONFIG_DRM_TOSHIBA_TC358767=m
CONFIG_DRM_TI_TFP410=m
CONFIG_DRM_I2C_ADV7511=m
# CONFIG_DRM_I2C_ADV7533 is not set
CONFIG_DRM_I2C_ADV7511_CEC=y
CONFIG_DRM_DW_HDMI=m
# CONFIG_DRM_DW_HDMI_CEC is not set
CONFIG_DRM_ARCPGU=m
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_MXSFB is not set
CONFIG_DRM_TINYDRM=m
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=m
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB=m
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
# CONFIG_FB_MODE_HELPERS is not set
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=m
# CONFIG_FB_VGA16 is not set
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_IBM_GXT4500=m
CONFIG_FB_GOLDFISH=m
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
# CONFIG_FB_AUO_K1900 is not set
CONFIG_FB_AUO_K1901=m
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
CONFIG_LCD_PLATFORM=m
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=m
CONFIG_BACKLIGHT_PWM=m
# CONFIG_BACKLIGHT_DA9052 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=m
CONFIG_BACKLIGHT_SAHARA=m
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=m
CONFIG_BACKLIGHT_PCF50633=m
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_LP8788 is not set
CONFIG_BACKLIGHT_SKY81452=m
CONFIG_BACKLIGHT_TPS65217=m
# CONFIG_BACKLIGHT_AS3711 is not set
CONFIG_BACKLIGHT_LV5207LP=m
CONFIG_BACKLIGHT_BD6107=m
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
# CONFIG_LOGO_LINUX_CLUT224 is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_ASUS is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LED is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=m
CONFIG_LEDS_CLASS_FLASH=m
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_AS3645A=m
# CONFIG_LEDS_BCM6328 is not set
# CONFIG_LEDS_BCM6358 is not set
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=m
CONFIG_LEDS_LM3692X=m
# CONFIG_LEDS_MT6323 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=m
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_LP8788=m
# CONFIG_LEDS_LP8860 is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_WM8350=m
CONFIG_LEDS_DA9052=m
CONFIG_LEDS_PWM=m
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_TCA6507=m
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_MAX77693 is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_MENF21BMC=m
CONFIG_LEDS_IS31FL319X=m
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
# CONFIG_LEDS_MLXREG is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=m
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
# CONFIG_ALTERA_MSGDMA is not set
CONFIG_FSL_EDMA=m
CONFIG_INTEL_IDMA64=m
# CONFIG_INTEL_IOATDMA is not set
CONFIG_QCOM_HIDMA_MGMT=m
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_CHARLCD=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=m
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
# CONFIG_GOLDFISH_BUS is not set
# CONFIG_GOLDFISH_PIPE is not set
# CONFIG_CHROME_PLATFORMS is not set
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_WM831X is not set
# CONFIG_CLK_HSDK is not set
# CONFIG_COMMON_CLK_MAX77686 is not set
# CONFIG_COMMON_CLK_RK808 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI514 is not set
# CONFIG_COMMON_CLK_SI570 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CDCE925 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_CLK_TWL6040 is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_COMMON_CLK_VC5 is not set
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_PLATFORM_MHU=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
CONFIG_MAILBOX_TEST=m
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=m
# CONFIG_RPMSG_CHAR is not set
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
CONFIG_RPMSG_VIRTIO=m
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#
# CONFIG_SOUNDWIRE_INTEL is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_MAX14577=y
# CONFIG_EXTCON_MAX77693 is not set
CONFIG_EXTCON_MAX77843=m
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_ATMEL_HLCDC_PWM is not set
# CONFIG_PWM_FSL_FTM is not set
# CONFIG_PWM_LP3943 is not set
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_TI_SYSCON is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=m
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_MAPPHONE_MDM6600 is not set
CONFIG_POWERCAP=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=m

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_RAS_CEC is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_DAX=y
CONFIG_DEV_DAX=m
# CONFIG_NVMEM is not set

#
# HW tracing support
#
CONFIG_STM=m
CONFIG_STM_DUMMY=m
# CONFIG_STM_SOURCE_CONSOLE is not set
CONFIG_STM_SOURCE_HEARTBEAT=m
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
# CONFIG_INTEL_TH_ACPI is not set
CONFIG_INTEL_TH_GTH=y
# CONFIG_INTEL_TH_STH is not set
CONFIG_INTEL_TH_MSU=y
# CONFIG_INTEL_TH_PTI is not set
CONFIG_INTEL_TH_DEBUG=y
# CONFIG_FPGA is not set
# CONFIG_FSI is not set
CONFIG_MULTIPLEXER=m

#
# Multiplexer drivers
#
CONFIG_MUX_ADG792A=m
# CONFIG_MUX_MMIO is not set
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=y
CONFIG_SIOX_BUS_GPIO=m
CONFIG_SLIMBUS=m
CONFIG_SLIM_QCOM_CTRL=m

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=m
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
CONFIG_OVERLAY_FS_INDEX=y
CONFIG_OVERLAY_FS_NFS_EXPORT=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
CONFIG_ECRYPT_FS=m
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_CRAMFS=m
CONFIG_PSTORE=y
# CONFIG_PSTORE_ZLIB_COMPRESS is not set
CONFIG_PSTORE_LZO_COMPRESS=y
# CONFIG_PSTORE_LZ4_COMPRESS is not set
# CONFIG_PSTORE_CONSOLE is not set
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_RAM is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
# CONFIG_NLS_UTF8 is not set
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
# CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT is not set
CONFIG_PAGE_POISONING=y
CONFIG_PAGE_POISONING_NO_SANITY=y
CONFIG_PAGE_POISONING_ZERO=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_ARCH_HAS_KCOV=y
CONFIG_KCOV=y
CONFIG_KCOV_ENABLE_COMPARISONS=y
CONFIG_KCOV_INSTRUMENT_ALL=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=m
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set
# CONFIG_UNWINDER_GUESS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
# CONFIG_PAGE_TABLE_ISOLATION is not set
# CONFIG_FORTIFY_SOURCE is not set
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
# CONFIG_CRYPTO_RSA is not set
# CONFIG_CRYPTO_DH is not set
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y
CONFIG_CRYPTO_ENGINE=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=m
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=m

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=m
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=m
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=m
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=m
CONFIG_CRYPTO_SHA256_MB=m
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=m
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_SPECK is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_842=m
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=m

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
CONFIG_CRYPTO_DEV_VIRTIO=m
# CONFIG_CRYPTO_DEV_CCREE is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC4=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=m
CONFIG_842_DECOMPRESS=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=m
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_DQL=y
CONFIG_NLATTR=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=m
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_PRIME_NUMBERS=m
# CONFIG_STRING_SELFTEST is not set

--fl6aawq5ck6ju622--
