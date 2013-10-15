Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A680B6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:55:17 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so9495410pab.11
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:55:17 -0700 (PDT)
Date: Tue, 15 Oct 2013 20:55:10 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
Message-ID: <20131015185510.GH3479@redhat.com>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
 <20131015143407.GE3479@redhat.com>
 <20131015144827.C45DDE0090@blue.fi.intel.com>
 <alpine.LNX.2.00.1310151029040.12481@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1310151029040.12481@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 15, 2013 at 10:53:10AM -0700, Hugh Dickins wrote:
> I'm afraid Andrea's mail about concurrent madvises gives me far more
> to think about than I have time for: seems to get into problems he
> knows a lot about but I'm unfamiliar with.  If this patch looks good
> for now on its own, let's put it in; but no problem if you guys prefer
> to wait for a fuller solution of more problems, we can ride with this
> one internally for the moment.

I'm very happy with the patch and I think it's a correct fix for the
COW scenario which is deterministic so the looping makes a meaningful
difference for it. If we wouldn't loop, part of the copied page
wouldn't be zapped after the COW.

The patch also solves the false positive for the other non
deterministic scenario of two MADV_DONTNEED (one partial, one whole)
plus a concurrent page fault.

> And I should admit that the crash has occurred too rarely for us yet
> to be able to judge whether this patch actually fixes it in practice.

It is very rare indeed, and thanks to the BUG_ON it cannot lead to any
user or kernel memory corruption, but it's a nuisance we need to
fix. I only have the two stack traces in the two links I posted in the
previous email and I also don't have the traces of the other CPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
