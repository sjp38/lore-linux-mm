Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 36A6C6B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 04:15:50 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 18 Jul 2012 13:45:46 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6I8Fhmg42991650
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 13:45:43 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6IDj1oR030155
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 23:45:02 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: fix wrong argument of migrate_huge_pages() in soft_offline_huge_page()
In-Reply-To: <alpine.DEB.2.00.1207171526440.23015@chino.kir.corp.google.com>
References: <1342544460-20095-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207171340420.9675@chino.kir.corp.google.com> <20120717134915.76adf9bd.akpm@linux-foundation.org> <alpine.DEB.2.00.1207171526440.23015@chino.kir.corp.google.com>
Date: Wed, 18 Jul 2012 13:45:41 +0530
Message-ID: <87ipdlcwnm.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

David Rientjes <rientjes@google.com> writes:

> On Tue, 17 Jul 2012, Andrew Morton wrote:
>
>> > > Commit a6bc32b899223a877f595ef9ddc1e89ead5072b8 ('mm: compaction: introduce
>> > > sync-light migration for use by compaction') change declaration of
>> > > migrate_pages() and migrate_huge_pages().
>> > > But, it miss changing argument of migrate_huge_pages()
>> > > in soft_offline_huge_page(). In this case, we should call with MIGRATE_SYNC.
>> > > So change it.
>> > > 
>> > > Additionally, there is mismatch between type of argument and function
>> > > declaration for migrate_pages(). So fix this simple case, too.
>> > > 
>> > > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
>> > 
>> > Acked-by: David Rientjes <rientjes@google.com>
>> > 
>> > Should be cc'd to stable for 3.3+.
>> 
>> Well, why?  I'm suspecting a switch from MIGRATE_SYNC_LIGHT to
>> MIGRATE_SYNC will have no discernable effect.  Unless it triggers hitherto
>> unknkown about deadlocks...
>> 
>> For a -stable backport we should have a description of the end-user
>> visible effects of the bug.  This changelog lacked such a description.
>> 
>
> I would put this:
>
> MIGRATE_SYNC_LIGHT will not aggressively attempt to defragment memory when 
> allocating hugepages for migration with MIGRATE_SYNC_LIGHT, such as not 
> defragmenting dirty pages, so MADV_SOFT_OFFLINE and 
> /sys/devices/system/memory/soft_offline_page would be significantly 
> less successful without this patch.

Is that true with hugetlb pages ? hugetlbfs_migrate_page doesn't seem to
use the mode argument at all. We do look at MIGRATE_SYNC if we fail to
get page lock, but other than that do we look at mode argument for
hugetlb pages ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
