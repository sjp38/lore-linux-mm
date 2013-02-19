Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id AB2136B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 17:55:53 -0500 (EST)
Date: Tue, 19 Feb 2013 22:55:47 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/2] arm: Set the page table freeing ceiling to TASK_SIZE
Message-ID: <20130219225547.GB6889@MacBook-Pro.local>
References: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
 <1361204311-14127-3-git-send-email-catalin.marinas@arm.com>
 <alpine.LNX.2.00.1302191008290.2139@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302191008290.2139@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Hugh,

On Tue, Feb 19, 2013 at 06:20:50PM +0000, Hugh Dickins wrote:
> On Mon, 18 Feb 2013, Catalin Marinas wrote:
> 
> > ARM processors with LPAE enabled use 3 levels of page tables, with an
> > entry in the top level (pgd) covering 1GB of virtual space. Because of
> > the branch relocation limitations on ARM, the loadable modules are
> > mapped 16MB below PAGE_OFFSET, making the corresponding 1GB pgd shared
> > between kernel modules and user space.
> > 
> > If free_pgtables() is called with the default ceiling 0,
> > free_pgd_range() (and subsequently called functions) also frees the page
> > table shared between user space and kernel modules (which is normally
> > handled by the ARM-specific pgd_free() function). This patch changes
> > defines the ARM USER_PGTABLES_CEILING to TASK_SIZE.
> 
> I don't have an ARM to test on, so I won't ack or nack this,
> but I am a little worried or puzzled.
> 
> I thought CONFIG_ARM_LPAE came in v3.3: so I would expect these
> patches to need "Cc: stable@vger.kernel.org" for porting back there.

Yes, I'll add this.

> But then, did v3.3..v3.8 have the appropriate arch/arm code to handle
> the freeing of the user+kernel pgd?  I'm not asserting that it could
> not, but when doing the similar arch/x86 thing, I had to make changes
> down there, so it's not necessarily something that works automatically.

Unfortunately it doesn't have any code to handle this, though it is
relatively hard to trigger the problem. The pgd entry shared between
user and kernel on ARM is used for loadable modules and kmap. It
triggers for example if we get an interrupt handled by a loadable module
during a task exit. The rest of the kernel pgd is fine as PAGE_OFFSET is
an entirely new pgd entry.

I had a workaround for arch/arm only but after discussions with rmk, we
decided that ceiling is the mode elegant solution.

> And does the ARM !LPAE case work correctly (not leaking page tables
> at any level) with this change from 0 to TASK_SIZE?  Again, I'm not
> asserting that it does not, but your commit description doesn't give
> enough confidence that you've tried that.

In the ARM !LPAE case, we only have two levels of page tables and the
pmd pages are allocated by pgd_alloc() and freed in pgd_free(). The next
pte level is not shared between user and kernel (actually for module
space and kmap below PAGE_OFFSET we don't even allocate new ptes, just
point the pmd to the existing kernel pte).

I'll add more information to the commit message.

> Perhaps you have some other patches to arch/arm, that of course I
> wouldn't have noticed, which make this all work together; and it's
> accepted that CONFIG_ARM_LPAE is broken on v3.3..v3.8, and too
> much risk to backport it all for -stable.

I think it makes sense to backport to v3.3 as we don't have any other
ARM patches addressing this. The shared pgd entry with LPAE is handled
explicitly in pgd_free() (I've done this from the beginning as a
precaution, though the condition never triggered because of the 0
ceiling).

> Maybe all I'm asking for is a more reassuring commit description.

I agree. I'm also waiting for rmk's ack.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
