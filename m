Message-ID: <41A0CC68.8000405@namesys.com>
Date: Sun, 21 Nov 2004 09:12:08 -0800
From: Hans Reiser <reiser@namesys.com>
MIME-Version: 1.0
Subject: Re: [PATCH]: 4/4 cluster page-out in VM scanner
References: <16800.47066.827146.370838@gargle.gargle.HOWL>
In-Reply-To: <16800.47066.827146.370838@gargle.gargle.HOWL>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux Kernel Mailing List <Linux-Kernel@Vger.Kernel.ORG>, Andrew Morton <AKPM@Osdl.ORG>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

How well does this integrate with reiser4.;-)

Hans

Nikita Danilov wrote:

>Implement pageout clustering at the VM level.
>
>With this patch VM scanner calls pageout_cluster() instead of
>->writepage(). pageout_cluster() tries to find a group of dirty pages around
>target page, called "pivot" page of the cluster. If group of suitable size is
>found, ->writepages() is called for it, otherwise, page_cluster() falls back
>to ->writepage().
>
>This is supposed to help in work-loads with significant page-out of
>file-system pages from tail of the inactive list (for example, heavy dirtying
>through mmap), because file system usually writes multiple pages more
>efficiently. Should also be advantageous for file-systems doing delayed
>allocation, as in this case they will allocate whole extents at once.
>
>Few points:
>
> - swap-cache pages are not clustered (although they can be, but by
>   page->private rather than page->index)
>
> - currently, kswapd clusters all the time, and direct reclaim only when
>   device queue is not congested. Probably direct reclaim shouldn't cluster at
>   all.
>
> - this patch adds new fields to struct writeback_control and expects
>   ->writepages() to interpret them. This is needed, because pageout_cluster()
>   calls ->writepages() with pivot page already locked, so that ->writepages()
>   is allowed to only trylock other pages in the cluster.
>
>   Besides, rather rough plumbing (wbc->pivot_ret field) is added to check
>   whether ->writepages() failed to write pivot page for any reason (in latter
>   case page_cluster() falls back to ->writepage()).
>
>   Only mpage_writepages() was updated to honor these new fields, but
>   all in-tree ->writepages() implementations seem to call
>   mpage_writepages(). (Except reiser4, of course, for which I'll send a
>   (trivial) patch, if necessary).
>
>Numbers that talk:
>
>Averaged number of microseconds it takes to dirty 1GB of
>16-times-larger-than-RAM ext3 file mmaped in 1GB chunks:
>
>without-patch:   average:    74188417.156250
>               deviation:    10538258.613280
>
>   with-patch:   average:    69449001.583333
>               deviation:    12621756.615280
>
>(Patch is for 2.6.10-rc2)
>
>  
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
