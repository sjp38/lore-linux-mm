Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 34E946B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:50:00 -0500 (EST)
Date: Thu, 8 Mar 2012 21:49:52 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-ID: <20120308214951.GB23916@ZenIV.linux.org.uk>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120308130256.c7855cbd.akpm@linux-foundation.org>
 <20120308211926.GB6546@boyd>
 <20120308134050.f53a0b2f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120308134050.f53a0b2f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tyler Hicks <tyhicks@canonical.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Gibson <david@gibson.dropbear.id.au>

On Thu, Mar 08, 2012 at 01:40:50PM -0800, Andrew Morton wrote:

> OK, thanks, yup.  Taking i_mutex in file_operations.mmap() is wrong.

... or in .release() (munmap() does fput() under mmap_sem).

> Is hugetlbfs actually deadlockable because of this, or is it the case
> that the i_mutex->mmap_sem ordering happens to never happen for this
> filesystem?

Yes, it is.  Look at read(2) on hugetlbfs; it copies userland data
while holding ->i_mutex.  So we have

read(2):
mutex_lock(&A)
down_read(&B)

mmap(2):
down_write(&B);
mutex_lock(&A);

which is an obvious deadlock.

> So we need to pull the i_mutex out of hugetlbfs_file_mmap().

IIRC, you have a patch in your tree doing just that...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
