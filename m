Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 380A36B0120
	for <linux-mm@kvack.org>; Wed, 27 May 2015 01:19:00 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so68324040pdb.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 22:18:59 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id eh1si24251201pac.45.2015.05.26.22.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 26 May 2015 22:18:59 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 27 May 2015 15:18:54 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BA1AF3578055
	for <linux-mm@kvack.org>; Wed, 27 May 2015 15:18:49 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4R5Ifrt23724090
	for <linux-mm@kvack.org>; Wed, 27 May 2015 15:18:49 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4R5IGZr016869
	for <linux-mm@kvack.org>; Wed, 27 May 2015 15:18:16 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/36] mmu_notifier: pass page pointer to mmu_notifier_invalidate_page()
In-Reply-To: <1432236705-4209-4-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-4-git-send-email-j.glisse@gmail.com>
Date: Wed, 27 May 2015 10:47:44 +0530
Message-ID: <87wpzulhtz.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>

j.glisse@gmail.com writes:

> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> Listener of mm event might not have easy way to get the struct page
> behind and address invalidated with mmu_notifier_invalidate_page()
> function as this happens after the cpu page table have been clear/
> updated. This happens for instance if the listener is storing a dma
> mapping inside its secondary page table. To avoid complex reverse
> dma mapping lookup just pass along a pointer to the page being
> invalidated.

.....

> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index ada3ed1..283ad26 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -172,6 +172,7 @@ struct mmu_notifier_ops {
>  	void (*invalidate_page)(struct mmu_notifier *mn,
>  				struct mm_struct *mm,
>  				unsigned long address,
> +				struct page *page,
>  				enum mmu_event event);
>=20=20

How do we handle this w.r.t invalidate_range ?=20

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
