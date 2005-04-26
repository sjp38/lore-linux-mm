Date: Tue, 26 Apr 2005 02:36:35 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 7/8 cluster pageout
Message-Id: <20050426023635.37ab2c38.akpm@osdl.org>
In-Reply-To: <17006.1794.857289.487941@gargle.gargle.HOWL>
References: <16994.40699.267629.21475@gargle.gargle.HOWL>
	<20050425211514.29e7c86b.akpm@osdl.org>
	<17006.1794.857289.487941@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Andrew Morton writes:
>  > Nikita Danilov <nikita@clusterfs.com> wrote:
>  > >
>  > > Implement pageout clustering at the VM level.
>  > 
>  > I dunno...
>  > 
>  > Once __mpage_writepages() has started I/O against the pivot page, I don't
>  > see that we have any guarantees that some other CPU cannot come in,
>  > truncated or reclaim all the inode's pages and then reclaimed the inode
>  > altogether.  While __mpage_writepages() is still dinking with it all.
> 
> Ah, silly me. Will __iget(page->mapping->host) in pageout_cluster() be
> enough? We risk truncate on matching iput(), but VM scanner calls iput()
> on inodes with ->i_nlink == 0 already (from shrink_dcache()).

I have vague memories about iput() in page reclaim causing deadlocks or
some other nastiness.  Maybe not.

ummm, generic_vm_writeback() used igrab(), to avoid races with the inode
disappearing.  Which would seem to be an odd thing to happen if we had a
locked page.  Maybe I used igrab because a bare atomic_inc(&inode->i_count)
seemed grubby, and there's no API function to do it.  But I do seem to
recall that igrab() was needed for other reasons.  It's all lost in the
mists of time.

> Also that patch fixes what I believe is a bug in mpage_writepages(): if
> ->writepage() returns WRITEPAGE_ACTIVATE page is still _locked_, but
> __mpage_writepages() doesn't unlock it. Attached is documentation fix.

OK.  WRITEPAGE_ACTIVATE is supposed to be a secret hack whcih filesystems
don't use.

>  > 
>  > I had something like this happening in 2.5.10(ish), but ended up deciding
>  > it was all too complex and writeout from the LRU is rare and the pages are
>  > probably close-by on the LRU and the elevator sorting would catch most
>  > cases so I tossed it all out.
> 
> Are you talking about ->vm_writeback()?

yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
