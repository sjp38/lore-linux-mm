Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C73DF6B0025
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 12:12:33 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y202-v6so3561763lfd.0
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:12:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p27sor2960201ljb.48.2018.04.23.09.12.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 09:12:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180423135947.dovwxnhzknobmyog@quack2.suse.cz>
References: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
 <20180422230948.2mvimlf3zspry4ji@quack2.suse.cz> <20180423022505.GA2308@bombadil.infradead.org>
 <20180423135947.dovwxnhzknobmyog@quack2.suse.cz>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 23 Apr 2018 21:42:30 +0530
Message-ID: <CAFqt6zajJkFBs-OAbLyU5srCLnrtNJVt7NMfWdawcVYOvwETMg@mail.gmail.com>
Subject: Re: [PATCH v3] fs: dax: Adding new return type vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, mawilcox@microsoft.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, kirill.shutemov@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Apr 23, 2018 at 7:29 PM, Jan Kara <jack@suse.cz> wrote:
> On Sun 22-04-18 19:25:05, Matthew Wilcox wrote:
>> On Mon, Apr 23, 2018 at 01:09:48AM +0200, Jan Kara wrote:
>> > > -int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
>> > > -                 pfn_t pfn)
>> > > +vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
>> > > +         unsigned long addr, pfn_t pfn)
>> > >  {
>> > > - return __vm_insert_mixed(vma, addr, pfn, true);
>> > > + int err;
>> > > +
>> > > + err =  __vm_insert_mixed(vma, addr, pfn, true);
>> > > + if (err == -ENOMEM)
>> > > +         return VM_FAULT_OOM;
>> > > + if (err < 0 && err != -EBUSY)
>> > > +         return VM_FAULT_SIGBUS;
>> > > + return VM_FAULT_NOPAGE;
>> > >  }
>> > > -EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
>> > > +EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
>> >
>> > So are we sure that all the callers of this function (and also of
>> > vmf_insert_mixed()) are OK with EBUSY? Because especially in the
>> > vmf_insert_mixed() case other page than the caller provided is in page
>> > tables and thus possibly the caller needs to do some error recovery (such
>> > as drop page refcount) in such case...
>>
>> I went through all the users and didn't find any that did anything
>> with -EBUSY other than turn it into VM_FAULT_NOPAGE.  I agree that it's
>> possible that there might have been someone who wanted to do that, but
>> we tend to rely on mapcount (through rmap) rather than refcount (ie we
>> use refcount to mean the number of kernel references to the page and then
>> use mapcount for the number of times it's mapped into a process' address
>> space).  All the drivers I audited would allocagte the page first, store
>> it in their own data structures, then try to insert it into the virtual
>> address space.  So an EBUSY always meant "the same page was inserted".
>>
>> If we did want to support "This happened already" in the future, we
>> could define a VM_FAULT flag for that.
>
> OK, fair enough and thanks for doing an audit! So possibly just add a
> comment above vmf_insert_mixed() and vmf_insert_mixed_mkwrite() like:
>
> /*
>  * If the insertion of PTE failed because someone else already added a
>  * different entry in the mean time, we treat that as success as we assume
>  * the same entry was actually inserted.
>  */
>
> After that feel free to add:
>
> Reviewed-by: Jan Kara <jack@suse.cz>
>
> to the patch.
>

Thanks , will add this in change log and send v4.
