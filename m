Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 007D36B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 01:59:42 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e192-v6so4040439lfg.11
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 22:59:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d79-v6sor3200182lfe.88.2018.04.23.22.59.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 22:59:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180423194917.GF13383@bombadil.infradead.org>
References: <20180423180625.GA16101@jordon-HP-15-Notebook-PC> <20180423194917.GF13383@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 24 Apr 2018 11:29:39 +0530
Message-ID: <CAFqt6zatfzk8PmBN110LD_x8goU+vO4U9TAGaamJ4UqwRm+g_g@mail.gmail.com>
Subject: Re: [PATCH v5] fs: dax: Adding new return type vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: jack@suse.cz, Al Viro <viro@zeniv.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, kirill.shutemov@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2018 at 1:19 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Mon, Apr 23, 2018 at 11:36:25PM +0530, Souptick Joarder wrote:
>> If the insertion of PTE failed because someone else
>> already added a different entry in the mean time, we
>> treat that as success as we assume the same entry was
>> actually inserted.
>
> No, Jan said to *make it a comment*.  In the source file.  That's why
> he formatted it with the /* */.  Not in the changelog.
Sorry, got confused.

I think this should be fine -

+/*
+If the insertion of PTE failed because someone else
+already added a different entry in the mean time, we
+treat that as success as we assume the same entry was
+actually inserted.
+*/

-int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
-                       pfn_t pfn)
+vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
+               unsigned long addr, pfn_t pfn)
 {
-       return __vm_insert_mixed(vma, addr, pfn, true);
+       int err;
+
+       err =  __vm_insert_mixed(vma, addr, pfn, true);
+       if (err == -ENOMEM)
+               return VM_FAULT_OOM;
+       if (err < 0 && err != -EBUSY)
+               return VM_FAULT_SIGBUS;
+       return VM_FAULT_NOPAGE;
 }
-EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
+EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
