Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69A026B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:33:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c4so13820362pfg.22
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:33:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w12-v6si10012391pgs.183.2018.05.02.14.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:33:26 -0700 (PDT)
Date: Wed, 2 May 2018 14:33:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node
 information
Message-Id: <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
In-Reply-To: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>, Dave Hansen <dave.hansen@intel.com>

On Tue,  1 May 2018 22:58:06 -0700 Prakash Sangappa <prakash.sangappa@oracle.com> wrote:

> For analysis purpose it is useful to have numa node information
> corresponding mapped address ranges of the process. Currently
> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
> allocated per VMA of the process. This is not useful if an user needs to
> determine which numa node the mapped pages are allocated from for a
> particular address range. It would have helped if the numa node information
> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
> exact numa node from where the pages have been allocated.
> 
> The format of /proc/<pid>/numa_maps file content is dependent on
> /proc/<pid>/maps file content as mentioned in the manpage. i.e one line
> entry for every VMA corresponding to entries in /proc/<pids>/maps file.
> Therefore changing the output of /proc/<pid>/numa_maps may not be possible.
> 
> Hence, this patch proposes adding file /proc/<pid>/numa_vamaps which will
> provide proper break down of VA ranges by numa node id from where the mapped
> pages are allocated. For Address ranges not having any pages mapped, a '-'
> is printed instead of numa node id. In addition, this file will include most
> of the other information currently presented in /proc/<pid>/numa_maps. The
> additional information included is for convenience. If this is not
> preferred, the patch could be modified to just provide VA range to numa node
> information as the rest of the information is already available thru
> /proc/<pid>/numa_maps file.
> 
> Since the VA range to numa node information does not include page's PFN,
> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
> 
> Here is the snippet from the new file content showing the format.
> 
> 00400000-00401000 N0=1 kernelpagesize_kB=4 mapped=1 file=/tmp/hmap2
> 00600000-00601000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 file=/tmp/hmap2
> 00601000-00602000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 file=/tmp/hmap2
> 7f0215600000-7f0215800000 N0=1 kernelpagesize_kB=2048 dirty=1 file=/mnt/f1
> 7f0215800000-7f0215c00000 -  file=/mnt/f1
> 7f0215c00000-7f0215e00000 N0=1 kernelpagesize_kB=2048 dirty=1 file=/mnt/f1
> 7f0215e00000-7f0216200000 -  file=/mnt/f1
> ..
> 7f0217ecb000-7f0217f20000 N0=85 kernelpagesize_kB=4 mapped=85 mapmax=51
>    file=/usr/lib64/libc-2.17.so
> 7f0217f20000-7f0217f30000 -  file=/usr/lib64/libc-2.17.so
> 7f0217f30000-7f0217f90000 N0=96 kernelpagesize_kB=4 mapped=96 mapmax=51
>    file=/usr/lib64/libc-2.17.so
> 7f0217f90000-7f0217fb0000 -  file=/usr/lib64/libc-2.17.so
> ..
> 
> The 'pmap' command can be enhanced to include an option to show numa node
> information which it can read from this new proc file. This will be a
> follow on proposal.

I'd like to hear rather more about the use-cases for this new
interface.  Why do people need it, what is the end-user benefit, etc?

> There have been couple of previous patch proposals to provide numa node
> information based on pfn or physical address. They seem to have not made
> progress. Also it would appear reading numa node information based on PFN
> or physical address will require privileges(CAP_SYS_ADMIN) similar to
> reading PFN info from /proc/<pid>/pagemap.
> 
> See
> https://marc.info/?t=139630938200001&r=1&w=2
> 
> https://marc.info/?t=139718724400001&r=1&w=2

OK, let's hope that these people will be able to provide their review,
feedback, testing, etc.  You missed a couple (Dave, Naoya).

>  fs/proc/base.c     |   2 +
>  fs/proc/internal.h |   3 +
>  fs/proc/task_mmu.c | 299 ++++++++++++++++++++++++++++++++++++++++++++++++++++-

Some Documentation/ updates seem appropriate.  I suggest you grep the
directory for "numa_maps" to find suitable locations.

And a quick build check shows that `size fs/proc/task_mmu.o' gets quite
a bit larger when CONFIG_SMP=n and CONFIG_NUMA=n.  That seems wrong -
please see if you can eliminate the bloat from systems which don't need
this feature.
