Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 8E5E06B00ED
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 18:11:37 -0500 (EST)
Date: Mon, 27 Feb 2012 15:11:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: Add new rw_semaphore to fix truncate/read
 race
Message-Id: <20120227151135.7d4076c6.akpm@linux-foundation.org>
In-Reply-To: <1330280398-27956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330280398-27956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org

On Sun, 26 Feb 2012 23:49:58 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Drop using inode->i_mutex from read, since that can result in deadlock with
> mmap. Ideally we can extend the patch to make sure we don't increase i_size
> in mmap. But that will break userspace, because application will have to now
> use truncate(2) to increase i_size in hugetlbfs.
> 
> AFAIU i_mutex was added in hugetlbfs_read as per
> http://lkml.indiana.edu/hypermail/linux/kernel/0707.2/3066.html

This patch comes somewhat out of the blue and I'm unsure what's going on.

You say there's some (potential?) deadlock with mmap, but it is
undescribed.  Have people observed this deadlock?  Has it caused
lockdep warnings?  Please update the changelog to fully describe the
bug.

Also, the new truncate_sem is undoumented.  This leaves readers to work
out for themselves what it might be for.  Please let's add code
comments which completely describe the race, and how this lock prevents
it.

We should also document our locking rules.  When should code take this
lock?  What are its ranking rules with respect to i_mutex, i_mmap_mutex
and possibly others?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
