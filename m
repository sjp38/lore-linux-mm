Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D391A6B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 00:17:48 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p65so6823326wmp.0
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 21:17:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ly10si25064472wjb.9.2016.02.27.21.17.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Feb 2016 21:17:47 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sun, 28 Feb 2016 16:09:29 +1100
Subject: [PATCH 0/3] RFC improvements to radix-tree related to DAX
Message-ID: <145663588892.3865.9987439671424028216.stgit@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi,

While pondering some issues with DAX and how it uses the radix tree I
conceived the following patches.  I don't know if they'll be useful
but I thought I would post them in case they are helpful.

The first is quite independent of the others - it removes some DAX
specific #defines from radix-tree.h which is a generic ADT.

The second makes an extra bit available when exception data is
stored in the radix tree.

The third uses this bit to provide a sleeping lock.  With this
it should be possible to delete exceptional entries from the radix
tree in a race-free way without external locking.
Like the page lock it requires an external set of wait_queue_heads.
The same ones used for page_lock would be suitable.

Note that this code is only compile tested.

NeilBrown


---

NeilBrown (3):
      DAX: move RADIX_DAX_ definitions to dax.c
      radix-tree: make 'indirect' bit available to exception entries.
      radix-tree: support locking of individual exception entries.


 fs/dax.c                   |    9 ++
 include/linux/radix-tree.h |   28 +++++---
 lib/radix-tree.c           |  160 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 185 insertions(+), 12 deletions(-)

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
