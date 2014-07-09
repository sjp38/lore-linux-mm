Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A5FA96B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 12:21:28 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so779122wiv.15
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:21:28 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [2a01:238:4242:f000:64f:6c43:3523:e535])
        by mx.google.com with ESMTP id t20si8672442wiv.102.2014.07.09.09.21.27
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 09:21:27 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 0A1E312B0EC
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 18:21:27 +0200 (CEST)
Date: Wed, 9 Jul 2014 18:21:24 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 1/8] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140709162123.GN1958@8bytes.org>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-2-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404856801-11702-2-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 08, 2014 at 05:59:58PM -0400, j.glisse@gmail.com wrote:
> +int mmput_register_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_register(&mmput_notifier, nb);
> +}
> +EXPORT_SYMBOL_GPL(mmput_register_notifier);
> +
> +int mmput_unregister_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_unregister(&mmput_notifier, nb);
> +}
> +EXPORT_SYMBOL_GPL(mmput_unregister_notifier);

I am still not convinced that this is required. For core code that needs
to hook into mmput (like aio or uprobes) it really improves code
readability if their teardown functions are called explicitly in mmput.

And drivers that deal with the mm can use the already existing
mmu_notifers. That works at least for the AMD-IOMMUv2 and KFD drivers.

Maybe HMM is different here, but then you should explain why and how it
is different and why you can't add an explicit teardown function for
HMM.


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
