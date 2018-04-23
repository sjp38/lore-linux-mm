Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92AA86B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:59:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k27-v6so18382937wre.23
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:59:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si2282810edj.92.2018.04.23.06.59.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 06:59:52 -0700 (PDT)
Date: Mon, 23 Apr 2018 15:59:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180423135947.dovwxnhzknobmyog@quack2.suse.cz>
References: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
 <20180422230948.2mvimlf3zspry4ji@quack2.suse.cz>
 <20180423022505.GA2308@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423022505.GA2308@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, viro@zeniv.linux.org.uk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 22-04-18 19:25:05, Matthew Wilcox wrote:
> On Mon, Apr 23, 2018 at 01:09:48AM +0200, Jan Kara wrote:
> > > -int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> > > -			pfn_t pfn)
> > > +vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
> > > +		unsigned long addr, pfn_t pfn)
> > >  {
> > > -	return __vm_insert_mixed(vma, addr, pfn, true);
> > > +	int err;
> > > +
> > > +	err =  __vm_insert_mixed(vma, addr, pfn, true);
> > > +	if (err == -ENOMEM)
> > > +		return VM_FAULT_OOM;
> > > +	if (err < 0 && err != -EBUSY)
> > > +		return VM_FAULT_SIGBUS;
> > > +	return VM_FAULT_NOPAGE;
> > >  }
> > > -EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
> > > +EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
> > 
> > So are we sure that all the callers of this function (and also of
> > vmf_insert_mixed()) are OK with EBUSY? Because especially in the
> > vmf_insert_mixed() case other page than the caller provided is in page
> > tables and thus possibly the caller needs to do some error recovery (such
> > as drop page refcount) in such case...
> 
> I went through all the users and didn't find any that did anything
> with -EBUSY other than turn it into VM_FAULT_NOPAGE.  I agree that it's
> possible that there might have been someone who wanted to do that, but
> we tend to rely on mapcount (through rmap) rather than refcount (ie we
> use refcount to mean the number of kernel references to the page and then
> use mapcount for the number of times it's mapped into a process' address
> space).  All the drivers I audited would allocagte the page first, store
> it in their own data structures, then try to insert it into the virtual
> address space.  So an EBUSY always meant "the same page was inserted".
> 
> If we did want to support "This happened already" in the future, we
> could define a VM_FAULT flag for that.

OK, fair enough and thanks for doing an audit! So possibly just add a
comment above vmf_insert_mixed() and vmf_insert_mixed_mkwrite() like:

/*
 * If the insertion of PTE failed because someone else already added a
 * different entry in the mean time, we treat that as success as we assume
 * the same entry was actually inserted.
 */

After that feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

to the patch.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
