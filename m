Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5D1E8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:40:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 191-v6so12142305pgb.23
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:40:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p17-v6sor334205pge.11.2018.09.26.05.40.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 05:40:37 -0700 (PDT)
Date: Wed, 26 Sep 2018 15:40:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] mm: Recheck page table entry with page table lock held
Message-ID: <20180926124032.gxvo43sisumybysu@kshutemo-mobl1>
References: <20180926031858.9692-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926031858.9692-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2018 at 08:48:58AM +0530, Aneesh Kumar K.V wrote:
> We clear the pte temporarily during read/modify/write update of the pte. If we
> take a page fault while the pte is cleared, the application can get SIGBUS. One
> such case is with remap_pfn_range without a backing vm_ops->fault callback.
> do_fault will return SIGBUS in that case.
> 
> cpu 0		 				cpu1
> mprotect()
> ptep_modify_prot_start()/pte cleared.
> .
> .						page fault.
> .
> .
> prep_modify_prot_commit()
> 
> Fix this by taking page table lock and rechecking for pte_none.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
> V1:
> * update commit message.

You choosed to stick with VM_FAULT_NOPAGE, that's fine.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Should it be in stable?

-- 
 Kirill A. Shutemov
