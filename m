Date: Wed, 4 Jun 2003 15:37:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Remove page_table_lock from vma manipulations
Message-ID: <20030604223759.GD15692@holomorphy.com>
References: <133290000.1054765825@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <133290000.1054765825@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 04, 2003 at 05:30:25PM -0500, Dave McCracken wrote:
> After more careful consideration, I don't see any reasons why
> page_table_lock is necessary for dealing with vmas.  I found one spot in
> swapoff, but it was easily changed to mmap_sem.  I've beat on this code and
> mjb has beat on this code with no problems.  Here's the patch to remove it.
> Feel free to poke holes in it.

shrink_list() calls try_to_unmap() under pte_chain_lock(page), and
hence try_to_unmap() cannot sleep. Furthermore try_to_unmap() calls
find_vma() under the sole protection of
spin_trylock(&mm->page_table_lock), which I don't see changed to a
read_trylock(&mm->mmap_sem) here.

Hence, this is racy.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
