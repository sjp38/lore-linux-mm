Date: Thu, 21 Oct 2004 17:15:58 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-Id: <20041021171558.3214cea4.akpm@osdl.org>
In-Reply-To: <20041021164245.4abec5d2.akpm@osdl.org>
References: <1098393346.7157.112.camel@localhost>
	<20041021144531.22dd0d54.akpm@osdl.org>
	<20041021223613.GA8756@dualathlon.random>
	<20041021160233.68a84971.akpm@osdl.org>
	<20041021232059.GE8756@dualathlon.random>
	<20041021164245.4abec5d2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@novell.com, shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> I don't get it.  invalidate has the pageframe.  All it need to do is to
> lock the page, examine mapcount and if it's non-zero, do the shootdown. 

unmap_mapping_range() will do that - can call it one page at a time, or
batch up runs of pages.  It's not fast, but presumably not frequent either.

The bigger problem is shooting down the buffer_heads.  It's certainly the
case that mpage_readpage() will call block_read_full_page() which will then
bring the page uptodate without performing any I/O.

And invalidating the buffer_heads in invalidate_inode_pages2() is tricky -
we need to enter the filesystem and I'm not sure that either
->invalidatepage() or ->releasepage() are quite suitable.  For a start,
they're best-effort and may fail.  If we just go and mark the buffers not
uptodate we'll probably give ext3 a heart attack, so careful work would be
needed there.

Let's go back to why we needed all of this.  Was it just for the NFS
something-changed-on-the-server code?  If so, would it be sufficient to add
a new invalidate_inode_pages3() just for NFS, which clears the uptodate
bit?  Or something along those lines?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
