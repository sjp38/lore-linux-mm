Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0778C6B0070
	for <linux-mm@kvack.org>; Sun,  8 Feb 2015 06:48:17 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id b13so1673155wgh.0
        for <linux-mm@kvack.org>; Sun, 08 Feb 2015 03:48:16 -0800 (PST)
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com. [74.125.82.174])
        by mx.google.com with ESMTPS id uu10si15857684wjc.213.2015.02.08.03.48.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Feb 2015 03:48:15 -0800 (PST)
Received: by mail-we0-f174.google.com with SMTP id k11so12866323wes.5
        for <linux-mm@kvack.org>; Sun, 08 Feb 2015 03:48:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150205213939.GA3364@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-5-git-send-email-matthew.r.wilcox@intel.com>
	<CACTTzNbZ2K824aoPqXe4Q8WDRuc72ch5+B9J3GZQ2Z4Kwia56A@mail.gmail.com>
	<20150205213939.GA3364@wil.cx>
Date: Sun, 8 Feb 2015 13:48:14 +0200
Message-ID: <CACTTzNYiq94G6U2sXPB8AGVmFC2MOk8K+vc5rZOXzBGC=2nE3w@mail.gmail.com>
Subject: Re: [PATCH v12 04/20] mm: Allow page fault handlers to perform the COW
From: Yigal Korman <yigal@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Feb 5, 2015 at 11:39 PM, Matthew Wilcox <willy@linux.intel.com> wrote:
>
> On Thu, Feb 05, 2015 at 11:16:53AM +0200, Yigal Korman wrote:
> > I have a question on a related issue (I think).
> > I've noticed that for pfn-only mappings (VM_FAULT_NOPAGE)
> > do_shared_fault only maps the pfn with r/o permissions.
> > So if I use DAX to write the mmap()-ed pfn I get two faults - first
> > handled by do_shared_fault and then again for making it r/w in
> > do_wp_page.
> > Is this simply a missing optimization like was done here with the
> > cow_page? or am I missing something?
>
> I have also noticed this behaviour.  I tracked down why it's happening:
>
> DAX calls:
>         error = vm_insert_mixed(vma, vaddr, pfn);
> which calls:
>         return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
>
> If you insert some debugging, you'll notice here that vm_page_prot does
> not include PROT_WRITE.
>
> That got cleared during mmap_region() where it does:
>
>         if (vma_wants_writenotify(vma)) {
>                 pgprot_t pprot = vma->vm_page_prot;
> ...
>                 vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
>
>
> And why do we want writenotify (according to the VM)?  Because we have:
>
>         /* The backer wishes to know when pages are first written to? */
>         if (vma->vm_ops && vma->vm_ops->page_mkwrite)
>                 return 1;
>
> We don't really want to be notified on a first write; we want the page to be
> inserted write-enabled.  But in the case where we've covered a hole with a
> read-only zero page, we need to be notified so we can allocate a page of
> storage.
>
> So, how to fix?  We could adjust vm_page_prot to include PROT_WRITE.
> I think that should work, since we'll only insert zeroed pages for read
> faults, and so the maybe_mkwrite() won't be called in do_set_pte().
> I'm just not entirely sure where to set it.  Perhaps a MM person could
> make a helpful suggestion?

I was thinking that do_shared_fault should simply call maybe_mkwrite()
in case of VM_FAULT_NOPAGE.
I think it's what do_wp_page does afterwards anyway:

entry = maybe_mkwrite(pte_mkdirty(entry), vma);

But I'm sure it's not the whole picture...
Help from MM would indeed be appreciated.

Y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
