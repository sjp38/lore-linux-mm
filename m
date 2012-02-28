Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 9ADC76B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 05:15:55 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 28 Feb 2012 15:45:49 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1SAFhfU4026390
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 15:45:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1SAFfKf029797
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 15:45:43 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlbfs: Add new rw_semaphore to fix truncate/read race
In-Reply-To: <20120227151135.7d4076c6.akpm@linux-foundation.org>
References: <1330280398-27956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120227151135.7d4076c6.akpm@linux-foundation.org>
Date: Tue, 28 Feb 2012 15:45:25 +0530
Message-ID: <87ipirclhe.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org

On Mon, 27 Feb 2012 15:11:35 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sun, 26 Feb 2012 23:49:58 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Drop using inode->i_mutex from read, since that can result in deadlock with
> > mmap. Ideally we can extend the patch to make sure we don't increase i_size
> > in mmap. But that will break userspace, because application will have to now
> > use truncate(2) to increase i_size in hugetlbfs.
> > 
> > AFAIU i_mutex was added in hugetlbfs_read as per
> > http://lkml.indiana.edu/hypermail/linux/kernel/0707.2/3066.html
> 
> This patch comes somewhat out of the blue and I'm unsure what's going on.
> 
> You say there's some (potential?) deadlock with mmap, but it is
> undescribed.  Have people observed this deadlock?  Has it caused
> lockdep warnings?  Please update the changelog to fully describe the
> bug.

Viro explained the deadlock in detail here:

http://mid.gmane.org/20120217002726.GL23916@ZenIV.linux.org.uk

I will also update the commit message with this information.

> 
> Also, the new truncate_sem is undoumented.  This leaves readers to work
> out for themselves what it might be for.  Please let's add code
> comments which completely describe the race, and how this lock prevents
> it.
> 
> We should also document our locking rules.  When should code take this
> lock?  What are its ranking rules with respect to i_mutex, i_mmap_mutex
> and possibly others?
> 

Will update the patch with these details

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
