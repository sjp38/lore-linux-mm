Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9C39F6B0092
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:04:38 -0500 (EST)
Message-Id: <20090216142926.440561506@cmpxchg.org>
Date: Mon, 16 Feb 2009 15:29:26 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] kzfree()
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This series introduces kzfree() and converts callsites which do
memset() + kfree() explicitely.

The callsites may be incomplete, I used coccinelle [1] to find them.

Regarding the recent re-exporting of ksize() to modules and the
discussion around it [2], this removes the single modular in-tree user
of ksize() again (unless I overgrepped something).

kfree() uses ksize() internally to determine the size of the memory
region to zero out.  This could mean overhead as the size is actually
that of the kmalloc cache the object is from, but memset() + kfree()
isn't really the common fast path pattern.

I left out w1 because I think it doesn't need to zero the memory at
all.  I will take a deeper look into it and send a followup with
either a kzfree() conversion or removal of the memset() alltogether.

	Hannes

[1] http://www.emn.fr/x-info/coccinelle/

	@@
	expression M, S;
	@@

	- memset(M, 0, S);
	- kfree(M);
	+ kzfree(M);

   (from the back of my head, no coccinelle installed on this box)

[2] http://lkml.org/lkml/2009/2/10/144

 arch/s390/crypto/prng.c             |    3 +--
 crypto/api.c                        |    5 +----
 drivers/md/dm-crypt.c               |    6 ++----
 drivers/s390/crypto/zcrypt_pcixcc.c |    3 +--
 drivers/usb/host/hwa-hc.c           |    3 +--
 drivers/usb/wusbcore/cbaf.c         |    3 +--
 fs/cifs/connect.c                   |    7 ++-----
 fs/cifs/misc.c                      |   12 ++++--------
 fs/ecryptfs/keystore.c              |    3 +--
 fs/ecryptfs/messaging.c             |    3 +--
 include/linux/slab.h                |    1 +
 mm/util.c                           |   19 +++++++++++++++++++
 net/atm/mpoa_caches.c               |   14 ++++----------
 13 files changed, 39 insertions(+), 43 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
