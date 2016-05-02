Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 873A46B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 15:02:06 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id e35so241177613qge.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 12:02:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 131si15649224qhb.37.2016.05.02.12.02.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 12:02:05 -0700 (PDT)
Date: Mon, 2 May 2016 21:02:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: GUP guarantees wrt to userspace mappings
Message-ID: <20160502190203.GD12310@redhat.com>
References: <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
 <20160502133919.GB4079@gmail.com>
 <20160502150013.GA24419@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502150013.GA24419@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 06:00:13PM +0300, Kirill A. Shutemov wrote:
> Switching to non-fast GUP would help :-P

If we had a race in khugepaged or ksmd against gup_fast O_DIRECT we'd
get flood of bugreports of data corruption with KVM run with
cache=direct.

Just wanted to reassure there's no race, explained how the
serialization to force a fallback to non-fast GUP works in previous
email.

This issue we're fixing for the COW is totally unrelated to KVM too,
because it uses MADV_DONTFORK, but the other races with O_DIRECT
against khugepaged/kksmd would still happen if we didn't already have
proper serialization against get_user_pages_fast.

> Alternatively, we have mmu_notifiers to track changes in userspace
> mappings.

This is always the absolute best solution, then no gup pins are used
at all and all VM functionality is activated regardless of the
secondary MMU, just most IOMMUs can't generate a synchronous page
fault, when they fault the I/O is undefined. It'd be like if when you
get a page fault in the CPU, when you return from the fault you go to
then next instruction and during the fault you've no way to even
emulate the faulting instruction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
