Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C37F6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 15:11:44 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id x189so208922693ywe.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 12:11:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b203si13465692qkc.242.2016.05.02.12.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 12:11:43 -0700 (PDT)
Date: Mon, 2 May 2016 21:11:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: GUP guarantees wrt to userspace mappings
Message-ID: <20160502191141.GE12310@redhat.com>
References: <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
 <20160502133919.GB4079@gmail.com>
 <20160502150013.GA24419@node.shutemov.name>
 <20160502152249.GA5827@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502152249.GA5827@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 05:22:49PM +0200, Jerome Glisse wrote:
> I think this is still fine as it means that device will read only and thus
> you can migrate to different page (ie the guest is not expecting to read back
> anything writen by the device and device writting to the page would be illegal
> and a proper IOMMU would forbid it). So it is like direct-io when you write
> from anonymous memory to a file.

Agreed. write=1 is so that if there's an O_DIRECT write() and the app
is only reading, there will be no COW generated on shared anonymous
memory/MAP_PRIVATE-filebacked.

> Now that i think again about it, i don't think it exist. pmdp_collapse_flush()
> will flush the tlb and thus send an IPI but get_user_pages_fast() can't be
> preempted so the flush will have to wait for existing get_user_pages_fast() to
> complete. Or am i missunderstanding flush ? So khugepaged is safe from GUP_fast
> point of view like the comment, inside it, says.

This is exactly correct, there's no race window.

The IPI (or the quiescent point in case of the gup_fast RCU version)
are the things that flush away get_user_pages_fast with pmdp_collapse_flush().

> Well you can't not rely on special vma here. Qemu alloc anonymous memory and
> hand it over to guest, then a guest driver (ie runing in the guest not on the
> host) try to map that memory and need valid DMA address for it, this is when
> vfio (on the host kernel) starts pining memory of regular anonymous vma (on
> the host). That same memory might back some special vma with ->mmap callback
> but in the guest. Point is there is no driver on the host and no special vma.
> From host point of view this is anonymous memory, but from guest POV it is
> just memory.

It's quite important it stays regular tmpfs/anon as device memory is
managed by the device and we'd lose everything (KSM/swapping/NUMA
balancing/compaction/memory-hotunplug/CMA etc..).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
