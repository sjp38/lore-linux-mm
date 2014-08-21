Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 230CF6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 17:46:04 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so15040999pab.33
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 14:46:03 -0700 (PDT)
Received: from mail-pd0-x24a.google.com (mail-pd0-x24a.google.com [2607:f8b0:400e:c02::24a])
        by mx.google.com with ESMTPS id bs4si38064534pbc.34.2014.08.21.14.46.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 14:46:03 -0700 (PDT)
Received: by mail-pd0-f202.google.com with SMTP id w10so2684830pde.1
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 14:46:02 -0700 (PDT)
Date: Thu, 21 Aug 2014 17:46:01 -0400
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH] mm: softdirty: write protect PTEs created for read
 faults after VM_SOFTDIRTY cleared
Message-ID: <20140821214601.GD16042@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <20140820234543.GA7987@node.dhcp.inet.fi>
 <20140821193737.GC16042@google.com>
 <20140821205115.GH14072@moon>
 <20140821213942.GA15218@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140821213942.GA15218@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <damm@opensource.se>

On Fri, Aug 22, 2014 at 12:39:42AM +0300, Kirill A. Shutemov wrote:
> On Fri, Aug 22, 2014 at 12:51:15AM +0400, Cyrill Gorcunov wrote:
> 
> Looks good to me.
> 
> Would you mind to apply the same pgprot_modify() approach on the
> clear_refs_write(), test and post the patch?
> 
> Feel free to use my singed-off-by (or suggested-by if you prefer) once
> it's tested (see merge case below).

Sure thing :-)

> One thing: there could be (I haven't checked) complications on
> vma_merge(): since vm_flags are identical it assumes that it can reuse
> vma->vm_page_prot of expanded vma. But VM_SOFTDIRTY is excluded from
> vm_flags compatibility check. What should we do with vm_page_prot there?

Since the merged VMA will have VM_SOFTDIRTY set, it's OK that it's vm_page_prot
won't be setup for write notifications. For the purpose of process migration,
you'll just get some false positives, which is tolerable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
