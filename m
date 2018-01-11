Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDE56B0253
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r8so1695140pgq.1
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor769321pgr.89.2018.01.10.18.03.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:22 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v5 00/38] Hardened usercopy whitelisting
Date: Wed, 10 Jan 2018 18:02:32 -0800
Message-Id: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

v5:
- add Acks
- split stddef changes into separate patch
- further refactor reporting code for readability
- adjust enforcement code for greater readability

v4:
- refactor reporting to include offset and remove %p
- explicitly WARN by default for the whitelisting
- add KVM whitelists and harden ioctl handling

v3:
- added LKDTM update patch
- downgrade BUGs to WARNs and fail closed
- add Acks/Reviews from v2

v2:
- added tracing of allocation and usage
- refactored solutions for task_struct
- split up network patches for readability

I intend for this to land via my usercopy hardening tree, so Acks,
Reviewed, and Tested-bys would be greatly appreciated. FWIW, the bulk of
this series has survived for months in 0-day testing and -next, with the
more recently-added offset-reporting having existed there for a week.

Linus, getting your attention early on this -- instead of during the
merge window :) -- would be greatly appreciated. I'm hoping this is a
good time, in a slight lull in PTI and related things needing attention.

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

Report offsets and drop %p usage:
    [PATCH 01/38] usercopy: Remove pointer from overflow report
    [PATCH 02/38] usercopy: Enhance and rename report_usercopy()
    [PATCH 03/38] usercopy: Include offset in hardened usercopy report
    [PATCH 04/38] lkdtm/usercopy: Adjust test to include an offset to

Prepare infrastructure, set up WARN handler, and whitelist kmalloc:
    [PATCH 05/38] stddef.h: Introduce sizeof_field()
    [PATCH 06/38] usercopy: Prepare for usercopy whitelisting
    [PATCH 07/38] usercopy: WARN() on slab cache usercopy region
    [PATCH 08/38] usercopy: Allow strict enforcement of whitelists
    [PATCH 09/38] usercopy: Mark kmalloc caches as usercopy caches

Update VFS layer for symlinks and other inline storage:
    [PATCH 10/38] dcache: Define usercopy region in dentry_cache slab
    [PATCH 11/38] vfs: Define usercopy region in names_cache slab caches
    [PATCH 12/38] vfs: Copy struct mount.mnt_id to userspace using
    [PATCH 13/38] ext4: Define usercopy region in ext4_inode_cache slab
    [PATCH 14/38] ext2: Define usercopy region in ext2_inode_cache slab
    [PATCH 15/38] jfs: Define usercopy region in jfs_ip slab cache
    [PATCH 16/38] befs: Define usercopy region in befs_inode_cache slab
    [PATCH 17/38] exofs: Define usercopy region in exofs_inode_cache slab
    [PATCH 18/38] orangefs: Define usercopy region in
    [PATCH 19/38] ufs: Define usercopy region in ufs_inode_cache slab
    [PATCH 20/38] vxfs: Define usercopy region in vxfs_inode slab cache
    [PATCH 21/38] cifs: Define usercopy region in cifs_request slab cache

Update scsi layer for inline storage:
    [PATCH 22/38] scsi: Define usercopy region in scsi_sense_cache slab

Whitelist a few network protocol-specific areas of memory:
    [PATCH 23/38] net: Define usercopy region in struct proto slab cache
    [PATCH 24/38] ip: Define usercopy region in IP proto slab cache
    [PATCH 25/38] caif: Define usercopy region in caif proto slab cache
    [PATCH 26/38] sctp: Define usercopy region in SCTP proto slab cache
    [PATCH 27/38] sctp: Copy struct sctp_sock.autoclose to userspace
    [PATCH 28/38] net: Restrict unwhitelisted proto caches to size 0

Whitelist areas of process memory:
    [PATCH 29/38] fork: Define usercopy region in mm_struct slab caches
    [PATCH 30/38] fork: Define usercopy region in thread_stack slab

Deal with per-architecture thread_struct whitelisting:
    [PATCH 31/38] fork: Provide usercopy whitelisting for task_struct
    [PATCH 32/38] x86: Implement thread_struct whitelist for hardened
    [PATCH 33/38] arm64: Implement thread_struct whitelist for hardened
    [PATCH 34/38] arm: Implement thread_struct whitelist for hardened

Update KVM for whitelisting:
    [PATCH 35/38] kvm: whitelist struct kvm_vcpu_arch
    [PATCH 36/38] kvm: x86: fix KVM_XEN_HVM_CONFIG ioctl

Make blacklisting the default:
    [PATCH 37/38] usercopy: Restrict non-usercopy caches to size 0

Update LKDTM:
    [PATCH 38/38] lkdtm: Update usercopy tests for whitelisting

Thanks!

-Kees (and David)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
