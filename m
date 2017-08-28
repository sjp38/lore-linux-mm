Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB866B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m15so2591690pgc.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:18 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id f3si1072679plb.107.2017.08.28.14.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:17 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id y15so5010789pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:16 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 00/30] Hardened usercopy whitelisting
Date: Mon, 28 Aug 2017 14:34:41 -0700
Message-Id: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>

This series is modified from Brad Spengler/PaX Team's PAX_USERCOPY code
in the last public patch of grsecurity/PaX based on our understanding
of the code. Changes or omissions from the original code are ours and
don't reflect the original grsecurity/PaX code.

David Windsor did the bulk of the porting, refactoring, splitting,
testing, etc; I just did some extra tweaks, hunk moving, traces,
and extra patches.

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
    [PATCH 01/30] usercopy: Prepare for usercopy whitelisting
    [PATCH 02/30] usercopy: Enforce slab cache usercopy region boundaries
    [PATCH 03/30] usercopy: Mark kmalloc caches as usercopy caches

Update VFS layer for symlinks and other inline storage:
    [PATCH 04/30] dcache: Define usercopy region in dentry_cache slab
    [PATCH 05/30] vfs: Define usercopy region in names_cache slab caches
    [PATCH 06/30] vfs: Copy struct mount.mnt_id to userspace using
    [PATCH 07/30] ext4: Define usercopy region in ext4_inode_cache slab
    [PATCH 08/30] ext2: Define usercopy region in ext2_inode_cache slab
    [PATCH 09/30] jfs: Define usercopy region in jfs_ip slab cache
    [PATCH 10/30] befs: Define usercopy region in befs_inode_cache slab
    [PATCH 11/30] exofs: Define usercopy region in exofs_inode_cache slab
    [PATCH 12/30] orangefs: Define usercopy region in
    [PATCH 13/30] ufs: Define usercopy region in ufs_inode_cache slab
    [PATCH 14/30] vxfs: Define usercopy region in vxfs_inode slab cache
    [PATCH 15/30] xfs: Define usercopy region in xfs_inode slab cache
    [PATCH 16/30] cifs: Define usercopy region in cifs_request slab cache

Update scsi layer for inline storage:
    [PATCH 17/30] scsi: Define usercopy region in scsi_sense_cache slab

Whitelist a few network protocol-specific areas of memory:
    [PATCH 18/30] net: Define usercopy region in struct proto slab cache
    [PATCH 19/30] ip: Define usercopy region in IP proto slab cache
    [PATCH 20/30] caif: Define usercopy region in caif proto slab cache
    [PATCH 21/30] sctp: Define usercopy region in SCTP proto slab cache
    [PATCH 22/30] sctp: Copy struct sctp_sock.autoclose to userspace
    [PATCH 23/30] net: Restrict unwhitelisted proto caches to size 0

Whitelist areas of process memory:
    [PATCH 24/30] fork: Define usercopy region in mm_struct slab caches
    [PATCH 25/30] fork: Define usercopy region in thread_stack slab

Deal with per-architecture thread_struct whitelisting:
    [PATCH 26/30] fork: Provide usercopy whitelisting for task_struct
    [PATCH 27/30] x86: Implement thread_struct whitelist for hardened
    [PATCH 28/30] arm64: Implement thread_struct whitelist for hardened
    [PATCH 29/30] arm: Implement thread_struct whitelist for hardened

Make blacklisting the default:
    [PATCH 30/30] usercopy: Restrict non-usercopy caches to size 0

v2:
- added tracing of allocation and usage
- refactored solutions for task_struct
- split up network patches for readability

I intend for this to land via my usercopy hardening tree, so Acks,
Reviewed, and Tested-bys would be greatly appreciated. I have some
questions in a few patches (e.g. CIFS and thread_stack) that would be
nice to get answered for completeness. FWIW, this series has survived
over the weekend in 0-day testing.

Thanks!

-Kees (and David)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
