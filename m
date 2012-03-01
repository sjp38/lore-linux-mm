Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 072D76B007E
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 17:40:31 -0500 (EST)
Date: Thu, 1 Mar 2012 17:40:14 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH -V2] hugetlbfs: Drop taking inode i_mutex lock from
 hugetlbfs_read
Message-ID: <20120301224014.GA21990@redhat.com>
References: <1330593530-2022-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120301141007.274ad458.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120301141007.274ad458.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org

On Thu, Mar 01, 2012 at 02:10:07PM -0800, Andrew Morton wrote:
 
 > > AFAIU i_mutex lock got added to  hugetlbfs_read as per
 > > http://lkml.indiana.edu/hypermail/linux/kernel/0707.2/3066.html
 > > to take care of the race between truncate and read. This patch fix
 > > this by looking at page->mapping under page_lock (find_lock_page())
 > > to ensure; the inode didn't get truncated in the range during a
 > > parallel read.
 > > 
 > > Ideally we can extend the patch to make sure we don't increase i_size
 > > in mmap. But that will break userspace, because application will now
 > > have to use truncate(2) to increase i_size in hugetlbfs.
 > 
 > Looks OK to me.
 > 
 > Given that the bug has been there for four years, I'm assuming that
 > we'll be OK merging this fix into 3.4.  Or we could merge it into 3.4
 > and tag it for backporting into earlier kernels - it depends on whether
 > people are hurting from it, which I don't know?

My testing hits this every day. It's not a real problem, but it's annoying
to see the lockdep spew constantly.  We've had a couple Fedora users
report it too in regular day-to-day use as opposed to the hostile
workloads I use to provoke it.

FWIW, I'll probably throw it in the Fedora kernels, so if it ends up
in stable, it'll be one less patch to carry.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
