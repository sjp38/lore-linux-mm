Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 34F4C6B0037
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 05:41:46 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so7353838wiv.16
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 02:41:45 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [2a01:238:4242:f000:64f:6c43:3523:e535])
        by mx.google.com with ESMTP id by15si3666425wib.73.2014.07.01.02.41.44
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 02:41:44 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 92D3A12B325
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 11:41:43 +0200 (CEST)
Date: Tue, 1 Jul 2014 11:41:41 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140701094141.GG26537@8bytes.org>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
 <019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
 <20140630154042.GD26537@8bytes.org>
 <20140630160604.GF1956@gmail.com>
 <20140630181623.GE26537@8bytes.org>
 <20140630183556.GB3280@gmail.com>
 <3725846D7614874B8367361CC6008D741645DFA0@storexdag01.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3725846D7614874B8367361CC6008D741645DFA0@storexdag01.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Lewycky, Andrew" <Andrew.Lewycky@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, "peterz@infraread.org" <peterz@infraread.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

Hi Andrew,

On Mon, Jun 30, 2014 at 06:57:48PM +0000, Lewycky, Andrew wrote:
> As an aside we found another small issue: amd_iommu_bind_pasid calls
> get_task_mm. This bumps the mm_struct use count and it will never be
> released. This would prevent the buggy code path described above from
> ever running in the first place.

You are right, the current code is a bit problematic, but to fix this no
new notifier chain in mm-code is needed.

In fact, using get_task_mm() is a good way to keep a reference to the mm
as a user (an external device is in fact another user) and defer the
destruction of the mappings to the file-close path (where you can call
mmput to destroy it). So this is another way to solve the problem
without any new notifier.


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
