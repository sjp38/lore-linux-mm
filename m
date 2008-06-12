Subject: Re: [PATCH] ext2: Use page_mkwrite vma_operations to get mmap
	write notification.
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20080612040643.GA5518@skywalker>
References: <1212685513-32237-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20080605123045.445e380a.akpm@linux-foundation.org>
	 <20080611150845.GA21910@skywalker>
	 <20080611120749.d0c5a7de.akpm@linux-foundation.org>
	 <20080612040643.GA5518@skywalker>
Content-Type: text/plain
Date: Thu, 12 Jun 2008 08:22:43 -0400
Message-Id: <1213273364.10187.281.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cmm@us.ibm.com, jack@suse.cz, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-06-12 at 09:36 +0530, Aneesh Kumar K.V wrote:
> On Wed, Jun 11, 2008 at 12:07:49PM -0700, Andrew Morton wrote:
> > On Wed, 11 Jun 2008 20:38:45 +0530
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> The idea is to have ext3/4_writepages. In writepages start a transaction
> and iterate over the pages take the lock and do block allocation. With
> that change we should be able to not do block allocation in the
> page_mkwrite path. We may still want to do block reservation there.
> 
> Something like.
> 
> ext4_writepages()
> {
> 	journal_start()
> 	for_each_page()

Even with delayed allocation, the vast majority of the pages won't need
any allocations.  You'll hit delalloc, do a big chunk with the journal
lock held and then do simple writepages that don't need anything
special.

I know the jbd journal_start is cheaper than the reiserfs one is, but it
might not perform well to hold it across the long writepages loop.  At
least reiser saw a good boost when I stopped calling journal_begin in
writepage unless the page really needed allocations.

With the loop you have in mind, it is easy enough to back out and start
the transaction only when required.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
