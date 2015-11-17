Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id BBCEB6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 19:33:27 -0500 (EST)
Received: by wmdw130 with SMTP id w130so134015462wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 16:33:27 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x84si22385054wmg.94.2015.11.16.16.33.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 16:33:26 -0800 (PST)
Received: by wmeo63 with SMTP id o63so690130wme.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 16:33:26 -0800 (PST)
Date: Tue, 17 Nov 2015 01:33:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix incorrect behavior when process virtual address
 space limit is exceeded
Message-ID: <20151117003324.GA1078@dhcp22.suse.cz>
References: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20151116205210.GB27526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116205210.GB27526@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, oleg@redhat.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Cyril Hrubis <chrubis@suse.cz>

On Mon 16-11-15 21:52:10, Michal Hocko wrote:
> [CCing Cyril]
> 
> On Mon 16-11-15 18:36:19, Piotr Kwapulinski wrote:
> > When a new virtual memory area is added to the process's virtual address
> > space and this vma causes the process's virtual address space limit
> > (RLIMIT_AS) to be exceeded then kernel behaves incorrectly. Incorrect
> > behavior is a result of a kernel bug. The kernel in most cases
> > unnecessarily scans the entire process's virtual address space trying to
> > find the overlapping vma with the virtual memory region being added.
> > The kernel incorrectly compares the MAP_FIXED flag with vm_flags variable
> > in mmap_region function. The vm_flags variable should not be compared
> > with MAP_FIXED flag. The MAP_FIXED flag has got the same numerical value
> > as VM_MAYREAD flag (0x10). As a result the following test
> > from mmap_region:
> > 
> > if (!(vm_flags & MAP_FIXED))
> > is in fact:
> > if (!(vm_flags & VM_MAYREAD))
> 
> It seems this has been broken since it was introduced e8420a8ece80
> ("mm/mmap: check for RLIMIT_AS before unmapping"). The patch has fixed
> the case where unmap happened before the we tested may_expand_vm and
> failed which was sufficient for the LTP test case but it apparently
> never tried to consider the overlapping ranges to eventually allow to
> create the mapping.
> 
> > The VM_MAYREAD flag is almost always set in vm_flags while MAP_FIXED
> > flag is not so common. The result of the above condition is somewhat
> > reverted.
> > This patch fixes this bug. It causes that the kernel tries to find the
> > overlapping vma only when the requested virtual memory region has got
> > the fixed starting virtual address (MAP_FIXED flag set).
> > For tile architecture Calling mmap_region with the MAP_FIXED flag only is
> > sufficient. However the MAP_ANONYMOUS and MAP_PRIVATE flags are passed for
> > the completeness of the solution.
> 
> I found the changelog rather hard to grasp. But the fix is correct. The
> user visible effect is that RLIMIT_AS might hit for a MAP_FIXED
> mapping even though it wouldn't enlarge the used address space.

And I was obviously blind and read the condition incorrectly. Sigh...
There is no real issue in fact. We do call count_vma_pages_range even
for !MAP_FIXED case but that is merely a pointless find_vma call but
nothing really earth shattering. So nothing for the stable tree and also
quite exaggerated to be called a bug.

I am sorry about the confusion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
