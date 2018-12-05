Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 083A16B73F9
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:04:19 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so9707833edq.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:04:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si915357edq.217.2018.12.05.03.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 03:04:17 -0800 (PST)
Date: Wed, 5 Dec 2018 12:04:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end calls
Message-ID: <20181205110416.GE22304@quack2.suse.cz>
References: <20181203201817.10759-1-jglisse@redhat.com>
 <20181203201817.10759-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181203201817.10759-3-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi Jerome!

On Mon 03-12-18 15:18:16, jglisse@redhat.com wrote:
> From: J�r�me Glisse <jglisse@redhat.com>
> 
> To avoid having to change many call sites everytime we want to add a
> parameter use a structure to group all parameters for the mmu_notifier
> invalidate_range_start/end cakks. No functional changes with this
> patch.

Two suggestions for the patch below:

> @@ -772,7 +775,8 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
>  		 * call mmu_notifier_invalidate_range_start() on our behalf
>  		 * before taking any lock.
>  		 */
> -		if (follow_pte_pmd(vma->vm_mm, address, &start, &end, &ptep, &pmdp, &ptl))
> +		if (follow_pte_pmd(vma->vm_mm, address, &range,
> +				   &ptep, &pmdp, &ptl))
>  			continue;

The change of follow_pte_pmd() arguments looks unexpected. Why should that
care about mmu notifier range? I see it may be convenient but it doesn't look
like a good API to me.

> @@ -1139,11 +1140,15 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  				downgrade_write(&mm->mmap_sem);
>  				break;
>  			}
> -			mmu_notifier_invalidate_range_start(mm, 0, -1);
> +
> +			range.start = 0;
> +			range.end = -1UL;
> +			range.mm = mm;
> +			mmu_notifier_invalidate_range_start(&range);

Also how about providing initializer for struct mmu_notifier_range? Or
something like DECLARE_MMU_NOTIFIER_RANGE? That will make sure that
unused arguments for particular notification places have defined values and
also if you add another mandatory argument (like you do in your third
patch), you just add another argument to the initializer and that way
the compiler makes sure you haven't missed any place. Finally the code will
remain more compact that way (less lines needed to initialize the struct).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
