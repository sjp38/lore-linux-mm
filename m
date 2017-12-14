Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7863E6B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:19:24 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id k186so7138747ith.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 01:19:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t194sor2369073ita.60.2017.12.14.01.19.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 01:19:23 -0800 (PST)
Date: Thu, 14 Dec 2017 01:19:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
In-Reply-To: <d6487124-b613-6614-f355-14b7388a8ae3@amd.com>
Message-ID: <alpine.DEB.2.10.1712140118160.260574@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com> <20171212200542.GJ5848@hpe.com> <alpine.DEB.2.10.1712121326280.134224@chino.kir.corp.google.com> <d6487124-b613-6614-f355-14b7388a8ae3@amd.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1113868975-822497440-1513243162=:260574"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
Cc: Dimitri Sivanich <sivanich@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1113868975-822497440-1513243162=:260574
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 13 Dec 2017, Christian KA?nig wrote:

> > > > --- a/drivers/misc/sgi-gru/grutlbpurge.c
> > > > +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> > > > @@ -298,6 +298,7 @@ struct gru_mm_struct
> > > > *gru_register_mmu_notifier(void)
> > > >   			return ERR_PTR(-ENOMEM);
> > > >   		STAT(gms_alloc);
> > > >   		spin_lock_init(&gms->ms_asid_lock);
> > > > +		gms->ms_notifier.flags = 0;
> > > >   		gms->ms_notifier.ops = &gru_mmuops;
> > > >   		atomic_set(&gms->ms_refcnt, 1);
> > > >   		init_waitqueue_head(&gms->ms_wait_queue);
> > > > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > > There is a kzalloc() just above this:
> > > 	gms = kzalloc(sizeof(*gms), GFP_KERNEL);
> > > 
> > > Is that not sufficient to clear the 'flags' field?
> > > 
> > Absolutely, but whether it is better to explicitly document that the mmu
> > notifier has cleared flags, i.e. there are no blockable callbacks, is
> > another story.  I can change it if preferred.
> 
> Actually I would invert the new flag, in other words specify that an MMU
> notifier will never sleep.
> 

Very good idea, I'll do that.  I'll also move the flags member to ops as 
Paolo suggested.

Thanks both!
--1113868975-822497440-1513243162=:260574--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
