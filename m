Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4CA6B0281
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:45:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a7so6486255pfj.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:45:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l5sor1459824pli.3.2017.09.20.13.45.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:45:57 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 00/31] Hardened usercopy whitelisting
Date: Wed, 20 Sep 2017 13:45:06 -0700
Message-Id: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>

v3:
- added LKDTM update patch
- downgrade BUGs to WARNs and fail closed
- add Acks/Reviews from v2

v2:
- added tracing of allocation and usage
- refactored solutions for task_struct
- split up network patches for readability

I intend for this to land via my usercopy hardening tree, so Acks,
Reviewed, and Tested-bys would be greatly appreciated. I have some
questions in a few patches (e.g. CIFS and thread_stack) that would be nice
to get answered for completeness. FWIW, this series has survived generally
for weeks in 0-day testing, and specifically over a couple days rebased
on v4.14-rc1, so I intend to put this in -next shortly unless there is
further feedback.

----

This series is modified from Brad Spengler/PaX Team's PAX_USERCOPY code
in the last public patch of grsecurity/PaX based on our understanding
of the code. Changes or omissions from the original code are ours and
don't reflect the original grsecurity/PaX code.

David Windsor did the bulk of the porting, refactoring, splitting,
testing, etc; I did some extra tweaks, hunk moving, traces, and extra
patches.

Description from patch 1:


Currently, hardened usercopy performs dynamic bounds checking on slab
cache objects. This is good, but still leaves a lot of kernel memory
available to be copied to/from userspace in the face of bugs. To further
restrict what memory is available for copying, this creates a way to
whitelist specific areas of a given slab cache object for copying to/from
userspace, allowing much finer granularity of access control. Slab caches
that are never exposed to userspace can declare no whitelist for their
objects, thereby keeping them unavailable to userspace via dynamic copy
operations. (Note, an implicit form of whitelisting is the use of constant
sizes in usercopy operations and get_user()/put_user(); these bypass
hardened usercopy checks since these sizes cannot change at runtime.)

To support this whitelist annotation, usercopy region offset and size
members are added to struct kmem_cache. The slab allocator receives a
new function, kmem_cache_create_usercopy(), that creates a new cache
with a usercopy region defined, suitable for declaring spans of fields
within the objects that get copied to/from userspace.

In this patch, the default kmem_cache_create() marks the entire allocation
as whitelisted, leaving it semantically unchanged. Once all fine-grained
whitelists have been added (in subsequent patches), this will be changed
to a usersize of 0, making caches created with kmem_cache_create() not
copyable to/from userspace.

After the entire usercopy whitelist series is applied, less than 15%
of the slab cache memory remains exposed to potential usercopy bugs
after a fresh boot:

Total Slab Memory:           48074720
Usercopyable Memory:          6367532  13.2%
         task_struct                    0.2%         4480/1630720
         RAW                            0.3%            300/96000
         RAWv6                          2.1%           1408/64768
         ext4_inode_cache               3.0%       269760/8740224
         dentry                        11.1%       585984/5273856
         mm_struct                     29.1%         54912/188448
         kmalloc-8                    100.0%          24576/24576
         kmalloc-16                   100.0%          28672/28672
         kmalloc-32                   100.0%          81920/81920
         kmalloc-192                  100.0%          96768/96768
         kmalloc-128                  100.0%        143360/143360
         names_cache                  100.0%        163840/163840
         kmalloc-64                   100.0%        167936/167936
         kmalloc-256                  100.0%        339968/339968
         kmalloc-512                  100.0%        350720/350720
         kmalloc-96                   100.0%        455616/455616
         kmalloc-8192                 100.0%        655360/655360
         kmalloc-1024                 100.0%        812032/812032
         kmalloc-4096                 100.0%        819200/819200
         kmalloc-2048                 100.0%      1310720/1310720

After some kernel build workloads, the percentage (mainly driven by
dentry and inode caches expanding) drops under 10%:

Total Slab Memory:           95516184
Usercopyable Memory:          8497452   8.8%
         task_struct                    0.2%         4000/1456000
         RAW                            0.3%            300/96000
         RAWv6                          2.1%           1408/64768
         ext4_inode_cache               3.0%     1217280/39439872
         dentry                        11.1%     1623200/14608800
         mm_struct                     29.1%         73216/251264
         kmalloc-8                    100.0%          24576/24576
         kmalloc-16                   100.0%          28672/28672
         kmalloc-32                   100.0%          94208/94208
         kmalloc-192                  100.0%          96768/96768
         kmalloc-128                  100.0%        143360/143360
         names_cache                  100.0%        163840/163840
         kmalloc-64                   100.0%        245760/245760
         kmalloc-256                  100.0%        339968/339968
         kmalloc-512                  100.0%        350720/350720
         kmalloc-96                   100.0%        563520/563520
         kmalloc-8192                 100.0%        655360/655360
         kmalloc-1024                 100.0%        794624/794624
         kmalloc-4096                 100.0%        819200/819200
         kmalloc-2048                 100.0%      1257472/1257472

------
The patches are broken in several stages of changes:

Prepare and whitelist kmalloc:
    [PATCH 01/31] usercopy: Prepare for usercopy whitelisting
    [PATCH 02/31] usercopy: Enforce slab cache usercopy region boundaries
    [PATCH 03/31] usercopy: Mark kmalloc caches as usercopy caches

Update VFS layer for symlinks and other inline storage:
    [PATCH 04/31] dcache: Define usercopy region in dentry_cache slab
    [PATCH 05/31] vfs: Define usercopy region in names_cache slab caches
    [PATCH 06/31] vfs: Copy struct mount.mnt_id to userspace using
    [PATCH 07/31] ext4: Define usercopy region in ext4_inode_cache slab
    [PATCH 08/31] ext2: Define usercopy region in ext2_inode_cache slab
    [PATCH 09/31] jfs: Define usercopy region in jfs_ip slab cache
    [PATCH 10/31] befs: Define usercopy region in befs_inode_cache slab
    [PATCH 11/31] exofs: Define usercopy region in exofs_inode_cache slab
    [PATCH 12/31] orangefs: Define usercopy region in
    [PATCH 13/31] ufs: Define usercopy region in ufs_inode_cache slab
    [PATCH 14/31] vxfs: Define usercopy region in vxfs_inode slab cache
    [PATCH 15/31] xfs: Define usercopy region in xfs_inode slab cache
    [PATCH 16/31] cifs: Define usercopy region in cifs_request slab cache

Update scsi layer for inline storage:
    [PATCH 17/31] scsi: Define usercopy region in scsi_sense_cache slab

Whitelist a few network protocol-specific areas of memory:
    [PATCH 18/31] net: Define usercopy region in struct proto slab cache
    [PATCH 19/31] ip: Define usercopy region in IP proto slab cache
    [PATCH 20/31] caif: Define usercopy region in caif proto slab cache
    [PATCH 21/31] sctp: Define usercopy region in SCTP proto slab cache
    [PATCH 22/31] sctp: Copy struct sctp_sock.autoclose to userspace
    [PATCH 23/31] net: Restrict unwhitelisted proto caches to size 0

Whitelist areas of process memory:
    [PATCH 24/31] fork: Define usercopy region in mm_struct slab caches
    [PATCH 25/31] fork: Define usercopy region in thread_stack slab

Deal with per-architecture thread_struct whitelisting:
    [PATCH 26/31] fork: Provide usercopy whitelisting for task_struct
    [PATCH 27/31] x86: Implement thread_struct whitelist for hardened
    [PATCH 28/31] arm64: Implement thread_struct whitelist for hardened
    [PATCH 29/31] arm: Implement thread_struct whitelist for hardened

Make blacklisting the default:
    [PATCH 30/31] usercopy: Restrict non-usercopy caches to size 0

Update LKDTM:
    [PATCH 31/31] lkdtm: Update usercopy tests for whitelisting


Thanks!

-Kees (and David)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
