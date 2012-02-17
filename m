Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 9D0856B007E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 04:17:25 -0500 (EST)
Received: by dadv6 with SMTP id v6so3702001dad.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 01:17:24 -0800 (PST)
Date: Fri, 17 Feb 2012 17:22:05 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Fine granularity page reclaim
Message-ID: <20120217092205.GA9462@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi all,

Currently, we encounter a problem about page reclaim. In our product system,
there is a lot of applictions that manipulate a number of files. In these
files, they can be divided into two categories. One is index file, another is
block file. The number of index files is about 15,000, and the number of
block files is about 23,000 in a 2TB disk. The application accesses index
file using mmap(2), and read/write block file using pread(2)/pwrite(2). We hope
to hold index file in memory as much as possible, and it works well in Redhat
2.6.18-164. It is about 60-70% of index files that can be hold in memory.
However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18 that the
linux uses an active list and an inactive list to handle page reclaim, and in
2.6.32 that they are divided into anonymous list and file list. So I am
curious about why most of index files can be hold in 2.6.18? The index file
should be replaced because mmap doesn't impact the lru list.

BTW, I have some problems that need to be discussed.

1. I want to let index and block files are separately reclaimed. Is there any
ways to satisify me in current upstream?

2. Maybe we can provide a mechansim to let different files to be mapped into
differnet nodes. we can provide a ioctl(2) to tell kernel that this file should
be mapped into a specific node id. A nid member is added into addpress_space
struct. When alloc_page is called, the page can be allocated from that specific
node id.

3. Currently the page can be reclaimed according to pid in memcg. But it is too
coarse. I don't know whether memcg could provide a fine granularity page
reclaim mechansim. For example, the page is reclaimed according to inode number.

I don't subscribe this mailing list, So please Cc me. Thank you.

Regards,
Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
