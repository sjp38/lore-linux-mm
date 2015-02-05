Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 57305828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 16:39:43 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so12474232pab.9
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 13:39:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id oi10si7692535pab.163.2015.02.05.13.39.42
        for <linux-mm@kvack.org>;
        Thu, 05 Feb 2015 13:39:42 -0800 (PST)
Date: Thu, 5 Feb 2015 16:39:39 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 04/20] mm: Allow page fault handlers to perform the
 COW
Message-ID: <20150205213939.GA3364@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-5-git-send-email-matthew.r.wilcox@intel.com>
 <CACTTzNbZ2K824aoPqXe4Q8WDRuc72ch5+B9J3GZQ2Z4Kwia56A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACTTzNbZ2K824aoPqXe4Q8WDRuc72ch5+B9J3GZQ2Z4Kwia56A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yigal Korman <yigal@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

On Thu, Feb 05, 2015 at 11:16:53AM +0200, Yigal Korman wrote:
> I have a question on a related issue (I think).
> I've noticed that for pfn-only mappings (VM_FAULT_NOPAGE)
> do_shared_fault only maps the pfn with r/o permissions.
> So if I use DAX to write the mmap()-ed pfn I get two faults - first
> handled by do_shared_fault and then again for making it r/w in
> do_wp_page.
> Is this simply a missing optimization like was done here with the
> cow_page? or am I missing something?

I have also noticed this behaviour.  I tracked down why it's happening:

DAX calls:
        error = vm_insert_mixed(vma, vaddr, pfn);
which calls:
        return insert_pfn(vma, addr, pfn, vma->vm_page_prot);

If you insert some debugging, you'll notice here that vm_page_prot does
not include PROT_WRITE.

That got cleared during mmap_region() where it does:

        if (vma_wants_writenotify(vma)) {
                pgprot_t pprot = vma->vm_page_prot;
...
                vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);


And why do we want writenotify (according to the VM)?  Because we have:

        /* The backer wishes to know when pages are first written to? */
        if (vma->vm_ops && vma->vm_ops->page_mkwrite)
                return 1;

We don't really want to be notified on a first write; we want the page to be
inserted write-enabled.  But in the case where we've covered a hole with a
read-only zero page, we need to be notified so we can allocate a page of
storage.

So, how to fix?  We could adjust vm_page_prot to include PROT_WRITE.
I think that should work, since we'll only insert zeroed pages for read
faults, and so the maybe_mkwrite() won't be called in do_set_pte().
I'm just not entirely sure where to set it.  Perhaps a MM person could
make a helpful suggestion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
