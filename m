Date: Tue, 13 May 2003 16:20:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030513232038.GB8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com> <3EC15C6D.1040403@kolumbus.fi> <199610000.1052864784@baldur.austin.ibm.com> <20030513224929.GX8978@holomorphy.com> <220550000.1052866808@baldur.austin.ibm.com> <20030513231139.GZ8978@holomorphy.com> <247390000.1052867776@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <247390000.1052867776@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Mika Penttil? <mika.penttila@kolumbus.fi>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday, May 13, 2003 16:11:39 -0700 William Lee Irwin III <wli@holomorphy.com> wrote:
>> Okay, what's stopping filemap_nopage() from fetching the page from
>> pagecache after one of the mm->mmap_sem's is dropped but before
>> truncate_inode_pages() removes the page? The fault path is only locked
>> out for one mm during one part of the operation. I can see taking
>> ->i_sem in do_no_page() fixing it, but not ->mmap_sem in vmtruncate()
>> (but of course that's _far_ too heavy-handed to merge at all).

On Tue, May 13, 2003 at 06:16:16PM -0500, Dave McCracken wrote:
> mmap_sem is held for read across the entire fault, so by the time
> vmtruncate_list() can call zap_page_range() the page has been instantiated
> in the page table and will get removed.

That's not quite the answer, inode->i_size is.

The mmap_sem works because then ->i_size can't be sampled by
filemap_nopage() before the pagetable wiping operation starts.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
