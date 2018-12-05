Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84F186B71F7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 21:35:33 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id g188so10219014pgc.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 18:35:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f21sor24925599pgm.40.2018.12.04.18.35.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 18:35:32 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] core-api/memory-hotplug.rst: divide Locking Internal section by different locks
Date: Wed,  5 Dec 2018 10:34:26 +0800
Message-Id: <20181205023426.24029-2-richard.weiyang@gmail.com>
In-Reply-To: <20181205023426.24029-1-richard.weiyang@gmail.com>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@redhat.com, mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Currently locking for memory hotplug is a little complicated.

Generally speaking, we leverage the two global lock:

  * device_hotplug_lock
  * mem_hotplug_lock

to serialise the process.

While for the long term, we are willing to have more fine-grained lock
to provide higher scalability.

This patch divides Locking Internal section based on these two global
locks to help readers to understand it. Also it adds some new finding to
enrich it.

[David: words arrangement]

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 Documentation/core-api/memory-hotplug.rst | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/Documentation/core-api/memory-hotplug.rst b/Documentation/core-api/memory-hotplug.rst
index de7467e48067..95662b283328 100644
--- a/Documentation/core-api/memory-hotplug.rst
+++ b/Documentation/core-api/memory-hotplug.rst
@@ -89,6 +89,20 @@ NOTIFY_STOP stops further processing of the notification queue.
 Locking Internals
 =================
 
+There are three locks involved in memory-hotplug, two global lock and one local
+lock:
+
+- device_hotplug_lock
+- mem_hotplug_lock
+- device_lock
+
+Currently, they are twisted together for all kinds of reasons. The following
+part is divided into device_hotplug_lock and mem_hotplug_lock parts
+respectively to describe those tricky situations.
+
+device_hotplug_lock
+---------------------
+
 When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
 the device_hotplug_lock should be held to:
 
@@ -111,13 +125,20 @@ As the device is visible to user space before taking the device_lock(), this
 can result in a lock inversion.
 
 onlining/offlining of memory should be done via device_online()/
-device_offline() - to make sure it is properly synchronized to actions
-via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
+device_offline() - to make sure it is properly synchronized to actions via
+sysfs. Even mem_hotplug_lock is used to protect the process, because of the
+lock inversion described above, holding device_hotplug_lock is still advised
+(to e.g. protect online_type)
+
+mem_hotplug_lock
+---------------------
 
 When adding/removing/onlining/offlining memory or adding/removing
 heterogeneous/device memory, we should always hold the mem_hotplug_lock in
 write mode to serialise memory hotplug (e.g. access to global/zone
-variables).
+variables). Currently, we take advantage of this to serialise sparsemem's
+mem_section handling in sparse_add_one_section() and
+sparse_remove_one_section().
 
 In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
 mode allows for a quite efficient get_online_mems/put_online_mems
-- 
2.15.1
