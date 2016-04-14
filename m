Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 357876B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 17:07:39 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id e185so162893205vkb.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 14:07:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s201si15607250qke.3.2016.04.14.14.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 14:07:38 -0700 (PDT)
Date: Thu, 14 Apr 2016 17:07:34 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC 2/8] userfaultfd: support write protection for userfault
 vma range
Message-ID: <20160414210734.GH9976@redhat.com>
References: <cover.1447964595.git.shli@fb.com>
 <60c73a4374d16d15e3975c590b48a2d2d384c23e.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60c73a4374d16d15e3975c590b48a2d2d384c23e.1447964595.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

Do you have a more recent version of this patchset?

On Thu, Nov 19, 2015 at 02:33:47PM -0800, Shaohua Li wrote:
> +	down_read(&dst_mm->mmap_sem);

[..]

> +	if (enable_wp)
> +		newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
> +	else
> +		newprot = vm_get_page_prot(dst_vma->vm_flags);

The vm_flags for anon vmas are always wrprotected, just we mark them
writable during fault or during cow if vm_flags VM_WRITE is set, when
we know it's not shared. So this requires checking the mapcount
somewhere while fork cannot run, or the above won't properly
unprotect?

> +
> +	change_protection(dst_vma, start, start + len, newprot,
> +				!enable_wp, 0);

change_protection(prot_numa=0) assumes mmap_sem hold for writing
breaking here:

	 /* !prot_numa is protected by mmap_sem held for write */
	if (!prot_numa)
		return pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);

	pmdl = pmd_lock(vma->vm_mm, pmd);
	if (unlikely(pmd_trans_huge(*pmd) || pmd_none(*pmd))) {
		spin_unlock(pmdl);
		return NULL;
	}

	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
	spin_unlock(pmdl);

With userfaultfd the pmd can be trans unstable as we only hold the
mmap_sem for reading.

In short calling change_protection() with prot_numa==0 with only the
mmap_sem for reading looks wrong...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
