Date: Wed, 28 May 2003 19:10:29 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Question about locking in mmap.c
Message-ID: <20030529021029.GH15692@holomorphy.com>
References: <33460000.1054135672@baldur.austin.ibm.com> <133810000.1054159806@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <133810000.1054159806@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday, May 28, 2003 10:27:52 -0500 Dave McCracken wrote:
>> My question is what is page_table_lock supposed to be protecting against?
>> Am I wrong that mmap_sem is sufficient to protect against concurrent
>> changes to the vmas?

On Wed, May 28, 2003 at 05:10:06PM -0500, Dave McCracken wrote:
> I decided one way to find out was to remove the page_table_lock from mmap.
> I discovered one place it protects against is vmtruncate(), so it's
> definitely needed as it stands.  I got an oops in zap_page_range() called
> from vmtruncate().

do_mmap_pgoff() should at least be taking ->i_shared_sem around
__vma_link(). The analogue for do_munmap() is not quite the case;
it appears that the links aren't simultaneously removed under
->i_shared_sem, which would be the cause of it.

vma_merge() appears to be safe, but unmap_vma() does not. The lock
hierarchy is essentially inconsistent around this area, so trylocking
and failure handling would be required to convert it.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
