Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 277DF6B04D5
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:18:17 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so49779666itb.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:18:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 68si12368455iov.239.2016.11.20.21.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 21:18:16 -0800 (PST)
Date: Mon, 21 Nov 2016 00:18:11 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 09/18] mm/hmm/mirror: mirror process address space on
 device with HMM helpers
Message-ID: <20161121051810.GF7872@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-10-git-send-email-jglisse@redhat.com>
 <e6389bd7-de09-e765-58a5-b594d063e276@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e6389bd7-de09-e765-58a5-b594d063e276@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon, Nov 21, 2016 at 01:42:43PM +1100, Balbir Singh wrote:
> On 19/11/16 05:18, Jerome Glisse wrote:

[...]

> > +/*
> > + * hmm_mirror_register() - register a mirror against an mm
> > + *
> > + * @mirror: new mirror struct to register
> > + * @mm: mm to register against
> > + *
> > + * To start mirroring a process address space device driver must register an
> > + * HMM mirror struct.
> > + */
> > +int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> > +{
> > +	/* Sanity check */
> > +	if (!mm || !mirror || !mirror->ops)
> > +		return -EINVAL;
> > +
> > +	mirror->hmm = hmm_register(mm);
> > +	if (!mirror->hmm)
> > +		return -ENOMEM;
> > +
> > +	/* Register mmu_notifier if not already, use mmap_sem for locking */
> > +	if (!mirror->hmm->mmu_notifier.ops) {
> > +		struct hmm *hmm = mirror->hmm;
> > +		down_write(&mm->mmap_sem);
> > +		if (!hmm->mmu_notifier.ops) {
> > +			hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> > +			if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
> > +				hmm->mmu_notifier.ops = NULL;
> > +				up_write(&mm->mmap_sem);
> > +				return -ENOMEM;
> > +			}
> > +		}
> > +		up_write(&mm->mmap_sem);
> > +	}
> 
> Does everything get mirrored, every update to the PTE (clear dirty, clear
> accessed bit, etc) or does the driver decide?

Driver decide but only read/write/valid matter for device. Device driver must
report dirtyness on invalidation. Some device do not have access bit and thus
can't provide that information.

The idea here is really to snapshot the CPU page table and duplicate it as
a GPU page table. The only synchronization HMM provide is that each virtual
address point to same memory at that at no point in time the same virtual
address can point to different physical memory on the device and on the CPU.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
