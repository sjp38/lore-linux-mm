Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92B168E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 18:37:02 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n12-v6so8521952otk.22
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 15:37:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e199-v6sor2627817oih.42.2018.09.28.15.37.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 15:37:01 -0700 (PDT)
MIME-Version: 1.0
References: <1538173916-95849-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1538173916-95849-1-git-send-email-yang.shi@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Sep 2018 15:36:49 -0700
Message-ID: <CAPcyv4jdTWoJMSPuxso=8fu8nGOrmbBPYxkJvsuEDfJSYvsDWg@mail.gmail.com>
Subject: Re: [PATCH] mm: enforce THP for VM_NOHUGEPAGE dax mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 28, 2018 at 3:34 PM <yang.shi@linux.alibaba.com> wrote:
>
> commit baabda261424517110ea98c6651f632ebf2561e3 ("mm: always enable thp
> for dax mappings") says madvise hguepage policy makes less sense for
> dax, and force enabling thp for dax mappings in all cases, even though
> THP is set to "never".
>
> However, transparent_hugepage_enabled() may return false if
> VM_NOHUGEPAGE is set even though the mapping is dax.
>
> So, move is_vma_dax() check to the very beginning to enforce THP for dax
> mappings in all cases.
>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> I didn't find anyone mention the check should be before VM_NOHUGEPAGE in
> the review for Dan's original patch. And, that patch commit log states
> clearly that THP for dax mapping for all cases even though THP is never.
> So, I'm supposed it should behave in this way.

No, if someone explicitly does MADV_NOHUGEPAGE then the kernel should
honor that, even if the mapping is DAX.
