Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4C88782F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 17:37:43 -0500 (EST)
Received: by pasz6 with SMTP id z6so139597126pas.2
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 14:37:43 -0800 (PST)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com. [209.85.220.51])
        by mx.google.com with ESMTPS id kz9si2994279pbc.150.2015.11.06.14.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 14:37:41 -0800 (PST)
Received: by padhx2 with SMTP id hx2so127230571pad.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 14:37:41 -0800 (PST)
From: Kevin Hilman <khilman@kernel.org>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<20151105094615.GP8644@n2100.arm.linux.org.uk>
	<563B81DA.2080409@redhat.com>
	<20151105162719.GQ8644@n2100.arm.linux.org.uk>
	<563BFCC4.8050705@redhat.com>
	<CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
	<563CF510.9080506@redhat.com>
	<CAGXu5jKLgL0Kt5xCWv-3ZUX94m1DNXLqsEDQKHoq7T=m6P7tvQ@mail.gmail.com>
	<CAGXu5j+Jeg-Cwc7Tr8UeY9vkJLudw07+b=m0h-d9GuSyKiO4QA@mail.gmail.com>
	<CAMAWPa9XvdS+dF78c7Fgs4ekRy7wVnfFT=0A5NLpu0UYaqV7fA@mail.gmail.com>
	<CAGXu5j+U-Q2R1Hw4qSPpFUKz3xyYrASGc5buMJTSy0K-3mWHBA@mail.gmail.com>
	<7h8u6ahm7d.fsf@deeprootsystems.com>
	<CAGXu5jJnjHkkX3y31y5LJFhNrP=A8_BASg2MUR5rwA5MLPeVQg@mail.gmail.com>
Date: Fri, 06 Nov 2015 14:37:38 -0800
In-Reply-To: <CAGXu5jJnjHkkX3y31y5LJFhNrP=A8_BASg2MUR5rwA5MLPeVQg@mail.gmail.com>
	(Kees Cook's message of "Fri, 6 Nov 2015 13:19:46 -0800")
Message-ID: <7hmvuqg3f1.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: info@kernelci.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Tyler Baker <tyler.baker@linaro.org>

Kees Cook <keescook@chromium.org> writes:

> On Fri, Nov 6, 2015 at 1:06 PM, Kevin Hilman <khilman@kernel.org> wrote:

[...]

> Well, all the stuff I wrote tests for in lkdtm expect the kernel to
> entirely Oops, and examining the Oops from outside is needed to verify
> it was the correct type of Oops. I don't think testing via lkdtm can
> be done from kselftest sensibly.

Well, at least on arm32, it's definitely oops'ing, but it's not a full
panic, so the oops could be grabbed from dmesg.

FWIW, below is a log from and arm32 board running mainline v4.3 that
runs through all the non-panic/lockup tests one after the other without
a reboot.

Kevin



/ # cat test.sh
#!/bin/sh

crash_test_dummy() {
  echo $1> /sys/kernel/debug/provoke-crash/DIRECT
}

# Find all the tests that don't lockup
TESTS=$(cat /sys/kernel/debug/provoke-crash/DIRECT |grep -v types| grep -v LOCK |grep -v PANIC)

for test in $TESTS; do
  echo "Performing test: $test"
  crash_test_dummy $test &
  sleep 1
done

/ # sh test.sh
Performing test: BUG
[ 1010.764560] lkdtm: Performing direct entry BUG
[ 1010.764715] ------------[ cut here ]------------
[ 1010.767920] kernel BUG at ../drivers/misc/lkdtm.c:373!
[ 1010.772695] Internal error: Oops - BUG: 0 [#3] SMP ARM
[ 1010.777638] Modules linked in:
[ 1010.785800] CPU: 3 PID: 140 Comm: sh Tainted: G      D         4.3.0 #3
[ 1010.785884] Hardware name: Qualcomm (Flattened Device Tree)
[ 1010.792318] task: ede204c0 ti: edec8000 task.ti: edec8000
[ 1010.797890] PC is at lkdtm_do_action+0x148/0x3c0
[ 1010.803426] LR is at direct_entry+0x118/0x158
[ 1010.808113] pc : [<c06554d0>]    lr : [<c0655860>]    psr: 80000013
[ 1010.808113] sp : edec9e90  ip : 00000000  fp : 00000000
[ 1010.812372] r10: 00000000  r9 : edec8000  r8 : edec9f88
[ 1010.823647] r7 : 00000004  r6 : ede81000  r5 : c0ab0dd8  r4 : 00000002
[ 1010.828860] r3 : c0ea6e94  r2 : 2d931000  r1 : ee7d7374  r0 : 00000001
[ 1010.835460] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1010.841969] Control: 10c5787d  Table: ade6806a  DAC: 00000051
[ 1010.849171] Process sh (pid: 140, stack limit = 0xedec8220)
[ 1010.854901] Stack: (0xedec9e90 to 0xedeca000)
[ 1010.860297] 9e80:                                     ede81000 00000002 c0ab0dd8 ede81000
[ 1010.864832] 9ea0: 00000004 edec9f88 edec8000 00000000 00000000 c028b47c c0cb9620 edec9edc
[ 1010.872989] 9ec0: c0655748 c02cccc8 ede81000 edec9edc c0ab0dd8 c0655858 00000002 c0ab0dd8
[ 1010.881151] 9ee0: ede81000 c0655860 edd7a240 c0655748 000b91f8 edec9f88 c0210c04 c030ef0c
[ 1010.889310] 9f00: 00000000 000b8b64 00000000 c020a34c 00000000 edec9f18 00000000 00000009
[ 1010.897470] 9f20: 0000000a ed8d1d00 ede204b8 edec9f60 ede204c0 c024daa4 00000000 ede20710
[ 1010.905630] 9f40: 00000001 00000000 be976b68 edd7a240 00000004 000b91f8 edec9f88 c0210c04
[ 1010.913789] 9f60: edec8000 c030f754 00000000 00000000 edd7a240 edd7a240 000b91f8 00000004
[ 1010.921948] 9f80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b91f8
[ 1010.930109] 9fa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b91f8 00000004 00000000
[ 1010.938267] 9fc0: 000b6a08 00000001 000b91f8 00000004 00000020 000b8e80 000b8b64 00000000
[ 1010.946428] 9fe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 edffdf6f ffff7f3d
[ 1010.954591] [<c06554d0>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1010.962739] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1010.970546] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1010.978181] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1010.985309] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1010.992598] Code: eaffffe8 e309054c e34c00cb ebf1dd4c (e7f001f2) 
[ 1010.999973] ---[ end trace 97ee148ea17cdd7c ]---
Performing test: WARNING
[ 1011.774195] lkdtm: Performing direct entry WARNING
[ 1011.774238] ------------[ cut here ]------------
[ 1011.777939] WARNING: CPU: 2 PID: 142 at ../drivers/misc/lkdtm.c:376 lkdtm_do_action+0x15c/0x3c0()
[ 1011.782776] Modules linked in:
[ 1011.794476] CPU: 2 PID: 142 Comm: sh Tainted: G      D         4.3.0 #3
[ 1011.794514] Hardware name: Qualcomm (Flattened Device Tree)
[ 1011.801053] [<c0219058>] (unwind_backtrace) from [<c0214754>] (show_stack+0x10/0x14)
[ 1011.806593] [<c0214754>] (show_stack) from [<c048565c>] (dump_stack+0x84/0x94)
[ 1011.814555] [<c048565c>] (dump_stack) from [<c024ab58>] (warn_slowpath_common+0x80/0xb0)
[ 1011.821596] [<c024ab58>] (warn_slowpath_common) from [<c024ac24>] (warn_slowpath_null+0x1c/0x24)
[ 1011.829831] [<c024ac24>] (warn_slowpath_null) from [<c06554e4>] (lkdtm_do_action+0x15c/0x3c0)
[ 1011.838588] [<c06554e4>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1011.847008] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1011.854822] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1011.862477] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1011.869598] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1011.876869] ---[ end trace 97ee148ea17cdd7d ]---
Performing test: EXCEPTION
[ 1012.784912] lkdtm: Performing direct entry EXCEPTION
[ 1012.784963] Unable to handle kernel NULL pointer dereference at virtual address 00000000
[ 1012.789901] pgd = edee8000
[ 1012.797925] [00000000] *pgd=fb044835
[ 1012.803766] Internal error: Oops: 817 [#4] SMP ARM
[ 1012.804030] Modules linked in:
[ 1012.811753] CPU: 0 PID: 144 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1012.811839] Hardware name: Qualcomm (Flattened Device Tree)
[ 1012.818267] task: ede497c0 ti: ede14000 task.ti: ede14000
[ 1012.823832] PC is at lkdtm_do_action+0x164/0x3c0
[ 1012.829380] LR is at direct_entry+0x118/0x158
[ 1012.834065] pc : [<c06554ec>]    lr : [<c0655860>]    psr: 80000013
[ 1012.834065] sp : ede15e90  ip : 00000000  fp : 00000000
[ 1012.838327] r10: 00000000  r9 : ede14000  r8 : ede15f88
[ 1012.849603] r7 : 0000000a  r6 : edfcc000  r5 : c0ab0de0  r4 : 00000004
[ 1012.854813] r3 : 00000000  r2 : 2d90d000  r1 : ee7b3374  r0 : 00000003
[ 1012.861414] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1012.867922] Control: 10c5787d  Table: adee806a  DAC: 00000051
[ 1012.875125] Process sh (pid: 144, stack limit = 0xede14220)
[ 1012.880857] Stack: (0xede15e90 to 0xede16000)
[ 1012.886246] 5e80:                                     edfcc000 00000004 c0ab0de0 edfcc000
[ 1012.890777] 5ea0: 0000000a ede15f88 ede14000 00000000 00000000 c028b47c c0cb9620 ede15edc
[ 1012.898934] 5ec0: c0655748 c02cccc8 edfcc000 ede15edc c0ab0de0 c0655858 00000004 c0ab0de0
[ 1012.907095] 5ee0: edfcc000 c0655860 edef6a80 c0655748 000b8c20 ede15f88 c0210c04 c030ef0c
[ 1012.915257] 5f00: 00000000 000b8b64 00000000 c020a34c 00000000 ede15f18 20000013 ffffffff
[ 1012.923415] 5f20: 0000000a edd5b600 ede497b8 ede15f60 ede497c0 c024daa4 00000000 ede49a10
[ 1012.931573] 5f40: 00000001 00000000 be976b68 edef6a80 0000000a 000b8c20 ede15f88 c0210c04
[ 1012.939734] 5f60: ede14000 c030f754 00000000 00000000 edef6a80 edef6a80 000b8c20 0000000a
[ 1012.947894] 5f80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b8c20
[ 1012.956055] 5fa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b8c20 0000000a 00000000
[ 1012.964213] 5fc0: 000b6a08 00000001 000b8c20 00000004 00000020 000b8e90 000b8b64 00000000
[ 1012.972372] 5fe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 67fde9cf d575ffaf
[ 1012.980528] [<c06554ec>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1012.988686] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1012.996494] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1013.004127] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1013.011254] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1013.018548] Code: e34c00cb ebefd5c8 eaffffdf e3a03000 (e5833000) 
[ 1013.026049] ---[ end trace 97ee148ea17cdd7e ]---
Performing test: LOOP
[ 1013.797951] lkdtm: Performing direct entry LOOP
Performing test: OVERFLOW
[ 1014.808793] lkdtm: Performing direct entry OVERFLOW
Performing test: CORRUPT_STACK
[ 1015.817949] lkdtm: Performing direct entry CORRUPT_STACK
[ 1015.818247] Unable to handle kernel NULL pointer dereference at virtual address 00000000
[ 1015.823885] pgd = edee8000
[ 1015.831938] [00000000] *pgd=fb0c5835
[ 1015.837772] Internal error: Oops: 80000007 [#5] SMP ARM
[ 1015.838027] Modules linked in:
[ 1015.846189] CPU: 0 PID: 150 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1015.846272] Hardware name: Qualcomm (Flattened Device Tree)
[ 1015.852701] task: ede4af80 ti: edea0000 task.ti: edea0000
[ 1015.858258] PC is at 0x0
[ 1015.863807] LR is at 0x0
[ 1015.866413] pc : [<00000000>]    lr : [<00000000>]    psr: 60000013
[ 1015.866413] sp : edea1e90  ip : 00000000  fp : 00000000
[ 1015.868938] r10: 00000000  r9 : edea0000  r8 : edea1f88
[ 1015.880130] r7 : 0000000e  r6 : edfcc000  r5 : c0ab0dec  r4 : 00000007
[ 1015.885340] r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : edea1ec0
[ 1015.891941] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1015.898451] Control: 10c5787d  Table: adee806a  DAC: 00000051
[ 1015.905652] Process sh (pid: 150, stack limit = 0xedea0220)
[ 1015.911381] Stack: (0xedea1e90 to 0xedea2000)
[ 1015.916772] 1e80:                                     00000000 00000000 00000000 00000000
[ 1015.921302] 1ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 1015.929462] 1ec0: c0655748 c02cccc8 edfcc000 edea1edc c0ab0dec c0655858 00000007 c0ab0dec
[ 1015.937622] 1ee0: edfcc000 c0655860 edef6300 c0655748 000b9030 edea1f88 c0210c04 c030ef0c
[ 1015.945782] 1f00: 00000000 000b8b64 00000000 c020a34c 00000000 edea1f18 20000013 ffffffff
[ 1015.953941] 1f20: 0000000a edd5bb00 ede4af78 edea1f60 ede4af80 c024daa4 00000000 ede4b1d0
[ 1015.962100] 1f40: 00000001 00000000 be976b68 edef6300 0000000e 000b9030 edea1f88 c0210c04
[ 1015.970259] 1f60: edea0000 c030f754 00000000 00000000 edef6300 edef6300 000b9030 0000000e
[ 1015.978418] 1f80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b9030
[ 1015.986580] 1fa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b9030 0000000e 00000000
[ 1015.994738] 1fc0: 000b6a08 00000001 000b9030 00000004 00000020 000b8e90 000b8b64 00000000
[ 1016.002899] 1fe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 dfefe9ff f859ffdc
[ 1016.011045] Code: bad PC value
[ 1016.019311] ---[ end trace 97ee148ea17cdd7f ]---
Performing test: UNALIGNED_LOAD_STORE_WRITE
[ 1016.830310] lkdtm: Performing direct entry UNALIGNED_LOAD_STORE_WRITE
Performing test: OVERWRITE_ALLOCATION
[ 1017.840276] lkdtm: Performing direct entry OVERWRITE_ALLOCATION
Performing test: WRITE_AFTER_FREE
[ 1018.850276] lkdtm: Performing direct entry WRITE_AFTER_FREE
Performing test: HUNG_TASK
[ 1019.860308] lkdtm: Performing direct entry HUNG_TASK
Performing test: EXEC_DATA
[ 1020.870248] lkdtm: Performing direct entry EXEC_DATA
[ 1020.870298] lkdtm: attempting ok execution at c0655294
[ 1020.875446] lkdtm: attempting bad execution at c0fdc084
[ 1020.880390] Unable to handle kernel paging request at virtual address c0fdc084
[ 1020.885431] pgd = ede1c000
[ 1020.892715] [c0fdc084] *pgd=80e1140e(bad)
[ 1020.899400] Internal error: Oops: 8000000d [#6] SMP ARM
[ 1020.899490] Modules linked in:
[ 1020.907647] CPU: 0 PID: 160 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1020.907734] Hardware name: Qualcomm (Flattened Device Tree)
[ 1020.914160] task: ede4df00 ti: edee2000 task.ti: edee2000
[ 1020.919720] PC is at 0xc0fdc084
[ 1020.925289] LR is at lkdtm_do_action+0x260/0x3c0
[ 1020.928221] pc : [<c0fdc084>]    lr : [<c06555e8>]    psr: 60000013
[ 1020.928221] sp : edee3e90  ip : 00000000  fp : 00000000
[ 1020.933095] r10: 00000000  r9 : edee2000  r8 : edee3f88
[ 1020.944280] r7 : 0000000a  r6 : edfcc000  r5 : c0ab0e0c  r4 : 0000000f
[ 1020.949494] r3 : c0fdc084  r2 : c0ee2840  r1 : 60000013  r0 : 0000002b
[ 1020.956094] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1020.962602] Control: 10c5787d  Table: ade1c06a  DAC: 00000051
[ 1020.969804] Process sh (pid: 160, stack limit = 0xedee2220)
[ 1020.975532] Stack: (0xedee3e90 to 0xedee4000)
[ 1020.980923] 3e80:                                     edfcc000 0000000f c0ab0e0c edfcc000
[ 1020.985456] 3ea0: 0000000a edee3f88 edee2000 00000000 00000000 c028b47c c0cb9620 edee3edc
[ 1020.993614] 3ec0: c0655748 c02cccc8 edfcc000 edee3edc c0ab0e0c c0655858 0000000f c0ab0e0c
[ 1021.001774] 3ee0: edfcc000 c0655860 edef6240 c0655748 000b9018 edee3f88 c0210c04 c030ef0c
[ 1021.009935] 3f00: 00000000 000b8b64 00000000 c020a34c 00000000 edee3f18 20000013 ffffffff
[ 1021.018094] 3f20: 0000000a edd5b900 ede4def8 edee3f60 ede4df00 c024daa4 00000000 ede4e150
[ 1021.026254] 3f40: 00000001 00000000 be976b68 edef6240 0000000a 000b9018 edee3f88 c0210c04
[ 1021.034413] 3f60: edee2000 c030f754 00000000 00000000 edef6240 edef6240 000b9018 0000000a
[ 1021.042574] 3f80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b9018
[ 1021.050731] 3fa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b9018 0000000a 00000000
[ 1021.058891] 3fc0: 000b6a08 00000001 000b9018 00000004 00000020 000b8e90 000b8b64 00000000
[ 1021.067052] 3fe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 af7fd861 af7fdc61
[ 1021.075217] [<c06555e8>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1021.083367] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1021.091173] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1021.098807] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1021.105936] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1021.113227] Code: 00000000 00010001 ed012000 00000000 (e12fff1e) 
[ 1021.120589] ---[ end trace 97ee148ea17cdd80 ]---
Performing test: EXEC_STACK
[ 1021.879876] lkdtm: Performing direct entry EXEC_STACK
[ 1021.880043] lkdtm: attempting ok execution at c0655294
[ 1021.885074] lkdtm: attempting bad execution at ede8fe98
[ 1021.890110] Unable to handle kernel paging request at virtual address ede8fe98
[ 1021.895149] pgd = ede1c000
[ 1021.902434] [ede8fe98] *pgd=ade1141e(bad)
[ 1021.909118] Internal error: Oops: 8000000d [#7] SMP ARM
[ 1021.909208] Modules linked in:
[ 1021.917365] CPU: 0 PID: 162 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1021.917454] Hardware name: Qualcomm (Flattened Device Tree)
[ 1021.923879] task: ede4e880 ti: ede8e000 task.ti: ede8e000
[ 1021.929439] PC is at 0xede8fe98
[ 1021.934996] LR is at lkdtm_do_action+0x26c/0x3c0
[ 1021.937939] pc : [<ede8fe98>]    lr : [<c06555f4>]    psr: 60000013
[ 1021.937939] sp : ede8fe90  ip : 00000000  fp : 00000000
[ 1021.942814] r10: 00000000  r9 : ede8e000  r8 : ede8ff88
[ 1021.954000] r7 : 0000000b  r6 : edfcc000  r5 : c0ab0e10  r4 : 00000010
[ 1021.959211] r3 : ede8fe98  r2 : c0ee2840  r1 : 60000013  r0 : 0000002b
[ 1021.965811] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1021.972323] Control: 10c5787d  Table: ade1c06a  DAC: 00000051
[ 1021.979523] Process sh (pid: 162, stack limit = 0xede8e220)
[ 1021.985254] Stack: (0xede8fe90 to 0xede90000)
[ 1021.990641] fe80:                                     edfcc000 00000010 e12fff1e e3a00000
[ 1021.995173] fea0: e12fff1e e30904c8 e34c00cb eaf1de7a e52de004 e24dd00c e3a01040 e1a0000d
[ 1022.003335] fec0: ebf8bd87 e28dd00c e49df004 e92d4010 e1a04000 e24ddc02 00000010 c0ab0e10
[ 1022.011495] fee0: edfcc000 c0655860 edfbb6c0 c0655748 000b8c38 ede8ff88 c0210c04 c030ef0c
[ 1022.019654] ff00: 00000000 000b8b64 00000000 c020a34c 00000000 ede8ff18 20000013 ffffffff
[ 1022.027813] ff20: 0000000a edd5b600 ede4e878 ede8ff60 ede4e880 c024daa4 00000000 ede4ead0
[ 1022.035974] ff40: 00000001 00000000 be976b68 edfbb6c0 0000000b 000b8c38 ede8ff88 c0210c04
[ 1022.044131] ff60: ede8e000 c030f754 00000000 00000000 edfbb6c0 edfbb6c0 000b8c38 0000000b
[ 1022.052292] ff80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b8c38
[ 1022.060451] ffa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b8c38 0000000b 00000000
[ 1022.068611] ffc0: 000b6a08 00000001 000b8c38 00000004 00000020 000b8e90 000b8b64 00000000
[ 1022.076771] ffe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 af7fd861 af7fdc61
[ 1022.084927] [<c06555f4>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1022.093081] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1022.100892] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1022.108527] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1022.115653] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1022.122945] Code: 00000051 c06555f4 edfcc000 00000010 (e12fff1e) 
[ 1022.130307] ---[ end trace 97ee148ea17cdd81 ]---
Performing test: EXEC_KMALLOC
[ 1022.888138] lkdtm: Performing direct entry EXEC_KMALLOC
[ 1022.888452] lkdtm: attempting ok execution at c0655294
[ 1022.893675] lkdtm: attempting bad execution at edf06c00
[ 1022.898853] Unable to handle kernel paging request at virtual address edf06c00
[ 1022.903901] pgd = ede68000
[ 1022.911185] [edf06c00] *pgd=ade1141e(bad)
[ 1022.917867] Internal error: Oops: 8000000d [#8] SMP ARM
[ 1022.917959] Modules linked in:
[ 1022.926118] CPU: 0 PID: 164 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1022.926204] Hardware name: Qualcomm (Flattened Device Tree)
[ 1022.932632] task: ede4f200 ti: c303e000 task.ti: c303e000
[ 1022.938192] PC is at 0xedf06c00
[ 1022.943751] LR is at lkdtm_do_action+0x28c/0x3c0
[ 1022.946695] pc : [<edf06c00>]    lr : [<c0655614>]    psr: 60000013
[ 1022.946695] sp : c303fe90  ip : 00000000  fp : 00000000
[ 1022.951564] r10: 00000000  r9 : c303e000  r8 : c303ff88
[ 1022.962751] r7 : 0000000d  r6 : ede7e000  r5 : c0ab0e14  r4 : edf06c00
[ 1022.967962] r3 : edf06c00  r2 : c0ee2840  r1 : 60000013  r0 : 0000002b
[ 1022.974563] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1022.981073] Control: 10c5787d  Table: ade6806a  DAC: 00000051
[ 1022.988273] Process sh (pid: 164, stack limit = 0xc303e220)
[ 1022.994001] Stack: (0xc303fe90 to 0xc3040000)
[ 1022.999394] fe80:                                     ede7e000 00000011 c0ab0e14 ede7e000
[ 1023.003925] fea0: 0000000d c303ff88 c303e000 00000000 00000000 c028b47c c0cb9620 c303fedc
[ 1023.012086] fec0: c0655748 c02cccc8 ede7e000 c303fedc c0ab0e14 c0655858 00000011 c0ab0e14
[ 1023.020246] fee0: ede7e000 c0655860 edfbb900 c0655748 000b9018 c303ff88 c0210c04 c030ef0c
[ 1023.028404] ff00: 00000000 000b8b64 00000000 c020a34c 00000000 c303ff18 20000013 ffffffff
[ 1023.036565] ff20: 0000000a edd5b500 ede4f1f8 c303ff60 ede4f200 c024daa4 00000000 ede4f450
[ 1023.044724] ff40: 00000001 00000000 be976b68 edfbb900 0000000d 000b9018 c303ff88 c0210c04
[ 1023.052882] ff60: c303e000 c030f754 00000000 00000000 edfbb900 edfbb900 000b9018 0000000d
[ 1023.061044] ff80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b9018
[ 1023.069203] ffa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b9018 0000000d 00000000
[ 1023.077362] ffc0: 000b6a08 00000001 000b9018 00000004 00000020 000b8e90 000b8b64 00000000
[ 1023.085521] ffe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 af7fd861 af7fdc61
[ 1023.093680] [<c0655614>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1023.101833] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1023.109641] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1023.117276] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1023.124402] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1023.131699] Code: f7ff7df9 adf5ff77 7dff7fcf f23eccad (e12fff1e) 
[ 1023.139058] ---[ end trace 97ee148ea17cdd82 ]---
Performing test: EXEC_VMALLOC
[ 1023.898810] lkdtm: Performing direct entry EXEC_VMALLOC
[ 1023.899173] lkdtm: attempting ok execution at c0655294
[ 1023.904301] lkdtm: attempting bad execution at f00bb000
[ 1023.909493] Unable to handle kernel paging request at virtual address f00bb000
[ 1023.914611] pgd = ede68000
[ 1023.921877] [f00bb000] *pgd=ad806811, *pte=adf3a65f, *ppte=adf3a45f
[ 1023.930503] Internal error: Oops: 8000000f [#9] SMP ARM
[ 1023.930850] Modules linked in:
[ 1023.939009] CPU: 0 PID: 166 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1023.939099] Hardware name: Qualcomm (Flattened Device Tree)
[ 1023.945525] task: ede484c0 ti: ede1e000 task.ti: ede1e000
[ 1023.951082] PC is at 0xf00bb000
[ 1023.956646] LR is at lkdtm_do_action+0x2a8/0x3c0
[ 1023.959583] pc : [<f00bb000>]    lr : [<c0655630>]    psr: 60000013
[ 1023.959583] sp : ede1fe90  ip : 00000000  fp : 00000000
[ 1023.964457] r10: 00000000  r9 : ede1e000  r8 : ede1ff88
[ 1023.975647] r7 : 0000000d  r6 : edf3a000  r5 : c0ab0e18  r4 : f00bb000
[ 1023.980856] r3 : f00bb000  r2 : c0ee2840  r1 : 60000013  r0 : 0000002b
[ 1023.987455] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1023.993967] Control: 10c5787d  Table: ade6806a  DAC: 00000051
[ 1024.001167] Process sh (pid: 166, stack limit = 0xede1e220)
[ 1024.006895] Stack: (0xede1fe90 to 0xede20000)
[ 1024.012288] fe80:                                     edf3a000 00000012 c0ab0e18 edf3a000
[ 1024.016818] fea0: 0000000d ede1ff88 ede1e000 00000000 00000000 c028b47c c0cb9620 ede1fedc
[ 1024.024978] fec0: c0655748 c02cccc8 edf3a000 ede1fedc c0ab0e18 c0655858 00000012 c0ab0e18
[ 1024.033139] fee0: edf3a000 c0655860 edfbba80 c0655748 000b8c38 ede1ff88 c0210c04 c030ef0c
[ 1024.041298] ff00: 00000000 000b8b64 00000000 c020a34c 00000000 ede1ff18 20000013 ffffffff
[ 1024.049457] ff20: 0000000a edd5b400 ede484b8 ede1ff60 ede484c0 c024daa4 00000000 ede48710
[ 1024.057617] ff40: 00000001 00000000 be976b68 edfbba80 0000000d 000b8c38 ede1ff88 c0210c04
[ 1024.065777] ff60: ede1e000 c030f754 00000000 00000000 edfbba80 edfbba80 000b8c38 0000000d
[ 1024.073936] ff80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b8c38
[ 1024.082097] ffa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b8c38 0000000d 00000000
[ 1024.090255] ffc0: 000b6a08 00000001 000b8c38 00000004 00000020 000b8e90 000b8b64 00000000
[ 1024.098415] ffe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 af7fd861 af7fdc61
[ 1024.106571] [<c0655630>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1024.114726] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1024.122533] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1024.130171] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1024.137292] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1024.144581] Code: bad PC value
[ 1024.152070] ---[ end trace 97ee148ea17cdd83 ]---
Performing test: EXEC_USERSPACE
[ 1024.909068] lkdtm: Performing direct entry EXEC_USERSPACE
[ 1024.909529] lkdtm: attempting ok execution at c0655294
[ 1024.914930] lkdtm: attempting bad execution at b6fa3000
[ 1024.919918] Unhandled prefetch abort: page domain fault (0x00b) at 0xb6fa3000
[ 1024.924982] Internal error: : b [#10] SMP ARM
[ 1024.932259] Modules linked in:
[ 1024.939549] CPU: 0 PID: 168 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1024.939637] Hardware name: Qualcomm (Flattened Device Tree)
[ 1024.946065] task: ede48980 ti: c3038000 task.ti: c3038000
[ 1024.951619] PC is at 0xb6fa3000
[ 1024.957187] LR is at lkdtm_do_action+0x370/0x3c0
[ 1024.960125] pc : [<b6fa3000>]    lr : [<c06556f8>]    psr: 60000013
[ 1024.960125] sp : c3039e90  ip : 00000000  fp : 00000000
[ 1024.964997] r10: 00000000  r9 : c3038000  r8 : c3039f88
[ 1024.976184] r7 : 0000000f  r6 : edf5b000  r5 : 00000051  r4 : b6fa3000
[ 1024.981396] r3 : c0ea6e94  r2 : 2d90d000  r1 : ee7b3374  r0 : 0000002b
[ 1024.987993] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1024.994505] Control: 10c5787d  Table: adecc06a  DAC: 00000051
[ 1025.001709] Process sh (pid: 168, stack limit = 0xc3038220)
[ 1025.007434] Stack: (0xc3039e90 to 0xc303a000)
[ 1025.012825] 9e80:                                     00000022 00000000 c0ab0e1c edf5b000
[ 1025.017359] 9ea0: 0000000f c3039f88 c3038000 00000000 00000000 c028b47c c0cb9620 c3039edc
[ 1025.025518] 9ec0: c0655748 c02cccc8 edf5b000 c3039edc c0ab0e1c c0655858 00000013 c0ab0e1c
[ 1025.033675] 9ee0: edf5b000 c0655860 edfbb0c0 c0655748 000b9018 c3039f88 c0210c04 c030ef0c
[ 1025.041835] 9f00: 00000000 000b8b64 00000000 c020a34c 00000000 c3039f18 20000013 ffffffff
[ 1025.049995] 9f20: 0000000a edd5b200 ede48978 c3039f60 ede48980 c024daa4 00000000 ede48bd0
[ 1025.058156] 9f40: 00000001 00000000 be976b68 edfbb0c0 0000000f 000b9018 c3039f88 c0210c04
[ 1025.066316] 9f60: c3038000 c030f754 00000000 00000000 edfbb0c0 edfbb0c0 000b9018 0000000f
[ 1025.074474] 9f80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b9018
[ 1025.082633] 9fa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b9018 0000000f 00000000
[ 1025.090793] 9fc0: 000b6a08 00000001 000b9018 00000004 00000020 000b8e90 000b8b64 00000000
[ 1025.098954] 9fe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 e7fddef0 e7fddef0
[ 1025.107113] [<c06556f8>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1025.115265] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1025.123075] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1025.130708] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1025.137831] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1025.145130] Code: 00000000 00000000 00000000 00000000 (e12fff1e) 
[ 1025.152494] ---[ end trace 97ee148ea17cdd84 ]---
Performing test: ACCESS_USERSPACE
[ 1025.919130] lkdtm: Performing direct entry ACCESS_USERSPACE
[ 1025.919586] lkdtm: attempting bad read at b6fa3000
[ 1025.925131] Unhandled fault: page domain fault (0x01b) at 0xb6fa3000
[ 1025.929907] pgd = edeb0000
[ 1025.936411] [b6fa3000] *pgd=fb06d835
[ 1025.942316] Internal error: : 1b [#11] SMP ARM
[ 1025.942575] Modules linked in:
[ 1025.949956] CPU: 0 PID: 170 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1025.950042] Hardware name: Qualcomm (Flattened Device Tree)
[ 1025.956472] task: c3030000 ti: edea4000 task.ti: edea4000
[ 1025.962040] PC is at lkdtm_do_action+0x388/0x3c0
[ 1025.967583] LR is at lkdtm_do_action+0x384/0x3c0
[ 1025.972269] pc : [<c0655710>]    lr : [<c065570c>]    psr: 60000013
[ 1025.972269] sp : edea5e90  ip : 00000000  fp : 00000000
[ 1025.976878] r10: 00000000  r9 : edea4000  r8 : edea5f88
[ 1025.988066] r7 : 00000011  r6 : edf5b000  r5 : c0ab0e20  r4 : b6fa3000
[ 1025.993274] r3 : c0ee2840  r2 : c0ee2840  r1 : 60000013  r0 : 000095c0
[ 1025.999877] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1026.006386] Control: 10c5787d  Table: adeb006a  DAC: 00000051
[ 1026.013586] Process sh (pid: 170, stack limit = 0xedea4220)
[ 1026.019319] Stack: (0xedea5e90 to 0xedea6000)
[ 1026.024708] 5e80:                                     00000022 00000000 c0ab0e20 edf5b000
[ 1026.029238] 5ea0: 00000011 edea5f88 edea4000 00000000 00000000 c028b47c c0cb9620 edea5edc
[ 1026.037397] 5ec0: c0655748 c02cccc8 edf5b000 edea5edc c0ab0e20 c0655858 00000014 c0ab0e20
[ 1026.045558] 5ee0: edf5b000 c0655860 edfbb9c0 c0655748 000b9018 edea5f88 c0210c04 c030ef0c
[ 1026.053719] 5f00: 00000000 000b8b64 00000000 c020a34c 00000000 edea5f18 20000013 ffffffff
[ 1026.061876] 5f20: 0000000a edd5b400 c302fff8 edea5f60 c3030000 c024daa4 00000000 c3030250
[ 1026.070037] 5f40: 00000001 00000000 be976b68 edfbb9c0 00000011 000b9018 edea5f88 c0210c04
[ 1026.078196] 5f60: edea4000 c030f754 00000000 00000000 edfbb9c0 edfbb9c0 000b9018 00000011
[ 1026.086359] 5f80: c0210c04 c030ff6c 00000000 00000000 00000001 000b6a08 00000001 000b9018
[ 1026.094515] 5fa0: 00000004 c0210a40 000b6a08 00000001 00000001 000b9018 00000011 00000000
[ 1026.102677] 5fc0: 000b6a08 00000001 000b9018 00000004 00000020 000b9338 000b8b64 00000000
[ 1026.110836] 5fe0: 00000000 be9769a4 0000e5d8 b6f05cbc 60000010 00000001 00000000 00000000
[ 1026.118997] [<c0655710>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1026.127145] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1026.134958] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1026.142590] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1026.149715] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1026.157010] Code: e1a01004 e34c00cb ebf1dd62 e30905c0 (e5945000) 
[ 1026.164372] ---[ end trace 97ee148ea17cdd85 ]---
Performing test: WRITE_RO
[ 1026.929067] lkdtm: Performing direct entry WRITE_RO
[ 1026.929108] lkdtm: attempting bad write at c0ab0dd0
Performing test: WRITE_KERN
[ 1027.939245] lkdtm: Performing direct entry WRITE_KERN
[ 1027.939398] lkdtm: attempting bad 12 byte write at c06552a0
[ 1027.944430] lkdtm: do_overwritten wasn't overwritten!
/ # 
/ # 
/ # 
/ # [ 1034.798860] INFO: rcu_sched self-detected stall on CPU
[ 1034.802907] 	3: (4200 ticks this GP) idle=09f/140000000000001/0 softirq=668/668 fqs=4201 
[ 1034.802987] 	[ 1034.804831] INFO: rcu_sched detected stalls on CPUs/tasks:
[ 1034.804857] 	3: (4200 ticks this GP) idle=09f/140000000000001/0 softirq=668/668 fqs=4201 
[ 1034.804863] 	(detected by 1, t=4202 jiffies, g=-3, c=-4, q=872)
[ 1034.804882] Task dump for CPU 3:
[ 1034.804891] sh              R running      0   146      1 0x00000002

[ 1034.838926]  (t=4208 jiffies g=-3 c=-4 q=872)
[ 1034.841786] Task dump for CPU 3:
[ 1034.846126] sh              R running      0   146      1 0x00000002
[ 1034.853043] [<c0219058>] (unwind_backtrace) from [<c0214754>] (show_stack+0x10/0x14)
[ 1034.855628] [<c0214754>] (show_stack) from [<c0294e40>] (rcu_dump_cpu_stacks+0x94/0xd4)
[ 1034.863522] [<c0294e40>] (rcu_dump_cpu_stacks) from [<c02983e4>] (rcu_check_callbacks+0x49c/0x7e0)
[ 1034.871255] [<c02983e4>] (rcu_check_callbacks) from [<c029ad20>] (update_process_times+0x38/0x64)
[ 1034.880275] [<c029ad20>] (update_process_times) from [<c02aafb0>] (tick_sched_timer+0x48/0x8c)
[ 1034.889219] [<c02aafb0>] (tick_sched_timer) from [<c029b68c>] (__hrtimer_run_queues+0x11c/0x1b4)
[ 1034.897725] [<c029b68c>] (__hrtimer_run_queues) from [<c029bcfc>] (hrtimer_interrupt+0xa8/0x204)
[ 1034.906673] [<c029bcfc>] (hrtimer_interrupt) from [<c086508c>] (msm_timer_interrupt+0x34/0x3c)
[ 1034.915443] [<c086508c>] (msm_timer_interrupt) from [<c028fe78>] (handle_percpu_devid_irq+0x6c/0x84)
[ 1034.923851] [<c028fe78>] (handle_percpu_devid_irq) from [<c028bfdc>] (generic_handle_irq+0x24/0x34)
[ 1034.933135] [<c028bfdc>] (generic_handle_irq) from [<c028c270>] (__handle_domain_irq+0x5c/0xb4)
[ 1034.941901] [<c028c270>] (__handle_domain_irq) from [<c020a704>] (gic_handle_irq+0x54/0x94)
[ 1034.950579] [<c020a704>] (gic_handle_irq) from [<c0215314>] (__irq_svc+0x54/0x70)
[ 1034.958899] Exception stack(0xede15e40 to 0xede15e88)
[ 1034.966566] 5e40: 00000004 ee7d7374 2d931000 c0ea6e94 00000005 c0ab0de4 ede81000 00000005
[ 1034.971604] 5e60: ede15f88 ede14000 00000000 00000000 00000000 ede15e90 c0655860 c06554f4
[ 1034.979737] 5e80: 80000013 ffffffff
[ 1034.987910] [<c0215314>] (__irq_svc) from [<c06554f4>] (lkdtm_do_action+0x16c/0x3c0)
[ 1034.991210] [<c06554f4>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1034.999195] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1035.006923] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1035.014557] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1035.021678] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)
[ 1040.008875] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [sh:146]
[ 1040.008912] Modules linked in:
[ 1040.017692] CPU: 3 PID: 146 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1040.017773] Hardware name: Qualcomm (Flattened Device Tree)
[ 1040.024205] task: ede497c0 ti: ede14000 task.ti: ede14000
[ 1040.029768] PC is at lkdtm_do_action+0x16c/0x3c0
[ 1040.035317] LR is at direct_entry+0x118/0x158
[ 1040.040002] pc : [<c06554f4>]    lr : [<c0655860>]    psr: 80000013
[ 1040.040002] sp : ede15e90  ip : 00000000  fp : 00000000
[ 1040.044260] r10: 00000000  r9 : ede14000  r8 : ede15f88
[ 1040.055539] r7 : 00000005  r6 : ede81000  r5 : c0ab0de4  r4 : 00000005
[ 1040.060747] r3 : c0ea6e94  r2 : 2d931000  r1 : ee7d7374  r0 : 00000004
[ 1040.067351] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[ 1040.073859] Control: 10c5787d  Table: adf1406a  DAC: 00000051
[ 1040.081069] CPU: 3 PID: 146 Comm: sh Tainted: G      D W       4.3.0 #3
[ 1040.086787] Hardware name: Qualcomm (Flattened Device Tree)
[ 1040.093242] [<c0219058>] (unwind_backtrace) from [<c0214754>] (show_stack+0x10/0x14)
[ 1040.098805] [<c0214754>] (show_stack) from [<c048565c>] (dump_stack+0x84/0x94)
[ 1040.106788] [<c048565c>] (dump_stack) from [<c02bc718>] (watchdog_timer_fn+0x1f8/0x260)
[ 1040.113814] [<c02bc718>] (watchdog_timer_fn) from [<c029b68c>] (__hrtimer_run_queues+0x11c/0x1b4)
[ 1040.121713] [<c029b68c>] (__hrtimer_run_queues) from [<c029bcfc>] (hrtimer_interrupt+0xa8/0x204)
[ 1040.130739] [<c029bcfc>] (hrtimer_interrupt) from [<c086508c>] (msm_timer_interrupt+0x34/0x3c)
[ 1040.139592] [<c086508c>] (msm_timer_interrupt) from [<c028fe78>] (handle_percpu_devid_irq+0x6c/0x84)
[ 1040.148008] [<c028fe78>] (handle_percpu_devid_irq) from [<c028bfdc>] (generic_handle_irq+0x24/0x34)
[ 1040.157295] [<c028bfdc>] (generic_handle_irq) from [<c028c270>] (__handle_domain_irq+0x5c/0xb4)
[ 1040.166061] [<c028c270>] (__handle_domain_irq) from [<c020a704>] (gic_handle_irq+0x54/0x94)
[ 1040.174741] [<c020a704>] (gic_handle_irq) from [<c0215314>] (__irq_svc+0x54/0x70)
[ 1040.183059] Exception stack(0xede15e40 to 0xede15e88)
[ 1040.190729] 5e40: 00000004 ee7d7374 2d931000 c0ea6e94 00000005 c0ab0de4 ede81000 00000005
[ 1040.195767] 5e60: ede15f88 ede14000 00000000 00000000 00000000 ede15e90 c0655860 c06554f4
[ 1040.203900] 5e80: 80000013 ffffffff
[ 1040.212069] [<c0215314>] (__irq_svc) from [<c06554f4>] (lkdtm_do_action+0x16c/0x3c0)
[ 1040.215373] [<c06554f4>] (lkdtm_do_action) from [<c0655860>] (direct_entry+0x118/0x158)
[ 1040.223360] [<c0655860>] (direct_entry) from [<c030ef0c>] (__vfs_write+0x1c/0xd8)
[ 1040.231079] [<c030ef0c>] (__vfs_write) from [<c030f754>] (vfs_write+0x90/0x16c)
[ 1040.238717] [<c030f754>] (vfs_write) from [<c030ff6c>] (SyS_write+0x44/0x9c)
[ 1040.245839] [<c030ff6c>] (SyS_write) from [<c0210a40>] (ret_fast_syscall+0x0/0x3c)

/ # 
/ # 
/ # 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
