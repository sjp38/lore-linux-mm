Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 16FFA6B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 08:32:52 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id t60so3324635wes.19
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 05:32:52 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id z42si12160584eel.302.2014.04.04.05.32.51
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 05:32:51 -0700 (PDT)
Date: Fri, 4 Apr 2014 15:32:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: get_user_pages(write,force) refuse to COW in shared
 areas
Message-ID: <20140404123242.GA22320@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1404040120110.6880@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404040120110.6880@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <m.chehab@samsung.com>, Omar Ramirez Luna <omar.ramirez@copitl.com>, Inki Dae <inki.dae@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org

On Fri, Apr 04, 2014 at 01:28:22AM -0700, Hugh Dickins wrote:
> get_user_pages(write=1, force=1) has always had odd behaviour on write-
> protected shared mappings: although it demands FMODE_WRITE-access to the
> underlying object (do_mmap_pgoff sets neither VM_SHARED nor VM_MAYWRITE
> without that), it ends up with do_wp_page substituting private anonymous
> Copied-On-Write pages for the shared file pages in the area.
> 
> That was long ago intentional, as a safety measure to prevent ptrace
> setting a breakpoint (or POKETEXT or POKEDATA) from inadvertently
> corrupting the underlying executable.  Yet exec and dynamic loaders
> open the file read-only, and use MAP_PRIVATE rather than MAP_SHARED.
> 
> The traditional odd behaviour still causes surprises and bugs in mm,
> and is probably not what any caller wants - even the comment on the flag
> says "You do not want this" (although it's undoubtedly necessary for
> overriding userspace protections in some contexts, and good when !write).
> 
> Let's stop doing that.  But it would be dangerous to remove the long-
> standing safety at this stage, so just make get_user_pages(write,force)
> fail with EFAULT when applied to a write-protected shared area.
> Infiniband may in future want to force write through to underlying
> object: we can add another FOLL_flag later to enable that if required.
> 
> Odd though the old behaviour was, there is no doubt that we may turn
> out to break userspace with this change, and have to revert it quickly.
> Issue a WARN_ON_ONCE to help debug the changed case (easily triggered
> by userspace, so only once to prevent spamming the logs); and delay a
> few associated cleanups until this change is proved.
> 
> get_user_pages callers who might see trouble from this change:
>   ptrace poking, or writing to /proc/<pid>/mem
>   drivers/infiniband/
>   drivers/media/v4l2-core/
>   drivers/gpu/drm/exynos/exynos_drm_gem.c
>   drivers/staging/tidspbridge/core/tiomap3430.c
> if they ever apply get_user_pages to write-protected shared mappings
> of an object which was opened for writing.
> 
> I went to apply the same change to mm/nommu.c, but retreated.  NOMMU
> has no place for COW, and its VM_flags conventions are not the same:
> I'd be more likely to screw up NOMMU than make an improvement there.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Hugh Dickins <hughd@google.com>

There's comment in do_wp_page() which is not true anymore with patch
applied. It should be fixed.

Otherwise, looks good to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
