Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD6AE6B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 15:06:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y62so70476pfd.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:06:07 -0800 (PST)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id x4si11858600pgv.629.2017.12.12.12.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 12:06:04 -0800 (PST)
Date: Tue, 12 Dec 2017 14:05:42 -0600
From: Dimitri Sivanich <sivanich@hpe.com>
Subject: Re: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
Message-ID: <20171212200542.GJ5848@hpe.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 11, 2017 at 02:11:55PM -0800, David Rientjes wrote:
> --- a/drivers/misc/sgi-gru/grutlbpurge.c
> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> @@ -298,6 +298,7 @@ struct gru_mm_struct *gru_register_mmu_notifier(void)
>  			return ERR_PTR(-ENOMEM);
>  		STAT(gms_alloc);
>  		spin_lock_init(&gms->ms_asid_lock);
> +		gms->ms_notifier.flags = 0;
>  		gms->ms_notifier.ops = &gru_mmuops;
>  		atomic_set(&gms->ms_refcnt, 1);
>  		init_waitqueue_head(&gms->ms_wait_queue);
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c

There is a kzalloc() just above this:
	gms = kzalloc(sizeof(*gms), GFP_KERNEL);

Is that not sufficient to clear the 'flags' field?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
