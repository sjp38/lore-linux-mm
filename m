Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1912F6B004D
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 19:10:51 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so2260576eaj.31
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:10:51 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id a41si2035118eef.92.2014.02.27.16.10.50
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 16:10:50 -0800 (PST)
Date: Fri, 28 Feb 2014 02:10:39 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 0/2] mm: map few pages around fault address if they are
 in page cache
Message-ID: <20140228001039.GB8034@node.dhcp.inet.fi>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 27, 2014 at 01:28:22PM -0800, Linus Torvalds wrote:
> On Thu, Feb 27, 2014 at 11:53 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Here's new version of faultaround patchset. It took a while to tune it and
> > collect performance data.
> 
> Andrew, mind taking this into -mm with my acks? It's based on top of
> Kirill's cleanup patches that I think are also in your tree.
> 
> Kirill - no complaints from me. I do have two minor issues that you
> might satisfy, but I think the patch is fine as-is.
> 
> The issues/questions are:
> 
>  (a) could you test this on a couple of different architectures? Even
> if you just have access to intel machines, testing it across a couple
> of generations of microarchitectures would be good. The reason I say
> that is that from my profiles, it *looks* like the page fault costs
> are relatively higher on Ivybridge/Haswell than on some earlier
> uarchs.

These numbers were from Ivy Bridge.
I'll bring some numbers for Westmere and Haswell.

>  (b) I suspect we should try to strongly discourage filesystems from
> actually using map_pages unless they use the standard
> filemap_map_pages function as-is. Even with the fairly clean
> interface, and forcing people to use "do_set_pte()", I think the docs
> might want to try to more explicitly discourage people from using this
> to do their own hacks..

We would need ->map_pages() at least for shmem/tmpfs. It should be
benefitial there.

Also Matthew noticed that some drivers do ugly hacks like fault in whole
VMA on first page fault. IIUC, it's for performance reasons. See
psbfb_vm_fault() or ttm_bo_vm_fault().

I thought it could be reasonable to have ->map_pages() there and do VMA
population get_user_pages() on mmap() instead.

What do you think?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
