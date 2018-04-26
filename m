Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 028076B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 15:58:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j25so19461499pfh.18
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 12:58:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v12-v6si19782443plk.62.2018.04.26.12.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 12:58:32 -0700 (PDT)
Date: Thu, 26 Apr 2018 13:58:31 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v6] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180426195831.GA27127@linux.intel.com>
References: <20180424164751.GA18923@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424164751.GA18923@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: willy@infradead.org, jack@suse.cz, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2018 at 10:17:51PM +0530, Souptick Joarder wrote:
> Use new return type vm_fault_t for fault handler. For
> now, this is just documenting that the function returns
> a VM_FAULT value rather than an errno. Once all instances
> are converted, vm_fault_t will become a distinct type.
> 
> commit 1c8f422059ae ("mm: change return type to vm_fault_t")
> 
> There was an existing bug inside dax_load_hole()
> if vm_insert_mixed had failed to allocate a page table,
> we'd return VM_FAULT_NOPAGE instead of VM_FAULT_OOM.
> With new vmf_insert_mixed() this issue is addressed.
> 
> vm_insert_mixed_mkwrite has inefficiency when it returns
> an error value, driver has to convert it to vm_fault_t
> type. With new vmf_insert_mixed_mkwrite() this limitation
> will be addressed.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

Sure, this looks correct.  You can add:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I noticed that we have the following status translation now in 4 places in 2
files:

        if (err == -ENOMEM)
                return VM_FAULT_OOM;
        if (err < 0 && err != -EBUSY)
                return VM_FAULT_SIGBUS;
        return VM_FAULT_NOPAGE;


This happens in vmf_insert_mixed_mkwrite(), vmf_insert_page(),
vmf_insert_mixed() and vmf_insert_pfn().

I think it'd be a good idea to consolidate this translation into an inline
helper, in the spirit of dax_fault_return().  This will ensure that if/when we
start changing this status translation, we won't accidentally miss some of the
places which would make them get out of sync.  No need to fold this into this
patch - it should be a separate change.
