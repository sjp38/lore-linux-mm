Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06D7A6B02FD
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g78so115399019pfg.4
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:48 -0700 (PDT)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id g5si10682959pln.247.2017.06.19.16.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:48 -0700 (PDT)
Received: by mail-pg0-x22b.google.com with SMTP id 132so21130676pgb.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:48 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 00/23] Hardened usercopy whitelisting
Date: Mon, 19 Jun 2017 16:36:14 -0700
Message-Id: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This series is modified from Brad Spengler/PaX Team's PAX_USERCOPY code
in the last public patch of grsecurity/PaX based on our understanding
of the code. Changes or omissions from the original code are ours and
don't reflect the original grsecurity/PaX code.

David Windsor did the bulk of the porting, refactoring, splitting,
testing, etc; I just did some extra tweaks, hunk moving, and small
extra patches.


This updates the slab allocator to add annotations (useroffset and
usersize) to define allowed usercopy regions. Currently, hardened
usercopy performs dynamic bounds checking on whole slab cache objects.
This is good, but still leaves a lot of kernel slab memory available to
be copied to/from userspace in the face of bugs. To further restrict
what memory is available for copying, this creates a way to whitelist
specific areas of a given slab cache object for copying to/from userspace,
allowing much finer granularity of access control. Slab caches that are
never exposed to userspace can declare no whitelist for their objects,
thereby keeping them unavailable to userspace via dynamic copy operations.
(Note, an implicit form of whitelisting is the use of constant sizes
in usercopy operations and get_user()/put_user(); these bypass hardened
usercopy checks since these sizes cannot change at runtime.)

Two good examples of how much more this protects are with task_struct
(a huge structure that only needs two fields exposed to userspace)
and mm_struct (another large and sensitive structure that only needs
auxv exposed). Other places for whitelists are mostly VFS name related,
and some areas of network caches.

To support the whitelist annotation, usercopy region offset and size
members are added to struct kmem_cache. The slab allocator receives a
new function that creates a new cache with a usercopy region defined
(kmem_cache_create_usercopy()), suitable for storing objects that get
copied to/from userspace. The default cache creation function
(kmem_cache_create()) remains unchanged and defaults to having no
whitelist region.

Additionally, a way to split trivially size-controllable kmallocs away
from the general-purpose kmalloc is added.

Finally, a Kconfig is created to control slab_nomerge, since it
would be nice to make this build-time controllable.

-Kees (and David)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
