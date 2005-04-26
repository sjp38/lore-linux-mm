From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17006.1794.857289.487941@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 13:16:50 +0400
Subject: Re: [PATCH]: VM 7/8 cluster pageout
In-Reply-To: <20050425211514.29e7c86b.akpm@osdl.org>
References: <16994.40699.267629.21475@gargle.gargle.HOWL>
	<20050425211514.29e7c86b.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Nikita Danilov <nikita@clusterfs.com> wrote:
 > >
 > > Implement pageout clustering at the VM level.
 > 
 > I dunno...
 > 
 > Once __mpage_writepages() has started I/O against the pivot page, I don't
 > see that we have any guarantees that some other CPU cannot come in,
 > truncated or reclaim all the inode's pages and then reclaimed the inode
 > altogether.  While __mpage_writepages() is still dinking with it all.

Ah, silly me. Will __iget(page->mapping->host) in pageout_cluster() be
enough? We risk truncate on matching iput(), but VM scanner calls iput()
on inodes with ->i_nlink == 0 already (from shrink_dcache()).

Also that patch fixes what I believe is a bug in mpage_writepages(): if
->writepage() returns WRITEPAGE_ACTIVATE page is still _locked_, but
__mpage_writepages() doesn't unlock it. Attached is documentation fix.

 > 
 > I had something like this happening in 2.5.10(ish), but ended up deciding
 > it was all too complex and writeout from the LRU is rare and the pages are
 > probably close-by on the LRU and the elevator sorting would catch most
 > cases so I tossed it all out.

Are you talking about ->vm_writeback()?

 > 
 > Plus some of your other patches make LRU-based writeout even less common.

Idea is that if we do pageout, it's better to send to the disk few
neighboring dirty pages too while we are here. Plus, this allows file
systems with delayed allocation to improve layout. I think XFS already
does similar clustering from ->writepage() by itself.

Nikita.
 Documentation/filesystems/Locking |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff -puN Documentation/filesystems/Locking~WRITEPAGE_ACTIVATE-doc-fix Documentation/filesystems/Locking
--- bk-linux/Documentation/filesystems/Locking~WRITEPAGE_ACTIVATE-doc-fix	2005-04-22 12:11:38.000000000 +0400
+++ bk-linux-nikita/Documentation/filesystems/Locking	2005-04-22 12:11:38.000000000 +0400
@@ -219,8 +219,12 @@ This may also be done to avoid internal 
 If the filesytem is called for sync then it must wait on any
 in-progress I/O and then start new I/O.
 
-The filesystem should unlock the page synchronously, before returning
-to the caller.
+The filesystem should unlock the page synchronously, before returning to the
+caller, unless ->writepage() returns special WRITEPAGE_ACTIVATE
+value. WRITEPAGE_ACTIVATE means that page cannot really be written out
+currently, and VM should stop calling ->writepage() on this page for some
+time. VM does this by moving page to the head of the active list, hence the
+name.
 
 Unless the filesystem is going to redirty_page_for_writepage(), unlock the page
 and return zero, writepage *must* run set_page_writeback() against the page,

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
