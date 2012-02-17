Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 4D1BD6B0126
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 15:20:11 -0500 (EST)
Received: by bkty12 with SMTP id y12so4406590bkt.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 12:20:09 -0800 (PST)
Message-ID: <4F3EB675.9030702@openvz.org>
Date: Sat, 18 Feb 2012 00:20:05 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: Fine granularity page reclaim
References: <20120217092205.GA9462@gmail.com>
In-Reply-To: <20120217092205.GA9462@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Zheng Liu wrote:
> Hi all,
>
> Currently, we encounter a problem about page reclaim. In our product system,
> there is a lot of applictions that manipulate a number of files. In these
> files, they can be divided into two categories. One is index file, another is
> block file. The number of index files is about 15,000, and the number of
> block files is about 23,000 in a 2TB disk. The application accesses index
> file using mmap(2), and read/write block file using pread(2)/pwrite(2). We hope
> to hold index file in memory as much as possible, and it works well in Redhat
> 2.6.18-164. It is about 60-70% of index files that can be hold in memory.
> However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18 that the
> linux uses an active list and an inactive list to handle page reclaim, and in
> 2.6.32 that they are divided into anonymous list and file list. So I am
> curious about why most of index files can be hold in 2.6.18? The index file
> should be replaced because mmap doesn't impact the lru list.

There was my patch for fixing similar problem with shared/executable mapped pages
"vmscan: promote shared file mapped pages" commit 34dbc67a644f and commit c909e99364c
maybe it will help in your case.

>
> BTW, I have some problems that need to be discussed.
>
> 1. I want to let index and block files are separately reclaimed. Is there any
> ways to satisify me in current upstream?
>
> 2. Maybe we can provide a mechansim to let different files to be mapped into
> differnet nodes. we can provide a ioctl(2) to tell kernel that this file should
> be mapped into a specific node id. A nid member is added into addpress_space
> struct. When alloc_page is called, the page can be allocated from that specific
> node id.
>
> 3. Currently the page can be reclaimed according to pid in memcg. But it is too
> coarse. I don't know whether memcg could provide a fine granularity page
> reclaim mechansim. For example, the page is reclaimed according to inode number.
>
> I don't subscribe this mailing list, So please Cc me. Thank you.
>
> Regards,
> Zheng
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
