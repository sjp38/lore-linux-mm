Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 794768E0006
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a70-v6so2852116qkb.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:05 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o3-v6si1423901qkd.87.2018.09.12.13.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:04 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 0/6] VA to numa node information
Date: Wed, 12 Sep 2018 13:23:58 -0700
Message-Id: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

For analysis purpose it is useful to have numa node information
corresponding mapped virtual address ranges of a process. Currently,
the file /proc/<pid>/numa_maps provides list of numa nodes from where pages
are allocated per VMA of a process. This is not useful if an user needs to
determine which numa node the mapped pages are allocated from for a
particular address range. It would have helped if the numa node information
presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
exact numa node from where the pages have been allocated.

The format of /proc/<pid>/numa_maps file content is dependent on
/proc/<pid>/maps file content as mentioned in the manpage. i.e one line
entry for every VMA corresponding to entries in /proc/<pids>/maps file.
Therefore changing the output of /proc/<pid>/numa_maps may not be possible.

This patch set introduces the file /proc/<pid>/numa_vamaps which
will provide proper break down of VA ranges by numa node id from where the
mapped pages are allocated. For Address ranges not having any pages mapped,
a '-' is printed instead of numa node id.

Includes support to lseek, allowing seeking to a specific process Virtual
address(VA) starting from where the address range to numa node information
can to be read from this file.

The new file /proc/<pid>/numa_vamaps will be governed by ptrace access
mode PTRACE_MODE_READ_REALCREDS.

See following for previous discussion about this proposal

https://marc.info/?t=152524073400001&r=1&w=2


Prakash Sangappa (6):
  Add check to match numa node id when gathering pte stats
  Add /proc/<pid>/numa_vamaps file for numa node information
  Provide process address range to numa node id mapping
  Add support to lseek /proc/<pid>/numa_vamaps file
  File /proc/<pid>/numa_vamaps access needs PTRACE_MODE_READ_REALCREDS
    check
  /proc/pid/numa_vamaps: document in Documentation/filesystems/proc.txt

 Documentation/filesystems/proc.txt |  21 +++
 fs/proc/base.c                     |   6 +-
 fs/proc/internal.h                 |   1 +
 fs/proc/task_mmu.c                 | 265 ++++++++++++++++++++++++++++++++++++-
 4 files changed, 285 insertions(+), 8 deletions(-)

-- 
2.7.4
