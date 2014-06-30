Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id A5EF76B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:36:03 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so7362450qcx.8
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:36:03 -0700 (PDT)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id s4si26185870qay.65.2014.06.30.11.36.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 11:36:03 -0700 (PDT)
Received: by mail-qc0-f178.google.com with SMTP id c9so7293587qcz.23
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:36:03 -0700 (PDT)
Date: Mon, 30 Jun 2014 14:35:57 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140630183556.GB3280@gmail.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
 <019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
 <20140630154042.GD26537@8bytes.org>
 <20140630160604.GF1956@gmail.com>
 <20140630181623.GE26537@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140630181623.GE26537@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, "peterz@infraread.org" <peterz@infraread.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

On Mon, Jun 30, 2014 at 08:16:23PM +0200, Joerg Roedel wrote:
> On Mon, Jun 30, 2014 at 12:06:05PM -0400, Jerome Glisse wrote:
> > No this patch does not duplicate it. Current user of mmu_notifier
> > rely on file close code path to call mmu_notifier_unregister. New
> > code like AMD IOMMUv2 or HMM can not rely on that. Thus they need
> > a way to call the mmu_notifer_unregister (which can not be done
> > from inside the the release call back).
> 
> No, when the mm is destroyed the .release function is called from
> exit_mmap() which calls mmu_notifier_release() right at the beginning.
> In this case you don't need to call mmu_notifer_unregister yourself (you
> can still call it, but it will be a nop).
> 

We do intend to tear down all secondary mapping inside the relase
callback but still we can not cleanup all the resources associated
with it.

> > If you look at current code the release callback is use to kill
> > secondary translation but not to free associated resources. All
> > the associated resources are free later on after the release
> > callback (well it depends if the file is close before the process
> > is kill).
> 
> In exit_mmap the .release function is called when all mappings are still
> present. Thats the perfect point in time to unbind all those resources
> from your device so that it can not use it anymore when the mappings get
> destroyed.
> 
> > So this patch aims to provide a callback to code outside of the
> > mmu_notifier realms, a place where it is safe to cleanup the
> > mmu_notifier and associated resources.
> 
> Still, this is a duplication of mmu_notifier release call-back, so still
> NACK.
> 

It is not, mmu_notifier_register take increase mm_count and only
mmu_notifier_unregister decrease the mm_count which is different
from the mm_users count (the latter being the one that trigger an
mmu notifier release).

As said from the release call back you can not call mmu_notifier_unregister
and thus you can not fully cleanup things. Only way to achieve so is
to do it ouside mmu_notifier callback. As pointed out current user do
not have this issue because they rely on file close callback to perform
the cleanup operation. New user will not necessarily have such things
to rely on. Hence factorizing various mm_struct destruction callback
with an callback chain.

If you know any other way to call mmu_notifier_unregister before the
end of mmput function than i am all ear. I am not adding this call
back just for the fun of it i spend serious time trying to find a
way to do thing without it. I might have miss a way so if i did please
show it to me.

Cheers,
Jerome Glisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
