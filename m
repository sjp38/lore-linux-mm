Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 014046B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 17:32:17 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so8275016qab.28
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:32:17 -0700 (PDT)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id cg4si8912289qcb.2.2014.07.01.14.32.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 14:32:15 -0700 (PDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so9118640qcv.12
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:32:14 -0700 (PDT)
Date: Tue, 1 Jul 2014 17:32:09 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140701213208.GC3322@gmail.com>
References: <019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
 <20140630154042.GD26537@8bytes.org>
 <20140630160604.GF1956@gmail.com>
 <20140630181623.GE26537@8bytes.org>
 <20140630183556.GB3280@gmail.com>
 <20140701091535.GF26537@8bytes.org>
 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
 <20140701110018.GH26537@8bytes.org>
 <20140701193343.GB3322@gmail.com>
 <20140701210620.GL26537@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140701210620.GL26537@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, "peterz@infraread.org" <peterz@infraread.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

On Tue, Jul 01, 2014 at 11:06:20PM +0200, Joerg Roedel wrote:
> On Tue, Jul 01, 2014 at 03:33:44PM -0400, Jerome Glisse wrote:
> > On Tue, Jul 01, 2014 at 01:00:18PM +0200, Joerg Roedel wrote:
> > > No, its not in this case. The file descriptor is used to connect a
> > > process address space with a device context. Thus without the mappings
> > > the file-descriptor is useless and the mappings should stay in-tact
> > > until the fd is closed.
> > > 
> > > It would be a very bad semantic for userspace if a fd that is passed on
> > > fails on the other side because the sending process died.
> > 
> > Consider use case where there is no file associated with the mmu_notifier
> > ie there is no device file descriptor that could hold and take care of
> > mmu_notifier destruction and cleanup. We need this call chain for this
> > case.
> 
> Example of such a use-case where no fd will be associated?
> 
> Anyway, even without an fd, there will always be something that sets the
> mm->device binding up (calling mmu_notifier_register) and tears it down
> in the end (calling mmu_notifier_unregister). And this will be the
> places where any resources left from the .release call-back can be
> cleaned up.
> 

That's the whole point we can not do what we want without the callback ie
the place where we do the cleanup is the mm callback we need. If you do not
like the call chain than we will just add ourself as another caller in the
exact same spot where the notifier chain is which Andrew disliked because
there are already enough submodule that are interested in being inform of
mm destruction.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
