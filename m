Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 082FA5F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:19:07 -0400 (EDT)
Subject: Re: [PATCH 01/23] mm: Introduce revoke_file_mappings.
References: <m1oct739xu.fsf@fess.ebiederm.org>
	<1243893048-17031-1-git-send-email-ebiederm@xmission.com>
	<20090601152553.b2de027a.akpm@linux-foundation.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 01 Jun 2009 17:12:19 -0700
In-Reply-To: <20090601152553.b2de027a.akpm@linux-foundation.org> (Andrew Morton's message of "Mon\, 1 Jun 2009 15\:25\:53 -0700")
Message-ID: <m1vdnfze70.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: viro@ZenIV.linux.org.uk, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, tj@kernel.org, hugh.dickins@tiscali.co.uk, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, hch@infradead.org, ebiederm@aristanetworks.com
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon,  1 Jun 2009 14:50:26 -0700
> "Eric W. Biederman" <ebiederm@xmission.com> wrote:
>
>> +static void revoke_vma(struct vm_area_struct *vma)
>
> This looks odd.
>
>> +{
>> +	struct file *file = vma->vm_file;
>> +	struct address_space *mapping = file->f_mapping;
>> +	unsigned long start_addr, end_addr, size;
>> +	struct mm_struct *mm;
>> +
>> +	start_addr = vma->vm_start;
>> +	end_addr = vma->vm_end;
>
> We take a copy of start_addr/end_addr (and this end_addr value is never used)
A foolish consistency.

>> +	/* Switch out the locks so I can maninuplate this under the mm sem.
>> +	 * Needed so I can call vm_ops->close.
>> +	 */
>> +	mm = vma->vm_mm;
>> +	atomic_inc(&mm->mm_users);
>> +	spin_unlock(&mapping->i_mmap_lock);
>> +
>> +	/* Block page faults and other code modifying the mm. */
>> +	down_write(&mm->mmap_sem);
>> +
>> +	/* Lookup a vma for my file address */
>> +	vma = find_vma(mm, start_addr);
>
> Then we look up a vma.  Is there reason to believe that this will
> differ from the incoming arg which we just overwrote?  Maybe the code
> is attempting to handle racing concurrent mmap/munmap activity?  If so,
> what are the implications of this?

Yes it is.  The file based index is only safe while we hold the i_mmap_lock.
The manipulation that needs to happen under the mmap_sem.

So I drop all of the locks and restart.  And use the time honored
kernel practice of relooking up the thing I am going to manipulate.
As long as it is for the same file I don't care.

> I _think_ that what the function is attempting to do is "unmap the vma
> which covers the address at vma->start_addr".  If so, why not just pass
> it that virtual address?

Actually it is  unmapping a vma for the file I am revoking.  I hand it
one and then it does an address space jig.

> Anyway, it's all a bit obscure and I do think that the semantics and
> behaviour should be carefully explained in a comment, no?
>
>> +	if (vma->vm_file != file)
>> +		goto out;
>
> This strengthens the theory that some sort of race-management is
> happening here.

Totally.  I dropped all of my locks so I am having to restart in
a different locking context.

>> +	start_addr = vma->vm_start;
>> +	end_addr   = vma->vm_end;
>> +	size	   = end_addr - start_addr;
>> +
>> +	/* Unlock the pages */
>> +	if (mm->locked_vm && (vma->vm_flags & VM_LOCKED)) {
>> +		mm->locked_vm -= vma_pages(vma);
>> +		vma->vm_flags &= ~VM_LOCKED;
>> +	}
>> +
>> +	/* Unmap the vma */
>> +	zap_page_range(vma, start_addr, size, NULL);
>> +
>> +	/* Unlink the vma from the file */
>> +	unlink_file_vma(vma);
>> +
>> +	/* Close the vma */
>> +	if (vma->vm_ops && vma->vm_ops->close)
>> +		vma->vm_ops->close(vma);
>> +	fput(vma->vm_file);
>> +	vma->vm_file = NULL;
>> +	if (vma->vm_flags & VM_EXECUTABLE)
>> +		removed_exe_file_vma(vma->vm_mm);
>> +
>> +	/* Repurpose the vma  */
>> +	vma->vm_private_data = NULL;
>> +	vma->vm_ops = &revoked_vm_ops;
>> +	vma->vm_flags &= ~(VM_NONLINEAR | VM_CAN_NONLINEAR);
>> +out:
>> +	up_write(&mm->mmap_sem);
>> +	spin_lock(&mapping->i_mmap_lock);
>> +}
>
> Also, I'm not a bit fan of the practice of overwriting the value of a
> formal argument, especially in a function which is this large and
> complex.  It makes the code harder to follow, because the one variable
> holds two conceptually different things within the span of the same
> function.  And it adds risk that someone will will later access a field
> of *vma and it will be the wrong vma.  Worse, the bug is only exposed
> under exeedingly rare conditions.
>
> So..  Use a new local, please.

We can never legitimately have more than one vma manipulated in this function.
As for the rest.  I guess I just assumed that the reader of the code would
have a basic understanding of the locking rules for those data structures.

Certainly the worst thing I suffer from is being close to the code,
and not realizing which pieces are not obvious to a naive observer.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
