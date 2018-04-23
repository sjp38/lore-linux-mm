Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 647606B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 22:25:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a6so9301105pfn.3
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 19:25:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e12-v6si5695210plj.143.2018.04.22.19.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 22 Apr 2018 19:25:25 -0700 (PDT)
Date: Sun, 22 Apr 2018 19:25:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180423022505.GA2308@bombadil.infradead.org>
References: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
 <20180422230948.2mvimlf3zspry4ji@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180422230948.2mvimlf3zspry4ji@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, viro@zeniv.linux.org.uk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 23, 2018 at 01:09:48AM +0200, Jan Kara wrote:
> > -int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> > -			pfn_t pfn)
> > +vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
> > +		unsigned long addr, pfn_t pfn)
> >  {
> > -	return __vm_insert_mixed(vma, addr, pfn, true);
> > +	int err;
> > +
> > +	err =  __vm_insert_mixed(vma, addr, pfn, true);
> > +	if (err == -ENOMEM)
> > +		return VM_FAULT_OOM;
> > +	if (err < 0 && err != -EBUSY)
> > +		return VM_FAULT_SIGBUS;
> > +	return VM_FAULT_NOPAGE;
> >  }
> > -EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
> > +EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
> 
> So are we sure that all the callers of this function (and also of
> vmf_insert_mixed()) are OK with EBUSY? Because especially in the
> vmf_insert_mixed() case other page than the caller provided is in page
> tables and thus possibly the caller needs to do some error recovery (such
> as drop page refcount) in such case...

I went through all the users and didn't find any that did anything
with -EBUSY other than turn it into VM_FAULT_NOPAGE.  I agree that it's
possible that there might have been someone who wanted to do that, but
we tend to rely on mapcount (through rmap) rather than refcount (ie we
use refcount to mean the number of kernel references to the page and then
use mapcount for the number of times it's mapped into a process' address
space).  All the drivers I audited would allocagte the page first, store
it in their own data structures, then try to insert it into the virtual
address space.  So an EBUSY always meant "the same page was inserted".

If we did want to support "This happened already" in the future, we
could define a VM_FAULT flag for that.
