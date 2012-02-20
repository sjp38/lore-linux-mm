Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id CFBBD6B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 01:15:23 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so7291867pbc.14
        for <linux-mm@kvack.org>; Sun, 19 Feb 2012 22:15:23 -0800 (PST)
Date: Mon, 20 Feb 2012 14:20:06 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: Fine granularity page reclaim
Message-ID: <20120220062006.GA5028@gmail.com>
References: <20120217092205.GA9462@gmail.com>
 <4F3EB675.9030702@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F3EB675.9030702@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernl@vger.kernel.org

Cc linux-kernel mailing list.

On Sat, Feb 18, 2012 at 12:20:05AM +0400, Konstantin Khlebnikov wrote:
> Zheng Liu wrote:
> >Hi all,
> >
> >Currently, we encounter a problem about page reclaim. In our product system,
> >there is a lot of applictions that manipulate a number of files. In these
> >files, they can be divided into two categories. One is index file, another is
> >block file. The number of index files is about 15,000, and the number of
> >block files is about 23,000 in a 2TB disk. The application accesses index
> >file using mmap(2), and read/write block file using pread(2)/pwrite(2). We hope
> >to hold index file in memory as much as possible, and it works well in Redhat
> >2.6.18-164. It is about 60-70% of index files that can be hold in memory.
> >However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18 that the
> >linux uses an active list and an inactive list to handle page reclaim, and in
> >2.6.32 that they are divided into anonymous list and file list. So I am
> >curious about why most of index files can be hold in 2.6.18? The index file
> >should be replaced because mmap doesn't impact the lru list.
> 
> There was my patch for fixing similar problem with shared/executable mapped pages
> "vmscan: promote shared file mapped pages" commit 34dbc67a644f and commit c909e99364c
> maybe it will help in your case.

Hi Konstantin,

Thank you for your reply.  I have tested it in upstream kernel.  These
patches are useful for multi-processes applications.  But, in our product
system, there are some applications that are multi-thread.  So
'references_ptes > 1' cannot help these applications to hold the data in
memory.

Regards,
Zheng

> 
> >
> >BTW, I have some problems that need to be discussed.
> >
> >1. I want to let index and block files are separately reclaimed. Is there any
> >ways to satisify me in current upstream?
> >
> >2. Maybe we can provide a mechansim to let different files to be mapped into
> >differnet nodes. we can provide a ioctl(2) to tell kernel that this file should
> >be mapped into a specific node id. A nid member is added into addpress_space
> >struct. When alloc_page is called, the page can be allocated from that specific
> >node id.
> >
> >3. Currently the page can be reclaimed according to pid in memcg. But it is too
> >coarse. I don't know whether memcg could provide a fine granularity page
> >reclaim mechansim. For example, the page is reclaimed according to inode number.
> >
> >I don't subscribe this mailing list, So please Cc me. Thank you.
> >
> >Regards,
> >Zheng
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> >Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
