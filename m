Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2706B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:16:29 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so8613075wes.28
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:16:28 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [2a01:238:4242:f000:64f:6c43:3523:e535])
        by mx.google.com with ESMTP id m8si24924126wjb.164.2014.06.30.11.16.26
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 11:16:27 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id A277412B325
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 20:16:25 +0200 (CEST)
Date: Mon, 30 Jun 2014 20:16:23 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140630181623.GE26537@8bytes.org>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
 <019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
 <20140630154042.GD26537@8bytes.org>
 <20140630160604.GF1956@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140630160604.GF1956@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, "peterz@infraread.org" <peterz@infraread.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

On Mon, Jun 30, 2014 at 12:06:05PM -0400, Jerome Glisse wrote:
> No this patch does not duplicate it. Current user of mmu_notifier
> rely on file close code path to call mmu_notifier_unregister. New
> code like AMD IOMMUv2 or HMM can not rely on that. Thus they need
> a way to call the mmu_notifer_unregister (which can not be done
> from inside the the release call back).

No, when the mm is destroyed the .release function is called from
exit_mmap() which calls mmu_notifier_release() right at the beginning.
In this case you don't need to call mmu_notifer_unregister yourself (you
can still call it, but it will be a nop).

> If you look at current code the release callback is use to kill
> secondary translation but not to free associated resources. All
> the associated resources are free later on after the release
> callback (well it depends if the file is close before the process
> is kill).

In exit_mmap the .release function is called when all mappings are still
present. Thats the perfect point in time to unbind all those resources
from your device so that it can not use it anymore when the mappings get
destroyed.

> So this patch aims to provide a callback to code outside of the
> mmu_notifier realms, a place where it is safe to cleanup the
> mmu_notifier and associated resources.

Still, this is a duplication of mmu_notifier release call-back, so still
NACK.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
