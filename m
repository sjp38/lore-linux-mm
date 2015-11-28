Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 378E96B0038
	for <linux-mm@kvack.org>; Sat, 28 Nov 2015 09:50:06 -0500 (EST)
Received: by wmww144 with SMTP id w144so82466776wmw.1
        for <linux-mm@kvack.org>; Sat, 28 Nov 2015 06:50:05 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id w201si17221115wmd.84.2015.11.28.06.50.04
        for <linux-mm@kvack.org>;
        Sat, 28 Nov 2015 06:50:04 -0800 (PST)
Date: Sat, 28 Nov 2015 15:50:03 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 4.3+: Atheros ethernet fails after resume from s2ram, due to
 order 4 allocation
Message-ID: <20151128145003.GA4135@amd>
References: <20151126163413.GA3816@amd>
 <20151127082010.GA2500@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151127082010.GA2500@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

Hi!


> >         /*                                                                      
> >          * real ring DMA buffer                                                 
> >          * each ring/block may need up to 8 bytes for alignment, hence the      
> >          * additional bytes tacked onto the end.                                
> >          */
> >         ring_header->size = size =
> >                 sizeof(struct atl1c_tpd_desc) * tpd_ring->count * 2 +
> >                 sizeof(struct atl1c_rx_free_desc) * rx_desc_count +
> >                 sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
> >                 8 * 4;
> > 
> >         ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> >                                 &ring_header->dma);
> 
> Why is pci_alloc_consistent doing an unconditional GFP_ATOMIC
> allocation? atl1_setup_ring_resources already does GFP_KERNEL
> allocation in the same function so this should be sleepable
> context. I think we should either add pci_alloc_consistent_gfp if
> there are no explicit reasons to not do so or you can workaround

There's existing interface "dma_alloc_coherent" which can be used.

I did not yet try with __GFP_REPEAT, but GFP_KERNEL should already be
big improvement.

Let me send a patch..
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
