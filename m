Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 72B726B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 06:55:11 -0500 (EST)
Message-ID: <50EFFD82.4030408@fold.natur.cuni.cz>
Date: Fri, 11 Jan 2013 12:54:42 +0100
From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
MIME-Version: 1.0
Subject: Re: linux-3.7.1: OOPS in page_lock_anon_vma
References: <50EA01BC.2080001@fold.natur.cuni.cz> <alpine.LNX.2.00.1301061616110.6198@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1301061616110.6198@eggly.anvils>
Content-Type: multipart/mixed;
 boundary="------------030202020108040804030806"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>

This is a multi-part message in MIME format.
--------------030202020108040804030806
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote:
> On Sun, 6 Jan 2013, Martin Mokrejs wrote:
> 
>> I was running 3.7.1 kernel quite fine for a while but I realized that it is slow and that
>> I should go and drop useless kernel drivers from my kernel. I have a SandyBridge-based
>> laptop and I found that I gain speed while setting CONFIG_NO_HZ=y, CONFIG_PREEMPT_NONE=y,
>> removing multicore scheduler, asking configurator set set maximum amount of CPUs for my
>> system (and not blindly specifying 4 for my dual-core i7 processor).
>> Further I get faster system while removing IOMMU and DMA redirects while it still
>> emulates NUMA. And, I switched away from CFQ scheduler to deadline and from SLAB to SLUB.
>> Finally, to make sure my CPU cores do not go back and forth between C0 and C7 states and
>> shutdown dynamically the 2 hyperthreaded cores. So I have really only two, physical cores
>> accessible. With performance CPU governor I have 1/2 of context switches and both cores
>> can be satured by whatever jobs (kernel compile or some computational jobs). It was not
>> possible to get the CPU running at turbo speed for a long while as it always went down
>> time to time. With ondemand governor I had cores in C7 for 50-70% of the time, that was
>> a bit better with performance governor but having the two hyperthreaded cores disabled
>> reduced the context switches by half, rescheduling interrupts went down by several orders
>> of magnitute. So it is crunching at max turbo speed on both cores, temp about 80 oC.
>>
>> I think none of the changes relates to the kernel crash directly but I had not a single crash
>> with 3.7.1 for few weeks. After the tweaks I had 3-4 crashes this afternoon. The system always
>> locked up so I could not see anything. Luckily, be it actually the same crash or not, now my X11
>> screen was dropped and to my framebuffer console and I got to see a kernel stacktrace. Here
>> is the first, fished out from /var/log/messages upon next bootup:
>>
>>
>> Jan  6 22:37:29 vostro kernel: [ 7663.251110] general protection fault: 0000 [#1] SMP
>> Jan  6 22:37:29 vostro kernel: [ 7663.251135] Modules linked in: i915 fbcon bitblit cfbfillrect softcursor cfbimgblt i2c_algo_bit font cfbcopyarea drm_kms_helper drm fb iwldvm iwlwifi fbdev sata_sil24
>> Jan  6 22:37:29 vostro kernel: [ 7663.251197] CPU 1 
>> Jan  6 22:37:29 vostro kernel: [ 7663.251206] Pid: 795, comm: kswapd0 Not tainted 3.7.1-default #22 Dell Inc. Vostro 3550/
>> Jan  6 22:37:29 vostro kernel: [ 7663.251229] RIP: 0010:[<ffffffff815d3dee>]  [<ffffffff815d3dee>] mutex_trylock+0xb/0x26
>> Jan  6 22:37:29 vostro kernel: [ 7663.251257] RSP: 0018:ffff88040d25bbb8  EFLAGS: 00010246
>> Jan  6 22:37:29 vostro kernel: [ 7663.251273] RAX: 0000000000000001 RBX: ffff88040bfdc000 RCX: ffff88040d25bce8
>> Jan  6 22:37:29 vostro kernel: [ 7663.251293] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0720072007200728
>> Jan  6 22:37:29 vostro kernel: [ 7663.251313] RBP: ffff88040d25bbb8 R08: dead000000200200 R09: dead000000100100
>> Jan  6 22:37:29 vostro kernel: [ 7663.251333] R10: ffff88040d25bc38 R11: ffff8804078acec0 R12: ffff88040bfdc001
>> Jan  6 22:37:29 vostro kernel: [ 7663.251354] R13: ffffea0010137440 R14: 0720072007200728 R15: 0000000000000001
>> Jan  6 22:37:29 vostro kernel: [ 7663.251374] FS:  0000000000000000(0000) GS:ffff88041fa80000(0000) knlGS:0000000000000000
>> Jan  6 22:37:29 vostro kernel: [ 7663.251396] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> Jan  6 22:37:29 vostro kernel: [ 7663.251413] CR2: 00002b876c545978 CR3: 00000000018f6000 CR4: 00000000000407e0
>> Jan  6 22:37:29 vostro kernel: [ 7663.251432] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> Jan  6 22:37:29 vostro kernel: [ 7663.251452] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Jan  6 22:37:29 vostro kernel: [ 7663.251472] Process kswapd0 (pid: 795, threadinfo ffff88040d25a000, task ffff88040d07ce30)
>> Jan  6 22:37:29 vostro kernel: [ 7663.251494] Stack:
>> Jan  6 22:37:29 vostro kernel: [ 7663.251501]  ffff88040d25bbe8 ffffffff810f6994 ffffea0010137440 0000000000000000
>> Jan  6 22:37:29 vostro kernel: [ 7663.251527]  ffff88040d25bde8 ffff88041fddad00 ffff88040d25bc58 ffffffff810f6b9e
>> Jan  6 22:37:29 vostro kernel: [ 7663.251551]  0000000000000000 ffff8804046d2dc0 00000000810dee97 ffff88040d25bce8
>> Jan  6 22:37:29 vostro kernel: [ 7663.251576] Call Trace:
>> Jan  6 22:37:29 vostro kernel: [ 7663.251587]  [<ffffffff810f6994>] page_lock_anon_vma+0x40/0xaf
>> Jan  6 22:37:29 vostro kernel: [ 7663.251605]  [<ffffffff810f6b9e>] page_referenced+0x78/0x1b7
>> Jan  6 22:37:29 vostro kernel: [ 7663.251623]  [<ffffffff810e026a>] shrink_active_list+0x209/0x305
>> Jan  6 22:37:29 vostro kernel: [ 7663.251641]  [<ffffffff810e1269>] kswapd+0x3fe/0x8ea
>> Jan  6 22:37:29 vostro kernel: [ 7663.251658]  [<ffffffff81091697>] ? wake_up_bit+0x25/0x25
>> Jan  6 22:37:29 vostro kernel: [ 7663.251675]  [<ffffffff810e0e6b>] ? try_to_free_pages+0x8c/0x8c
>> Jan  6 22:37:29 vostro kernel: [ 7663.251692]  [<ffffffff81091120>] kthread+0x90/0x98
>> Jan  6 22:37:29 vostro kernel: [ 7663.251707]  [<ffffffff81091090>] ? kthread_freezable_should_stop+0x3c/0x3c
>> Jan  6 22:37:29 vostro kernel: [ 7663.251727]  [<ffffffff815d5dec>] ret_from_fork+0x7c/0xb0
>> Jan  6 22:37:29 vostro kernel: [ 7663.251743]  [<ffffffff81091090>] ? kthread_freezable_should_stop+0x3c/0x3c
>> Jan  6 22:37:29 vostro kernel: [ 7663.251762] Code: 8d 53 08 c7 03 01 00 00 00 48 39 d0 74 09 48 8b 78 10 e8 a0 79 ac ff 66 83 43 04 01 5a 5b c9 c3 55 b8 01 00 00 00 48 89 e5 31 d2 <f0> 0f b1 17 ff c8 75 0f 65 48 8b 04 25 00 b8 00 00 b2 01 48 89 
>> Jan  6 22:37:29 vostro kernel: [ 7663.251898] RIP  [<ffffffff815d3dee>] mutex_trylock+0xb/0x26
>> Jan  6 22:37:29 vostro kernel: [ 7663.251916]  RSP <ffff88040d25bbb8>
>> Jan  6 22:37:29 vostro kernel: [ 7663.471083] ---[ end trace 15db67145b2c838a ]---
>> Jan  6 22:37:39 vostro kernel: [ 7672.954999] SysRq : Emergency Sync
>>
>>
>>
>> It seemed the kernel was still running, disk was doing some work and CPU fan was changing its speed.
>> I then pressed alt+sysrq+i and got (retyped from a camera picture which is attached as this one was
>> not in /var/log/messages):
>>
>> lock_anon_vma_root.clone
>> unlink_anon_vmas
>> free_pgtables
>> exit_mmap
>> mmput
>> exit_mm
>> do_exit
>> ? recalc_sigpending_tsk
>> do_group_exit
>> get_signal_to_deliver
>> do_signal
>> ? timespec_add_safe
>> ? __fput
>> do_notify_resume
>> int_signal
>>
>> But the system was dead, I had to turn off the power.
>>
>>
>> Any clues? What kernel .config item should I enable/disable to avoid it in the future? ;-)
>> Thank you,
>> Martin
> 
> One of your struct anon_vmas seems to have been overwritten with 0x0720s.
> I've no idea why.  But since you mention you've put SLUB in, best to take
> advantage of it by rebooting with slub_debug=AFPZ and see if that shows
> up anything interesting.

I can only add that since the changes to my .config (see attached diff) I did not get a crash
in last days. However, two kmemleaks were reported to me by kernel and although I passed them
to linux-pci and lkml I got no answer. Actually, have no idea if they could be related or not
to the issue or whether some of those debug or lock correctness options fixed that inadverently.
Why had there CPUS=4096 in the past and CONFIG_SPLIT_PTLOCK_CPUS=999999 at the moment I do not know.
Looks silly on a dual-core i7 laptop.

Martin

--------------030202020108040804030806
Content-Type: text/plain; charset=us-ascii;
 name=".config.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename=".config.diff"

LS0tIC90bXAvLmNvbmZpZy1iYWQJMjAxMy0wMS0xMSAxMjo0NzowNS4wMDAwMDAwMDAgKzAx
MDAKKysrIC90bXAvLmNvbmZpZy1nb29kCTIwMTMtMDEtMTEgMTI6NDk6NTEuMDAwMDAwMDAw
ICswMTAwCkBAIC0xOTQsMTIgKzE5NCw3IEBACiBDT05GSUdfREVGQVVMVF9JT1NDSEVEPSJk
ZWFkbGluZSIKIENPTkZJR19QQURBVEE9eQogQ09ORklHX0FTTjE9eQotQ09ORklHX0lOTElO
RV9TUElOX1VOTE9DS19JUlE9eQotQ09ORklHX0lOTElORV9SRUFEX1VOTE9DSz15Ci1DT05G
SUdfSU5MSU5FX1JFQURfVU5MT0NLX0lSUT15Ci1DT05GSUdfSU5MSU5FX1dSSVRFX1VOTE9D
Sz15Ci1DT05GSUdfSU5MSU5FX1dSSVRFX1VOTE9DS19JUlE9eQotQ09ORklHX01VVEVYX1NQ
SU5fT05fT1dORVI9eQorQ09ORklHX1VOSU5MSU5FX1NQSU5fVU5MT0NLPXkKIENPTkZJR19G
UkVFWkVSPXkKIAogQ09ORklHX1pPTkVfRE1BPXkKQEAgLTIzOCw3ICsyMzMsNiBAQAogQ09O
RklHX1g4Nl9NQ0VfSU5URUw9eQogQ09ORklHX1g4Nl9NQ0VfVEhSRVNIT0xEPXkKIENPTkZJ
R19YODZfVEhFUk1BTF9WRUNUT1I9eQotQ09ORklHX0k4Sz15CiBDT05GSUdfTUlDUk9DT0RF
PXkKIENPTkZJR19NSUNST0NPREVfSU5URUw9eQogQ09ORklHX01JQ1JPQ09ERV9PTERfSU5U
RVJGQUNFPXkKQEAgLTI2OSw3ICsyNjMsNyBAQAogQ09ORklHX0hBVkVfTUVNQkxPQ0tfTk9E
RV9NQVA9eQogQ09ORklHX0FSQ0hfRElTQ0FSRF9NRU1CTE9DSz15CiBDT05GSUdfUEFHRUZM
QUdTX0VYVEVOREVEPXkKLUNPTkZJR19TUExJVF9QVExPQ0tfQ1BVUz00CitDT05GSUdfU1BM
SVRfUFRMT0NLX0NQVVM9OTk5OTk5CiBDT05GSUdfQ09NUEFDVElPTj15CiBDT05GSUdfTUlH
UkFUSU9OPXkKIENPTkZJR19QSFlTX0FERFJfVF82NEJJVD15CkBAIC0yNzgsOCArMjcyLDYg
QEAKIENPTkZJR19WSVJUX1RPX0JVUz15CiBDT05GSUdfREVGQVVMVF9NTUFQX01JTl9BRERS
PTQwOTYKIENPTkZJR19BUkNIX1NVUFBPUlRTX01FTU9SWV9GQUlMVVJFPXkKLUNPTkZJR19U
UkFOU1BBUkVOVF9IVUdFUEFHRT15Ci1DT05GSUdfVFJBTlNQQVJFTlRfSFVHRVBBR0VfTUFE
VklTRT15CiBDT05GSUdfQ0xFQU5DQUNIRT15CiBDT05GSUdfRlJPTlRTV0FQPXkKIENPTkZJ
R19YODZfUkVTRVJWRV9MT1c9NjQKQEAgLTU1OCw3ICs1NTAsNiBAQAogQ09ORklHX0NCNzEw
X0RFQlVHX0FTU1VNUFRJT05TPXkKIAogCi1DT05GSUdfSU5URUxfTUVJPXkKIENPTkZJR19I
QVZFX0lERT15CiAKIENPTkZJR19TQ1NJX01PRD15CkBAIC05MDIsOSArODkzLDEzIEBACiBD
T05GSUdfQ0hBUkdFUl9HUElPPW0KIENPTkZJR19DSEFSR0VSX1NNQjM0Nz1tCiBDT05GSUdf
SFdNT049eQorQ09ORklHX0hXTU9OX1ZJRD1tCiBDT05GSUdfSFdNT05fREVCVUdfQ0hJUD15
CiAKK0NPTkZJR19TRU5TT1JTX0dQSU9fRkFOPW0KIENPTkZJR19TRU5TT1JTX0NPUkVURU1Q
PXkKK0NPTkZJR19TRU5TT1JTX0lUODc9bQorQ09ORklHX1NFTlNPUlNfSkM0Mj1tCiBDT05G
SUdfU0VOU09SU19MVEM0MjE1PW0KIAogQ09ORklHX1NFTlNPUlNfQUNQSV9QT1dFUj1tCkBA
IC0xNDkwLDIyICsxNDg1LDMyIEBACiBDT05GSUdfRlJBTUVfV0FSTj0yMDQ4CiBDT05GSUdf
TUFHSUNfU1lTUlE9eQogQ09ORklHX0RFQlVHX0ZTPXkKK0NPTkZJR19IRUFERVJTX0NIRUNL
PXkKIENPTkZJR19ERUJVR19LRVJORUw9eQogQ09ORklHX0RFQlVHX1NISVJRPXkKIENPTkZJ
R19MT0NLVVBfREVURUNUT1I9eQogQ09ORklHX0hBUkRMT0NLVVBfREVURUNUT1I9eQotQ09O
RklHX0JPT1RQQVJBTV9IQVJETE9DS1VQX1BBTklDPXkKLUNPTkZJR19CT09UUEFSQU1fSEFS
RExPQ0tVUF9QQU5JQ19WQUxVRT0xCi1DT05GSUdfQk9PVFBBUkFNX1NPRlRMT0NLVVBfUEFO
SUM9eQotQ09ORklHX0JPT1RQQVJBTV9TT0ZUTE9DS1VQX1BBTklDX1ZBTFVFPTEKK0NPTkZJ
R19CT09UUEFSQU1fSEFSRExPQ0tVUF9QQU5JQ19WQUxVRT0wCitDT05GSUdfQk9PVFBBUkFN
X1NPRlRMT0NLVVBfUEFOSUNfVkFMVUU9MAogQ09ORklHX1BBTklDX09OX09PUFNfVkFMVUU9
MAogQ09ORklHX0RFVEVDVF9IVU5HX1RBU0s9eQogQ09ORklHX0RFRkFVTFRfSFVOR19UQVNL
X1RJTUVPVVQ9MTIwCi1DT05GSUdfQk9PVFBBUkFNX0hVTkdfVEFTS19QQU5JQz15Ci1DT05G
SUdfQk9PVFBBUkFNX0hVTkdfVEFTS19QQU5JQ19WQUxVRT0xCitDT05GSUdfQk9PVFBBUkFN
X0hVTkdfVEFTS19QQU5JQ19WQUxVRT0wCiBDT05GSUdfU0NIRURfREVCVUc9eQogQ09ORklH
X1NDSEVEU1RBVFM9eQorQ09ORklHX1NMVUJfREVCVUdfT049eQogQ09ORklHX0hBVkVfREVC
VUdfS01FTUxFQUs9eQorQ09ORklHX0RFQlVHX0tNRU1MRUFLPXkKK0NPTkZJR19ERUJVR19L
TUVNTEVBS19FQVJMWV9MT0dfU0laRT00MDAKK0NPTkZJR19ERUJVR19SVF9NVVRFWEVTPXkK
K0NPTkZJR19ERUJVR19QSV9MSVNUPXkKK0NPTkZJR19ERUJVR19TUElOTE9DSz15CitDT05G
SUdfREVCVUdfTVVURVhFUz15CitDT05GSUdfREVCVUdfTE9DS19BTExPQz15CitDT05GSUdf
UFJPVkVfTE9DS0lORz15CitDT05GSUdfTE9DS0RFUD15CitDT05GSUdfVFJBQ0VfSVJRRkxB
R1M9eQorQ09ORklHX1NUQUNLVFJBQ0U9eQogQ09ORklHX0RFQlVHX0JVR1ZFUkJPU0U9eQog
Q09ORklHX0RFQlVHX0lORk89eQogQ09ORklHX0RFQlVHX01FTU9SWV9JTklUPXkKQEAgLTE1
MzYsNiArMTU0MSw3IEBACiBDT05GSUdfREVGQVVMVF9JT19ERUxBWV9UWVBFPTAKIENPTkZJ
R19ERUJVR19CT09UX1BBUkFNUz15CiBDT05GSUdfT1BUSU1JWkVfSU5MSU5JTkc9eQorQ09O
RklHX0RFQlVHX1NUUklDVF9VU0VSX0NPUFlfQ0hFQ0tTPXkKIAogQ09ORklHX0tFWVM9eQog
Q09ORklHX1NFQ1VSSVRZRlM9eQo=
--------------030202020108040804030806--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
