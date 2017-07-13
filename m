Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABC0D4408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 17:15:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id h63so25051870qkf.6
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:15:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t185si6093824qkc.252.2017.07.13.14.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 14:15:44 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 6/6] mm/hmm: documents how device memory is accounted in rss and memcg
Date: Thu, 13 Jul 2017 17:15:32 -0400
Message-Id: <20170713211532.970-7-jglisse@redhat.com>
In-Reply-To: <20170713211532.970-1-jglisse@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

For now we account device memory exactly like a regular page in
respect to rss counters and memory cgroup. We do this so that any
existing application that starts using device memory without knowing
about it will keep running unimpacted. This also simplify migration
code.

We will likely revisit this choice once we gain more experience with
how device memory is use and how it impacts overall memory resource
management. For now we believe this is a good enough choice.

Note that device memory can not be pin. Nor by device driver, nor
by GUP thus device memory can always be free and unaccounted when
a process exit.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 Documentation/vm/hmm.txt | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
index 192dcdb38bd1..4d3aac9f4a5d 100644
--- a/Documentation/vm/hmm.txt
+++ b/Documentation/vm/hmm.txt
@@ -15,6 +15,15 @@ section present the new migration helper that allow to leverage the device DMA
 engine.
 
 
+1) Problems of using device specific memory allocator:
+2) System bus, device memory characteristics
+3) Share address space and migration
+4) Address space mirroring implementation and API
+5) Represent and manage device memory from core kernel point of view
+6) Migrate to and from device memory
+7) Memory cgroup (memcg) and rss accounting
+
+
 -------------------------------------------------------------------------------
 
 1) Problems of using device specific memory allocator:
@@ -342,3 +351,34 @@ that happens then the finalize_and_map() can catch any pages that was not
 migrated. Note those page were still copied to new page and thus we wasted
 bandwidth but this is considered as a rare event and a price that we are
 willing to pay to keep all the code simpler.
+
+
+-------------------------------------------------------------------------------
+
+7) Memory cgroup (memcg) and rss accounting
+
+For now device memory is accounted as any regular page in rss counters (either
+anonymous if device page is use for anonymous, file if device page is use for
+file back page or shmem if device page is use for share memory). This is a
+deliberate choice to keep existing application that might start using device
+memory without knowing about it to keep runing unimpacted.
+
+Drawbacks is that OOM killer might kill an application using a lot of device
+memory and not a lot of regular system memory and thus not freeing much system
+memory. We want to gather more real world experience on how application and
+system react under memory pressure in the presence of device memory before
+deciding to account device memory differently.
+
+
+Same decision was made for memory cgroup. Device memory page are accounted
+against same memory cgroup a regular page would be accounted to. This does
+simplify migration to and from device memory. This also means that migration
+back from device memory to regular memory can not fail because it would
+go above memory cgroup limit. We might revisit this choice latter on once we
+get more experience in how device memory is use and its impact on memory
+resource control.
+
+
+Note that device memory can never be pin nor by device driver nor through GUP
+and thus such memory is always free upon process exit. Or when last reference
+is drop in case of share memory or file back memory.
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
