Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED13E6B0007
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:19:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g5-v6so138332pgv.12
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:19:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h126-v6si7681354pgc.429.2018.07.23.04.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 04:19:51 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/4] cleanups and refactor of /proc/pid/smaps*
Date: Mon, 23 Jul 2018 13:19:29 +0200
Message-Id: <20180723111933.15443-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The recent regression in /proc/pid/smaps made me look more into the code.
Especially the issues with smaps_rollup reported in [1] as explained in
Patch 4, which fixes them by refactoring the code. Patches 2 and 3 are
preparations for that. Patch 1 is me realizing that there's a lot of
boilerplate left from times where we tried (unsuccessfuly) to mark thread
stacks in the output.

Originally I had also plans to rework the translation from /proc/pid/*maps*
file offsets to the internal structures. Now the offset means "vma number",
which is not really stable (vma's can come and go between read() calls) and
there's an extra caching of last vma's address. My idea was that offsets would
be interpreted directly as addresses, which would also allow meaningful seeks
(see the ugly seek_to_smaps_entry() in tools/testing/selftests/vm/mlock2.h).
However loff_t is (signed) long long so that might be insufficient somewhere
for the unsigned long addresses.

So the result is fixed issues with skewed /proc/pid/smaps_rollup results,
simpler smaps code, and a lot of unused code removed.

[1] https://marc.info/?l=linux-mm&m=151927723128134&w=2

Vlastimil Babka (4):
  mm: /proc/pid/*maps remove is_pid and related wrappers
  mm: proc/pid/smaps: factor out mem stats gathering
  mm: proc/pid/smaps: factor out common stats printing
  mm: proc/pid/smaps_rollup: convert to single value seq_file

 fs/proc/base.c       |   6 +-
 fs/proc/internal.h   |   3 -
 fs/proc/task_mmu.c   | 294 +++++++++++++++++++------------------------
 fs/proc/task_nommu.c |  39 +-----
 4 files changed, 133 insertions(+), 209 deletions(-)

-- 
2.18.0
