Date: Thu, 12 Jun 2003 13:49:46 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-Id: <20030612134946.450e0f77.akpm@digeo.com>
In-Reply-To: <133430000.1055448961@baldur.austin.ibm.com>
References: <133430000.1055448961@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> Paul McKenney and I sat down today and hashed out just what the races are
> for both  vmtruncate and the distributed filesystems.  We took Andrea's
> idea of using seqlocks and came up with a simple solution that definitely
> fixes the race in vmtruncate, as well as most likely the invalidate race in
> distributed filesystems.  Paul is going to discuss it with the DFS folks to
> verify that it's a complete fix for them, but neither of us can see a hole.
> 

> +  seqlock_init(&(mtd_rawdevice->as.truncate_lock));

Why cannot this just be an atomic_t?

> +	/* Protect against page fault */
> +	write_seqlock(&mapping->truncate_lock);
> +	write_sequnlock(&mapping->truncate_lock);

See, this just does foo++.

> +	/*
> +	 * If someone invalidated the page, serialize against the inode,
> +	 * then go try again.
> +	 */

This comment is inaccurate.  "If this vma is file-backed and someone has
truncated that file, this page may have been invalidated".

> +	if (unlikely(read_seqretry(&mapping->truncate_lock, sequence))) {
> +		spin_unlock(&mm->page_table_lock);
> +		down(&inode->i_sem);
> +		up(&inode->i_sem);
> +		goto retry;
> +	}
> +

mm/memory.c shouldn't know about inodes (ok, vmtruncate() should be in
filemap.c).

How about you do this:

do_no_page()
{
	int sequence = 0;
	...

retry:
	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &sequence);
	....
	if (vma->vm_ops->revalidate && vma->vm_opa->revalidate(vma, sequence))
		goto retry;
}


filemap_nopage(..., int *sequence)
{
	...
	*sequence = atomic_read(&mapping->truncate_sequence);
	...
}

int filemap_revalidate(vma, sequence)
{
	struct address_space *mapping;

	mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
	return sequence - atomic_read(&mapping->truncate_sequence);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
