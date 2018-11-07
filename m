Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id F086B6B04DD
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:18:44 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id 88-v6so14887528wrp.21
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:18:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3-v6sor176996wru.7.2018.11.07.02.18.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 02:18:43 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/5] mm, memory_hotplug: improve memory offlining failures debugging
Date: Wed,  7 Nov 2018 11:18:25 +0100
Message-Id: <20181107101830.17405-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
I have been promissing to improve memory offlining failures debugging
for quite some time. As things stand now we get only very limited
information in the kernel log when the offlining fails. It is usually
only
[ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed
without no further details. We do not know what exactly fails and for
what reason. Whenever I was forced to debug such a failure I've always
had to do a debugging patch to tell me more. We can enable some
tracepoints but it would be much better to get a better picture without
using them.

This patch series does 2 things. The first one is to make dump_page
more usable by printing more information about the mapping patch 1.
Then it reduces the log level from emerg to warning so that this
function is usable from less critical context patch 2. Then I have
added more detailed information about the offlining failure patch 4
and finally add dump_page to isolation and offlining migration paths.
Patch 3 is a trivial cleanup.

Does this look go to you?

Shortlog
Michal Hocko (5):
      mm: print more information about mapping in __dump_page
      mm: lower the printk loglevel for __dump_page messages
      mm, memory_hotplug: drop pointless block alignment checks from __offline_pages
      mm, memory_hotplug: print reason for the offlining failure
      mm, memory_hotplug: be more verbose for memory offline failures

Diffstat:
 mm/debug.c          | 23 ++++++++++++++++++-----
 mm/memory_hotplug.c | 52 +++++++++++++++++++++++++++++++---------------------
 mm/page_alloc.c     |  1 +
 3 files changed, 50 insertions(+), 26 deletions(-)
