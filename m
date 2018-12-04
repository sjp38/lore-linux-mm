Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F09AD6B711E
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:50:24 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id h9so9939402pgm.1
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:50:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h7si17466080pls.326.2018.12.04.14.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 14:50:23 -0800 (PST)
Date: Tue, 4 Dec 2018 14:50:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] filemap: drop the mmap_sem for all blocking
 operations
Message-Id: <20181204145017.62d952c2a209975aa5888acf@linux-foundation.org>
In-Reply-To: <20181130195812.19536-4-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
	<20181130195812.19536-4-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri, 30 Nov 2018 14:58:11 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> Currently we only drop the mmap_sem if there is contention on the page
> lock.  The idea is that we issue readahead and then go to lock the page
> while it is under IO and we want to not hold the mmap_sem during the IO.
> 
> The problem with this is the assumption that the readahead does
> anything.  In the case that the box is under extreme memory or IO
> pressure we may end up not reading anything at all for readahead, which
> means we will end up reading in the page under the mmap_sem.

Please describe here why this is considered to be a problem. 
Application stalling, I assume?  Some description of in-the-field
observations would be appropriate.  ie, how serious is the problem
whcih is being addressed.

> Instead rework filemap fault path to drop the mmap sem at any point that
> we may do IO or block for an extended period of time.  This includes
> while issuing readahead, locking the page, or needing to call ->readpage
> because readahead did not occur.  Then once we have a fully uptodate
> page we can return with VM_FAULT_RETRY and come back again to find our
> nicely in-cache page that was gotten outside of the mmap_sem.
> 
> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2304,28 +2304,44 @@ EXPORT_SYMBOL(generic_file_read_iter);
>  
>  #ifdef CONFIG_MMU
>  #define MMAP_LOTSAMISS  (100)
> +static struct file *maybe_unlock_mmap_for_io(struct file *fpin,
> +					     struct vm_area_struct *vma,
> +					     int flags)
> +{
> +	if (fpin)
> +		return fpin;
> +	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) ==
> +	    FAULT_FLAG_ALLOW_RETRY) {
> +		fpin = get_file(vma->vm_file);
> +		up_read(&vma->vm_mm->mmap_sem);
> +	}
> +	return fpin;
> +}

A code comment would be nice.  What it does and, especially, why it does it.

> -	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
> -		put_page(page);
> -		return ret | VM_FAULT_RETRY;
> +	/*
> +	 * We are open-coding lock_page_or_retry here because we want to do the
> +	 * readpage if necessary while the mmap_sem is dropped.  If there
> +	 * happens to be a lock on the page but it wasn't being faulted in we'd
> +	 * come back around without ALLOW_RETRY set and then have to do the IO
> +	 * under the mmap_sem, which would be a bummer.

Expanding on "a bummer" would help here ;)

> +	 */
> +	if (!trylock_page(page)) {
> +		fpin = maybe_unlock_mmap_for_io(fpin, vmf->vma, vmf->flags);
> +		if (vmf->flags & FAULT_FLAG_RETRY_NOWAIT)
> +			goto out_retry;
> +		if (vmf->flags & FAULT_FLAG_KILLABLE) {
> +			if (__lock_page_killable(page)) {
> +				/*
> +				 * If we don't have the right flags for
> +				 * maybe_unlock_mmap_for_io to do it's thing we

"its"

> +				 * still need to drop the sem and return
> +				 * VM_FAULT_RETRY so the upper layer checks the
> +				 * signal and takes the appropriate action.
> +				 */
> +				if (!fpin)
> +					up_read(&vmf->vma->vm_mm->mmap_sem);
> +				goto out_retry;
> +			}
> +		} else
> +			__lock_page(page);
>  	}
>  
>  	/* Did it get truncated? */
