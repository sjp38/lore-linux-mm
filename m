Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBA506B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 06:07:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i130so7016784wmg.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 03:07:24 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id u126si2435920wmd.6.2016.10.07.03.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 03:07:23 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id 123so2170905wmb.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 03:07:23 -0700 (PDT)
Date: Fri, 7 Oct 2016 11:07:20 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
Message-ID: <20161007100720.GA14859@lucifer>
References: <20160911225425.10388-1-lstoakes@gmail.com>
 <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com>
 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 25, 2016 at 03:50:21PM -0700, Linus Torvalds wrote:
> I'd really like to re-open the "drop FOLL_FORCE entirely" discussion,
> because the thing really is disgusting.
>
> I realize that debuggers etc sometimes would want to punch through
> PROT_NONE protections, and I also realize that right now we only have
> a read/write flag, and we have that whole issue with "what if it's
> executable but not readable", which currently FOLL_FORCE makes a
> non-issue.

So I've experimented with this a little locally, removing FOLL_FORCE altogether
and tracking places where it is used (it seems to be a fair few places
actually.)

I've rather naively replaced the FOLL_FORCE check in check_vma_flags() with a
check against 'tsk && tsk->ptrace && tsk->parent == current', I'm not sure how
valid or sane this is, however, but a quick check against gdb proves that it is
able to do its thing in this configuration. Is this a viable path, or is this
way off the mark here?

The places I've found that have invoked gup functions which eventually result in
FOLL_FORCE being set are:

Calls __get_user_pages():
	mm/gup.c: populate_vma_page_range()
	mm/gup.c: get_dump_page()

calls get_user_pages_unlocked():
	drivers/media/pci/ivtv/ivtv-yuv.c: ivtv_yuv_prep_user_dma()
	drivers/media/pci/ivtv/ivtv-udma.c: ivtv_udma_setup()

calls get_user_pages_remote():
	mm/memory.c: __access_remote_vm() [ see below for callers ]
	fs/exec.c: get_arg_page()
	kernel/events/uprobes.c: uprobe_write_opcode()
	kernel/events/uprobes.c: is_trap_at_addr()
	security/tomoyo/domain.c: tomoyo_dump_page()

calls __access_remote_vm():
	mm/memory.c: access_remote_vm() [ see below for callers ]
	mm/memory.c: access_process_vm()

access_process_vm() is exclusively used for ptrace, omitting its callers here.

calls access_remote_vm():
	fs/proc/base.c: proc_pid_cmdline_read()
	fs/proc/base.c: memrw()
	fs/proc/base.c: environ_read()

calls get_user_pages():
	drivers/infiniband/core/umem.c: ib_umem_get()
	drivers/infiniband/hw/qib/qib_user_pages.c: __qib_get_user_pages()
	drivers/infiniband/hw/usnic/usnic_uiom.c: usnic_uiom_get_pages()
	drivers/media/v4l2-core/videobuf-dma-sg.c: videobuf_dma_init_user_locked()

calls get_vaddr_frames():
	drivers/media/v4l2-core/videobuf2-memops.c: vb2_create_framevec()
	drivers/gpu/drm/exynos/exynos_drm_g2d.c: g2d_userptr_get_dma_addr()

So it seems the general areas where it is used are tracing, uprobes and DMA
initialisation what what I can tell. I'm thinking some extra provision/careful
checking will be needed in each of these cases to see if an alternative is
possible.

I'm happy to explore this some more if that is useful in any way, though of
course I defer to your expertise as to how a world without FOLL_FORCE might
look!

Cheers, Lorenzo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
