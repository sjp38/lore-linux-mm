Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	UPPERCASE_50_75,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82452C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 00:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 931902173C
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 00:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 931902173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D1626B0003; Wed, 22 May 2019 20:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45A656B0006; Wed, 22 May 2019 20:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08B476B0007; Wed, 22 May 2019 20:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 745246B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 20:58:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t1so2908215pfa.10
        for <linux-mm@kvack.org>; Wed, 22 May 2019 17:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HsNlWklNQFDPe24pUB1aIPJ9aHybJMa0iKFtLPR9cp4=;
        b=EIU5Ttn3LQGMXDlJf48CLgzsxldbsWK1X7YvdvWUv0RCGTi04tuQwhh2NHtL6aMSb0
         SZYtnESydHXqxsxCkQX0JlbLz+gEVpRrvVyq9vcnEarrhtzoeQDiJPp3kwE5l8XRpH0G
         ahspf4ZF78A/ipvoGIi3zdWmN/HwtuMuCBvv9i3I0f+oAiofC6TlzFrBF3VdW3c1z+rM
         5aSmUGY4TvA0R5cKem4oIAxcyEVEUBiHLrTzVaseb89dEFDwJlrFL81oyOyhLxucgkYN
         LE8A1qvKX/FPS76eVf323ppjxVOGpiJDEpTK6q7dV/A6s3QL8f8BtIVV7lu8+Zt3HAU3
         +sXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVlsfQcH1ELP8k7inHbcBrlis18QxWAN4OAfitDblw+Fr3cp3xL
	nccXSQSR+Cm6GtWooMEtccALkTmQzQmeHD8ZHhLH9tukfBeUnSIM9YbDKrBhyeESUhcRXOIsRUv
	py1siEoPdESi+t18GfcMMcIXkcu4InMvz91FOlpf7ALONShGx70/hlKOP1ZMJf4drJw==
X-Received: by 2002:a17:90a:3510:: with SMTP id q16mr135702pjb.13.1558573130658;
        Wed, 22 May 2019 17:58:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUWWvouK2NbjNVrTqeiAUwwJ9xQBC7Y46DQA6GnDdNlS64fYm1MOt/bV/sCxhWdLf2CurT
X-Received: by 2002:a17:90a:3510:: with SMTP id q16mr135686pjb.13.1558573124245;
        Wed, 22 May 2019 17:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558573124; cv=none;
        d=google.com; s=arc-20160816;
        b=OslPeVsDurFfYivreGadvvkujB+Zhx1GTp+6RgnRJtIDi0td32BdwNR4mLcbEJCfNn
         SGHe3uHhbb0d+UMNGbFoPsX99+MzPjCdlo79xDTbvEICQy63ejEjp8uAqZfSDomIRIvk
         rHHeBPDVr1a2mtFujLsY1ykTf6bfrpBF9b/u5w5S2xYBZA9OrbS9nYnwX/Ob9xN0qUXQ
         P1qRqrFlE+Bye0owvPCyl+TDl0buGcmll93ZzpstrrGGbawuF1doMIugvqeEbjPkQ1q1
         s5HyJeO3wr/cFRMnKUdDYKPu7IqmDXKtBZV7SShCr2deomfU9e9es7bA1yB5pVe5KhA0
         B4sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date;
        bh=HsNlWklNQFDPe24pUB1aIPJ9aHybJMa0iKFtLPR9cp4=;
        b=BQMMMaZ94Jri3abAJH94BlSdRydso63j1VoIJJqsjMnA+TtY3KnWoclYNuWBtBV0/Q
         oyqJrhSduHUjwfkeEThzoqCmvn10irdQS5B7IMV1X8kGqIHHu3qwO5Ae5Jp4X5xyuNcP
         1Dznoc9HS92nRaJA7cGT9KKF4sRxRxDW6oos/magoRgoyRPROimt7GvOwJjZ2QvG51qS
         AbtkHSRA6eqBbcSZZT1ucXkNgjwx0rSAvP1BOGLwA5yhLaV0/O+FYwAmUZXDuTG9axhZ
         DW24GEgNBkN3KCvIqR+nYF2DyoqQWGQXwDrLhcq1Oc/PrKfgHzksO/C7mYQ9aH14ttKw
         G9mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x21si26658245pll.85.2019.05.22.17.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 17:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 May 2019 17:58:43 -0700
X-ExtLoop1: 1
Received: from shao2-debian.sh.intel.com (HELO localhost) ([10.239.13.6])
  by fmsmga005.fm.intel.com with ESMTP; 22 May 2019 17:58:38 -0700
Date: Thu, 23 May 2019 08:58:58 +0800
From: kernel test robot <rong.a.chen@intel.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Christoph Lameter <cl@linux.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, lkp@01.org
Subject: [mm] e52271917f:
 BUG:sleeping_function_called_from_invalid_context_at_mm/slab.h
Message-ID: <20190523005858.GJ19312@shao2-debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="GUPx2O/K0ibUojHx"
Content-Disposition: inline
In-Reply-To: <20190514213940.2405198-6-guro@fb.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--GUPx2O/K0ibUojHx
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

FYI, we noticed the following commit (built with gcc-7):

commit: e52271917f9f5159c791eda8ba748a66d659c27e ("[PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle management")
url: https://github.com/0day-ci/linux/commits/Roman-Gushchin/mm-reparent-slab-memory-on-cgroup-removal/20190517-173841


in testcase: nvml
with following parameters:

	group: obj
	test: non-pmem



on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 8G

caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):


+------------------------------------------------------------------------------+------------+------------+
|                                                                              | ff756a15f3 | e52271917f |
+------------------------------------------------------------------------------+------------+------------+
| boot_successes                                                               | 5          | 4          |
| boot_failures                                                                | 861        | 852        |
| BUG:kernel_reboot-without-warning_in_test_stage                              | 738        | 163        |
| BUG:kernel_hang_in_boot_stage                                                | 120        | 122        |
| BUG:soft_lockup-CPU##stuck_for#s                                             | 4          | 1          |
| RIP:free_unref_page                                                          | 1          |            |
| Kernel_panic-not_syncing:softlockup:hung_tasks                               | 4          | 1          |
| RIP:free_reserved_area                                                       | 3          | 1          |
| BUG:sleeping_function_called_from_invalid_context_at_mm/slab.h               | 0          | 560        |
| BUG:scheduling_while_atomic                                                  | 0          | 561        |
| WARNING:at_lib/usercopy.c:#_copy_to_user                                     | 0          | 116        |
| RIP:_copy_to_user                                                            | 0          | 116        |
| WARNING:at_arch/x86/kernel/fpu/signal.c:#copy_fpstate_to_sigframe            | 0          | 534        |
| RIP:copy_fpstate_to_sigframe                                                 | 0          | 532        |
| WARNING:at_arch/x86/kernel/signal.c:#do_signal                               | 0          | 527        |
| RIP:do_signal                                                                | 0          | 526        |
| WARNING:at_lib/usercopy.c:#_copy_from_user                                   | 0          | 389        |
| RIP:_copy_from_user                                                          | 0          | 388        |
| kernel_BUG_at_mm/vmalloc.c                                                   | 0          | 304        |
| invalid_opcode:#[##]                                                         | 0          | 304        |
| RIP:__get_vm_area_node                                                       | 0          | 301        |
| Kernel_panic-not_syncing:Fatal_exception_in_interrupt                        | 0          | 294        |
| Kernel_panic-not_syncing:Aiee,killing_interrupt_handler                      | 0          | 155        |
| WARNING:at_fs/read_write.c:#vfs_write                                        | 0          | 15         |
| RIP:vfs_write                                                                | 0          | 15         |
| BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/rwsem.c  | 0          | 101        |
| BUG:sleeping_function_called_from_invalid_context_at_include/linux/uaccess.h | 0          | 54         |
| Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode=                    | 0          | 47         |
| BUG:sleeping_function_called_from_invalid_context_at_lib/iov_iter.c          | 0          | 1          |
| BUG:sleeping_function_called_from_invalid_context_at_fs/dcache.c             | 0          | 57         |
| BUG:sleeping_function_called_from_invalid_context_at_mm/memory.c             | 0          | 1          |
| BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/mutex.c  | 0          | 104        |
| BUG:kernel_hang_in_test_stage                                                | 0          | 5          |
| WARNING:at_arch/x86/include/asm/uaccess.h:#strncpy_from_user                 | 0          | 4          |
| RIP:strncpy_from_user                                                        | 0          | 4          |
| WARNING:at_fs/read_write.c:#vfs_read                                         | 0          | 4          |
| RIP:vfs_read                                                                 | 0          | 4          |
| BUG:sleeping_function_called_from_invalid_context_at_mm/filemap.c            | 0          | 3          |
| BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c         | 0          | 8          |
| BUG:sleeping_function_called_from_invalid_context_at_mm/gup.c                | 0          | 1          |
| BUG:sleeping_function_called_from_invalid_context_at_include/linux/freezer.h | 0          | 1          |
| BUG:sleeping_function_called_from_invalid_context_at/kb                      | 0          | 1          |
+------------------------------------------------------------------------------+------------+------------+


If you fix the issue, kindly add following tag
Reported-by: kernel test robot <rong.a.chen@intel.com>


[ 1025.218323] BUG: sleeping function called from invalid context at mm/slab.h:457
[ 1025.222456] in_atomic(): 1, irqs_disabled(): 0, pid: 1, name: systemd
[ 1025.225612] CPU: 0 PID: 1 Comm: systemd Not tainted 5.1.0-12240-ge522719 #1
[ 1025.226200] BUG: scheduling while atomic: systemd-journal/187/0x00000031
[ 1025.228830] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.228832] Call Trace:
[ 1025.228850]  dump_stack+0x5c/0x7b
[ 1025.230292]  ___might_sleep+0xf1/0x110
[ 1025.233781] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.237363]  kmem_cache_alloc+0x170/0x1c0
[ 1025.237371]  security_file_alloc+0x24/0x90
[ 1025.237379]  __alloc_file+0x4f/0xe0
[ 1025.237384]  ? security_inode_permission+0x30/0x50
[ 1025.273837]  alloc_empty_file+0x43/0xe0
[ 1025.278046]  path_openat+0x4a/0x1550
[ 1025.282100]  ? terminate_walk+0xed/0x100
[ 1025.286222]  ? path_parentat+0x3c/0x80
[ 1025.290224]  ? filename_parentat+0x10b/0x190
[ 1025.294306]  do_filp_open+0x9b/0x110
[ 1025.298138]  ? __d_lookup+0x65/0x150
[ 1025.301905]  ? cp_new_stat+0x150/0x180
[ 1025.305720]  ? _cond_resched+0x19/0x30
[ 1025.309143]  ? kernfs_dop_revalidate+0xab/0xc0
[ 1025.311459]  ? lookup_dcache+0x3b/0x60
[ 1025.313618]  ? __check_object_size+0xcf/0x1a0
[ 1025.315852]  ? do_sys_open+0x1bd/0x250
[ 1025.317905]  do_sys_open+0x1bd/0x250
[ 1025.319925]  do_syscall_64+0x5b/0x1e0
[ 1025.321948]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1025.324202] RIP: 0033:0x7f70f2df9840
[ 1025.326146] Code: 73 01 c3 48 8b 0d 68 77 20 00 f7 d8 64 89 01 48 83 c8 ff c3 66 0f 1f 44 00 00 83 3d 89 bb 20 00 00 75 10 b8 02 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 31 c3 48 83 ec 08 e8 1e f6 ff ff 48 89 04 24
[ 1025.332881] RSP: 002b:00007ffd9115fa28 EFLAGS: 00000246 ORIG_RAX: 0000000000000002
[ 1025.335760] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f70f2df9840
[ 1025.338563] RDX: 0000000000000000 RSI: 0000000000080101 RDI: 000055b3e928f740
[ 1025.341351] RBP: 00007ffd9115faf0 R08: 0000000000000000 R09: 0000000000000040
[ 1025.344061] R10: 0000000000000075 R11: 0000000000000246 R12: 000055b3e928f740
[ 1025.346701] R13: 00007ffd9115faf0 R14: 00007ffd9115fac0 R15: 000055b3e925b4c0
[ 1025.349282] CPU: 1 PID: 187 Comm: systemd-journal Not tainted 5.1.0-12240-ge522719 #1
[ 1025.349486] BUG: scheduling while atomic: systemd/1/0x00000009
[ 1025.353183] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.353185] Call Trace:
[ 1025.353202]  dump_stack+0x5c/0x7b
[ 1025.353209]  __schedule_bug+0x55/0x70
[ 1025.355515] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.359746]  __schedule+0x560/0x670
[ 1025.359755]  ? ep_item_poll+0x3f/0xb0
[ 1025.359757]  ? ep_poll+0x23e/0x510
[ 1025.390358]  schedule+0x34/0xb0
[ 1025.392950]  schedule_hrtimeout_range_clock+0x19e/0x1b0
[ 1025.396331]  ? ep_read_events_proc+0xe0/0xe0
[ 1025.399354]  ? ep_scan_ready_list+0x228/0x250
[ 1025.402581]  ? ep_poll+0x23e/0x510
[ 1025.405262]  ep_poll+0x21f/0x510
[ 1025.407839]  ? wake_up_q+0x80/0x80
[ 1025.410156]  do_epoll_wait+0xbd/0xe0
[ 1025.412637]  __x64_sys_epoll_wait+0x1a/0x20
[ 1025.415418]  do_syscall_64+0x5b/0x1e0
[ 1025.418110]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1025.420985] RIP: 0033:0x7f3c827f42e3
[ 1025.423515] Code: 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 83 3d 29 54 2b 00 00 75 13 49 89 ca b8 e8 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 0b c2 00 00 48 89 04 24
[ 1025.432467] RSP: 002b:00007ffd45cf3588 EFLAGS: 00000246 ORIG_RAX: 00000000000000e8
[ 1025.436394] RAX: ffffffffffffffda RBX: 00005652bbd42200 RCX: 00007f3c827f42e3
[ 1025.440324] RDX: 0000000000000017 RSI: 00007ffd45cf3590 RDI: 0000000000000008
[ 1025.444213] RBP: 00007ffd45cf37b0 R08: 000000005ce3fecc R09: 00007ffd45d850a0
[ 1025.448172] R10: 00000000ffffffff R11: 0000000000000246 R12: 00007ffd45cf3590
[ 1025.452040] R13: 0000000000000001 R14: ffffffffffffffff R15: 00058965eeb2926e
[ 1025.455776] CPU: 0 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1025.458800] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.461791] Call Trace:
[ 1025.463352]  dump_stack+0x5c/0x7b
[ 1025.465118]  __schedule_bug+0x55/0x70
[ 1025.466952]  __schedule+0x560/0x670
[ 1025.468812]  schedule+0x34/0xb0
[ 1025.470607]  exit_to_usermode_loop+0x5c/0xf0
[ 1025.471094] systemd-journal[187]: segfault at 7f3c808da000 ip 00007f3c8321ba88 sp 00007ffd45cf0780 error 6 in libsystemd-shared-232.so[7f3c830f7000+192000]
[ 1025.472523]  do_syscall_64+0x1a7/0x1e0
[ 1025.472528]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1025.472532] RIP: 0033:0x7f70f2df9840
[ 1025.472535] Code: 73 01 c3 48 8b 0d 68 77 20 00 f7 d8 64 89 01 48 83 c8 ff c3 66 0f 1f 44 00 00 83 3d 89 bb 20 00 00 75 10 b8 02 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 31 c3 48 83 ec 08 e8 1e f6 ff ff 48 89 04 24
[ 1025.472536] RSP: 002b:00007ffd9115fa28 EFLAGS: 00000246 ORIG_RAX: 0000000000000002
[ 1025.472538] RAX: 0000000000000018 RBX: 0000000000000000 RCX: 00007f70f2df9840
[ 1025.472541] RDX: 0000000000000000 RSI: 0000000000080101 RDI: 000055b3e928f740
[ 1025.480301] Code: 08 4c 8d 4c 24 20 31 d2 49 89 d8 89 ee 4c 89 e7 e8 ad d4 ff ff 85 c0 78 40 48 8b 44 24 20 48 8b 74 24 08 48 c7 00 00 00 00 00 <48> 89 58 08 40 88 28 49 8b 94 24 c8 00 00 00 48 89 b2 88 00 00 00
[ 1025.482147] RBP: 00007ffd9115faf0 R08: 0000000000000000 R09: 0000000000000040
[ 1025.482148] R10: 0000000000000075 R11: 0000000000000246 R12: 000055b3e928f740
[ 1025.482149] R13: 00007ffd9115faf0 R14: 00007ffd9115fac0 R15: 000055b3e925b4c0
[ 1025.548055] BUG: scheduling while atomic: systemd-journal/187/0x00000041
[ 1025.552815] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.568486] BUG: scheduling while atomic: systemd/1/0x00000093
[ 1025.572547] CPU: 1 PID: 187 Comm: systemd-journal Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1025.574964] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.579611] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.579614] Call Trace:
[ 1025.579633]  dump_stack+0x5c/0x7b
[ 1025.579641]  __schedule_bug+0x55/0x70
[ 1025.605125]  __schedule+0x560/0x670
[ 1025.608455]  ? force_sig_info+0xc7/0xe0
[ 1025.611994]  ? async_page_fault+0x8/0x30
[ 1025.615444]  schedule+0x34/0xb0
[ 1025.617623]  exit_to_usermode_loop+0x5c/0xf0
[ 1025.619711]  prepare_exit_to_usermode+0xa0/0xe0
[ 1025.621827]  retint_user+0x8/0x8
[ 1025.623637] RIP: 0033:0x7f3c8321ba88
[ 1025.625519] Code: 08 4c 8d 4c 24 20 31 d2 49 89 d8 89 ee 4c 89 e7 e8 ad d4 ff ff 85 c0 78 40 48 8b 44 24 20 48 8b 74 24 08 48 c7 00 00 00 00 00 <48> 89 58 08 40 88 28 49 8b 94 24 c8 00 00 00 48 89 b2 88 00 00 00
[ 1025.632024] RSP: 002b:00007ffd45cf0780 EFLAGS: 00010202
[ 1025.634366] RAX: 00007f3c808d9ff8 RBX: 000000000000005d RCX: 000000000022eff8
[ 1025.637138] RDX: 0000000000000000 RSI: 000000000022eff8 RDI: 00005652bbd44140
[ 1025.639921] RBP: 0000000000000001 R08: 000000000022f055 R09: 00005652bbd44140
[ 1025.642722] R10: 00007ffd45cf0730 R11: 00000000001eb892 R12: 00005652bbd43ea0
[ 1025.645511] R13: 00007ffd45cf08b0 R14: 00007ffd45cf08a8 R15: 000000003d5f1097
[ 1025.648317] CPU: 0 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1025.652678] meminfo[1008]: segfault at 5636a4cb5f1c ip 00005636a3adfbec sp 00007ffd8a3a5a50 error 7
[ 1025.652682] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.652683]  in dash[5636a3ad4000+1b000]
[ 1025.657131] Call Trace:
[ 1025.657150]  dump_stack+0x5c/0x7b
[ 1025.657157]  __schedule_bug+0x55/0x70
[ 1025.660476] Code: 89 c6 74 06 48 8b 43 10 8b 30 89 ef e8 55 79 ff ff 41 83 fd 01 0f 84 73 01 00 00 0f b7 43 1c 48 8b 53 10 8d 48 01 48 c1 e0 04 <66> 89 4b 1c 48 8d 1c 02 48 8d 05 a5 30 21 00 48 89 43 08 8b 05 67
[ 1025.663501]  __schedule+0x560/0x670
[ 1025.663509]  ? __sys_sendmsg+0x5e/0xa0
[ 1025.663513]  schedule+0x34/0xb0
[ 1025.665307] BUG: scheduling while atomic: meminfo/1008/0x000000a7
[ 1025.668183]  exit_to_usermode_loop+0x5c/0xf0
[ 1025.668186]  do_syscall_64+0x1a7/0x1e0
[ 1025.670259] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.679316]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1025.679322] RIP: 0033:0x7f70f2df9e67
[ 1025.679326] Code: 89 02 48 c7 c0 ff ff ff ff eb d0 0f 1f 84 00 00 00 00 00 8b 05 6a b5 20 00 85 c0 75 2e 48 63 ff 48 63 d2 b8 2e 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 01 c3 48 8b 15 11 71 20 00 f7 d8 64 89 02 48
[ 1025.679327] RSP: 002b:00007ffd9115f8f8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[ 1025.679330] RAX: 00000000000000d9 RBX: 000055b3e9200a80 RCX: 00007f70f2df9e67
[ 1025.679333] RDX: 0000000000004040 RSI: 00007ffd9115f940 RDI: 000000000000002a
[ 1025.741650] RBP: 00007ffd9115f9b0 R08: 0000000000000002 R09: 000055b3e928f5b0
[ 1025.746173] R10: 0000000000000090 R11: 0000000000000246 R12: 00007ffd9115f940
[ 1025.750679] R13: 00007ffd9115fa40 R14: 000055b3e928f100 R15: 00007ffd9115f900
[ 1025.755203] CPU: 1 PID: 1008 Comm: meminfo Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1025.763548] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.771669] Call Trace:
[ 1025.776170]  dump_stack+0x5c/0x7b
[ 1025.781246]  __schedule_bug+0x55/0x70
[ 1025.786466]  __schedule+0x560/0x670
[ 1025.791572]  ? force_sig_info+0xc7/0xe0
[ 1025.797122]  ? async_page_fault+0x8/0x30
[ 1025.802590]  schedule+0x34/0xb0
[ 1025.807556]  exit_to_usermode_loop+0x5c/0xf0
[ 1025.813222]  prepare_exit_to_usermode+0xa0/0xe0
[ 1025.818974]  retint_user+0x8/0x8
[ 1025.823834] RIP: 0033:0x5636a3adfbec
[ 1025.828729] Code: 89 c6 74 06 48 8b 43 10 8b 30 89 ef e8 55 79 ff ff 41 83 fd 01 0f 84 73 01 00 00 0f b7 43 1c 48 8b 53 10 8d 48 01 48 c1 e0 04 <66> 89 4b 1c 48 8d 1c 02 48 8d 05 a5 30 21 00 48 89 43 08 8b 05 67
[ 1025.845269] RSP: 002b:00007ffd8a3a5a50 EFLAGS: 00010246
[ 1025.847989] BUG: scheduling while atomic: dbus-daemon/261/0x00000005
[ 1025.849294] RAX: 0000000000000000 RBX: 00005636a4cb5f00 RCX: 0000000000000001
[ 1025.849296] RDX: 00005636a4cb5f00 RSI: 0000000000000000 RDI: 0000000001200011
[ 1025.849297] RBP: 000000000000734f R08: 00007f434abb5700 R09: 00007f434a52a360
[ 1025.849298] R10: 00007f434abb59d0 R11: 0000000000000246 R12: 00005636a3cf2bc8
[ 1025.849299] R13: 0000000000000002 R14: 00005636a3aea582 R15: 00005636a3cf2bc8
[ 1025.850974] note: systemd-journal[187] exited with preempt_count 2
[ 1025.853356] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.982919] BUG: scheduling while atomic: systemd-logind/281/0x00000007
[ 1025.986290] CPU: 0 PID: 261 Comm: dbus-daemon Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1025.988978] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1025.992777] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1025.992779] Call Trace:
[ 1025.992800]  dump_stack+0x5c/0x7b
[ 1025.992808]  __schedule_bug+0x55/0x70
[ 1025.992817]  __schedule+0x560/0x670
[ 1026.052486]  ? ep_item_poll+0x3f/0xb0
[ 1026.055863]  ? ep_poll+0x23e/0x510
[ 1026.058868]  schedule+0x34/0xb0
[ 1026.061839]  schedule_hrtimeout_range_clock+0x19e/0x1b0
[ 1026.065339]  ? ep_read_events_proc+0xe0/0xe0
[ 1026.068467]  ? ep_scan_ready_list+0x228/0x250
[ 1026.071926]  ? __switch_to_asm+0x40/0x70
[ 1026.074961]  ? __switch_to_asm+0x34/0x70
[ 1026.077998]  ? ep_poll+0x23e/0x510
[ 1026.080820]  ep_poll+0x21f/0x510
[ 1026.083604]  ? wake_up_q+0x80/0x80
[ 1026.086336]  do_epoll_wait+0xbd/0xe0
[ 1026.089050]  __x64_sys_epoll_wait+0x1a/0x20
[ 1026.091861]  do_syscall_64+0x5b/0x1e0
[ 1026.094535]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1026.097636] RIP: 0033:0x7f60d105c2e3
[ 1026.100314] Code: 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 83 3d 29 54 2b 00 00 75 13 49 89 ca b8 e8 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 0b c2 00 00 48 89 04 24
[ 1026.109332] RSP: 002b:00007ffda738f118 EFLAGS: 00000246 ORIG_RAX: 00000000000000e8
[ 1026.113430] RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 00007f60d105c2e3
[ 1026.117441] RDX: 0000000000000040 RSI: 00007ffda738f120 RDI: 0000000000000004
[ 1026.121480] RBP: 00007ffda738f4d0 R08: 0000000000000401 R09: 00007ffda73a80b0
[ 1026.125452] R10: 00000000ffffffff R11: 0000000000000246 R12: 000055f82d37b500
[ 1026.129312] R13: 0000000000000001 R14: 000055f82d3971e8 R15: 000055f82d39cd00
[ 1026.133177] CPU: 1 PID: 281 Comm: systemd-logind Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.136258] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.137642] meminfo[29519]: segfault at 5636a4cb6360 ip 00005636a3adab0b sp 00007ffd8a3a5850 error 7 in dash[5636a3ad4000+1b000]
[ 1026.139203] Call Trace:
[ 1026.139220]  dump_stack+0x5c/0x7b
[ 1026.139227]  __schedule_bug+0x55/0x70
[ 1026.146531] Code: 5b 5d 41 5c 41 5d c3 0f 1f 84 00 00 00 00 00 31 db 45 85 e4 74 dc 48 89 ef e8 81 c8 ff ff 48 8d 78 18 e8 88 5b 00 00 48 89 c3 <49> 89 45 00 48 c7 00 00 00 00 00 48 8d 7b 13 b8 ff ff ff ff 48 89
[ 1026.148112]  __schedule+0x560/0x670
[ 1026.148119]  ? ep_item_poll+0x3f/0xb0
[ 1026.151038] BUG: scheduling while atomic: meminfo/29519/0x0000000b
[ 1026.152903]  ? ep_poll+0x23e/0x510
[ 1026.152907]  schedule+0x34/0xb0
[ 1026.152911]  schedule_hrtimeout_range_clock+0x19e/0x1b0
[ 1026.152913]  ? ep_read_events_proc+0xe0/0xe0
[ 1026.152914]  ? ep_scan_ready_list+0x228/0x250
[ 1026.152916]  ? ep_poll+0x23e/0x510
[ 1026.152917]  ep_poll+0x21f/0x510
[ 1026.152920]  ? _cond_resched+0x19/0x30
[ 1026.152926]  ? wake_up_q+0x80/0x80
[ 1026.152930]  do_epoll_wait+0xbd/0xe0
[ 1026.162286] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1026.164714]  __x64_sys_epoll_wait+0x1a/0x20
[ 1026.164722]  do_syscall_64+0x5b/0x1e0
[ 1026.164729]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1026.233261] RIP: 0033:0x7f60b575a2e3
[ 1026.236611] Code: 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 83 3d 29 54 2b 00 00 75 13 49 89 ca b8 e8 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 0b c2 00 00 48 89 04 24
[ 1026.247869] RSP: 002b:00007ffcb8705c48 EFLAGS: 00000246 ORIG_RAX: 00000000000000e8
[ 1026.253346] RAX: ffffffffffffffda RBX: 0000563d3e17b280 RCX: 00007f60b575a2e3
[ 1026.258686] RDX: 000000000000000b RSI: 00007ffcb8705c50 RDI: 0000000000000004
[ 1026.263861] RBP: 00007ffcb8705de0 R08: 0000563d3e187aa0 R09: 0000563d3e187c00
[ 1026.269119] R10: 00000000ffffffff R11: 0000000000000246 R12: 00007ffcb8705c50
[ 1026.274380] R13: 0000000000000001 R14: ffffffffffffffff R15: 00007ffcb8705ee0
[ 1026.279813] CPU: 0 PID: 29519 Comm: meminfo Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.284461] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.288825] Call Trace:
[ 1026.291505]  dump_stack+0x5c/0x7b
[ 1026.294329]  __schedule_bug+0x55/0x70
[ 1026.297276]  __schedule+0x560/0x670
[ 1026.300041]  ? force_sig_info+0xc7/0xe0
[ 1026.302841]  ? async_page_fault+0x8/0x30
[ 1026.305748]  schedule+0x34/0xb0
[ 1026.308355]  exit_to_usermode_loop+0x5c/0xf0
[ 1026.311269]  prepare_exit_to_usermode+0xa0/0xe0
[ 1026.314286]  retint_user+0x8/0x8
[ 1026.316873] RIP: 0033:0x5636a3adab0b
[ 1026.319498] Code: 5b 5d 41 5c 41 5d c3 0f 1f 84 00 00 00 00 00 31 db 45 85 e4 74 dc 48 89 ef e8 81 c8 ff ff 48 8d 78 18 e8 88 5b 00 00 48 89 c3 <49> 89 45 00 48 c7 00 00 00 00 00 48 8d 7b 13 b8 ff ff ff ff 48 89
[ 1026.327848] RSP: 002b:00007ffd8a3a5850 EFLAGS: 00010206
[ 1026.330976] RAX: 00005636a4cb8d50 RBX: 00005636a4cb8d50 RCX: 00007f434a795b00
[ 1026.334636] RDX: 00005636a4cb8d50 RSI: 0000000000000000 RDI: 0000000000000001
[ 1026.338287] RBP: 00005636a4cb85f0 R08: 000000000000ffff R09: 0000000000000030
[ 1026.341808] R10: 00007f434a526430 R11: 0000000000000246 R12: 0000000000000001
[ 1026.345387] R13: 00005636a4cb6360 R14: 0000000000000001 R15: 0000000000000000
[ 1026.349691] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:65
[ 1026.349780] BUG: scheduling while atomic: systemd/1/0x00000005
[ 1026.354095] in_atomic(): 1, irqs_disabled(): 0, pid: 29520, name: systemd-cgroups
[ 1026.356679] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1026.360422] CPU: 0 PID: 29520 Comm: systemd-cgroups Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.376244] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.380767] Call Trace:
[ 1026.383659]  dump_stack+0x5c/0x7b
[ 1026.386775]  ___might_sleep+0xf1/0x110
[ 1026.390034]  down_write+0x1c/0x50
[ 1026.393029]  vma_link+0x42/0xb0
[ 1026.395960]  mmap_region+0x423/0x660
[ 1026.398922]  do_mmap+0x3e3/0x580
[ 1026.401762]  vm_mmap_pgoff+0xd2/0x120
[ 1026.404666]  elf_map+0x8c/0x120
[ 1026.407450]  load_elf_binary+0x6a3/0x1180
[ 1026.410467]  search_binary_handler+0x91/0x1e0
[ 1026.413508]  __do_execve_file+0x761/0x940
[ 1026.416610]  do_execve+0x21/0x30
[ 1026.419328]  call_usermodehelper_exec_async+0x1a8/0x1c0
[ 1026.422561]  ? recalc_sigpending+0x17/0x50
[ 1026.425493]  ? call_usermodehelper+0xa0/0xa0
[ 1026.428404]  ret_from_fork+0x35/0x40
[ 1026.431159] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.431293] note: systemd-cgroups[29520] exited with preempt_count 6
[ 1026.433971] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.433972] Call Trace:
[ 1026.433984]  dump_stack+0x5c/0x7b
[ 1026.433989]  __schedule_bug+0x55/0x70
[ 1026.433997]  __schedule+0x560/0x670
[ 1026.437738] note: meminfo[29519] exited with preempt_count 2
[ 1026.440163]  ? hrtimer_start_range_ns+0x1e4/0x2c0
[ 1026.440166]  schedule+0x34/0xb0
[ 1026.440169]  schedule_hrtimeout_range_clock+0xbb/0x1b0
[ 1026.440171]  ? __hrtimer_init+0xb0/0xb0
[ 1026.440178]  poll_schedule_timeout+0x4d/0x80
[ 1026.440181]  do_sys_poll+0x3d6/0x590
[ 1026.440187]  ? ep_poll_callback+0x26f/0x2e0
[ 1026.440192]  ? __wake_up_common+0x76/0x170
[ 1026.443001] BUG: scheduling while atomic: dbus-daemon/261/0x00000005
[ 1026.444172]  ? _cond_resched+0x19/0x30
[ 1026.444174]  ? mutex_lock+0x21/0x40
[ 1026.444177]  ? set_fd_set+0x50/0x50
[ 1026.444183]  ? import_iovec+0x8d/0xb0
[ 1026.444188]  ? unix_stream_recvmsg+0x53/0x70
[ 1026.444192]  ? __unix_insert_socket+0x40/0x40
[ 1026.444199]  ? ___sys_recvmsg+0x1ab/0x250
[ 1026.446953] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1026.448644]  ? __switch_to_asm+0x40/0x70
[ 1026.448646]  ? __switch_to_asm+0x34/0x70
[ 1026.448647]  ? __switch_to_asm+0x40/0x70
[ 1026.448648]  ? __switch_to_asm+0x34/0x70
[ 1026.448650]  ? __switch_to_asm+0x40/0x70
[ 1026.448652]  ? __switch_to_asm+0x34/0x70
[ 1026.501741]  ? __switch_to_asm+0x40/0x70
[ 1026.503383]  ? __switch_to_asm+0x34/0x70
[ 1026.504999]  ? __switch_to_asm+0x40/0x70
[ 1026.506617]  ? __switch_to_asm+0x34/0x70
[ 1026.508233]  ? __switch_to_asm+0x40/0x70
[ 1026.509824]  ? __switch_to_asm+0x34/0x70
[ 1026.511384]  ? __switch_to_asm+0x40/0x70
[ 1026.512969]  ? __switch_to_asm+0x34/0x70
[ 1026.514576]  ? __switch_to_asm+0x40/0x70
[ 1026.516156]  ? __switch_to_asm+0x34/0x70
[ 1026.517713]  ? __switch_to_asm+0x40/0x70
[ 1026.519272]  ? __switch_to_asm+0x34/0x70
[ 1026.520793]  ? __switch_to_asm+0x40/0x70
[ 1026.522328]  ? __switch_to_asm+0x34/0x70
[ 1026.523833]  ? __switch_to_asm+0x40/0x70
[ 1026.525358]  ? __switch_to_asm+0x34/0x70
[ 1026.526825]  ? __switch_to_asm+0x40/0x70
[ 1026.528256]  ? __switch_to_asm+0x34/0x70
[ 1026.529680]  ? __switch_to_asm+0x40/0x70
[ 1026.531141]  ? __switch_to_asm+0x34/0x70
[ 1026.532558]  ? __switch_to_asm+0x40/0x70
[ 1026.533967]  ? __switch_to_asm+0x34/0x70
[ 1026.535395]  ? kvm_clock_get_cycles+0x14/0x20
[ 1026.536895]  ? ktime_get_ts64+0x4c/0xe0
[ 1026.538283]  ? __x64_sys_ppoll+0xbb/0x110
[ 1026.539683]  __x64_sys_ppoll+0xbb/0x110
[ 1026.541087]  do_syscall_64+0x5b/0x1e0
[ 1026.542409]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1026.544007] RIP: 0033:0x7f70f2b2992d
[ 1026.545341] Code: 48 8b 52 08 48 89 44 24 10 8b 05 ee ed 2b 00 48 89 54 24 18 48 8d 54 24 10 85 c0 75 30 41 b8 08 00 00 00 b8 0f 01 00 00 0f 05 <48> 3d 00 f0 ff ff 77 73 48 83 c4 20 5b 5d 41 5c c3 66 90 8b 05 ba
[ 1026.550658] RSP: 002b:00007ffd9115f7f0 EFLAGS: 00000246 ORIG_RAX: 000000000000010f
[ 1026.552914] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007f70f2b2992d
[ 1026.555097] RDX: 00007ffd9115f800 RSI: 0000000000000001 RDI: 00007ffd9115f840
[ 1026.557347] RBP: 0000000000000001 R08: 0000000000000008 R09: 00007ffd911eb0b0
[ 1026.559525] R10: 0000000000000000 R11: 0000000000000246 R12: 00000000017d7838
[ 1026.561705] R13: 000055b3e9200a80 R14: 0000000000000000 R15: 000000003ea29a30
[ 1026.563887] CPU: 0 PID: 261 Comm: dbus-daemon Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.567501] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.570383] note: meminfo[1008] exited with preempt_count 2
[ 1026.570931] Call Trace:
[ 1026.574448]  dump_stack+0x5c/0x7b
[ 1026.576334]  __schedule_bug+0x55/0x70
[ 1026.578318]  __schedule+0x560/0x670
[ 1026.580243]  ? ep_item_poll+0x3f/0xb0
[ 1026.582542]  ? ep_poll+0x23e/0x510
[ 1026.584452]  schedule+0x34/0xb0
[ 1026.586332]  schedule_hrtimeout_range_clock+0x19e/0x1b0
[ 1026.588750]  ? ep_read_events_proc+0xe0/0xe0
[ 1026.590926]  ? ep_scan_ready_list+0x228/0x250
[ 1026.593511]  ? __switch_to_asm+0x40/0x70
[ 1026.595722]  ? __switch_to_asm+0x34/0x70
[ 1026.597925]  ? ep_poll+0x23e/0x510
[ 1026.600019]  ep_poll+0x21f/0x510
[ 1026.602107]  ? wake_up_q+0x80/0x80
[ 1026.604158]  do_epoll_wait+0xbd/0xe0
[ 1026.606235]  __x64_sys_epoll_wait+0x1a/0x20
[ 1026.608492]  do_syscall_64+0x5b/0x1e0
[ 1026.610581]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1026.613180] RIP: 0033:0x7f60d105c2e3
[ 1026.615508] Code: 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 83 3d 29 54 2b 00 00 75 13 49 89 ca b8 e8 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 0b c2 00 00 48 89 04 24
[ 1026.623765] RSP: 002b:00007ffda738f118 EFLAGS: 00000246 ORIG_RAX: 00000000000000e8
[ 1026.627784] RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 00007f60d105c2e3
[ 1026.631737] RDX: 0000000000000040 RSI: 00007ffda738f120 RDI: 0000000000000004
[ 1026.635748] RBP: 00007ffda738f4d0 R08: 0000000000000401 R09: 00007ffda73a80b0
[ 1026.639522] R10: 00000000ffffffff R11: 0000000000000246 R12: 000055f82d37b500
[ 1026.643262] R13: 0000000000000001 R14: 000055f82d3971e8 R15: 000055f82d39cd00
[ 1026.778152] BUG: scheduling while atomic: systemd/1/0x000000cf
[ 1026.782050] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1026.797533] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.801475] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.805600] Call Trace:
[ 1026.807512]  dump_stack+0x5c/0x7b
[ 1026.809734]  __schedule_bug+0x55/0x70
[ 1026.812039]  __schedule+0x560/0x670
[ 1026.814245]  ? hrtimer_start_range_ns+0x1e4/0x2c0
[ 1026.816807]  schedule+0x34/0xb0
[ 1026.818834]  schedule_hrtimeout_range_clock+0xbb/0x1b0
[ 1026.821629]  ? __hrtimer_init+0xb0/0xb0
[ 1026.824902]  poll_schedule_timeout+0x4d/0x80
[ 1026.829051]  do_sys_poll+0x3d6/0x590
[ 1026.831529]  ? ep_poll_callback+0x26f/0x2e0
[ 1026.833992]  ? __wake_up_common+0x76/0x170
[ 1026.837040]  ? _cond_resched+0x19/0x30
[ 1026.840385]  ? mutex_lock+0x21/0x40
[ 1026.843059]  ? set_fd_set+0x50/0x50
[ 1026.844962]  ? import_iovec+0x8d/0xb0
[ 1026.846680]  ? unix_stream_recvmsg+0x53/0x70
[ 1026.848624]  ? __unix_insert_socket+0x40/0x40
[ 1026.851521]  ? ___sys_recvmsg+0x1ab/0x250
[ 1026.854455]  ? flush_workqueue+0x1a9/0x420
[ 1026.856529]  ? list_lru_add+0xbf/0x1b0
[ 1026.858244]  ? kvm_clock_get_cycles+0x14/0x20
[ 1026.860170]  ? ktime_get_ts64+0x4c/0xe0
[ 1026.862266]  ? __x64_sys_ppoll+0xbb/0x110
[ 1026.865057]  __x64_sys_ppoll+0xbb/0x110
[ 1026.867461]  do_syscall_64+0x5b/0x1e0
[ 1026.869307]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1026.871899] RIP: 0033:0x7f70f2b2992d
[ 1026.874535] Code: 48 8b 52 08 48 89 44 24 10 8b 05 ee ed 2b 00 48 89 54 24 18 48 8d 54 24 10 85 c0 75 30 41 b8 08 00 00 00 b8 0f 01 00 00 0f 05 <48> 3d 00 f0 ff ff 77 73 48 83 c4 20 5b 5d 41 5c c3 66 90 8b 05 ba
[ 1026.882409] RSP: 002b:00007ffd9115f7e0 EFLAGS: 00000246 ORIG_RAX: 000000000000010f
[ 1026.885278] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007f70f2b2992d
[ 1026.888507] RDX: 00007ffd9115f7f0 RSI: 0000000000000001 RDI: 00007ffd9115f830
[ 1026.891872] RBP: 0000000000000001 R08: 0000000000000008 R09: 00007ffd911eb0b0
[ 1026.894542] R10: 0000000000000000 R11: 0000000000000246 R12: 00000000017d783d
[ 1026.897386] R13: 000055b3e9200a80 R14: 0000000000000000 R15: 000000003ea92388
[ 1026.934533] BUG: scheduling while atomic: dbus-daemon/261/0x00000009
[ 1026.938388] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1026.955687] CPU: 1 PID: 261 Comm: dbus-daemon Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1026.961323] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1026.965624] Call Trace:
[ 1026.967513]  dump_stack+0x5c/0x7b
[ 1026.970336]  __schedule_bug+0x55/0x70
[ 1026.973714]  __schedule+0x560/0x670
[ 1026.976381]  ? ep_item_poll+0x3f/0xb0
[ 1026.978878]  ? ep_poll+0x23e/0x510
[ 1026.981032]  schedule+0x34/0xb0
[ 1026.983865]  schedule_hrtimeout_range_clock+0x19e/0x1b0
[ 1026.987829]  ? ep_read_events_proc+0xe0/0xe0
[ 1026.990498]  ? ep_scan_ready_list+0x228/0x250
[ 1026.993743]  ? __switch_to_asm+0x40/0x70
[ 1026.997050]  ? __switch_to_asm+0x34/0x70
[ 1027.000404]  ? ep_poll+0x23e/0x510
[ 1027.003260]  ep_poll+0x21f/0x510
[ 1027.005401]  ? wake_up_q+0x80/0x80
[ 1027.007492]  do_epoll_wait+0xbd/0xe0
[ 1027.009642]  __x64_sys_epoll_wait+0x1a/0x20
[ 1027.012888]  do_syscall_64+0x5b/0x1e0
[ 1027.015546]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1027.018343] RIP: 0033:0x7f60d105c2e3
[ 1027.020584] Code: 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 83 3d 29 54 2b 00 00 75 13 49 89 ca b8 e8 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 0b c2 00 00 48 89 04 24
[ 1027.031748] systemd[1]: segfault at 7f70f2de6830 ip 00007f70f2b024ba sp 00007ffd9115f8d0 error 7 in libc-2.24.so[7f70f2a4a000+195000]
[ 1027.032437] RSP: 002b:00007ffda738f118 EFLAGS: 00000246 ORIG_RAX: 00000000000000e8
[ 1027.032441] RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 00007f60d105c2e3
[ 1027.032443] RDX: 0000000000000040 RSI: 00007ffda738f120 RDI: 0000000000000004
[ 1027.032444] RBP: 00007ffda738f4d0 R08: 0000000000000402 R09: 00007ffda73a80b0
[ 1027.032446] R10: 00000000ffffffff R11: 0000000000000246 R12: 000055f82d37b500
[ 1027.032447] R13: 0000000000000001 R14: 000055f82d3971e8 R15: 000055f82d39cd00
[ 1027.034233] BUG: scheduling while atomic: rs:main Q:Reg/264/0x00000007
[ 1027.039915] Code: 48 85 db 74 ce 41 bc ca 00 00 00 eb 0c 0f 1f 00 48 8b 5b 08 48 85 db 74 ba 48 8b 3b 48 8b 47 10 48 85 c0 74 05 ff d0 48 8b 3b <f0> ff 4f 28 0f 94 c0 84 c0 74 db 8b 47 2c 85 c0 74 d4 48 83 c7 28
[ 1027.039929] BUG: scheduling while atomic: systemd/1/0x00000101
[ 1027.044540] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.048883] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.053364] CPU: 1 PID: 264 Comm: rs:main Q:Reg Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.116462] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.121503] Call Trace:
[ 1027.123566]  dump_stack+0x5c/0x7b
[ 1027.125524]  __schedule_bug+0x55/0x70
[ 1027.127513]  __schedule+0x560/0x670
[ 1027.129604]  ? get_futex_key+0x337/0x420
[ 1027.132763]  schedule+0x34/0xb0
[ 1027.134848]  futex_wait_queue_me+0xd3/0x150
[ 1027.136947]  futex_wait+0xeb/0x250
[ 1027.138862]  ? set_page_dirty+0xe/0xb0
[ 1027.140830]  ? simple_write_end+0x4e/0x140
[ 1027.143048]  ? generic_perform_write+0x142/0x1d0
[ 1027.146190]  do_futex+0x12c/0x970
[ 1027.148027]  ? new_sync_write+0x12d/0x1d0
[ 1027.150363]  __x64_sys_futex+0x134/0x180
[ 1027.153496]  ? ksys_write+0x66/0xe0
[ 1027.156447]  do_syscall_64+0x5b/0x1e0
[ 1027.158726]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1027.160999] RIP: 0033:0x7f7f3b98217f
[ 1027.163370] Code: 30 83 f8 20 75 15 be 8b 00 00 00 b8 ca 00 00 00 0f 05 83 f8 00 41 0f 94 c0 eb 0f be 80 00 00 00 45 30 c0 b8 ca 00 00 00 0f 05 <8b> 3c 24 e8 49 2d 00 00 48 8b 7c 24 08 be 01 00 00 00 31 c0 f0 0f
[ 1027.171164] RSP: 002b:00007f7f38f40c70 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
[ 1027.174246] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f7f3b98217f
[ 1027.178390] RDX: 00000000000002ff RSI: 0000000000000080 RDI: 000055b0a6fbc28c
[ 1027.182242] RBP: 000055b0a6fbc288 R08: 000055b0a6fbc000 R09: 000000000000017f
[ 1027.185219] R10: 0000000000000000 R11: 0000000000000246 R12: 00007f7f38f40cd0
[ 1027.189140] R13: 0000000000000000 R14: 000055b0a52e6290 R15: 0000000000000000
[ 1027.191974] CPU: 0 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.192447] (systemd)[29521]: segfault at 7f70f2b252d0 ip 00007f70f2b252d0 sp 00007ffd9115f628 error 14 in libc-2.24.so[7f70f2a4a000+195000]
[ 1027.196520] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.196522] Call Trace:
[ 1027.196539]  dump_stack+0x5c/0x7b
[ 1027.196549]  __schedule_bug+0x55/0x70
[ 1027.204249] Code: Bad RIP value.
[ 1027.208742]  __schedule+0x560/0x670
[ 1027.208749]  ? force_sig_info+0xc7/0xe0
[ 1027.210544] BUG: scheduling while atomic: (systemd)/29521/0x0000000b
[ 1027.213570]  ? async_page_fault+0x8/0x30
[ 1027.213575]  schedule+0x34/0xb0
[ 1027.213585]  exit_to_usermode_loop+0x5c/0xf0
[ 1027.213589]  prepare_exit_to_usermode+0xa0/0xe0
[ 1027.216777] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.219831]  retint_user+0x8/0x8
[ 1027.219838] RIP: 0033:0x7f70f2b024ba
[ 1027.219843] Code: 48 85 db 74 ce 41 bc ca 00 00 00 eb 0c 0f 1f 00 48 8b 5b 08 48 85 db 74 ba 48 8b 3b 48 8b 47 10 48 85 c0 74 05 ff d0 48 8b 3b <f0> ff 4f 28 0f 94 c0 84 c0 74 db 8b 47 2c 85 c0 74 d4 48 83 c7 28
[ 1027.271149] RSP: 002b:00007ffd9115f8d0 EFLAGS: 00010246
[ 1027.274596] RAX: 0000000000000000 RBX: 00007ffd9115f8d0 RCX: 00007f70f2b0238b
[ 1027.278564] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00007f70f2de6808
[ 1027.282528] RBP: 00007ffd9115f920 R08: 00007f70f455a500 R09: 000055b3e7eb2e01
[ 1027.286508] R10: 00007f70f455a7d0 R11: 0000000000000246 R12: 00000000000000ca
[ 1027.290492] R13: 0000000000007351 R14: 0000000000000000 R15: 0000000000000000
[ 1027.294496] CPU: 1 PID: 29521 Comm: (systemd) Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.295208] BUG: scheduling while atomic: systemd-logind/281/0x00000011
[ 1027.297676] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.297678] Call Trace:
[ 1027.297697]  dump_stack+0x5c/0x7b
[ 1027.297705]  __schedule_bug+0x55/0x70
[ 1027.297714]  __schedule+0x560/0x670
[ 1027.297719]  ? force_sig_info+0xc7/0xe0
[ 1027.297725]  ? async_page_fault+0x8/0x30
[ 1027.297728]  schedule+0x34/0xb0
[ 1027.297735]  exit_to_usermode_loop+0x5c/0xf0
[ 1027.297738]  prepare_exit_to_usermode+0xa0/0xe0
[ 1027.297740]  retint_user+0x8/0x8
[ 1027.297744] RIP: 0033:0x7f70f2b252d0
[ 1027.297755] Code: Bad RIP value.
[ 1027.301693] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.304924] RSP: 002b:00007ffd9115f628 EFLAGS: 00010206
[ 1027.304926] RAX: 0000000000000018 RBX: 0000000000000018 RCX: 00007f70f2afd9b1
[ 1027.304927] RDX: 00007ffd9115f630 RSI: 0000000000000018 RDI: 0000000000000001
[ 1027.304928] RBP: 00007ffd9115f8e0 R08: 0000000000000000 R09: 0000000000000000
[ 1027.304929] R10: 0000000000000008 R11: 0000000000000202 R12: 0000000000000001
[ 1027.304930] R13: 00007ffd9115f740 R14: 000055b3e928b260 R15: 00007ffd9115f9c0
[ 1027.305238] BUG: scheduling while atomic: dbus-daemon/261/0x00000005
[ 1027.307700] CPU: 0 PID: 281 Comm: systemd-logind Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.309610] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.312390] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.312392] Call Trace:
[ 1027.312410]  dump_stack+0x5c/0x7b
[ 1027.312418]  __schedule_bug+0x55/0x70
[ 1027.415964]  __schedule+0x560/0x670
[ 1027.419154]  ? hrtimer_start_range_ns+0x1e4/0x2c0
[ 1027.422716]  schedule+0x34/0xb0
[ 1027.425681]  schedule_hrtimeout_range_clock+0xbb/0x1b0
[ 1027.429219]  ? __hrtimer_init+0xb0/0xb0
[ 1027.432331]  poll_schedule_timeout+0x4d/0x80
[ 1027.435930]  do_sys_poll+0x3d6/0x590
[ 1027.438802]  ? ep_poll_callback+0x26f/0x2e0
[ 1027.441774]  ? __wake_up_common+0x76/0x170
[ 1027.444701]  ? _cond_resched+0x19/0x30
[ 1027.447584]  ? mutex_lock+0x21/0x40
[ 1027.450358]  ? set_fd_set+0x50/0x50
[ 1027.453318]  ? import_iovec+0x8d/0xb0
[ 1027.456025]  ? unix_stream_recvmsg+0x53/0x70
[ 1027.458847]  ? __unix_insert_socket+0x40/0x40
[ 1027.461731]  ? ___sys_recvmsg+0x1ab/0x250
[ 1027.464491]  ? shmem_evict_inode+0x87/0x240
[ 1027.467349]  ? init_wait_var_entry+0x40/0x40
[ 1027.470286]  ? fsnotify_grab_connector+0x45/0x90
[ 1027.473221]  ? fsnotify_destroy_marks+0x22/0xf0
[ 1027.476178]  ? __seccomp_filter+0x96/0x6c0
[ 1027.479045]  ? __dentry_kill+0x14f/0x1a0
[ 1027.481733]  ? kvm_clock_get_cycles+0x14/0x20
[ 1027.484542]  ? ktime_get_ts64+0x4c/0xe0
[ 1027.487323]  ? __x64_sys_ppoll+0xbb/0x110
[ 1027.490153]  __x64_sys_ppoll+0xbb/0x110
[ 1027.492889]  do_syscall_64+0x5b/0x1e0
[ 1027.495502]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1027.498483] RIP: 0033:0x7f60b575092d
[ 1027.501132] Code: 48 8b 52 08 48 89 44 24 10 8b 05 ee ed 2b 00 48 89 54 24 18 48 8d 54 24 10 85 c0 75 30 41 b8 08 00 00 00 b8 0f 01 00 00 0f 05 <48> 3d 00 f0 ff ff 77 73 48 83 c4 20 5b 5d 41 5c c3 66 90 8b 05 ba
[ 1027.510407] RSP: 002b:00007ffcb8705a70 EFLAGS: 00000246 ORIG_RAX: 000000000000010f
[ 1027.514922] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007f60b575092d
[ 1027.518889] RDX: 00007ffcb8705a80 RSI: 0000000000000001 RDI: 00007ffcb8705ac0
[ 1027.522841] RBP: 0000000000000001 R08: 0000000000000008 R09: 00007ffcb872d0b0
[ 1027.526843] R10: 0000000000000000 R11: 0000000000000246 R12: 00000000017d783b
[ 1027.530702] R13: 0000563d3e17ce30 R14: 0000000000000000 R15: 000000003eb10744
[ 1027.534670] CPU: 1 PID: 261 Comm: dbus-daemon Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.539363] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.543416] Call Trace:
[ 1027.544863]  dump_stack+0x5c/0x7b
[ 1027.546559]  __schedule_bug+0x55/0x70
[ 1027.548809]  __schedule+0x560/0x670
[ 1027.551199]  ? ep_item_poll+0x3f/0xb0
[ 1027.554014]  ? ep_poll+0x23e/0x510
[ 1027.556385]  schedule+0x34/0xb0
[ 1027.557935]  schedule_hrtimeout_range_clock+0x19e/0x1b0
[ 1027.559980]  ? ep_read_events_proc+0xe0/0xe0
[ 1027.562110]  ? ep_scan_ready_list+0x228/0x250
[ 1027.564859]  ? __switch_to_asm+0x40/0x70
[ 1027.566505]  ? __switch_to_asm+0x34/0x70
[ 1027.568179]  ? ep_poll+0x23e/0x510
[ 1027.570290]  ep_poll+0x21f/0x510
[ 1027.571741]  ? wake_up_q+0x80/0x80
[ 1027.573237]  do_epoll_wait+0xbd/0xe0
[ 1027.575255]  __x64_sys_epoll_wait+0x1a/0x20
[ 1027.577511]  do_syscall_64+0x5b/0x1e0
[ 1027.579095]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1027.581373] RIP: 0033:0x7f60d105c2e3
[ 1027.583288] Code: 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 83 3d 29 54 2b 00 00 75 13 49 89 ca b8 e8 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 0b c2 00 00 48 89 04 24
[ 1027.591216] RSP: 002b:00007ffda738f118 EFLAGS: 00000246 ORIG_RAX: 00000000000000e8
[ 1027.593894] RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 00007f60d105c2e3
[ 1027.597199] RDX: 0000000000000040 RSI: 00007ffda738f120 RDI: 0000000000000004
[ 1027.601159] RBP: 00007ffda738f4d0 R08: 0000000000000402 R09: 00007ffda73a80b0
[ 1027.603940] R10: 00000000ffffffff R11: 0000000000000246 R12: 000055f82d37b500
[ 1027.606577] R13: 0000000000000001 R14: 000055f82d3971e8 R15: 000055f82d39cd00
[ 1027.614459] BUG: sleeping function called from invalid context at mm/slab.h:457
[ 1027.621770] in_atomic(): 1, irqs_disabled(): 0, pid: 264, name: rs:main Q:Reg
[ 1027.627321] CPU: 1 PID: 264 Comm: rs:main Q:Reg Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.634447] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.641503] Call Trace:
[ 1027.645089]  dump_stack+0x5c/0x7b
[ 1027.649052]  ___might_sleep+0xf1/0x110
[ 1027.654233]  __kmalloc+0x186/0x220
[ 1027.659092]  security_prepare_creds+0x8a/0xa0
[ 1027.664729]  prepare_creds+0xd5/0x110
[ 1027.669133]  do_faccessat+0x3c/0x230
[ 1027.673566]  ? ksys_write+0x66/0xe0
[ 1027.677681]  do_syscall_64+0x5b/0x1e0
[ 1027.681915]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1027.686496] RIP: 0033:0x7f7f3aa8d9c7
[ 1027.690557] Code: 83 c4 08 48 3d 01 f0 ff ff 73 01 c3 48 8b 0d c8 d4 2b 00 f7 d8 64 89 01 48 83 c8 ff c3 66 0f 1f 44 00 00 b8 15 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d a1 d4 2b 00 f7 d8 64 89 01 48
[ 1027.703729] RSP: 002b:00007f7f38f403f8 EFLAGS: 00000246 ORIG_RAX: 0000000000000015
[ 1027.708542] RAX: ffffffffffffffda RBX: 00007f7f38f404e0 RCX: 00007f7f3aa8d9c7
[ 1027.711834] RDX: 00007f7f3ab1a850 RSI: 0000000000000000 RDI: 00007f7f3ab16f43
[ 1027.715464] RBP: 00007f7f38f4050c R08: 00007f7f300362ec R09: 00007f7f3aadfda0
[ 1027.718680] R10: 000055b0a5515280 R11: 0000000000000246 R12: 00007f7f38f40660
[ 1027.722348] R13: 000055b0a6fc9b20 R14: 000055b0a6fc9c10 R15: 0000000000000001
[ 1027.725522] BUG: scheduling while atomic: rs:main Q:Reg/264/0x00000005
[ 1027.729102] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.742015] CPU: 1 PID: 264 Comm: rs:main Q:Reg Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.746595] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.750411] Call Trace:
[ 1027.752982]  dump_stack+0x5c/0x7b
[ 1027.755243]  __schedule_bug+0x55/0x70
[ 1027.757282]  __schedule+0x560/0x670
[ 1027.759982]  schedule+0x34/0xb0
[ 1027.762139]  exit_to_usermode_loop+0x5c/0xf0
[ 1027.765267]  do_syscall_64+0x1a7/0x1e0
[ 1027.767852]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1027.771188] RIP: 0033:0x7f7f3aa8d9c7
[ 1027.773594] Code: 83 c4 08 48 3d 01 f0 ff ff 73 01 c3 48 8b 0d c8 d4 2b 00 f7 d8 64 89 01 48 83 c8 ff c3 66 0f 1f 44 00 00 b8 15 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d a1 d4 2b 00 f7 d8 64 89 01 48
[ 1027.782778] RSP: 002b:00007f7f38f403f8 EFLAGS: 00000246 ORIG_RAX: 0000000000000015
[ 1027.787564] RAX: fffffffffffffffe RBX: 00007f7f38f404e0 RCX: 00007f7f3aa8d9c7
[ 1027.790392] RDX: 00007f7f3ab1a850 RSI: 0000000000000000 RDI: 00007f7f3ab16f43
[ 1027.794576] RBP: 00007f7f38f4050c R08: 00007f7f300362ec R09: 00007f7f3aadfda0
[ 1027.797345] R10: 000055b0a5515280 R11: 0000000000000246 R12: 00007f7f38f40660
[ 1027.801338] R13: 000055b0a6fc9b20 R14: 000055b0a6fc9c10 R15: 0000000000000001
[ 1027.806481] rs:main Q:Reg[264]: segfault at 7f7f300371d8 ip 00007f7f3aa2a525 sp 00007f7f38f40630 error 6 in libc-2.24.so[7f7f3a9b2000+195000]
[ 1027.812964] Code: 01 16 32 00 48 29 e8 31 c9 48 8d 34 2a 48 39 fb 0f 95 c1 48 83 cd 01 48 83 c8 01 48 c1 e1 02 48 89 73 58 48 09 cd 48 89 6a 08 <48> 89 46 08 48 8d 42 10 48 83 c4 48 5b 5d 41 5c 41 5d 41 5e 41 5f
[ 1027.821383] BUG: scheduling while atomic: rs:main Q:Reg/264/0x00000003
[ 1027.824319] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.842129] CPU: 1 PID: 264 Comm: rs:main Q:Reg Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.846058] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.850241] Call Trace:
[ 1027.852537]  dump_stack+0x5c/0x7b
[ 1027.856448]  __schedule_bug+0x55/0x70
[ 1027.859812]  __schedule+0x560/0x670
[ 1027.861958]  ? force_sig_info+0xc7/0xe0
[ 1027.864876]  ? async_page_fault+0x8/0x30
[ 1027.868539]  schedule+0x34/0xb0
[ 1027.872143]  exit_to_usermode_loop+0x5c/0xf0
[ 1027.875005]  prepare_exit_to_usermode+0xa0/0xe0
[ 1027.877260]  retint_user+0x8/0x8
[ 1027.880534] RIP: 0033:0x7f7f3aa2a525
[ 1027.883724] Code: 01 16 32 00 48 29 e8 31 c9 48 8d 34 2a 48 39 fb 0f 95 c1 48 83 cd 01 48 83 c8 01 48 c1 e1 02 48 89 73 58 48 09 cd 48 89 6a 08 <48> 89 46 08 48 8d 42 10 48 83 c4 48 5b 5d 41 5c 41 5d 41 5e 41 5f
[ 1027.894440] RSP: 002b:00007f7f38f40630 EFLAGS: 00010202
[ 1027.898589] RAX: 0000000000000e31 RBX: 00007f7f30000020 RCX: 0000000000000004
[ 1027.902200] RDX: 00007f7f30036fc0 RSI: 00007f7f300371d0 RDI: 00007f7f3ad4bb00
[ 1027.906383] RBP: 0000000000000215 R08: 00007f7f30000000 R09: 0000000000037000
[ 1027.911204] R10: 00007f7f30037000 R11: 0000000000000206 R12: 0000000000000040
[ 1027.914322] R13: 00007f7f30036fc0 R14: 0000000000001000 R15: 0000000000000230
[ 1027.918621] BUG: scheduling while atomic: rs:main Q:Reg/264/0x00000003
[ 1027.923333] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1027.937497] CPU: 1 PID: 264 Comm: rs:main Q:Reg Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1027.941786] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1027.947455] Call Trace:
[ 1027.949422]  dump_stack+0x5c/0x7b
[ 1027.951408]  __schedule_bug+0x55/0x70
[ 1027.953837]  __schedule+0x560/0x670
[ 1027.956709]  ? enqueue_task_fair+0x1a4/0x960
[ 1027.960171]  ? wait_for_completion+0x123/0x1c0
[ 1027.962341]  schedule+0x34/0xb0
[ 1027.965777]  schedule_timeout+0x1f2/0x310
[ 1027.969002]  ? ttwu_do_wakeup+0x1e/0x150
[ 1027.972630]  ? wait_for_completion+0x123/0x1c0
[ 1027.975991]  wait_for_completion+0x15b/0x1c0
[ 1027.979743]  ? wake_up_q+0x80/0x80
[ 1027.983889]  do_coredump+0x350/0xfa0
[ 1027.987053]  ? __show_regs+0xae/0x2d0
[ 1027.990200]  ? __module_text_address+0xe/0x60
[ 1027.993195]  get_signal+0x16a/0x8a0
[ 1027.996308]  ? __switch_to_asm+0x34/0x70
[ 1027.999713]  ? __switch_to_asm+0x40/0x70
[ 1028.003131]  ? async_page_fault+0x8/0x30
[ 1028.006003]  do_signal+0x36/0x670
[ 1028.009099]  ? __switch_to+0x101/0x470
[ 1028.012206]  ? __schedule+0x25d/0x670
[ 1028.015399]  ? async_page_fault+0x8/0x30
[ 1028.018597]  ? async_page_fault+0x8/0x30
[ 1028.021154]  exit_to_usermode_loop+0x89/0xf0
[ 1028.023804]  prepare_exit_to_usermode+0xa0/0xe0
[ 1028.026953]  retint_user+0x8/0x8
[ 1028.029906] RIP: 0033:0x7f7f3aa2a525
[ 1028.033031] Code: 01 16 32 00 48 29 e8 31 c9 48 8d 34 2a 48 39 fb 0f 95 c1 48 83 cd 01 48 83 c8 01 48 c1 e1 02 48 89 73 58 48 09 cd 48 89 6a 08 <48> 89 46 08 48 8d 42 10 48 83 c4 48 5b 5d 41 5c 41 5d 41 5e 41 5f
[ 1028.042156] RSP: 002b:00007f7f38f40630 EFLAGS: 00010202
[ 1028.045456] RAX: 0000000000000e31 RBX: 00007f7f30000020 RCX: 0000000000000004
[ 1028.049389] RDX: 00007f7f30036fc0 RSI: 00007f7f300371d0 RDI: 00007f7f3ad4bb00
[ 1028.053725] RBP: 0000000000000215 R08: 00007f7f30000000 R09: 0000000000037000
[ 1028.056513] systemd[1]: segfault at 7ffd9115f2f8 ip 000055b3e7e387df sp 00007ffd9115f300 error 7 in systemd[55b3e7e00000+ed000]
[ 1028.057954] R10: 00007f7f30037000 R11: 0000000000000206 R12: 0000000000000040
[ 1028.057956] R13: 00007f7f30036fc0 R14: 0000000000001000 R15: 0000000000000230
[ 1028.060376] note: (systemd)[29521] exited with preempt_count 2
[ 1028.062283] Code: d2 31 c0 be 11 00 00 00 bf 38 00 00 00 e8 49 f3 fe ff 85 c0 49 89 c4 0f 88 af 02 00 00 0f 84 4e 01 00 00 48 8d 74 24 20 89 c7 <e8> 3c f3 fe ff 85 c0 41 89 c6 0f 88 49 03 00 00 44 8b 74 24 28 41
[ 1028.077142] BUG: scheduling while atomic: systemd/1/0x00000101
[ 1028.079432] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1028.090606] CPU: 0 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.093539] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.096557] Call Trace:
[ 1028.098204]  dump_stack+0x5c/0x7b
[ 1028.099913]  __schedule_bug+0x55/0x70
[ 1028.101807]  __schedule+0x560/0x670
[ 1028.103655]  ? force_sig_info+0xc7/0xe0
[ 1028.105457]  ? async_page_fault+0x8/0x30
[ 1028.107335]  schedule+0x34/0xb0
[ 1028.108967]  exit_to_usermode_loop+0x5c/0xf0
[ 1028.110918]  prepare_exit_to_usermode+0xa0/0xe0
[ 1028.112914]  retint_user+0x8/0x8
[ 1028.114616] RIP: 0033:0x55b3e7e387df
[ 1028.116383] Code: d2 31 c0 be 11 00 00 00 bf 38 00 00 00 e8 49 f3 fe ff 85 c0 49 89 c4 0f 88 af 02 00 00 0f 84 4e 01 00 00 48 8d 74 24 20 89 c7 <e8> 3c f3 fe ff 85 c0 41 89 c6 0f 88 49 03 00 00 44 8b 74 24 28 41
[ 1028.122835] RSP: 002b:00007ffd9115f300 EFLAGS: 00010202
[ 1028.125101] RAX: 0000000000007352 RBX: 00007ffd9115f3a0 RCX: 00007f70f2b2e469
[ 1028.127834] RDX: 00007f70f2dfa1de RSI: 00007ffd9115f320 RDI: 0000000000007352
[ 1028.130613] RBP: 000000000000000b R08: 0000000000000000 R09: 0000000000000013
[ 1028.133346] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000007352
[ 1028.136015] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[ 1028.291136] BUG: scheduling while atomic: systemd/1/0x00000101
[ 1028.293508] note: systemd[29522] exited with preempt_count 10
[ 1028.295468] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1028.298227] note: systemd-cgroups[29523] exited with preempt_count 6
[ 1028.315213] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.321359] note: systemd[29524] exited with preempt_count 8
[ 1028.323241] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.323243] Call Trace:
[ 1028.323264]  dump_stack+0x5c/0x7b
[ 1028.337985]  __schedule_bug+0x55/0x70
[ 1028.341117]  __schedule+0x560/0x670
[ 1028.344308]  ? _do_fork+0x13e/0x430
[ 1028.348012]  schedule+0x34/0xb0
[ 1028.351461]  exit_to_usermode_loop+0x5c/0xf0
[ 1028.355570]  do_syscall_64+0x1a7/0x1e0
[ 1028.358617]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1028.362529] RIP: 0033:0x7f70f2b2e469
[ 1028.366126] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d ff 49 2b 00 f7 d8 64 89 01 48
[ 1028.376240] RSP: 002b:00007ffd9115ed38 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[ 1028.382006] RAX: 0000000000007354 RBX: 00007ffd9115ede0 RCX: 00007f70f2b2e469
[ 1028.386191] RDX: 00007f70f2dfa1de RSI: 0000000000000000 RDI: 0000000000000011
[ 1028.390447] RBP: 000000000000000b R08: 0000000000000000 R09: 000055b3e7ed5478
[ 1028.395542] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000007352
[ 1028.399842] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[ 1028.404556] systemd[1]: segfault at 7f70f455a2f8 ip 00007f70f420e1c6 sp 00007ffd9115e3d0 error 7 in libsystemd-shared-232.so[7f70f4127000+192000]
[ 1028.414950] Code: 10 78 51 44 89 e0 83 e0 07 3b 05 45 60 13 00 0f 8e bf 00 00 00 89 d8 f7 d8 48 8b 94 24 28 08 00 00 64 48 33 14 25 28 00 00 00 <44> 89 55 00 0f 85 a6 00 00 00 48 81 c4 38 08 00 00 5b 5d 41 5c 41
[ 1028.427866] BUG: scheduling while atomic: systemd/1/0x00000005
[ 1028.433726] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1028.454314] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.461356] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.467907] Call Trace:
[ 1028.471795]  dump_stack+0x5c/0x7b
[ 1028.477133]  __schedule_bug+0x55/0x70
[ 1028.481254]  __schedule+0x560/0x670
[ 1028.485185]  ? force_sig_info+0xc7/0xe0
[ 1028.490054]  ? async_page_fault+0x8/0x30
[ 1028.494260]  schedule+0x34/0xb0
[ 1028.497970]  exit_to_usermode_loop+0x5c/0xf0
[ 1028.503246]  prepare_exit_to_usermode+0xa0/0xe0
[ 1028.507376]  retint_user+0x8/0x8
[ 1028.511137] RIP: 0033:0x7f70f420e1c6
[ 1028.515620] Code: 10 78 51 44 89 e0 83 e0 07 3b 05 45 60 13 00 0f 8e bf 00 00 00 89 d8 f7 d8 48 8b 94 24 28 08 00 00 64 48 33 14 25 28 00 00 00 <44> 89 55 00 0f 85 a6 00 00 00 48 81 c4 38 08 00 00 5b 5d 41 5c 41
[ 1028.530270] RSP: 002b:00007ffd9115e3d0 EFLAGS: 00010246
[ 1028.534156] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00000000fffffffe
[ 1028.538848] RDX: 0000000000000000 RSI: 00007ffd9115d910 RDI: 0000000000000000
[ 1028.543472] RBP: 00007f70f455a2f8 R08: 000000000000ff00 R09: 0000000000000076
[ 1028.549765] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
[ 1028.554497] R13: 000055b3e7ec89a7 R14: 000055b3e7eb9900 R15: 00007ffd9115ec50
[ 1028.559959] systemd[1]: segfault at 7ffd9115ddf8 ip 000055b3e7e387df sp 00007ffd9115de00 error 7 in systemd[55b3e7e00000+ed000]
[ 1028.563711] note: systemd[29525] exited with preempt_count 8
[ 1028.568045] Code: d2 31 c0 be 11 00 00 00 bf 38 00 00 00 e8 49 f3 fe ff 85 c0 49 89 c4 0f 88 af 02 00 00 0f 84 4e 01 00 00 48 8d 74 24 20 89 c7 <e8> 3c f3 fe ff 85 c0 41 89 c6 0f 88 49 03 00 00 44 8b 74 24 28 41
[ 1028.581705] BUG: scheduling while atomic: systemd/1/0x00000101
[ 1028.586305] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1028.606428] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.612931] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.617898] Call Trace:
[ 1028.621540]  dump_stack+0x5c/0x7b
[ 1028.625205]  __schedule_bug+0x55/0x70
[ 1028.628488]  __schedule+0x560/0x670
[ 1028.631736]  ? force_sig_info+0xc7/0xe0
[ 1028.635875]  ? async_page_fault+0x8/0x30
[ 1028.639305]  schedule+0x34/0xb0
[ 1028.642904]  exit_to_usermode_loop+0x5c/0xf0
[ 1028.647455]  prepare_exit_to_usermode+0xa0/0xe0
[ 1028.651738]  retint_user+0x8/0x8
[ 1028.654830] RIP: 0033:0x55b3e7e387df
[ 1028.657923] Code: d2 31 c0 be 11 00 00 00 bf 38 00 00 00 e8 49 f3 fe ff 85 c0 49 89 c4 0f 88 af 02 00 00 0f 84 4e 01 00 00 48 8d 74 24 20 89 c7 <e8> 3c f3 fe ff 85 c0 41 89 c6 0f 88 49 03 00 00 44 8b 74 24 28 41
[ 1028.669529] RSP: 002b:00007ffd9115de00 EFLAGS: 00010206
[ 1028.674148] RAX: 0000000000007355 RBX: 00007ffd9115dea0 RCX: 00007f70f2b2e469
[ 1028.678643] RDX: 00007f70f2dfa1de RSI: 00007ffd9115de20 RDI: 0000000000007355
[ 1028.684384] RBP: 000000000000000b R08: 0000000000000000 R09: 00007ffd9115ed30
[ 1028.688712] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000007355
[ 1028.694207] R13: 0000000000000000 R14: 000055b3e7eb9900 R15: 00007ffd9115ec50
[ 1028.698943] BUG: sleeping function called from invalid context at mm/slab.h:457
[ 1028.705135] in_atomic(): 1, irqs_disabled(): 0, pid: 1, name: systemd
[ 1028.709499] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.715113] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.720857] Call Trace:
[ 1028.723657]  dump_stack+0x5c/0x7b
[ 1028.726746]  ___might_sleep+0xf1/0x110
[ 1028.729978]  kmem_cache_alloc_node_trace+0x1cf/0x1f0
[ 1028.734557]  __get_vm_area_node+0x7a/0x170
[ 1028.738118]  __vmalloc_node_range+0x6d/0x260
[ 1028.742207]  ? _do_fork+0xce/0x430
[ 1028.745957]  copy_process+0x8d6/0x1b60
[ 1028.749353]  ? _do_fork+0xce/0x430
[ 1028.752351]  ? copy_fpstate_to_sigframe+0x318/0x3b0
[ 1028.756138]  _do_fork+0xce/0x430
[ 1028.759602]  do_syscall_64+0x5b/0x1e0
[ 1028.762430]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1028.766866] RIP: 0033:0x7f70f2b2e469
[ 1028.769766] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d ff 49 2b 00 f7 d8 64 89 01 48
[ 1028.780821] RSP: 002b:00007ffd9115d838 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[ 1028.786738] RAX: ffffffffffffffda RBX: 00007ffd9115d8e0 RCX: 00007f70f2b2e469
[ 1028.791246] RDX: 00007f70f2dfa1de RSI: 0000000000000000 RDI: 0000000000000011
[ 1028.796548] RBP: 000000000000000b R08: 0000000000000000 R09: 00007f70f425c6ad
[ 1028.801917] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000007355
[ 1028.806264] R13: 0000000000000000 R14: 000055b3e7eb9900 R15: 00007ffd9115ec50
[ 1028.812652] BUG: scheduling while atomic: systemd/1/0x00000101
[ 1028.816688] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1028.836033] CPU: 1 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.841916] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.848165] Call Trace:
[ 1028.851169]  dump_stack+0x5c/0x7b
[ 1028.855034]  __schedule_bug+0x55/0x70
[ 1028.858866]  __schedule+0x560/0x670
[ 1028.862040]  ? _do_fork+0x13e/0x430
[ 1028.865329]  schedule+0x34/0xb0
[ 1028.869115]  exit_to_usermode_loop+0x5c/0xf0
[ 1028.873514]  do_syscall_64+0x1a7/0x1e0
[ 1028.876621]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1028.880199] RIP: 0033:0x7f70f2b2e469
[ 1028.883704] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d ff 49 2b 00 f7 d8 64 89 01 48
[ 1028.893950] RSP: 002b:00007ffd9115d838 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[ 1028.899852] RAX: 0000000000007356 RBX: 00007ffd9115d8e0 RCX: 00007f70f2b2e469
[ 1028.904040] RDX: 00007f70f2dfa1de RSI: 0000000000000000 RDI: 0000000000000011
[ 1028.909513] RBP: 000000000000000b R08: 0000000000000000 R09: 00007f70f425c6ad
[ 1028.913649] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000007355
[ 1028.917973] R13: 0000000000000000 R14: 000055b3e7eb9900 R15: 00007ffd9115ec50
[ 1028.923936] oom-killer[1012]: segfault at 55d8de51ca6c ip 000055d8dde77bec sp 00007ffec5ba4130 error 7 in dash[55d8dde6c000+1b000]
[ 1028.931540] Code: 89 c6 74 06 48 8b 43 10 8b 30 89 ef e8 55 79 ff ff 41 83 fd 01 0f 84 73 01 00 00 0f b7 43 1c 48 8b 53 10 8d 48 01 48 c1 e0 04 <66> 89 4b 1c 48 8d 1c 02 48 8d 05 a5 30 21 00 48 89 43 08 8b 05 67
[ 1028.937120] note: dmesg[29527] exited with preempt_count 20
[ 1028.943263] BUG: scheduling while atomic: oom-killer/1012/0x000000ab
[ 1028.943265] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1028.971922] CPU: 1 PID: 1012 Comm: oom-killer Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1028.977277] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1028.982421] Call Trace:
[ 1028.985520]  dump_stack+0x5c/0x7b
[ 1028.989498]  __schedule_bug+0x55/0x70
[ 1028.993886]  __schedule+0x560/0x670
[ 1028.997362]  ? force_sig_info+0xc7/0xe0
[ 1029.000658]  ? async_page_fault+0x8/0x30
[ 1029.004928]  schedule+0x34/0xb0
[ 1029.007887]  exit_to_usermode_loop+0x5c/0xf0
[ 1029.012051]  prepare_exit_to_usermode+0xa0/0xe0
[ 1029.016064]  retint_user+0x8/0x8
[ 1029.019036] RIP: 0033:0x55d8dde77bec
[ 1029.022100] Code: 89 c6 74 06 48 8b 43 10 8b 30 89 ef e8 55 79 ff ff 41 83 fd 01 0f 84 73 01 00 00 0f b7 43 1c 48 8b 53 10 8d 48 01 48 c1 e0 04 <66> 89 4b 1c 48 8d 1c 02 48 8d 05 a5 30 21 00 48 89 43 08 8b 05 67
[ 1029.033718] RSP: 002b:00007ffec5ba4130 EFLAGS: 00010256
[ 1029.037691] RAX: 0000000000000000 RBX: 000055d8de51ca50 RCX: 0000000000000001
[ 1029.044253] RDX: 000055d8de51cbc0 RSI: 0000000000000000 RDI: 0000000001200011
[ 1029.049040] RBP: 0000000000007357 R08: 00007fe496bda700 R09: 000000000000001f
[ 1029.054197] R10: 00007fe496bda9d0 R11: 0000000000000246 R12: 000055d8de51c580
[ 1029.059459] R13: 0000000000000000 R14: 00007ffec5ba4180 R15: 000055d8de51c580
[ 1029.069642] note: systemd[29526] exited with preempt_count 8
[ 1029.075197] note: oom-killer[1012] exited with preempt_count 2
[ 1029.076618] WARNING: CPU: 0 PID: 1 at arch/x86/kernel/fpu/signal.c:167 copy_fpstate_to_sigframe+0x393/0x3b0
[ 1029.083698] note: systemd[29528] exited with preempt_count 8
[ 1029.088386] Modules linked in: sr_mod cdrom sg crct10dif_pclmul crc32_pclmul ppdev crc32c_intel ghash_clmulni_intel bochs_drm ttm aesni_intel drm_kms_helper ata_generic pata_acpi crypto_simd syscopyarea sysfillrect sysimgblt cryptd fb_sys_fops snd_pcm glue_helper joydev snd_timer drm snd serio_raw soundcore pcspkr ata_piix libata i2c_piix4 parport_pc floppy parport ip_tables
[ 1029.088425] CPU: 0 PID: 1 Comm: systemd Tainted: G        W         5.1.0-12240-ge522719 #1
[ 1029.088433] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[ 1029.122518] RIP: 0010:copy_fpstate_to_sigframe+0x393/0x3b0
[ 1029.127225] Code: c0 f7 d8 e9 fb fd ff ff bb f2 ff ff ff e9 3a fe ff ff 0f 0b e9 3b fd ff ff 83 ca f2 eb d9 49 c7 c4 20 0b 8e b7 e9 60 ff ff ff <0f> 0b e9 b1 fc ff ff b8 ff ff ff ff e9 c8 fd ff ff e8 27 17 06 00
[ 1029.138673] RSP: 0000:ffffb07e00c5fdf8 EFLAGS: 00010206
[ 1029.143275] RAX: 0000000080000100 RBX: ffffb07e00c5ff58 RCX: ffffb07e00c5fe80
[ 1029.148328] RDX: 0000000000000200 RSI: 00007ffd9115c680 RDI: 00007ffd9115c680
[ 1029.153473] RBP: 00007ffd9115c680 R08: 00007ffd9115c4c0 R09: ffffffffb5ab1f0b
[ 1029.158429] R10: 00007ffd9115c680 R11: 0000000000000000 R12: ffff98f046dd8af8
[ 1029.163529] R13: 000000000000000b R14: ffff98f046dd8000 R15: 00007ffd9115c4b8
[ 1029.168297] FS:  00007f70f455a500(0000) GS:ffff98f17fc00000(0000) knlGS:0000000000000000
[ 1029.173510] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1029.177915] CR2: 00007ffd9115c8f8 CR3: 00000001bf09a000 CR4: 00000000000006f0
[ 1029.182603] Call Trace:
[ 1029.185775]  do_signal+0x57f/0x670
[ 1029.189322]  ? async_page_fault+0x8/0x30
[ 1029.192814]  exit_to_usermode_loop+0x89/0xf0
[ 1029.196356]  prepare_exit_to_usermode+0xa0/0xe0
[ 1029.200001]  retint_user+0x8/0x8
[ 1029.203114] RIP: 0033:0x55b3e7e387df
[ 1029.206360] Code: d2 31 c0 be 11 00 00 00 bf 38 00 00 00 e8 49 f3 fe ff 85 c0 49 89 c4 0f 88 af 02 00 00 0f 84 4e 01 00 00 48 8d 74 24 20 89 c7 <e8> 3c f3 fe ff 85 c0 41 89 c6 0f 88 49 03 00 00 44 8b 74 24 28 41
[ 1029.216737] RSP: 002b:00007ffd9115c900 EFLAGS: 00010202
[ 1029.220774] RAX: 0000000000007358 RBX: 00007ffd9115c9a0 RCX: 00007f70f2b2e469
[ 1029.225287] RDX: 00007f70f2dfa1de RSI: 00007ffd9115c920 RDI: 0000000000007358
[ 1029.229884] RBP: 000000000000000b R08: 0000000000000000 R09: 00007ffd9115d830
[ 1029.234573] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000007358
[ 1029.239053] R13: 0000000000000000 R14: 000055b3e7eb9900 R15: 00007ffd9115d750
[ 1029.243783] ---[ end trace cb78806200d92def ]---


To reproduce:

        # build kernel
	cd linux
	cp config-5.1.0-12240-ge522719 .config
	make HOSTCC=gcc-7 CC=gcc-7 ARCH=x86_64 olddefconfig
	make HOSTCC=gcc-7 CC=gcc-7 ARCH=x86_64 prepare
	make HOSTCC=gcc-7 CC=gcc-7 ARCH=x86_64 modules_prepare
	make HOSTCC=gcc-7 CC=gcc-7 ARCH=x86_64 SHELL=/bin/bash
	make HOSTCC=gcc-7 CC=gcc-7 ARCH=x86_64 bzImage


        git clone https://github.com/intel/lkp-tests.git
        cd lkp-tests
        bin/lkp qemu -k <bzImage> job-script # job-script is attached in this email



Thanks,
Rong Chen


--GUPx2O/K0ibUojHx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-5.1.0-12240-ge522719"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.1.0 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_CC_HAS_ASM_GOTO=y
CONFIG_CC_HAS_WARN_MAYBE_UNINITIALIZED=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_BUILD_SALT=""
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_ARCH_CLOCKSOURCE_INIT=y
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
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_HAVE_SCHED_AVG_IRQ=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
# CONFIG_PSI is not set
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
# CONFIG_IKHEADERS_PROC is not set
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
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
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_IO_URING=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_RSEQ=y
# CONFIG_DEBUG_RSEQ is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
# CONFIG_SHUFFLE_PAGE_ALLOCATOR is not set
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_SYSTEM_DATA_VERIFICATION=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
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
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DYNAMIC_PHYSICAL_MASK=y
CONFIG_PGTABLE_LEVELS=5
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_X86_CPU_RESCTRL=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_NUMACHIP is not set
# CONFIG_X86_VSMP is not set
CONFIG_X86_UV=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=y
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_XXL=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
CONFIG_XEN=y
CONFIG_XEN_PV=y
CONFIG_XEN_PV_SMP=y
# CONFIG_XEN_DOM0 is not set
CONFIG_XEN_PVHVM=y
CONFIG_XEN_PVHVM_SMP=y
CONFIG_XEN_512GB=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
# CONFIG_PVH is not set
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
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
CONFIG_CPU_SUP_HYGON=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_MAXSMP=y
CONFIG_NR_CPUS_RANGE_BEGIN=8192
CONFIG_NR_CPUS_RANGE_END=8192
CONFIG_NR_CPUS_DEFAULT=8192
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y

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
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_X86_5LEVEL=y
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT is not set
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=m
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=1
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_EFI_MIXED=y
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
CONFIG_KEXEC_VERIFY_SIG=y
CONFIG_KEXEC_BZIMAGE_VERIFY_SIG=y
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_DYNAMIC_MEMORY_LAYOUT=y
CONFIG_RANDOMIZE_MEMORY=y
CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING=0xa
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
# CONFIG_ENERGY_MODEL is not set
CONFIG_ARCH_SUPPORTS_ACPI=y
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
CONFIG_ACPI_EC_DEBUGFS=m
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_TAD is not set
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=m
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
# CONFIG_NFIT_SECURITY_DEBUG is not set
# CONFIG_ACPI_HMAT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=m
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_DPTF_POWER is not set
CONFIG_ACPI_WATCHDOG=y
CONFIG_ACPI_EXTLOG=m
CONFIG_ACPI_ADXL=y
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
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_AMD_FREQ_SENSITIVITY=m
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_CPU_IDLE_GOV_TEO is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
CONFIG_IA32_EMULATION=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_VARS_PSTORE=y
CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=y
CONFIG_EFI_RUNTIME_MAP=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
# CONFIG_EFI_BOOTLOADER_CONTROL is not set
# CONFIG_EFI_CAPSULE_LOADER is not set
# CONFIG_EFI_TEST is not set
CONFIG_APPLE_PROPERTIES=y
# CONFIG_RESET_ATTACK_MITIGATION is not set
CONFIG_UEFI_CPER=y
CONFIG_UEFI_CPER_X86=y
CONFIG_EFI_DEV_PATH_PARSER=y
CONFIG_EFI_EARLYCON=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_COMPAT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
CONFIG_KVM_AMD_SEV=y
CONFIG_KVM_MMU_AUDIT=y
CONFIG_VHOST_NET=m
# CONFIG_VHOST_SCSI is not set
CONFIG_VHOST_VSOCK=m
CONFIG_VHOST=m
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_HOTPLUG_SMT=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
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
CONFIG_ARCH_HAS_SET_DIRECT_MAP=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_FUNCTION_ARG_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_ARCH_JUMP_LABEL_RELATIVE=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_ARCH_STACKLEAK=y
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
CONFIG_STACKPROTECTOR=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_MOVE_PMD=y
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
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
CONFIG_64BIT_TIME=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
CONFIG_ARCH_USE_MEMREMAP_PROT=y
# CONFIG_LOCK_EVENT_COUNTS is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y

#
# GCC plugins
#
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
# CONFIG_GCC_PLUGIN_LATENT_ENTROPY is not set
# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
CONFIG_MODULE_SIG_ALL=y
# CONFIG_MODULE_SIG_SHA1 is not set
# CONFIG_MODULE_SIG_SHA224 is not set
CONFIG_MODULE_SIG_SHA256=y
# CONFIG_MODULE_SIG_SHA384 is not set
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha256"
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_ZONED=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_DEV_THROTTLING_LOW is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
# CONFIG_BLK_CGROUP_IOLATENCY is not set
CONFIG_BLK_DEBUG_FS=y
CONFIG_BLK_DEBUG_FS_ZONED=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_PM=y

#
# IO Schedulers
#
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_KYBER=y
# CONFIG_IOSCHED_BFQ is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_CONTIG_ALLOC=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_MEM_SOFT_DIRTY=y
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_ZONE_DEVICE=y
CONFIG_ARCH_HAS_HMM_MIRROR=y
CONFIG_ARCH_HAS_HMM_DEVICE=y
CONFIG_ARCH_HAS_HMM=y
CONFIG_MIGRATE_VMA_HELPER=y
CONFIG_DEV_PAGEMAP_OPS=y
CONFIG_HMM=y
CONFIG_HMM_MIRROR=y
# CONFIG_DEVICE_PRIVATE is not set
# CONFIG_DEVICE_PUBLIC is not set
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y
CONFIG_SKB_EXTENSIONS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_SCM=y
CONFIG_UNIX_DIAG=m
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_INTERFACE is not set
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
# CONFIG_XDP_SOCKETS is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IP_TUNNEL=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE_COMMON=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=m
CONFIG_NET_UDP_TUNNEL=m
CONFIG_NET_FOU=m
CONFIG_NET_FOU_IP_TUNNELS=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
# CONFIG_INET_ESP_OFFLOAD is not set
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_INET_UDP_DIAG=m
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
# CONFIG_TCP_CONG_NV is not set
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
CONFIG_TCP_CONG_DCTCP=m
# CONFIG_TCP_CONG_CDG is not set
# CONFIG_TCP_CONG_BBR is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
# CONFIG_INET6_ESP_OFFLOAD is not set
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_IPV6_VTI=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_GRE=m
CONFIG_IPV6_FOU=m
CONFIG_IPV6_FOU_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
CONFIG_IPV6_SEG6_LWTUNNEL=y
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_IPV6_SEG6_BPF=y
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=m

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_FAMILY_BRIDGE=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_ACCT=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NETFILTER_NETLINK_OSF=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_LOG_COMMON=m
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NETFILTER_CONNCOUNT=m
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
CONFIG_NF_CT_NETLINK_TIMEOUT=m
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_SIP=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_REDIRECT=y
CONFIG_NF_NAT_MASQUERADE=y
CONFIG_NETFILTER_SYNPROXY=m
CONFIG_NF_TABLES=m
# CONFIG_NF_TABLES_SET is not set
# CONFIG_NF_TABLES_INET is not set
# CONFIG_NF_TABLES_NETDEV is not set
# CONFIG_NFT_NUMGEN is not set
CONFIG_NFT_CT=m
CONFIG_NFT_COUNTER=m
# CONFIG_NFT_CONNLIMIT is not set
CONFIG_NFT_LOG=m
CONFIG_NFT_LIMIT=m
CONFIG_NFT_MASQ=m
CONFIG_NFT_REDIR=m
# CONFIG_NFT_TUNNEL is not set
# CONFIG_NFT_OBJREF is not set
CONFIG_NFT_QUEUE=m
# CONFIG_NFT_QUOTA is not set
CONFIG_NFT_REJECT=m
CONFIG_NFT_COMPAT=m
CONFIG_NFT_HASH=m
# CONFIG_NFT_XFRM is not set
# CONFIG_NFT_SOCKET is not set
# CONFIG_NFT_OSF is not set
# CONFIG_NFT_TPROXY is not set
# CONFIG_NF_FLOW_TABLE is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_HMARK=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_NAT=m
CONFIG_NETFILTER_XT_TARGET_NETMAP=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
CONFIG_NETFILTER_XT_TARGET_MASQUERADE=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_BPF=m
CONFIG_NETFILTER_XT_MATCH_CGROUP=m
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ECN=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_L2TP=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_SOCKET=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
CONFIG_IP_SET_HASH_IPMARK=m
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
CONFIG_IP_SET_HASH_IPMAC=m
CONFIG_IP_SET_HASH_MAC=m
CONFIG_IP_SET_HASH_NETPORTNET=m
CONFIG_IP_SET_HASH_NET=m
CONFIG_IP_SET_HASH_NETNET=m
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_HASH_NETIFACE=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
# CONFIG_IP_VS_FO is not set
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
# CONFIG_IP_VS_MH is not set
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS MH scheduler
#
CONFIG_IP_VS_MH_TAB_INDEX=12

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_SOCKET_IPV4=m
CONFIG_NF_TPROXY_IPV4=m
# CONFIG_NF_TABLES_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
CONFIG_NF_DUP_IPV4=m
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_RPFILTER=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_SYNPROXY=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_SOCKET_IPV6=m
CONFIG_NF_TPROXY_IPV6=m
# CONFIG_NF_TABLES_IPV6 is not set
CONFIG_NF_DUP_IPV6=m
CONFIG_NF_REJECT_IPV6=m
CONFIG_NF_LOG_IPV6=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RPFILTER=m
CONFIG_IP6_NF_MATCH_RT=m
# CONFIG_IP6_NF_MATCH_SRH is not set
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_TARGET_SYNPROXY=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
CONFIG_IP6_NF_NAT=m
CONFIG_IP6_NF_TARGET_MASQUERADE=m
CONFIG_IP6_NF_TARGET_NPT=m
CONFIG_NF_DEFRAG_IPV6=m
# CONFIG_NF_TABLES_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
# CONFIG_BPFILTER is not set
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=m
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
CONFIG_L2TP_DEBUGFS=m
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=m
CONFIG_L2TP_ETH=m
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_MRP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
CONFIG_6LOWPAN=m
# CONFIG_6LOWPAN_DEBUGFS is not set
CONFIG_6LOWPAN_NHC=m
CONFIG_6LOWPAN_NHC_DEST=m
CONFIG_6LOWPAN_NHC_FRAGMENT=m
CONFIG_6LOWPAN_NHC_HOP=m
CONFIG_6LOWPAN_NHC_IPV6=m
CONFIG_6LOWPAN_NHC_MOBILITY=m
CONFIG_6LOWPAN_NHC_ROUTING=m
CONFIG_6LOWPAN_NHC_UDP=m
# CONFIG_6LOWPAN_GHC_EXT_HDR_HOP is not set
# CONFIG_6LOWPAN_GHC_UDP is not set
# CONFIG_6LOWPAN_GHC_ICMPV6 is not set
# CONFIG_6LOWPAN_GHC_EXT_HDR_DEST is not set
# CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG is not set
# CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE is not set
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_IEEE802154_6LOWPAN=m
CONFIG_MAC802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
# CONFIG_NET_SCH_CBS is not set
# CONFIG_NET_SCH_ETF is not set
# CONFIG_NET_SCH_TAPRIO is not set
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
# CONFIG_NET_SCH_SKBPRIO is not set
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
# CONFIG_NET_SCH_CAKE is not set
CONFIG_NET_SCH_FQ=m
# CONFIG_NET_SCH_HHF is not set
# CONFIG_NET_SCH_PIE is not set
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_SCH_PLUG=m
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_FLOWER=m
CONFIG_NET_CLS_MATCHALL=m
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
# CONFIG_NET_EMATCH_CANID is not set
CONFIG_NET_EMATCH_IPSET=m
# CONFIG_NET_EMATCH_IPT is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_SAMPLE=m
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
CONFIG_NET_ACT_CSUM=m
CONFIG_NET_ACT_VLAN=m
# CONFIG_NET_ACT_BPF is not set
CONFIG_NET_ACT_CONNMARK=m
CONFIG_NET_ACT_SKBMOD=m
# CONFIG_NET_ACT_IFE is not set
CONFIG_NET_ACT_TUNNEL_KEY=m
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_OPENVSWITCH_GENEVE=m
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS_COMMON=m
CONFIG_HYPERV_VSOCKETS=m
CONFIG_NETLINK_DIAG=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_MPLS_ROUTING is not set
CONFIG_NET_NSH=m
# CONFIG_HSR is not set
CONFIG_NET_SWITCHDEV=y
CONFIG_NET_L3_MASTER_DEV=y
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m
CONFIG_CAN_GW=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=m
# CONFIG_CAN_VXCAN is not set
CONFIG_CAN_SLCAN=m
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_C_CAN=m
CONFIG_CAN_C_CAN_PLATFORM=m
CONFIG_CAN_C_CAN_PCI=m
CONFIG_CAN_CC770=m
# CONFIG_CAN_CC770_ISA is not set
CONFIG_CAN_CC770_PLATFORM=m
# CONFIG_CAN_IFI_CANFD is not set
# CONFIG_CAN_M_CAN is not set
# CONFIG_CAN_PEAK_PCIEFD is not set
CONFIG_CAN_SJA1000=m
# CONFIG_CAN_SJA1000_ISA is not set
CONFIG_CAN_SJA1000_PLATFORM=m
CONFIG_CAN_EMS_PCI=m
CONFIG_CAN_PEAK_PCI=m
CONFIG_CAN_PEAK_PCIEC=y
CONFIG_CAN_KVASER_PCI=m
CONFIG_CAN_PLX_PCI=m
CONFIG_CAN_SOFTING=m

#
# CAN SPI interfaces
#
# CONFIG_CAN_HI311X is not set
# CONFIG_CAN_MCP251X is not set

#
# CAN USB interfaces
#
CONFIG_CAN_8DEV_USB=m
CONFIG_CAN_EMS_USB=m
CONFIG_CAN_ESD_USB2=m
# CONFIG_CAN_GS_USB is not set
CONFIG_CAN_KVASER_USB=m
# CONFIG_CAN_MCBA_USB is not set
CONFIG_CAN_PEAK_USB=m
# CONFIG_CAN_UCAN is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_BT=m
CONFIG_BT_BREDR=y
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=m
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_CMTP=m
CONFIG_BT_HIDP=m
CONFIG_BT_HS=y
CONFIG_BT_LE=y
# CONFIG_BT_6LOWPAN is not set
# CONFIG_BT_LEDS is not set
# CONFIG_BT_SELFTEST is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=m
CONFIG_BT_BCM=m
CONFIG_BT_RTL=m
CONFIG_BT_HCIBTUSB=m
# CONFIG_BT_HCIBTUSB_AUTOSUSPEND is not set
CONFIG_BT_HCIBTUSB_BCM=y
CONFIG_BT_HCIBTUSB_RTL=y
CONFIG_BT_HCIBTSDIO=m
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
# CONFIG_BT_HCIUART_INTEL is not set
# CONFIG_BT_HCIUART_AG6XX is not set
# CONFIG_BT_HCIUART_MRVL is not set
CONFIG_BT_HCIBCM203X=m
CONFIG_BT_HCIBPA10X=m
CONFIG_BT_HCIBFUSB=m
CONFIG_BT_HCIVHCI=m
CONFIG_BT_MRVL=m
CONFIG_BT_MRVL_SDIO=m
CONFIG_BT_ATH3K=m
# CONFIG_BT_MTKSDIO is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=m
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
# CONFIG_NFC is not set
CONFIG_PSAMPLE=m
# CONFIG_NET_IFE is not set
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_SOCK_MSG=y
CONFIG_NET_DEVLINK=y
CONFIG_FAILOVER=m
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_HAVE_EISA=y
# CONFIG_EISA is not set
CONFIG_HAVE_PCI=y
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIE_ECRC=y
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
# CONFIG_PCIE_PTM is not set
# CONFIG_PCIE_BW is not set
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_PCI_PF_STUB is not set
# CONFIG_XEN_PCIDEV_FRONTEND is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
# CONFIG_PCI_P2PDMA is not set
CONFIG_PCI_LABEL=y
CONFIG_PCI_HYPERV=m
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
CONFIG_VMD=y

#
# DesignWare PCI Core Support
#
# CONFIG_PCIE_DW_PLAT_HOST is not set
# CONFIG_PCI_MESON is not set

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_GNSS is not set
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#
# CONFIG_MTD_REDBOOT_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_MCHP23K256 is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_ONENAND is not set
# CONFIG_MTD_RAW_NAND is not set
# CONFIG_MTD_SPI_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_NULL_BLK_FAULT_INJECTION=y
CONFIG_BLK_DEV_FD=m
CONFIG_CDROM=m
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=m
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=0
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_SKD is not set
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
CONFIG_BLK_DEV_RBD=m
# CONFIG_BLK_DEV_RSXX is not set

#
# NVME Support
#
CONFIG_NVME_CORE=m
CONFIG_BLK_DEV_NVME=m
CONFIG_NVME_MULTIPATH=y
CONFIG_NVME_FABRICS=m
CONFIG_NVME_FC=m
# CONFIG_NVME_TCP is not set
CONFIG_NVME_TARGET=m
CONFIG_NVME_TARGET_LOOP=m
CONFIG_NVME_TARGET_FC=m
CONFIG_NVME_TARGET_FCLOOP=m
# CONFIG_NVME_TARGET_TCP is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_SGI_XP=m
CONFIG_HP_ILO=m
CONFIG_SGI_GRU=m
# CONFIG_SGI_GRU_DEBUG is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=m
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_PVPANIC=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
# CONFIG_EEPROM_EE1004 is not set
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=m
CONFIG_INTEL_MEI_ME=m
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_INTEL_MEI_HDCP is not set
CONFIG_VMWARE_VMCI=m

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
# CONFIG_MISC_ALCOR_PCI is not set
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
# CONFIG_HABANA_AI is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
CONFIG_SCSI_CXGB4_ISCSI=m
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BE2ISCSI=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=m
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=m
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=m
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=m
CONFIG_SCSI_UFSHCD_PCI=m
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
# CONFIG_SCSI_UFS_BSG is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_MYRB is not set
# CONFIG_SCSI_MYRS is not set
CONFIG_VMWARE_PVSCSI=m
# CONFIG_XEN_SCSI_FRONTEND is not set
CONFIG_HYPERV_STORAGE=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
CONFIG_SCSI_STEX=m
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
CONFIG_TCM_QLA2XXX=m
# CONFIG_TCM_QLA2XXX_DEBUG is not set
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_QEDI is not set
# CONFIG_QEDF is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
CONFIG_SCSI_PM8001=m
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=m
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_ATA=m
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_MOBILE_LPM_POLICY=0
CONFIG_SATA_AHCI_PLATFORM=m
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
# CONFIG_SATA_DWC is not set
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
CONFIG_PATA_NINJA32=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=m
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=m
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
# CONFIG_MD_CLUSTER is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
# CONFIG_DM_UNSTRIPED is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
CONFIG_DM_CACHE_SMQ=m
# CONFIG_DM_WRITECACHE is not set
CONFIG_DM_ERA=m
CONFIG_DM_MIRROR=m
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
# CONFIG_DM_DUST is not set
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
# CONFIG_DM_VERITY_FEC is not set
CONFIG_DM_SWITCH=m
CONFIG_DM_LOG_WRITES=m
# CONFIG_DM_INTEGRITY is not set
# CONFIG_DM_ZONED is not set
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
CONFIG_TCM_USER2=m
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
CONFIG_ISCSI_TARGET=m
CONFIG_ISCSI_TARGET_CXGB4=m
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_FC is not set
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
CONFIG_IFB=m
CONFIG_NET_TEAM=m
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=m
CONFIG_NET_TEAM_MODE_RANDOM=m
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=m
CONFIG_NET_TEAM_MODE_LOADBALANCE=m
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
# CONFIG_IPVLAN is not set
CONFIG_VXLAN=m
CONFIG_GENEVE=m
# CONFIG_GTP is not set
CONFIG_MACSEC=y
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_NTB_NETDEV=m
CONFIG_TUN=m
CONFIG_TAP=m
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=m
CONFIG_VIRTIO_NET=m
CONFIG_NLMON=m
CONFIG_NET_VRF=y
CONFIG_VSOCKMON=m
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_ENA_ETHERNET=m
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=m
CONFIG_PCNET32=m
CONFIG_AMD_XGBE=m
# CONFIG_AMD_XGBE_DCB is not set
CONFIG_AMD_XGBE_HAVE_ECC=y
CONFIG_NET_VENDOR_AQUANTIA=y
CONFIG_AQTION=m
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_ALX=m
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
# CONFIG_BCMGENET is not set
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_TIGON3=y
CONFIG_TIGON3_HWMON=y
CONFIG_BNX2X=m
CONFIG_BNX2X_SRIOV=y
# CONFIG_SYSTEMPORT is not set
CONFIG_BNXT=m
CONFIG_BNXT_SRIOV=y
CONFIG_BNXT_FLOWER_OFFLOAD=y
CONFIG_BNXT_DCB=y
CONFIG_BNXT_HWMON=y
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=m
CONFIG_NET_VENDOR_CADENCE=y
CONFIG_MACB=m
CONFIG_MACB_USE_HWSTAMP=y
# CONFIG_MACB_PCI is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
CONFIG_LIQUIDIO=m
CONFIG_LIQUIDIO_VF=m
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3=m
CONFIG_CHELSIO_T4=m
# CONFIG_CHELSIO_T4_DCB is not set
CONFIG_CHELSIO_T4VF=m
CONFIG_CHELSIO_LIB=m
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=m
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
CONFIG_DNET=m
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=m
CONFIG_BE2NET_HWMON=y
CONFIG_BE2NET_BE2=y
CONFIG_BE2NET_BE3=y
CONFIG_BE2NET_LANCER=y
CONFIG_BE2NET_SKYHAWK=y
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGBVF=m
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_I40E=y
CONFIG_I40E_DCB=y
CONFIG_IAVF=m
CONFIG_I40EVF=m
# CONFIG_ICE is not set
CONFIG_FM10K=m
# CONFIG_IGC is not set
CONFIG_JME=m
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=m
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=m
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_MLX4_CORE_GEN2=y
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MICROCHIP is not set
CONFIG_NET_VENDOR_MICROSEMI=y
# CONFIG_MSCC_OCELOT_SWITCH is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=m
CONFIG_MYRI10GE_DCA=y
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NFP=m
CONFIG_NFP_APP_FLOWER=y
CONFIG_NFP_APP_ABM_NIC=y
# CONFIG_NFP_DEBUG is not set
CONFIG_NET_VENDOR_NI=y
# CONFIG_NI_XGE_MANAGEMENT_ENET is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_ETHOC=m
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=m
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=m
CONFIG_QLCNIC=m
CONFIG_QLCNIC_SRIOV=y
CONFIG_QLCNIC_DCB=y
CONFIG_QLCNIC_HWMON=y
CONFIG_QLGE=m
CONFIG_NETXEN_NIC=m
CONFIG_QED=m
CONFIG_QED_SRIOV=y
CONFIG_QEDE=m
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
CONFIG_8139CP=y
CONFIG_8139TOO=y
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_ROCKER=m
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
# CONFIG_NET_VENDOR_SEEQ is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_SFC_MCDI_LOGGING=y
CONFIG_SFC_FALCON=m
CONFIG_SFC_FALCON_MTD=y
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_EPIC100=m
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=m
CONFIG_NET_VENDOR_SOCIONEXT=y
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_PHY_SEL is not set
CONFIG_TLAN=m
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_NET_VENDOR_XILINX=y
# CONFIG_XILINX_LL_TEMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
# CONFIG_MDIO_BCM_UNIMAC is not set
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
# CONFIG_MDIO_MSCC_MIIM is not set
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=m
# CONFIG_AQUANTIA_PHY is not set
# CONFIG_ASIX_PHY is not set
CONFIG_AT803X_PHY=m
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=m
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_CICADA_PHY=m
# CONFIG_CORTINA_PHY is not set
CONFIG_DAVICOM_PHY=m
# CONFIG_DP83822_PHY is not set
# CONFIG_DP83TC811_PHY is not set
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=m
# CONFIG_INTEL_XWAY_PHY is not set
CONFIG_LSI_ET1011C_PHY=m
CONFIG_LXT_PHY=m
CONFIG_MARVELL_PHY=m
# CONFIG_MARVELL_10G_PHY is not set
CONFIG_MICREL_PHY=m
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROCHIP_T1_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
CONFIG_NATIONAL_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_REALTEK_PHY=y
# CONFIG_RENESAS_PHY is not set
# CONFIG_ROCKCHIP_PHY is not set
CONFIG_SMSC_PHY=m
CONFIG_STE10XP=m
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=m
# CONFIG_XILINX_GMII2RGMII is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=m
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPPOL2TP=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_RTL8152=m
# CONFIG_USB_LAN78XX is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=m
CONFIG_USB_NET_HUAWEI_CDC_NCM=m
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
# CONFIG_USB_NET_SR9800 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET_ENABLE=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_NET_QMI_WWAN=m
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=m
# CONFIG_USB_NET_CH9200 is not set
# CONFIG_USB_NET_AQC111 is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
# CONFIG_ADM8211 is not set
CONFIG_ATH_COMMON=m
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_ATH9K_HW=m
CONFIG_ATH9K_COMMON=m
CONFIG_ATH9K_BTCOEX_SUPPORT=y
# CONFIG_ATH9K is not set
CONFIG_ATH9K_HTC=m
# CONFIG_ATH9K_HTC_DEBUGFS is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
# CONFIG_AR5523 is not set
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_ATMEL is not set
# CONFIG_AT76C50X_USB is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_BRCMSMAC is not set
# CONFIG_BRCMFMAC is not set
CONFIG_WLAN_VENDOR_CISCO=y
# CONFIG_AIRO is not set
CONFIG_WLAN_VENDOR_INTEL=y
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
CONFIG_IWLEGACY=m
CONFIG_IWL4965=m
CONFIG_IWL3945=m

#
# iwl3945 / iwl4965 Debugging Options
#
CONFIG_IWLEGACY_DEBUG=y
CONFIG_IWLEGACY_DEBUGFS=y
CONFIG_IWLWIFI=m
CONFIG_IWLWIFI_LEDS=y
CONFIG_IWLDVM=m
CONFIG_IWLMVM=m
CONFIG_IWLWIFI_OPMODE_MODULAR=y
# CONFIG_IWLWIFI_BCAST_FILTERING is not set
# CONFIG_IWLWIFI_PCIE_RTPM is not set

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
CONFIG_IWLWIFI_DEBUGFS=y
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_HERMES is not set
# CONFIG_P54_COMMON is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_MWIFIEX is not set
# CONFIG_MWL8K is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT7601U is not set
# CONFIG_MT76x0U is not set
# CONFIG_MT76x0E is not set
# CONFIG_MT76x2E is not set
# CONFIG_MT76x2U is not set
# CONFIG_MT7603E is not set
# CONFIG_MT7615E is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
# CONFIG_RTL8180 is not set
# CONFIG_RTL8187 is not set
# CONFIG_RTL_CARDS is not set
# CONFIG_RTL8XXXU is not set
# CONFIG_RTW88 is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_ZD1211RW is not set
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_QTNFMAC_PCIE is not set
CONFIG_MAC80211_HWSIM=m
# CONFIG_USB_NET_RNDIS_WLAN is not set
# CONFIG_VIRT_WIFI is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKELB=m
# CONFIG_IEEE802154_AT86RF230 is not set
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_IEEE802154_CC2520 is not set
# CONFIG_IEEE802154_ATUSB is not set
# CONFIG_IEEE802154_ADF7242 is not set
# CONFIG_IEEE802154_CA8210 is not set
# CONFIG_IEEE802154_MCR20A is not set
# CONFIG_IEEE802154_HWSIM is not set
CONFIG_XEN_NETDEV_FRONTEND=m
CONFIG_VMXNET3=m
CONFIG_FUJITSU_ES=m
CONFIG_THUNDERBOLT_NET=m
CONFIG_HYPERV_NET=m
CONFIG_NETDEVSIM=m
CONFIG_NET_FAILOVER=m
CONFIG_ISDN=y
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
CONFIG_IPPP_FILTER=y
# CONFIG_ISDN_PPP_BSDCOMP is not set
CONFIG_ISDN_AUDIO=y
CONFIG_ISDN_TTY_FAX=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=m

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
CONFIG_ISDN_DRV_HISAX=m

#
# D-channel protocol features
#
CONFIG_HISAX_EURO=y
CONFIG_DE_AOC=y
CONFIG_HISAX_NO_SENDCOMPLETE=y
CONFIG_HISAX_NO_LLC=y
CONFIG_HISAX_NO_KEYPAD=y
CONFIG_HISAX_1TR6=y
CONFIG_HISAX_NI1=y
CONFIG_HISAX_MAX_CARDS=8

#
# HiSax supported cards
#
CONFIG_HISAX_16_3=y
CONFIG_HISAX_TELESPCI=y
CONFIG_HISAX_S0BOX=y
CONFIG_HISAX_FRITZPCI=y
CONFIG_HISAX_AVM_A1_PCMCIA=y
CONFIG_HISAX_ELSA=y
CONFIG_HISAX_DIEHLDIVA=y
CONFIG_HISAX_SEDLBAUER=y
CONFIG_HISAX_NETJET=y
CONFIG_HISAX_NETJET_U=y
CONFIG_HISAX_NICCY=y
CONFIG_HISAX_BKM_A4T=y
CONFIG_HISAX_SCT_QUADRO=y
CONFIG_HISAX_GAZEL=y
CONFIG_HISAX_HFC_PCI=y
CONFIG_HISAX_W6692=y
CONFIG_HISAX_HFC_SX=y
CONFIG_HISAX_ENTERNOW_PCI=y
# CONFIG_HISAX_DEBUG is not set

#
# HiSax PCMCIA card service modules
#

#
# HiSax sub driver modules
#
CONFIG_HISAX_ST5481=m
# CONFIG_HISAX_HFCUSB is not set
CONFIG_HISAX_HFC4S8S=m
CONFIG_HISAX_FRITZ_PCIPNP=m
CONFIG_ISDN_CAPI=m
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPIDRV=m
# CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE is not set

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
CONFIG_MISDN_NETJET=m
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_ISDN_HDLC=m
CONFIG_NVM=y
# CONFIG_NVM_PBLK is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1050 is not set
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_ELANTECH_SMBUS=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
CONFIG_MOUSE_PS2_VMMOUSE=y
CONFIG_MOUSE_PS2_SMBUS=y
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_CYAPA=m
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
CONFIG_MOUSE_SYNAPTICS_USB=m
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
# CONFIG_TOUCHSCREEN_AD7877 is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ADC is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_BU21029 is not set
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8505 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_EXC3000 is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_HIDEEP is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_S6SY761 is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2004 is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_RM_TS is not set
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_STMFTS is not set
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_SURFACE3_SPI is not set
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_TOUCHSCREEN_ZET6223 is not set
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
# CONFIG_TOUCHSCREEN_IQS5XX is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
# CONFIG_INPUT_MSM_VIBRATOR is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=m
CONFIG_INPUT_GP2A=m
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_DECODER is not set
# CONFIG_INPUT_GPIO_VIBRA is not set
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_PWM_BEEPER is not set
# CONFIG_INPUT_PWM_VIBRA is not set
CONFIG_INPUT_GPIO_ROTARY_ENCODER=m
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=m
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
CONFIG_RMI4_CORE=m
# CONFIG_RMI4_I2C is not set
# CONFIG_RMI4_SPI is not set
CONFIG_RMI4_SMB=m
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=m
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
# CONFIG_RMI4_F34 is not set
# CONFIG_RMI4_F54 is not set
# CONFIG_RMI4_F55 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
CONFIG_HYPERV_KEYBOARD=m
# CONFIG_SERIO_GPIO_PS2 is not set
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
# CONFIG_NULL_TTY is not set
CONFIG_LDISC_AUTOLOAD=y
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_DMI_DECODE=y
CONFIG_IPMI_PLAT_DATA=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_SSIF=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_UV_MMTIMER=m
CONFIG_TCG_TPM=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
CONFIG_TCG_TIS_I2C_ATMEL=m
CONFIG_TCG_TIS_I2C_INFINEON=m
CONFIG_TCG_TIS_I2C_NUVOTON=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
# CONFIG_TCG_XEN is not set
CONFIG_TCG_CRB=y
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=m
CONFIG_TCG_TIS_ST33ZP24_I2C=m
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set
# CONFIG_RANDOM_TRUST_CPU is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_MUX_MLXCPLD is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=y
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
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
# CONFIG_I2C_AMD_MP2 is not set
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_NVIDIA_GPU is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I3C is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y
# CONFIG_SPI_MEM is not set

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_AXI_SPI_ENGINE is not set
# CONFIG_SPI_BITBANG is not set
# CONFIG_SPI_BUTTERFLY is not set
# CONFIG_SPI_CADENCE is not set
# CONFIG_SPI_DESIGNWARE is not set
# CONFIG_SPI_NXP_FLEXSPI is not set
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_SIFIVE is not set
# CONFIG_SPI_MXIC is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
# CONFIG_SPI_LOOPBACK_TEST is not set
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPI_SLAVE is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=m
CONFIG_PTP_1588_CLOCK_KVM=m
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
CONFIG_PINCTRL_AMD=m
# CONFIG_PINCTRL_MCP23S08 is not set
# CONFIG_PINCTRL_SX150X is not set
CONFIG_PINCTRL_BAYTRAIL=y
# CONFIG_PINCTRL_CHERRYVIEW is not set
CONFIG_PINCTRL_INTEL=m
# CONFIG_PINCTRL_BROXTON is not set
CONFIG_PINCTRL_CANNONLAKE=m
# CONFIG_PINCTRL_CEDARFORK is not set
CONFIG_PINCTRL_DENVERTON=m
CONFIG_PINCTRL_GEMINILAKE=m
# CONFIG_PINCTRL_ICELAKE is not set
CONFIG_PINCTRL_LEWISBURG=m
CONFIG_PINCTRL_SUNRISEPOINT=m
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=m

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=m
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_ICH=m
# CONFIG_GPIO_LYNXPOINT is not set
# CONFIG_GPIO_MB86S7X is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_AMD_FCH is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_WINBOND is not set
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX3191X is not set
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set
# CONFIG_GPIO_XRA1403 is not set

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=m
CONFIG_GPIO_MOCKUP=y
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_TEST_POWER is not set
# CONFIG_CHARGER_ADP5061 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_MANAGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_LT3651 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_FTSTEUTATES is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_IIO_HWMON is not set
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX31722 is not set
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_TC654 is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
# CONFIG_SENSORS_NPCM7XX is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
# CONFIG_SENSORS_IBM_CFFPS is not set
# CONFIG_SENSORS_IR35221 is not set
# CONFIG_SENSORS_IR38064 is not set
# CONFIG_SENSORS_ISL68137 is not set
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=m
# CONFIG_SENSORS_MAX20751 is not set
# CONFIG_SENSORS_MAX31785 is not set
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=m
CONFIG_SENSORS_UCD9200=m
CONFIG_SENSORS_ZL6100=m
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
# CONFIG_SENSORS_W83773G is not set
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set

#
# Intel thermal drivers
#
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
CONFIG_INTEL_SOC_DTS_IOSF_CORE=m
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=m
CONFIG_ACPI_THERMAL_REL=m
# CONFIG_INT3406_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_GENERIC_ADC_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
CONFIG_WDAT_WDT=m
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_EBC_C384_WDT is not set
CONFIG_F71808E_WDT=m
CONFIG_SP5100_TCO=m
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=m
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=m
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=m
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=m
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_TQMX86_WDT is not set
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_INTEL_MEI_WDT=m
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
# CONFIG_MEN_A21_WDT is not set
CONFIG_XEN_WDT=m

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_BD9571MWV is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_MFD_MADERA is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=m
CONFIG_LPC_SCH=m
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
CONFIG_MFD_INTEL_LPSS_PCI=y
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=m
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=m
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TQMX86 is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
CONFIG_RC_CORE=m
CONFIG_RC_MAP=m
CONFIG_LIRC=y
CONFIG_RC_DECODERS=y
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_SANYO_DECODER=m
CONFIG_IR_SHARP_DECODER=m
CONFIG_IR_MCE_KBD_DECODER=m
# CONFIG_IR_XMP_DECODER is not set
# CONFIG_IR_IMON_DECODER is not set
# CONFIG_IR_RCMM_DECODER is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=m
CONFIG_IR_ENE=m
CONFIG_IR_IMON=m
# CONFIG_IR_IMON_RAW is not set
CONFIG_IR_MCEUSB=m
CONFIG_IR_ITE_CIR=m
CONFIG_IR_FINTEK=m
CONFIG_IR_NUVOTON=m
CONFIG_IR_REDRAT3=m
CONFIG_IR_STREAMZAP=m
CONFIG_IR_WINBOND_CIR=m
# CONFIG_IR_IGORPLUGUSB is not set
CONFIG_IR_IGUANA=m
CONFIG_IR_TTUSBIR=m
CONFIG_RC_LOOPBACK=m
# CONFIG_IR_SERIAL is not set
# CONFIG_IR_SIR is not set
# CONFIG_RC_XBOX_DVD is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_CEC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=m
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_DVB_CORE=m
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set
# CONFIG_DVB_ULE_DEBUG is not set

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
CONFIG_USB_GSPCA_CPIA1=m
# CONFIG_USB_GSPCA_DTCS033 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_JL2005BCD=m
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SE401=m
CONFIG_USB_GSPCA_SN9C2028=m
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
CONFIG_USB_GSPCA_SPCA1528=m
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
# CONFIG_USB_GSPCA_STK1135 is not set
CONFIG_USB_GSPCA_STV0680=m
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TOPRO=m
# CONFIG_USB_GSPCA_TOUPTEK is not set
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_VIDEO_USBTV is not set

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_USBVISION=m
# CONFIG_VIDEO_STK1160_COMMON is not set
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_AU0828_V4L2=y
# CONFIG_VIDEO_AU0828_RC is not set
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_TM6000=m
CONFIG_VIDEO_TM6000_ALSA=m
CONFIG_VIDEO_TM6000_DVB=m

#
# Digital TV USB devices
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_DIB3000MC=m
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_PCTV452E=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_AZ6027=m
CONFIG_DVB_USB_TECHNISAT_USB2=m
CONFIG_DVB_USB_V2=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_AF9035=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_AZ6007=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_EC168=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_LME2510=m
CONFIG_DVB_USB_MXL111SF=m
CONFIG_DVB_USB_RTL28XXU=m
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
CONFIG_SMS_USB_DRV=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
CONFIG_VIDEO_EM28XX_RC=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_MEYE is not set
# CONFIG_VIDEO_SOLO6X10 is not set
# CONFIG_VIDEO_TW5864 is not set
# CONFIG_VIDEO_TW68 is not set
# CONFIG_VIDEO_TW686X is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_IVTV=m
# CONFIG_VIDEO_IVTV_DEPRECATED_IOCTLS is not set
# CONFIG_VIDEO_IVTV_ALSA is not set
CONFIG_VIDEO_FB_IVTV=m
# CONFIG_VIDEO_FB_IVTV_FORCE_PAT is not set
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set
# CONFIG_VIDEO_DT3155 is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=m
CONFIG_VIDEO_CX18_ALSA=m
CONFIG_VIDEO_CX23885=m
CONFIG_MEDIA_ALTERA_CI=m
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_ENABLE_VP3054=y
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_BT848=m
CONFIG_DVB_BT8XX=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_SAA7164=m

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=m
CONFIG_DVB_DM1105=m
CONFIG_DVB_PT1=m
# CONFIG_DVB_PT3 is not set
CONFIG_MANTIS_CORE=m
CONFIG_DVB_MANTIS=m
CONFIG_DVB_HOPPER=m
CONFIG_DVB_NGENE=m
CONFIG_DVB_DDBRIDGE=m
# CONFIG_DVB_DDBRIDGE_MSIENABLE is not set
# CONFIG_DVB_SMIPCIE is not set
# CONFIG_DVB_NETUP_UNIDVB is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=m
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=m
# CONFIG_RADIO_SI470X is not set
# CONFIG_RADIO_SI4713 is not set
# CONFIG_USB_MR800 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_SHARK is not set
# CONFIG_RADIO_SHARK2 is not set
# CONFIG_USB_KEENE is not set
# CONFIG_USB_RAREMONO is not set
# CONFIG_USB_MA901 is not set
# CONFIG_RADIO_TEA5764 is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_CYPRESS_FIRMWARE=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_V4L2=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEOBUF2_DMA_SG=m
CONFIG_VIDEOBUF2_DVB=m
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_SMS_SIANO_MDTV=m
CONFIG_SMS_SIANO_RC=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS3308=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m

#
# Camera sensor devices
#

#
# Lens drivers
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_M52790=m

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA18250=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2063=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_MEDIA_TUNER_FC0011=m
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88RS6000T=m
CONFIG_MEDIA_TUNER_TUA9001=m
CONFIG_MEDIA_TUNER_SI2157=m
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_QM1D1C0042=m
CONFIG_MEDIA_TUNER_QM1D1B0004=m

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV0910=m
CONFIG_DVB_STV6110x=m
CONFIG_DVB_STV6111=m
CONFIG_DVB_MXL5XX=m
CONFIG_DVB_M88DS3103=m

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_SI2165=m
CONFIG_DVB_MN88472=m
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_CX24117=m
CONFIG_DVB_CX24120=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_TS2020=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m
CONFIG_DVB_TDA10071=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_EC100=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m
CONFIG_DVB_CXD2841ER=m
CONFIG_DVB_RTL2830=m
CONFIG_DVB_RTL2832=m
CONFIG_DVB_SI2168=m
CONFIG_DVB_GP8PSK_FE=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_AU8522_DTV=m
CONFIG_DVB_AU8522_V4L=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=m
CONFIG_DVB_LNBH25=m
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_A8293=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
CONFIG_DVB_IX2505V=m
CONFIG_DVB_M88RS2000=m
CONFIG_DVB_AF9033=m

#
# Common Interface (EN50221) controller drivers
#
CONFIG_DVB_CXD2099=m

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=m

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=64
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_SELFTEST=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_FBDEV_LEAK_PHYS_SMEM is not set
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
# CONFIG_DRM_DP_CEC is not set
CONFIG_DRM_TTM=m
CONFIG_DRM_GEM_SHMEM_HELPER=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_I2C_NXP_TDA9950 is not set

#
# ARM devices
#
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
CONFIG_DRM_I915_USERPTR=y
CONFIG_DRM_I915_GVT=y
CONFIG_DRM_I915_GVT_KVMGT=m

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_DEBUG_GUC is not set
# CONFIG_DRM_I915_SELFTEST is not set
# CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
# CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
# CONFIG_DRM_I915_DEBUG_RUNTIME_PM is not set
CONFIG_DRM_VGEM=m
# CONFIG_DRM_VKMS is not set
CONFIG_DRM_VMWGFX=m
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
CONFIG_DRM_BOCHS=m
CONFIG_DRM_VIRTIO_GPU=m
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_DRM_ETNAVIV is not set
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_XEN is not set
# CONFIG_DRM_VBOXVIDEO is not set
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_MODE_HELPERS is not set
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_XEN_FBDEV_FRONTEND is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_HYPERV=m
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SM712 is not set

#
# Backlight & LCD device support
#
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
# CONFIG_LCD_ILI922X is not set
# CONFIG_LCD_ILI9320 is not set
# CONFIG_LCD_TDO24M is not set
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=m
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
# CONFIG_LCD_OTM3225A is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_APPLE=m
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=m
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER is not set
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_PCM_ELD=y
CONFIG_SND_HWDEP=m
CONFIG_SND_SEQ_DEVICE=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_COMPRESS_OFFLOAD=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_HRTIMER=m
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_SEQUENCER_OSS=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_SEQ_MIDI_EVENT=m
CONFIG_SND_SEQ_MIDI=m
CONFIG_SND_SEQ_MIDI_EMUL=m
CONFIG_SND_SEQ_VIRMIDI=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_OPL3_LIB_SEQ=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=5
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_ES1968_RADIO=y
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=0
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
CONFIG_SND_HDA_CODEC_VIA=m
CONFIG_SND_HDA_CODEC_HDMI=m
CONFIG_SND_HDA_CODEC_CIRRUS=m
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=m
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_COMPONENT=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_EXT_CORE=m
CONFIG_SND_HDA_PREALLOC_SIZE=512
# CONFIG_SND_SPI is not set
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_AUDIO_USE_MEDIA_CONTROLLER=y
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
CONFIG_SND_USB_HIFACE=m
CONFIG_SND_BCD2000=m
CONFIG_SND_USB_LINE6=m
CONFIG_SND_USB_POD=m
CONFIG_SND_USB_PODHD=m
CONFIG_SND_USB_TONEPORT=m
CONFIG_SND_USB_VARIAX=m
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
# CONFIG_SND_DICE is not set
# CONFIG_SND_OXFW is not set
CONFIG_SND_ISIGHT=m
# CONFIG_SND_FIREWORKS is not set
# CONFIG_SND_BEBOB is not set
# CONFIG_SND_FIREWIRE_DIGI00X is not set
# CONFIG_SND_FIREWIRE_TASCAM is not set
# CONFIG_SND_FIREWIRE_MOTU is not set
# CONFIG_SND_FIREFACE is not set
CONFIG_SND_SOC=m
CONFIG_SND_SOC_COMPRESS=y
CONFIG_SND_SOC_TOPOLOGY=y
CONFIG_SND_SOC_ACPI=m
# CONFIG_SND_SOC_AMD_ACP is not set
# CONFIG_SND_SOC_AMD_ACP3x is not set
# CONFIG_SND_ATMEL_SOC is not set
# CONFIG_SND_DESIGNWARE_I2S is not set

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
# CONFIG_SND_SOC_FSL_SAI is not set
# CONFIG_SND_SOC_FSL_AUDMIX is not set
# CONFIG_SND_SOC_FSL_SSI is not set
# CONFIG_SND_SOC_FSL_SPDIF is not set
# CONFIG_SND_SOC_FSL_ESAI is not set
# CONFIG_SND_SOC_FSL_MICFIL is not set
# CONFIG_SND_SOC_IMX_AUDMUX is not set
# CONFIG_SND_I2S_HI6210_I2S is not set
# CONFIG_SND_SOC_IMG is not set
CONFIG_SND_SOC_INTEL_SST_TOPLEVEL=y
CONFIG_SND_SST_IPC=m
CONFIG_SND_SST_IPC_ACPI=m
CONFIG_SND_SOC_INTEL_SST_ACPI=m
CONFIG_SND_SOC_INTEL_SST=m
CONFIG_SND_SOC_INTEL_SST_FIRMWARE=m
CONFIG_SND_SOC_INTEL_HASWELL=m
CONFIG_SND_SST_ATOM_HIFI2_PLATFORM=m
# CONFIG_SND_SST_ATOM_HIFI2_PLATFORM_PCI is not set
CONFIG_SND_SST_ATOM_HIFI2_PLATFORM_ACPI=m
CONFIG_SND_SOC_INTEL_SKYLAKE=m
CONFIG_SND_SOC_INTEL_SKL=m
CONFIG_SND_SOC_INTEL_APL=m
CONFIG_SND_SOC_INTEL_KBL=m
CONFIG_SND_SOC_INTEL_GLK=m
CONFIG_SND_SOC_INTEL_CNL=m
CONFIG_SND_SOC_INTEL_CFL=m
CONFIG_SND_SOC_INTEL_SKYLAKE_FAMILY=m
CONFIG_SND_SOC_INTEL_SKYLAKE_SSP_CLK=m
# CONFIG_SND_SOC_INTEL_SKYLAKE_HDAUDIO_CODEC is not set
CONFIG_SND_SOC_INTEL_SKYLAKE_COMMON=m
CONFIG_SND_SOC_ACPI_INTEL_MATCH=m
CONFIG_SND_SOC_INTEL_MACH=y
CONFIG_SND_SOC_INTEL_HASWELL_MACH=m
CONFIG_SND_SOC_INTEL_BDW_RT5677_MACH=m
CONFIG_SND_SOC_INTEL_BROADWELL_MACH=m
CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH=m
CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH=m
CONFIG_SND_SOC_INTEL_CHT_BSW_RT5672_MACH=m
CONFIG_SND_SOC_INTEL_CHT_BSW_RT5645_MACH=m
CONFIG_SND_SOC_INTEL_CHT_BSW_MAX98090_TI_MACH=m
# CONFIG_SND_SOC_INTEL_CHT_BSW_NAU8824_MACH is not set
CONFIG_SND_SOC_INTEL_BYT_CHT_DA7213_MACH=m
CONFIG_SND_SOC_INTEL_BYT_CHT_ES8316_MACH=m
CONFIG_SND_SOC_INTEL_BYT_CHT_NOCODEC_MACH=m
CONFIG_SND_SOC_INTEL_SKL_RT286_MACH=m
CONFIG_SND_SOC_INTEL_SKL_NAU88L25_SSM4567_MACH=m
CONFIG_SND_SOC_INTEL_SKL_NAU88L25_MAX98357A_MACH=m
CONFIG_SND_SOC_INTEL_BXT_DA7219_MAX98357A_MACH=m
CONFIG_SND_SOC_INTEL_BXT_RT298_MACH=m
CONFIG_SND_SOC_INTEL_KBL_RT5663_MAX98927_MACH=m
CONFIG_SND_SOC_INTEL_KBL_RT5663_RT5514_MAX98927_MACH=m
# CONFIG_SND_SOC_INTEL_KBL_DA7219_MAX98357A_MACH is not set
# CONFIG_SND_SOC_INTEL_KBL_DA7219_MAX98927_MACH is not set
# CONFIG_SND_SOC_INTEL_KBL_RT5660_MACH is not set
# CONFIG_SND_SOC_INTEL_GLK_RT5682_MAX98357A_MACH is not set
# CONFIG_SND_SOC_MTK_BTCVSD is not set
# CONFIG_SND_SOC_SOF_TOPLEVEL is not set

#
# STMicroelectronics STM32 SOC audio support
#
# CONFIG_SND_SOC_XILINX_I2S is not set
# CONFIG_SND_SOC_XILINX_AUDIO_FORMATTER is not set
# CONFIG_SND_SOC_XILINX_SPDIF is not set
# CONFIG_SND_SOC_XTFPGA_I2S is not set
# CONFIG_ZX_TDM is not set
CONFIG_SND_SOC_I2C_AND_SPI=m

#
# CODEC drivers
#
# CONFIG_SND_SOC_AC97_CODEC is not set
# CONFIG_SND_SOC_ADAU1701 is not set
# CONFIG_SND_SOC_ADAU1761_I2C is not set
# CONFIG_SND_SOC_ADAU1761_SPI is not set
# CONFIG_SND_SOC_ADAU7002 is not set
# CONFIG_SND_SOC_AK4104 is not set
# CONFIG_SND_SOC_AK4118 is not set
# CONFIG_SND_SOC_AK4458 is not set
# CONFIG_SND_SOC_AK4554 is not set
# CONFIG_SND_SOC_AK4613 is not set
# CONFIG_SND_SOC_AK4642 is not set
# CONFIG_SND_SOC_AK5386 is not set
# CONFIG_SND_SOC_AK5558 is not set
# CONFIG_SND_SOC_ALC5623 is not set
# CONFIG_SND_SOC_BD28623 is not set
# CONFIG_SND_SOC_BT_SCO is not set
# CONFIG_SND_SOC_CS35L32 is not set
# CONFIG_SND_SOC_CS35L33 is not set
# CONFIG_SND_SOC_CS35L34 is not set
# CONFIG_SND_SOC_CS35L35 is not set
# CONFIG_SND_SOC_CS35L36 is not set
# CONFIG_SND_SOC_CS42L42 is not set
# CONFIG_SND_SOC_CS42L51_I2C is not set
# CONFIG_SND_SOC_CS42L52 is not set
# CONFIG_SND_SOC_CS42L56 is not set
# CONFIG_SND_SOC_CS42L73 is not set
# CONFIG_SND_SOC_CS4265 is not set
# CONFIG_SND_SOC_CS4270 is not set
# CONFIG_SND_SOC_CS4271_I2C is not set
# CONFIG_SND_SOC_CS4271_SPI is not set
# CONFIG_SND_SOC_CS42XX8_I2C is not set
# CONFIG_SND_SOC_CS43130 is not set
# CONFIG_SND_SOC_CS4341 is not set
# CONFIG_SND_SOC_CS4349 is not set
# CONFIG_SND_SOC_CS53L30 is not set
CONFIG_SND_SOC_DA7213=m
CONFIG_SND_SOC_DA7219=m
CONFIG_SND_SOC_DMIC=m
# CONFIG_SND_SOC_ES7134 is not set
# CONFIG_SND_SOC_ES7241 is not set
CONFIG_SND_SOC_ES8316=m
# CONFIG_SND_SOC_ES8328_I2C is not set
# CONFIG_SND_SOC_ES8328_SPI is not set
# CONFIG_SND_SOC_GTM601 is not set
CONFIG_SND_SOC_HDAC_HDMI=m
# CONFIG_SND_SOC_INNO_RK3036 is not set
# CONFIG_SND_SOC_MAX98088 is not set
CONFIG_SND_SOC_MAX98090=m
CONFIG_SND_SOC_MAX98357A=m
# CONFIG_SND_SOC_MAX98504 is not set
# CONFIG_SND_SOC_MAX9867 is not set
CONFIG_SND_SOC_MAX98927=m
# CONFIG_SND_SOC_MAX98373 is not set
# CONFIG_SND_SOC_MAX9860 is not set
# CONFIG_SND_SOC_MSM8916_WCD_DIGITAL is not set
# CONFIG_SND_SOC_PCM1681 is not set
# CONFIG_SND_SOC_PCM1789_I2C is not set
# CONFIG_SND_SOC_PCM179X_I2C is not set
# CONFIG_SND_SOC_PCM179X_SPI is not set
# CONFIG_SND_SOC_PCM186X_I2C is not set
# CONFIG_SND_SOC_PCM186X_SPI is not set
# CONFIG_SND_SOC_PCM3060_I2C is not set
# CONFIG_SND_SOC_PCM3060_SPI is not set
# CONFIG_SND_SOC_PCM3168A_I2C is not set
# CONFIG_SND_SOC_PCM3168A_SPI is not set
# CONFIG_SND_SOC_PCM512x_I2C is not set
# CONFIG_SND_SOC_PCM512x_SPI is not set
# CONFIG_SND_SOC_RK3328 is not set
CONFIG_SND_SOC_RL6231=m
CONFIG_SND_SOC_RL6347A=m
CONFIG_SND_SOC_RT286=m
CONFIG_SND_SOC_RT298=m
CONFIG_SND_SOC_RT5514=m
CONFIG_SND_SOC_RT5514_SPI=m
# CONFIG_SND_SOC_RT5616 is not set
# CONFIG_SND_SOC_RT5631 is not set
CONFIG_SND_SOC_RT5640=m
CONFIG_SND_SOC_RT5645=m
CONFIG_SND_SOC_RT5651=m
CONFIG_SND_SOC_RT5663=m
CONFIG_SND_SOC_RT5670=m
CONFIG_SND_SOC_RT5677=m
CONFIG_SND_SOC_RT5677_SPI=m
# CONFIG_SND_SOC_SGTL5000 is not set
# CONFIG_SND_SOC_SIMPLE_AMPLIFIER is not set
# CONFIG_SND_SOC_SIRF_AUDIO_CODEC is not set
# CONFIG_SND_SOC_SPDIF is not set
# CONFIG_SND_SOC_SSM2305 is not set
# CONFIG_SND_SOC_SSM2602_SPI is not set
# CONFIG_SND_SOC_SSM2602_I2C is not set
CONFIG_SND_SOC_SSM4567=m
# CONFIG_SND_SOC_STA32X is not set
# CONFIG_SND_SOC_STA350 is not set
# CONFIG_SND_SOC_STI_SAS is not set
# CONFIG_SND_SOC_TAS2552 is not set
# CONFIG_SND_SOC_TAS5086 is not set
# CONFIG_SND_SOC_TAS571X is not set
# CONFIG_SND_SOC_TAS5720 is not set
# CONFIG_SND_SOC_TAS6424 is not set
# CONFIG_SND_SOC_TDA7419 is not set
# CONFIG_SND_SOC_TFA9879 is not set
# CONFIG_SND_SOC_TLV320AIC23_I2C is not set
# CONFIG_SND_SOC_TLV320AIC23_SPI is not set
# CONFIG_SND_SOC_TLV320AIC31XX is not set
# CONFIG_SND_SOC_TLV320AIC32X4_I2C is not set
# CONFIG_SND_SOC_TLV320AIC32X4_SPI is not set
# CONFIG_SND_SOC_TLV320AIC3X is not set
CONFIG_SND_SOC_TS3A227E=m
# CONFIG_SND_SOC_TSCS42XX is not set
# CONFIG_SND_SOC_TSCS454 is not set
# CONFIG_SND_SOC_WM8510 is not set
# CONFIG_SND_SOC_WM8523 is not set
# CONFIG_SND_SOC_WM8524 is not set
# CONFIG_SND_SOC_WM8580 is not set
# CONFIG_SND_SOC_WM8711 is not set
# CONFIG_SND_SOC_WM8728 is not set
# CONFIG_SND_SOC_WM8731 is not set
# CONFIG_SND_SOC_WM8737 is not set
# CONFIG_SND_SOC_WM8741 is not set
# CONFIG_SND_SOC_WM8750 is not set
# CONFIG_SND_SOC_WM8753 is not set
# CONFIG_SND_SOC_WM8770 is not set
# CONFIG_SND_SOC_WM8776 is not set
# CONFIG_SND_SOC_WM8782 is not set
# CONFIG_SND_SOC_WM8804_I2C is not set
# CONFIG_SND_SOC_WM8804_SPI is not set
# CONFIG_SND_SOC_WM8903 is not set
# CONFIG_SND_SOC_WM8904 is not set
# CONFIG_SND_SOC_WM8960 is not set
# CONFIG_SND_SOC_WM8962 is not set
# CONFIG_SND_SOC_WM8974 is not set
# CONFIG_SND_SOC_WM8978 is not set
# CONFIG_SND_SOC_WM8985 is not set
# CONFIG_SND_SOC_ZX_AUD96P22 is not set
# CONFIG_SND_SOC_MAX9759 is not set
# CONFIG_SND_SOC_MT6351 is not set
# CONFIG_SND_SOC_MT6358 is not set
# CONFIG_SND_SOC_NAU8540 is not set
# CONFIG_SND_SOC_NAU8810 is not set
# CONFIG_SND_SOC_NAU8822 is not set
CONFIG_SND_SOC_NAU8824=m
CONFIG_SND_SOC_NAU8825=m
# CONFIG_SND_SOC_TPA6130A2 is not set
# CONFIG_SND_SIMPLE_CARD is not set
CONFIG_SND_X86=y
CONFIG_HDMI_LPE_AUDIO=m
CONFIG_SND_SYNTH_EMUX=m
# CONFIG_SND_XEN_FRONTEND is not set
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=m
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
# CONFIG_HID_BIGBEN_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
# CONFIG_HID_COUGAR is not set
# CONFIG_HID_MACALLY is not set
CONFIG_HID_PRODIKEYS=m
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELAN is not set
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
CONFIG_HID_WALTOP=m
# CONFIG_HID_VIEWSONIC is not set
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
CONFIG_HID_ITE=y
# CONFIG_HID_JABRA is not set
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=m
CONFIG_HID_LED=m
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MALTRON is not set
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_REDRAGON=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=m
# CONFIG_HID_RETRODE is not set
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=m
# CONFIG_HID_STEAM is not set
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_RMI=m
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=m
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_U2FZERO is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m
CONFIG_HID_SENSOR_CUSTOM_SENSOR=m
CONFIG_HID_ALPS=m

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=m

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=y
# CONFIG_INTEL_ISH_FIRMWARE_DOWNLOADER is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_LEDS_TRIGGER_USBPORT=m
CONFIG_USB_AUTOSUSPEND_DELAY=2
CONFIG_USB_MON=y
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=y
# CONFIG_USB_XHCI_PLATFORM is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_FSL is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=m
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=m
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m
CONFIG_USBIP_CORE=m
# CONFIG_USBIP_VHCI_HCD is not set
# CONFIG_USBIP_HOST is not set
# CONFIG_USBIP_DEBUG is not set
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_F8153X is not set
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
CONFIG_USB_SERIAL_QCAUX=m
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_XSENS_MT=m
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=m
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_GADGET is not set
CONFIG_TYPEC=y
# CONFIG_TYPEC_TCPM is not set
CONFIG_TYPEC_UCSI=y
# CONFIG_UCSI_CCG is not set
CONFIG_UCSI_ACPI=y
# CONFIG_TYPEC_TPS6598X is not set

#
# USB Type-C Multiplexer/DeMultiplexer Switch support
#
# CONFIG_TYPEC_MUX_PI3USB30532 is not set

#
# USB Type-C Alternate Mode drivers
#
# CONFIG_TYPEC_DP_ALTMODE is not set
# CONFIG_USB_ROLE_SWITCH is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_ACPI=m
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_SDHCI_F_SDH30 is not set
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_CQHCI=m
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MMC_SDHCI_XENON is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3532 is not set
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=m
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_MLXREG is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_DISK is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
CONFIG_LEDS_TRIGGER_GPIO=m
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
# CONFIG_LEDS_TRIGGER_PATTERN is not set
CONFIG_LEDS_TRIGGER_AUDIO=m
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
CONFIG_EDAC_GHES=y
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
CONFIG_EDAC_IE31200=m
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
CONFIG_EDAC_I7CORE=m
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
CONFIG_EDAC_I7300=m
CONFIG_EDAC_SBRIDGE=m
CONFIG_EDAC_SKX=m
# CONFIG_EDAC_I10NM is not set
CONFIG_EDAC_PND2=m
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABEOZ9 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_DS1307=m
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=m
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF85063 is not set
# CONFIG_RTC_DRV_PCF85363 is not set
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=m
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=m
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
# CONFIG_RTC_DRV_RV3028 is not set
# CONFIG_RTC_DRV_RV8803 is not set
# CONFIG_RTC_DRV_SD3078 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6916 is not set
# CONFIG_RTC_DRV_R9701 is not set
CONFIG_RTC_DRV_RX4581=m
# CONFIG_RTC_DRV_RX6110 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=m
CONFIG_RTC_DRV_DS3232_HWMON=y
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DS2404=m
CONFIG_RTC_DRV_STK17TA8=m
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
# CONFIG_ALTERA_MSGDMA is not set
# CONFIG_INTEL_IDMA64 is not set
CONFIG_INTEL_IOATDMA=m
# CONFIG_QCOM_HIDMA_MGMT is not set
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_UDMABUF is not set
CONFIG_DCA=m
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=m
CONFIG_CFAG12864B_RATE=20
# CONFIG_IMG_ASCII_LCD is not set
# CONFIG_PARPORT_PANEL is not set
# CONFIG_CHARLCD_BL_OFF is not set
# CONFIG_CHARLCD_BL_ON is not set
CONFIG_CHARLCD_BL_FLASH=y
# CONFIG_PANEL is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
CONFIG_UIO_HV_GENERIC=m
CONFIG_VFIO_IOMMU_TYPE1=m
CONFIG_VFIO_VIRQFD=m
CONFIG_VFIO=m
CONFIG_VFIO_NOIOMMU=y
CONFIG_VFIO_PCI=m
# CONFIG_VFIO_PCI_VGA is not set
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
# CONFIG_VFIO_PCI_IGD is not set
CONFIG_VFIO_MDEV=m
CONFIG_VFIO_MDEV_DEVICE=m
CONFIG_IRQ_BYPASS_MANAGER=m
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_INPUT=m
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=m
CONFIG_HYPERV_TSCPAGE=y
CONFIG_HYPERV_UTILS=m
CONFIG_HYPERV_BALLOON=m

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SELFBALLOONING is not set
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES_DEFAULT=y
CONFIG_XEN_DEV_EVTCHN=m
# CONFIG_XEN_BACKEND is not set
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
# CONFIG_XEN_GRANT_DMA_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=m
# CONFIG_XEN_PVCALLS_FRONTEND is not set
CONFIG_XEN_PRIVCMD=m
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_STAGING=y
# CONFIG_PRISM2_USB is not set
# CONFIG_COMEDI is not set
# CONFIG_RTL8192U is not set
CONFIG_RTLLIB=m
CONFIG_RTLLIB_CRYPTO_CCMP=m
CONFIG_RTLLIB_CRYPTO_TKIP=m
CONFIG_RTLLIB_CRYPTO_WEP=m
CONFIG_RTL8192E=m
# CONFIG_RTL8723BS is not set
CONFIG_R8712U=m
# CONFIG_R8188EU is not set
# CONFIG_RTS5208 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
# CONFIG_ADIS16203 is not set
# CONFIG_ADIS16240 is not set

#
# Analog to digital converters
#
# CONFIG_AD7816 is not set
# CONFIG_AD7192 is not set
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
# CONFIG_AD9832 is not set
# CONFIG_AD9834 is not set

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Active energy metering IC
#
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#
# CONFIG_AD2S1210 is not set
# CONFIG_FB_SM750 is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_LTE_GDM724X is not set
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
# CONFIG_GS_FPGABOOT is not set
# CONFIG_UNISYSSPAR is not set
# CONFIG_FB_TFT is not set
# CONFIG_WILC1000_SDIO is not set
# CONFIG_WILC1000_SPI is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set
# CONFIG_PI433 is not set

#
# Gasket devices
#
# CONFIG_STAGING_GASKET_FRAMEWORK is not set
# CONFIG_EROFS_FS is not set
# CONFIG_FIELDBUS_DEV is not set
# CONFIG_KPC2000 is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
# CONFIG_ACER_WIRELESS is not set
CONFIG_ACERHDF=m
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
CONFIG_DCDBAS=m
CONFIG_DELL_SMBIOS=m
CONFIG_DELL_SMBIOS_WMI=y
CONFIG_DELL_SMBIOS_SMM=y
CONFIG_DELL_LAPTOP=m
CONFIG_DELL_WMI=m
CONFIG_DELL_WMI_DESCRIPTOR=m
CONFIG_DELL_WMI_AIO=m
# CONFIG_DELL_WMI_LED is not set
CONFIG_DELL_SMO8800=m
CONFIG_DELL_RBTN=m
CONFIG_DELL_RBU=m
CONFIG_FUJITSU_LAPTOP=m
CONFIG_FUJITSU_TABLET=m
CONFIG_AMILO_RFKILL=m
# CONFIG_GPD_POCKET_FAN is not set
CONFIG_HP_ACCEL=m
CONFIG_HP_WIRELESS=m
CONFIG_HP_WMI=m
# CONFIG_LG_LAPTOP is not set
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=m
# CONFIG_SURFACE3_WMI is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=m
CONFIG_ASUS_WMI=m
CONFIG_ASUS_NB_WMI=m
CONFIG_EEEPC_WMI=m
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=m
CONFIG_WMI_BMOF=m
CONFIG_INTEL_WMI_THUNDERBOLT=m
CONFIG_MSI_WMI=m
# CONFIG_PEAQ_WMI is not set
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_ACPI_TOSHIBA=m
CONFIG_TOSHIBA_BT_RFKILL=m
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
# CONFIG_INTEL_INT0002_VGPIO is not set
CONFIG_INTEL_HID_EVENT=m
CONFIG_INTEL_VBTN=m
CONFIG_INTEL_IPS=m
CONFIG_INTEL_PMC_CORE=m
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_INTEL_OAKTRAIL=m
CONFIG_APPLE_GMUX=m
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
# CONFIG_MLX_PLATFORM is not set
# CONFIG_INTEL_TURBO_MAX_3 is not set
# CONFIG_I2C_MULTI_INSTANTIATE is not set
# CONFIG_INTEL_ATOMISP2_PM is not set
# CONFIG_HUAWEI_WMI is not set
# CONFIG_PCENGINES_APU2 is not set
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_MAX9485 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI544 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_CLK_SIFIVE is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_IOVA=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set
# CONFIG_IOMMU_DEFAULT_PASSTHROUGH is not set
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=m
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y
CONFIG_HYPERV_IOMMU=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
# CONFIG_RPMSG_VIRTIO is not set
# CONFIG_SOUNDWIRE is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Aspeed SoC drivers
#

#
# Broadcom SoC drivers
#

#
# NXP/Freescale QorIQ SoC drivers
#

#
# i.MX SoC drivers
#

#
# IXP4xx SoC drivers
#
# CONFIG_IXP4XX_QMGR is not set
# CONFIG_IXP4XX_NPE is not set

#
# Qualcomm SoC drivers
#
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
# CONFIG_XILINX_VCU is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
# CONFIG_IIO_BUFFER_HW_CONSUMER is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=m
# CONFIG_IIO_CONFIGFS is not set
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
# CONFIG_IIO_SW_TRIGGER is not set

#
# Accelerometers
#
# CONFIG_ADIS16201 is not set
# CONFIG_ADIS16209 is not set
# CONFIG_ADXL345_I2C is not set
# CONFIG_ADXL345_SPI is not set
# CONFIG_ADXL372_SPI is not set
# CONFIG_ADXL372_I2C is not set
# CONFIG_BMA180 is not set
# CONFIG_BMA220 is not set
# CONFIG_BMC150_ACCEL is not set
# CONFIG_DA280 is not set
# CONFIG_DA311 is not set
# CONFIG_DMARD09 is not set
# CONFIG_DMARD10 is not set
CONFIG_HID_SENSOR_ACCEL_3D=m
# CONFIG_IIO_CROS_EC_ACCEL_LEGACY is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
# CONFIG_KXSD9 is not set
# CONFIG_KXCJK1013 is not set
# CONFIG_MC3230 is not set
# CONFIG_MMA7455_I2C is not set
# CONFIG_MMA7455_SPI is not set
# CONFIG_MMA7660 is not set
# CONFIG_MMA8452 is not set
# CONFIG_MMA9551 is not set
# CONFIG_MMA9553 is not set
# CONFIG_MXC4005 is not set
# CONFIG_MXC6255 is not set
# CONFIG_SCA3000 is not set
# CONFIG_STK8312 is not set
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
# CONFIG_AD7124 is not set
# CONFIG_AD7266 is not set
# CONFIG_AD7291 is not set
# CONFIG_AD7298 is not set
# CONFIG_AD7476 is not set
# CONFIG_AD7606_IFACE_PARALLEL is not set
# CONFIG_AD7606_IFACE_SPI is not set
# CONFIG_AD7766 is not set
# CONFIG_AD7768_1 is not set
# CONFIG_AD7780 is not set
# CONFIG_AD7791 is not set
# CONFIG_AD7793 is not set
# CONFIG_AD7887 is not set
# CONFIG_AD7923 is not set
# CONFIG_AD7949 is not set
# CONFIG_AD799X is not set
# CONFIG_HI8435 is not set
# CONFIG_HX711 is not set
# CONFIG_INA2XX_ADC is not set
# CONFIG_LTC2471 is not set
# CONFIG_LTC2485 is not set
# CONFIG_LTC2497 is not set
# CONFIG_MAX1027 is not set
# CONFIG_MAX11100 is not set
# CONFIG_MAX1118 is not set
# CONFIG_MAX1363 is not set
# CONFIG_MAX9611 is not set
# CONFIG_MCP320X is not set
# CONFIG_MCP3422 is not set
# CONFIG_MCP3911 is not set
# CONFIG_NAU7802 is not set
# CONFIG_TI_ADC081C is not set
# CONFIG_TI_ADC0832 is not set
# CONFIG_TI_ADC084S021 is not set
# CONFIG_TI_ADC12138 is not set
# CONFIG_TI_ADC108S102 is not set
# CONFIG_TI_ADC128S052 is not set
# CONFIG_TI_ADC161S626 is not set
# CONFIG_TI_ADS1015 is not set
# CONFIG_TI_ADS7950 is not set
# CONFIG_TI_TLC4541 is not set
# CONFIG_VIPERBOARD_ADC is not set

#
# Analog Front Ends
#

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
# CONFIG_BME680 is not set
# CONFIG_CCS811 is not set
# CONFIG_IAQCORE is not set
# CONFIG_SENSIRION_SGP30 is not set
# CONFIG_SPS30 is not set
# CONFIG_VZ89X is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORHUB is not set

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
# CONFIG_AD5360 is not set
# CONFIG_AD5380 is not set
# CONFIG_AD5421 is not set
# CONFIG_AD5446 is not set
# CONFIG_AD5449 is not set
# CONFIG_AD5592R is not set
# CONFIG_AD5593R is not set
# CONFIG_AD5504 is not set
# CONFIG_AD5624R_SPI is not set
# CONFIG_LTC1660 is not set
# CONFIG_LTC2632 is not set
# CONFIG_AD5686_SPI is not set
# CONFIG_AD5696_I2C is not set
# CONFIG_AD5755 is not set
# CONFIG_AD5758 is not set
# CONFIG_AD5761 is not set
# CONFIG_AD5764 is not set
# CONFIG_AD5791 is not set
# CONFIG_AD7303 is not set
# CONFIG_AD8801 is not set
# CONFIG_DS4424 is not set
# CONFIG_M62332 is not set
# CONFIG_MAX517 is not set
# CONFIG_MCP4725 is not set
# CONFIG_MCP4922 is not set
# CONFIG_TI_DAC082S085 is not set
# CONFIG_TI_DAC5571 is not set
# CONFIG_TI_DAC7311 is not set
# CONFIG_TI_DAC7612 is not set

#
# IIO dummy driver
#

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
# CONFIG_ADIS16130 is not set
# CONFIG_ADIS16136 is not set
# CONFIG_ADIS16260 is not set
# CONFIG_ADXRS450 is not set
# CONFIG_BMG160 is not set
# CONFIG_FXAS21002C is not set
CONFIG_HID_SENSOR_GYRO_3D=m
# CONFIG_MPU3050_I2C is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
# CONFIG_AFE4403 is not set
# CONFIG_AFE4404 is not set
# CONFIG_MAX30100 is not set
# CONFIG_MAX30102 is not set

#
# Humidity sensors
#
# CONFIG_AM2315 is not set
# CONFIG_DHT11 is not set
# CONFIG_HDC100X is not set
# CONFIG_HID_SENSOR_HUMIDITY is not set
# CONFIG_HTS221 is not set
# CONFIG_HTU21 is not set
# CONFIG_SI7005 is not set
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
# CONFIG_ADIS16480 is not set
# CONFIG_BMI160_I2C is not set
# CONFIG_BMI160_SPI is not set
# CONFIG_KMX61 is not set
# CONFIG_INV_MPU6050_I2C is not set
# CONFIG_INV_MPU6050_SPI is not set
# CONFIG_IIO_ST_LSM6DSX is not set

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
# CONFIG_ADJD_S311 is not set
# CONFIG_AL3320A is not set
# CONFIG_APDS9300 is not set
# CONFIG_APDS9960 is not set
# CONFIG_BH1750 is not set
# CONFIG_BH1780 is not set
# CONFIG_CM32181 is not set
# CONFIG_CM3232 is not set
# CONFIG_CM3323 is not set
# CONFIG_CM36651 is not set
# CONFIG_GP2AP020A00F is not set
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_ISL29125 is not set
CONFIG_HID_SENSOR_ALS=m
CONFIG_HID_SENSOR_PROX=m
# CONFIG_JSA1212 is not set
# CONFIG_RPR0521 is not set
# CONFIG_LTR501 is not set
# CONFIG_LV0104CS is not set
# CONFIG_MAX44000 is not set
# CONFIG_MAX44009 is not set
# CONFIG_OPT3001 is not set
# CONFIG_PA12203001 is not set
# CONFIG_SI1133 is not set
# CONFIG_SI1145 is not set
# CONFIG_STK3310 is not set
# CONFIG_ST_UVIS25 is not set
# CONFIG_TCS3414 is not set
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
# CONFIG_TSL2583 is not set
# CONFIG_TSL2772 is not set
# CONFIG_TSL4531 is not set
# CONFIG_US5182D is not set
# CONFIG_VCNL4000 is not set
# CONFIG_VCNL4035 is not set
# CONFIG_VEML6070 is not set
# CONFIG_VL6180 is not set
# CONFIG_ZOPT2201 is not set

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
# CONFIG_AK09911 is not set
# CONFIG_BMC150_MAGN_I2C is not set
# CONFIG_BMC150_MAGN_SPI is not set
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=m
# CONFIG_MMC35240 is not set
# CONFIG_IIO_ST_MAGN_3AXIS is not set
# CONFIG_SENSORS_HMC5843_I2C is not set
# CONFIG_SENSORS_HMC5843_SPI is not set
# CONFIG_SENSORS_RM3100_I2C is not set
# CONFIG_SENSORS_RM3100_SPI is not set

#
# Multiplexers
#

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=m
CONFIG_HID_SENSOR_DEVICE_ROTATION=m

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
# CONFIG_AD5272 is not set
# CONFIG_DS1803 is not set
# CONFIG_MAX5481 is not set
# CONFIG_MAX5487 is not set
# CONFIG_MCP4018 is not set
# CONFIG_MCP4131 is not set
# CONFIG_MCP4531 is not set
# CONFIG_MCP41010 is not set
# CONFIG_TPL0102 is not set

#
# Digital potentiostats
#
# CONFIG_LMP91000 is not set

#
# Pressure sensors
#
# CONFIG_ABP060MG is not set
# CONFIG_BMP280 is not set
CONFIG_HID_SENSOR_PRESS=m
# CONFIG_HP03 is not set
# CONFIG_MPL115_I2C is not set
# CONFIG_MPL115_SPI is not set
# CONFIG_MPL3115 is not set
# CONFIG_MS5611 is not set
# CONFIG_MS5637 is not set
# CONFIG_IIO_ST_PRESS is not set
# CONFIG_T5403 is not set
# CONFIG_HP206C is not set
# CONFIG_ZPA2326 is not set

#
# Lightning sensors
#
# CONFIG_AS3935 is not set

#
# Proximity and distance sensors
#
# CONFIG_ISL29501 is not set
# CONFIG_LIDAR_LITE_V2 is not set
# CONFIG_MB1232 is not set
# CONFIG_RFD77402 is not set
# CONFIG_SRF04 is not set
# CONFIG_SX9500 is not set
# CONFIG_SRF08 is not set
# CONFIG_VL53L0X_I2C is not set

#
# Resolver to digital converters
#
# CONFIG_AD2S90 is not set
# CONFIG_AD2S1200 is not set

#
# Temperature sensors
#
# CONFIG_MAXIM_THERMOCOUPLE is not set
# CONFIG_HID_SENSOR_TEMP is not set
# CONFIG_MLX90614 is not set
# CONFIG_MLX90632 is not set
# CONFIG_TMP006 is not set
# CONFIG_TMP007 is not set
# CONFIG_TSYS01 is not set
# CONFIG_TSYS02D is not set
# CONFIG_MAX31856 is not set
CONFIG_NTB=m
CONFIG_NTB_AMD=m
# CONFIG_NTB_IDT is not set
# CONFIG_NTB_INTEL is not set
# CONFIG_NTB_SWITCHTEC is not set
# CONFIG_NTB_PINGPONG is not set
# CONFIG_NTB_TOOL is not set
CONFIG_NTB_PERF=m
CONFIG_NTB_TRANSPORT=m
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_PHY_CPCAP_USB is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
# CONFIG_IDLE_INJECT is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_RAS_CEC is not set
CONFIG_THUNDERBOLT=y

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=m
CONFIG_BLK_DEV_PMEM=m
CONFIG_ND_BLK=m
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=m
CONFIG_BTT=y
CONFIG_ND_PFN=m
CONFIG_NVDIMM_PFN=y
CONFIG_NVDIMM_DAX=y
CONFIG_NVDIMM_KEYS=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_DEV_DAX_KMEM=m
CONFIG_DEV_DAX_PMEM_COMPAT=m
CONFIG_NVMEM=y
CONFIG_NVMEM_SYSFS=y

#
# HW tracing support
#
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set
# CONFIG_FPGA is not set
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
# CONFIG_SIOX is not set
# CONFIG_SLIMBUS is not set
# CONFIG_INTERCONNECT is not set
# CONFIG_COUNTER is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_VALIDATE_FS_PARSER=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=m
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
CONFIG_XFS_ONLINE_SCRUB=y
CONFIG_XFS_ONLINE_REPAIR=y
CONFIG_XFS_DEBUG=y
CONFIG_XFS_ASSERT_FATAL=y
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_BTRFS_FS_REF_VERIFY is not set
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_F2FS_IO_TRACE is not set
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_OVERLAY_FS=m
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
# CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW is not set
# CONFIG_OVERLAY_FS_INDEX is not set
# CONFIG_OVERLAY_FS_XINO_AUTO is not set
# CONFIG_OVERLAY_FS_METACOPY is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_VMCORE_DEVICE_DUMP is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_EFIVAR_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
CONFIG_CRAMFS=m
CONFIG_CRAMFS_BLOCKDEV=y
# CONFIG_CRAMFS_MTD is not set
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=m
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS is not set
# CONFIG_PSTORE_842_COMPRESS is not set
# CONFIG_PSTORE_ZSTD_COMPRESS is not set
CONFIG_PSTORE_COMPRESS=y
CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_PNFS=y
# CONFIG_NFSD_BLOCKLAYOUT is not set
CONFIG_NFSD_SCSILAYOUT=y
# CONFIG_NFSD_FLEXFILELAYOUT is not set
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=m
# CONFIG_CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES is not set
CONFIG_SUNRPC_DEBUG=y
CONFIG_CEPH_FS=m
# CONFIG_CEPH_FSCACHE is not set
CONFIG_CEPH_FS_POSIX_ACL=y
CONFIG_CIFS=m
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y
# CONFIG_UNICODE is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITY_WRITABLE_HOOKS=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
CONFIG_INTEL_TXT=y
CONFIG_LSM_MMAP_MIN_ADDR=65535
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY_FALLBACK=y
# CONFIG_HARDENED_USERCOPY_PAGESPAN is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_HASH=y
CONFIG_SECURITY_APPARMOR_HASH_DEFAULT=y
# CONFIG_SECURITY_APPARMOR_DEBUG is not set
# CONFIG_SECURITY_LOADPIN is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_SECURITY_SAFESETID is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_INTEGRITY_TRUSTED_KEYRING=y
# CONFIG_INTEGRITY_PLATFORM_KEYRING is not set
CONFIG_INTEGRITY_AUDIT=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_LSM_RULES=y
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
# CONFIG_IMA_READ_POLICY is not set
CONFIG_IMA_APPRAISE=y
# CONFIG_IMA_ARCH_POLICY is not set
# CONFIG_IMA_APPRAISE_BUILD_POLICY is not set
CONFIG_IMA_APPRAISE_BOOTPARAM=y
CONFIG_IMA_TRUSTED_KEYRING=y
# CONFIG_IMA_BLACKLIST_KEYRING is not set
# CONFIG_IMA_LOAD_X509 is not set
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
# CONFIG_EVM_ADD_XATTRS is not set
# CONFIG_EVM_LOAD_X509 is not set
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_LSM="yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"

#
# Kernel hardening options
#

#
# Memory initialization
#
CONFIG_INIT_STACK_NONE=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK_USER is not set
# CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF is not set
# CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL is not set
# CONFIG_GCC_PLUGIN_STACKLEAK is not set
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
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
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=m
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_SIMD=m
CONFIG_CRYPTO_GLUE_HELPER_X86=m
CONFIG_CRYPTO_ENGINE=m

#
# Public-key cryptography
#
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=m
CONFIG_CRYPTO_ECC=m
CONFIG_CRYPTO_ECDH=m
# CONFIG_CRYPTO_ECRDSA is not set

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
# CONFIG_CRYPTO_AEGIS128 is not set
# CONFIG_CRYPTO_AEGIS128L is not set
# CONFIG_CRYPTO_AEGIS256 is not set
# CONFIG_CRYPTO_AEGIS128_AESNI_SSE2 is not set
# CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2 is not set
# CONFIG_CRYPTO_AEGIS256_AESNI_SSE2 is not set
# CONFIG_CRYPTO_MORUS640 is not set
# CONFIG_CRYPTO_MORUS640_SSE2 is not set
# CONFIG_CRYPTO_MORUS1280 is not set
# CONFIG_CRYPTO_MORUS1280_SSE2 is not set
# CONFIG_CRYPTO_MORUS1280_AVX2 is not set
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
CONFIG_CRYPTO_LRW=m
# CONFIG_CRYPTO_OFB is not set
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set
# CONFIG_CRYPTO_NHPOLY1305_SSE2 is not set
# CONFIG_CRYPTO_NHPOLY1305_AVX2 is not set
# CONFIG_CRYPTO_ADIANTUM is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=m
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_SM3 is not set
# CONFIG_CRYPTO_STREEBOG is not set
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
# CONFIG_CRYPTO_SM4 is not set
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set
# CONFIG_CRYPTO_ZSTD is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_USER_API_RNG=m
# CONFIG_CRYPTO_USER_API_AEAD is not set
# CONFIG_CRYPTO_STATS is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
CONFIG_CRYPTO_DEV_CCP=y
CONFIG_CRYPTO_DEV_CCP_DD=m
CONFIG_CRYPTO_DEV_SP_CCP=y
CONFIG_CRYPTO_DEV_CCP_CRYPTO=m
CONFIG_CRYPTO_DEV_SP_PSP=y
CONFIG_CRYPTO_DEV_QAT=m
CONFIG_CRYPTO_DEV_QAT_DH895xCC=m
CONFIG_CRYPTO_DEV_QAT_C3XXX=m
CONFIG_CRYPTO_DEV_QAT_C62X=m
CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=m
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=m
CONFIG_CRYPTO_DEV_QAT_C62XVF=m
# CONFIG_CRYPTO_DEV_NITROX_CNN55XX is not set
CONFIG_CRYPTO_DEV_CHELSIO=m
CONFIG_CRYPTO_DEV_VIRTIO=m
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
# CONFIG_ASYMMETRIC_TPM_KEY_SUBTYPE is not set
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS8_PRIVATE_KEY_PARSER is not set
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
CONFIG_SIGNED_PE_FILE_VERIFICATION=y

#
# Certificates for signature checking
#
CONFIG_MODULE_SIG_KEY="certs/signing_key.pem"
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_RAID6_PQ_BENCHMARK=y
# CONFIG_PACKING is not set
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_CORDIC=m
CONFIG_PRIME_NUMBERS=m
CONFIG_RATIONAL=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC64 is not set
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=m
CONFIG_CRC8=m
CONFIG_XXHASH=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=m
CONFIG_ZSTD_DECOMPRESS=m
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
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_XARRAY_MULTI=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DMA_DECLARE_COHERENT=y
CONFIG_SWIOTLB=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=200
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
# CONFIG_DMA_API_DEBUG is not set
CONFIG_SGL_ALLOC=y
CONFIG_IOMMU_HELPER=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_ARCH_STACKWALK=y
CONFIG_SBITMAP=y
# CONFIG_STRING_SELFTEST is not set

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
# CONFIG_PRINTK_CALLER is not set
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_DEBUG_INFO_BTF is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_MISC=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_OWNER is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_CC_HAS_KASAN_GENERIC=y
# CONFIG_KASAN is not set
CONFIG_KASAN_STACK=1
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_RWSEMS is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
CONFIG_WW_MUTEX_SELFTEST=m
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PLIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=m
CONFIG_RCU_PERF_TEST=m
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=m
CONFIG_PM_NOTIFIER_ERROR_INJECT=m
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FUNCTION_ERROR_INJECTION=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_FAIL_FUNCTION is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
CONFIG_HWLAT_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENTS=y
# CONFIG_KPROBE_EVENTS_ON_NOTRACE is not set
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_DYNAMIC_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
# CONFIG_BPF_KPROBE_OVERRIDE is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=m
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_PREEMPTIRQ_DELAY_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_RUNTIME_TESTING_MENU=y
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_STRSCPY is not set
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_PRINTF=m
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_BITFIELD is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_XARRAY is not set
# CONFIG_TEST_OVERFLOW is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_IDA is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_VMALLOC is not set
CONFIG_TEST_USER_COPY=m
CONFIG_TEST_BPF=m
# CONFIG_FIND_BIT_BENCHMARK is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_SYSCTL=m
# CONFIG_TEST_UDELAY is not set
CONFIG_TEST_STATIC_KEYS=m
CONFIG_TEST_KMOD=m
# CONFIG_TEST_MEMCAT_P is not set
CONFIG_TEST_LIVEPATCH=m
# CONFIG_TEST_STACKINIT is not set
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_UBSAN_ALIGNMENT=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_X86_DECODER_SELFTEST=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set
# CONFIG_UNWINDER_GUESS is not set

--GUPx2O/K0ibUojHx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=job-script

#!/bin/sh

export_top_env()
{
	export suite='nvml'
	export testcase='nvml'
	export category='functional'
	export branch='linux-devel/devel-hourly-2019051800'
	export need_memory='3G'
	export group='obj'
	export test='non-pmem'
	export queue_cmdline_keys='branch
commit'
	export queue='validate'
	export testbox='vm-snb-8G-408'
	export tbox_group='vm-snb-8G'
	export submit_id='5ce3f88af18fc30ef8aa409f'
	export job_file='/lkp/jobs/scheduled/vm-snb-8G-408/nvml-obj-non-pmem-debian-x86_64-2018-04-03.cgz-e52271917f9f5159c791e-20190521-3832-1mp49tj-7.yaml'
	export id='2517e4021d7b3f76993b5900c050aec580cabe24'
	export queuer_version='/lkp/lkp/src'
	export arch='x86_64'
	export need_kconfig='CONFIG_NVDIMM_PFN=y
CONFIG_FS_DAX=y
CONFIG_KVM_GUEST=y'
	export commit='e52271917f9f5159c791eda8ba748a66d659c27e'
	export ssh_base_port=26000
	export kconfig='x86_64-rhel-7.6'
	export compiler='gcc-7'
	export rootfs='debian-x86_64-2018-04-03.cgz'
	export enqueue_time='2019-05-21 21:09:33 +0800'
	export _id='5ce3f88ef18fc30ef8aa40a6'
	export _rt='/result/nvml/obj-non-pmem/vm-snb-8G/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.6/gcc-7/e52271917f9f5159c791eda8ba748a66d659c27e'
	export user='lkp'
	export head_commit='6fb29e0cfa475856b99f038eae27c7b298597d0b'
	export base_commit='e93c9c99a629c61837d5a7fc2120cd2b6c70dbdd'
	export result_root='/result/nvml/obj-non-pmem/vm-snb-8G/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.6/gcc-7/e52271917f9f5159c791eda8ba748a66d659c27e/73'
	export scheduler_version='/lkp/lkp/.src-20190521-163139'
	export LKP_SERVER='inn'
	export max_uptime=3600
	export initrd='/osimage/debian/debian-x86_64-2018-04-03.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/jobs/scheduled/vm-snb-8G-408/nvml-obj-non-pmem-debian-x86_64-2018-04-03.cgz-e52271917f9f5159c791e-20190521-3832-1mp49tj-7.yaml
ARCH=x86_64
kconfig=x86_64-rhel-7.6
branch=linux-devel/devel-hourly-2019051800
commit=e52271917f9f5159c791eda8ba748a66d659c27e
BOOT_IMAGE=/pkg/linux/x86_64-rhel-7.6/gcc-7/e52271917f9f5159c791eda8ba748a66d659c27e/vmlinuz-5.1.0-12240-ge522719
max_uptime=3600
RESULT_ROOT=/result/nvml/obj-non-pmem/vm-snb-8G/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.6/gcc-7/e52271917f9f5159c791eda8ba748a66d659c27e/73
LKP_SERVER=inn
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
rw'
	export modules_initrd='/pkg/linux/x86_64-rhel-7.6/gcc-7/e52271917f9f5159c791eda8ba748a66d659c27e/modules.cgz'
	export bm_initrd='/osimage/deps/debian-x86_64-2018-04-03.cgz/run-ipconfig_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/lkp_2019-04-24.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/rsync-rootfs_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/nvml_2019-04-29.cgz,/osimage/pkg/debian-x86_64-2018-04-03.cgz/nvml-x86_64-b87259db7_2019-05-14.cgz'
	export lkp_initrd='/lkp/lkp/lkp-x86_64.cgz'
	export site='inn'
	export LKP_CGI_PORT=80
	export LKP_CIFS_PORT=139
	export repeat_to=98
	export schedule_notify_address=
	export model='qemu-system-x86_64 -enable-kvm -cpu SandyBridge'
	export nr_cpu=2
	export memory='8G'
	export hdd_partitions='/dev/vda /dev/vdb /dev/vdc /dev/vdd /dev/vde /dev/vdf'
	export swap_partitions='/dev/vdg'
	export job_origin='/lkp/jobs/scheduled/vm-snb-8G-408/nvml-obj-non-pmem-debian-x86_64-2018-04-03.cgz-e52271917f9f5159c791e-20190521-3832-1mp49tj-7.yaml'
	export vm_tbox_group='vm-snb-8G'
	export nr_vm=134
	export vm_base_id=801
	export kernel='/pkg/linux/x86_64-rhel-7.6/gcc-7/e52271917f9f5159c791eda8ba748a66d659c27e/vmlinuz-5.1.0-12240-ge522719'
	export dequeue_time='2019-05-21 21:18:38 +0800'
	export job_initrd='/lkp/jobs/scheduled/vm-snb-8G-408/nvml-obj-non-pmem-debian-x86_64-2018-04-03.cgz-e52271917f9f5159c791e-20190521-3832-1mp49tj-7.cgz'

	[ -n "$LKP_SRC" ] ||
	export LKP_SRC=/lkp/${user:-lkp}/src
}

run_job()
{
	echo $$ > $TMP/run-job.pid

	. $LKP_SRC/lib/http.sh
	. $LKP_SRC/lib/job.sh
	. $LKP_SRC/lib/env.sh

	export_top_env

	run_monitor $LKP_SRC/monitors/wrapper kmsg
	run_monitor $LKP_SRC/monitors/wrapper heartbeat
	run_monitor $LKP_SRC/monitors/wrapper meminfo
	run_monitor $LKP_SRC/monitors/wrapper oom-killer
	run_monitor $LKP_SRC/monitors/plain/watchdog

	run_test $LKP_SRC/tests/wrapper nvml
}

extract_stats()
{
	export stats_part_begin=
	export stats_part_end=

	$LKP_SRC/stats/wrapper nvml
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper meminfo

	$LKP_SRC/stats/wrapper time nvml.time
	$LKP_SRC/stats/wrapper dmesg
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper last_state
	$LKP_SRC/stats/wrapper stderr
	$LKP_SRC/stats/wrapper time
}

"$@"

--GUPx2O/K0ibUojHx
Content-Type: application/x-xz
Content-Disposition: attachment; filename="dmesg.xz"
Content-Transfer-Encoding: base64

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
scRn+wIAAAAABFla

--GUPx2O/K0ibUojHx--

