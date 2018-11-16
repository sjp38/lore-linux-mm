Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEEE6B087E
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:30:33 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id s50so2669810edd.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:30:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w15-v6sor15286100edb.5.2018.11.16.00.30.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 00:30:31 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/5] mm, memory_hotplug: improve memory offlining failures debugging
Date: Fri, 16 Nov 2018 09:30:15 +0100
Message-Id: <20181116083020.20260-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this has been posted as an RFC [1]. I have screwed during rebasing so
there were few compilation issues in the previous version. I have also
integrated review feedback from Andrew and Anshuman.

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

[1] http://lkml.kernel.org/r/20181107101830.17405-1-mhocko@kernel.org

Shortlog
Michal Hocko (5):
      mm: print more information about mapping in __dump_page
      mm: lower the printk loglevel for __dump_page messages
      mm, memory_hotplug: drop pointless block alignment checks from __offline_pages
      mm, memory_hotplug: print reason for the offlining failure
      mm, memory_hotplug: be more verbose for memory offline failures

Diffstat
 mm/debug.c          | 23 ++++++++++++++++++-----
 mm/memory_hotplug.c | 52 +++++++++++++++++++++++++++++++---------------------
 mm/page_alloc.c     |  1 +
 3 files changed, 50 insertions(+), 26 deletions(-)
