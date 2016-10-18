Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9F546B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 19:10:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n85so251461pfi.7
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 16:10:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y71si37719452pfb.71.2016.10.18.16.10.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 16:10:00 -0700 (PDT)
Date: Tue, 18 Oct 2016 16:09:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, thp: avoid unlikely branches for split_huge_pmd
Message-Id: <20161018160959.16187f78b58d76c6087e8491@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1610181600300.84525@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1610181600300.84525@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Oct 2016 16:04:06 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> While doing MADV_DONTNEED on a large area of thp memory, I noticed we 
> encountered many unlikely() branches in profiles for each backing 
> hugepage.  This is because zap_pmd_range() would call split_huge_pmd(), 
> which rechecked the conditions that were already validated, but as part of 
> an unlikely() branch.
> 
> Avoid the unlikely() branch when in a context where pmd is known to be 
> good for __split_huge_pmd() directly.

Before:

   text    data     bss     dec     hex filename
  38442      75      48   38565    96a5 mm/memory.o
  21755    2369   18464   42588    a65c mm/mempolicy.o
   4557    1816       0    6373    18e5 mm/mprotect.o

After:

  38362      75      48   38485    9655 mm/memory.o
  21714    2369   18464   42547    a633 mm/mempolicy.o
   4541    1816       0    6357    18d5 mm/mprotect.o


So there's a size improvment too.  gcc-4.4.4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
