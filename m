Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 880386B005A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 18:37:18 -0500 (EST)
Date: Fri, 16 Dec 2011 15:37:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/11] Reduce compaction-related stalls and improve
 asynchronous migration of dirty pages v6
Message-Id: <20111216153716.434bbf05.akpm@linux-foundation.org>
In-Reply-To: <1323877293-15401-1-git-send-email-mgorman@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 14 Dec 2011 15:41:22 +0000
Mel Gorman <mgorman@suse.de> wrote:

> Short summary: There are severe stalls when a USB stick using VFAT
> is used with THP enabled that are reduced by this series. If you are
> experiencing this problem, please test and report back and considering
> I have seen complaints from openSUSE and Fedora users on this as well
> as a few private mails, I'm guessing it's a widespread issue. This
> is a new type of USB-related stall because it is due to synchronous
> compaction writing where as in the past the big problem was dirty
> pages reaching the end of the LRU and being written by reclaim.

Overall footprint:

 fs/btrfs/disk-io.c            |    5 
 fs/hugetlbfs/inode.c          |    3 
 fs/nfs/internal.h             |    2 
 fs/nfs/write.c                |    4 
 include/linux/fs.h            |   11 +-
 include/linux/migrate.h       |   23 +++-
 include/linux/mmzone.h        |    4 
 include/linux/vm_event_item.h |    1 
 mm/compaction.c               |    5 
 mm/memory-failure.c           |    2 
 mm/memory_hotplug.c           |    2 
 mm/mempolicy.c                |    2 
 mm/migrate.c                  |  171 +++++++++++++++++++++-----------
 mm/page_alloc.c               |   50 +++++++--
 mm/swap.c                     |   74 ++++++++++++-
 mm/vmscan.c                   |  114 ++++++++++++++++++---
 mm/vmstat.c                   |    2 
 17 files changed, 371 insertions(+), 104 deletions(-)

The line count belies the increase in complexity.

Sigh, this whole hugetlb page thing is just killing us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
