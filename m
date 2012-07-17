Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 62CF06B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 18:29:46 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1206000ghr.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 15:29:45 -0700 (PDT)
Date: Tue, 17 Jul 2012 15:29:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix wrong argument of migrate_huge_pages() in
 soft_offline_huge_page()
In-Reply-To: <20120717134915.76adf9bd.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1207171526440.23015@chino.kir.corp.google.com>
References: <1342544460-20095-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207171340420.9675@chino.kir.corp.google.com> <20120717134915.76adf9bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

On Tue, 17 Jul 2012, Andrew Morton wrote:

> > > Commit a6bc32b899223a877f595ef9ddc1e89ead5072b8 ('mm: compaction: introduce
> > > sync-light migration for use by compaction') change declaration of
> > > migrate_pages() and migrate_huge_pages().
> > > But, it miss changing argument of migrate_huge_pages()
> > > in soft_offline_huge_page(). In this case, we should call with MIGRATE_SYNC.
> > > So change it.
> > > 
> > > Additionally, there is mismatch between type of argument and function
> > > declaration for migrate_pages(). So fix this simple case, too.
> > > 
> > > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> > 
> > Should be cc'd to stable for 3.3+.
> 
> Well, why?  I'm suspecting a switch from MIGRATE_SYNC_LIGHT to
> MIGRATE_SYNC will have no discernable effect.  Unless it triggers hitherto
> unknkown about deadlocks...
> 
> For a -stable backport we should have a description of the end-user
> visible effects of the bug.  This changelog lacked such a description.
> 

I would put this:

MIGRATE_SYNC_LIGHT will not aggressively attempt to defragment memory when 
allocating hugepages for migration with MIGRATE_SYNC_LIGHT, such as not 
defragmenting dirty pages, so MADV_SOFT_OFFLINE and 
/sys/devices/system/memory/soft_offline_page would be significantly 
less successful without this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
