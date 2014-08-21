Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 889CC6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 18:50:35 -0400 (EDT)
Received: by mail-yh0-f45.google.com with SMTP id 29so8563887yhl.18
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 15:50:35 -0700 (PDT)
Received: from mail-yk0-x24a.google.com (mail-yk0-x24a.google.com [2607:f8b0:4002:c07::24a])
        by mx.google.com with ESMTPS id v64si30319037yhk.17.2014.08.21.15.50.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 15:50:34 -0700 (PDT)
Received: by mail-yk0-f202.google.com with SMTP id q9so1189661ykb.5
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 15:50:34 -0700 (PDT)
Date: Thu, 21 Aug 2014 18:50:33 -0400
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH] mm: softdirty: write protect PTEs created for read
 faults after VM_SOFTDIRTY cleared
Message-ID: <20140821225033.GE16042@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <20140820234543.GA7987@node.dhcp.inet.fi>
 <20140821193737.GC16042@google.com>
 <20140821205115.GH14072@moon>
 <20140821213942.GA15218@node.dhcp.inet.fi>
 <20140821214601.GD16042@google.com>
 <20140821215147.GA15482@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140821215147.GA15482@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <damm@opensource.se>

On Fri, Aug 22, 2014 at 12:51:47AM +0300, Kirill A. Shutemov wrote:
> > > One thing: there could be (I haven't checked) complications on
> > > vma_merge(): since vm_flags are identical it assumes that it can reuse
> > > vma->vm_page_prot of expanded vma. But VM_SOFTDIRTY is excluded from
> > > vm_flags compatibility check. What should we do with vm_page_prot there?
> > 
> > Since the merged VMA will have VM_SOFTDIRTY set, it's OK that it's vm_page_prot
> > won't be setup for write notifications. For the purpose of process migration,
> > you'll just get some false positives, which is tolerable.
> 
> Right. But should we disable writenotify back to avoid exessive wp-faults
> if it was enabled due to soft-dirty (the case when expanded vma is
> soft-dirty)?

Ah, I understand now. I've got a patch in the works that disables the write
faults when a VMA is merged. I'll send a series with all of the changes
tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
