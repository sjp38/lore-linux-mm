Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB696B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:25:31 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id i34so136983476qkh.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:25:31 -0800 (PST)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id 37si28062871qto.161.2016.11.29.09.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:25:30 -0800 (PST)
Subject: linux-next 20161129 - BUG: sleeping function called from invalid context at mm/page_alloc.c:3775
From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1480440324_3026P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Nov 2016 12:25:24 -0500
Message-ID: <12959.1480440324@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

--==_Exmh_1480440324_3026P
Content-Type: text/plain; charset=us-ascii

Seeing this same BUG all over the place at boot - some 30 times just getting
to a single-user prompt and saving a dmesg.  Everything from netlink to execve
to ext4 file I/O to process exit time.

[    3.746004] BUG: sleeping function called from invalid context at mm/page_alloc.c:3775
[    3.746091] in_atomic(): 1, irqs_disabled(): 0, pid: 385, name: systemd-vconsol
[    3.746162] 2 locks held by systemd-vconsol/385:
[    3.746164]  #0:
[    3.746166]  (
[    3.746167] &sig->cred_guard_mutex
[    3.746169] ){+.+.+.}
[    3.746170] , at:
[    3.746175] [<ffffffffa93ebc58>] prepare_bprm_creds+0x38/0xf0
[    3.746177]  #1:
[    3.746178]  (
[    3.746179] &(ptlock_ptr(page))->rlock
[    3.746181] #2
[    3.746182] ){+.+...}
[    3.746184] , at:
[    3.746189] [<ffffffffa9352949>] unmap_page_range+0x479/0x1280
[    3.746193] CPU: 2 PID: 385 Comm: systemd-vconsol Tainted: G        W       4.9.0-rc7-next-20161129-dirty #361
[    3.746194] Hardware name: Dell Inc. Latitude E6530/07Y85M, BIOS A17 08/19/2015
[    3.746196] Call Trace:
[    3.746202]  dump_stack+0x7b/0xd1
[    3.746206]  ___might_sleep+0x194/0x300
[    3.746210]  __alloc_pages_nodemask+0x13f/0x730
[    3.746213]  __get_free_pages+0x18/0x60
[    3.746217]  __tlb_remove_page_size+0x8b/0x120
[    3.746221]  unmap_page_range+0x866/0x1280
[    3.746224]  ? release_pages+0x158/0x750
[    3.746229]  unmap_single_vma+0x13b/0x180
[    3.746232]  unmap_vmas+0x37/0x60
[    3.746235]  exit_mmap+0x8f/0x190
[    3.746240]  mmput+0x9c/0x250
[    3.746243]  flush_old_exec+0x559/0xf40
[    3.746247]  load_elf_binary+0x35d/0x1930
[    3.746251]  ? preempt_count_sub+0x4a/0x90
[    3.746255]  search_binary_handler+0xbc/0x260
[    3.746258]  do_execveat_common.isra.30+0x9dd/0x1270
[    3.746261]  ? do_execveat_common.isra.30+0x905/0x1270
[    3.746264]  SyS_execve+0x3a/0x50
[    3.746267]  do_syscall_64+0x8c/0x290
[    3.746271]  entry_SYSCALL64_slow_path+0x25/0x25
[    3.746273] RIP: 0033:0x7f33befaac47
[    3.746275] RSP: 002b:00007ffd24cea888 EFLAGS: 00000202 ORIG_RAX: 000000000000003b
[    3.746279] RAX: ffffffffffffffda RBX: 00005585dae94ea4 RCX: 00007f33befaac47
[    3.746281] RDX: 00007ffd24ceaab8 RSI: 00007ffd24cea930 RDI: 00005585dae94fd4
[    3.746283] RBP: 00007ffd24cea9c0 R08: 0000000000000000 R09: 0000000000000000
[    3.746285] R10: 0000000000000008 R11: 0000000000000202 R12: 00005585dae94801
[    3.746287] R13: 0000000000000000 R14: 0000000000000001 R15: 00007ffd24cea8d0


--==_Exmh_1480440324_3026P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.5 07/13/2001

iQEVAwUBWD26BI0DS38y7CIcAQLMiAf+Lq0c7S7N3GdOd0Ls4H+RfGE2YNsM+u6V
y1mKA6K4cCYlzBuKPpiA28YUvTAGEQyXi4KyIeQPd3pnWUlZGGvRaIoveIj5K8T2
dSyV6f86Ib4QIsFooMGkp3JvPkhm0qHXW8nrQ/P8vARHUk+cfRm/QfZHwjnXINqW
Ogzx8aCBSC7/uFsVM/PHyjCHSj3EFOIQpL7II8I8JoS25ivtPBb6vooOkn7cpUWb
8q4IXwlELdpdmMovYJXKKh/HeNbxem6qJwsAB2MzlzZ2DcacdFtOuabvrl0GLb78
azNK+O/Sv5lpGXJTRbYUEdhV4LpRwXm+8rb97Xfh0C96ryZLG7jp8A==
=bxsX
-----END PGP SIGNATURE-----

--==_Exmh_1480440324_3026P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
