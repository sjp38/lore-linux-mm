Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C52C6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:09:31 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 20so952587qtq.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:09:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s55si1671812qth.127.2017.06.14.19.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 19:09:30 -0700 (PDT)
Date: Wed, 14 Jun 2017 22:09:25 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-CDM 5/5] mm/hmm: simplify kconfig and enable HMM and
 DEVICE_PUBLIC for ppc64
Message-ID: <20170615020925.GC4666@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
 <20170614201144.9306-6-jglisse@redhat.com>
 <9aeed880-c200-a070-a7a4-212ee38c15ed@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9aeed880-c200-a070-a7a4-212ee38c15ed@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Nellans <dnellans@nvidia.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, Jun 14, 2017 at 04:10:32PM -0700, John Hubbard wrote:
> On 06/14/2017 01:11 PM, Jerome Glisse wrote:
> > This just simplify kconfig and allow HMM and DEVICE_PUBLIC to be
> > selected for ppc64 once ZONE_DEVICE is allowed on ppc64 (different
> > patchset).
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > Cc: Balbir Singh <balbirs@au1.ibm.com>
> > Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> > Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> >   include/linux/hmm.h |  4 ++--
> >   mm/Kconfig          | 27 ++++++---------------------
> >   mm/hmm.c            |  4 ++--
> >   3 files changed, 10 insertions(+), 25 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index f6713b2..720d18c 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -327,7 +327,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
> >   #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> > -#if IS_ENABLED(CONFIG_HMM_DEVMEM)
> > +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) || IS_ENABLED(CONFIG_DEVICE_PUBLIC)
> >   struct hmm_devmem;
> >   struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
> > @@ -456,7 +456,7 @@ struct hmm_device {
> >    */
> >   struct hmm_device *hmm_device_new(void *drvdata);
> >   void hmm_device_put(struct hmm_device *hmm_device);
> > -#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
> > +#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> >   /* Below are for HMM internal use only! Not to be used by device driver! */
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index ad082b9..7de939a 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -265,7 +265,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
> >   config ARCH_HAS_HMM
> >   	bool
> >   	default y
> > -	depends on X86_64
> > +	depends on X86_64 || PPC64
> >   	depends on ZONE_DEVICE
> >   	depends on MMU && 64BIT
> >   	depends on MEMORY_HOTPLUG
> > @@ -277,7 +277,7 @@ config HMM
> >   config HMM_MIRROR
> >   	bool "HMM mirror CPU page table into a device page table"
> > -	depends on ARCH_HAS_HMM
> > +	depends on ARCH_HAS_HMM && X86_64
> >   	select MMU_NOTIFIER
> >   	select HMM
> >   	help
> 
> Hi Jerome,
> 
> There are still some problems with using this configuration. First and
> foremost, it is still possible (and likely, given the complete dissimilarity
> in naming, and difference in location on the screen) to choose HMM_MIRROR,
> and *not* to choose either DEVICE_PRIVATE or DEVICE_PUBLIC. And then we end
> up with a swath of important page fault handling code being ifdef'd out, and
> one ends up having to investigate why.
> 
> As for solutions, at least for the x86 (DEVICE_PRIVATE)case, we could do this:
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 7de939a29466..f64182d7b956 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -279,6 +279,7 @@ config HMM_MIRROR
>         bool "HMM mirror CPU page table into a device page table"
>         depends on ARCH_HAS_HMM && X86_64
>         select MMU_NOTIFIER
> +       select DEVICE_PRIVATE
>         select HMM
>         help
>           Select HMM_MIRROR if you want to mirror range of the CPU page table of a
> 
> ...and that is better than the other direction (having HMM_MIRROR depend on
> DEVICE_PRIVATE), because in the latter case, HMM_MIRROR will disappear (and
> it's several lines above) until you select DEVICE_PRIVATE. That is hard to
> work with for the user.
> 
> The user will tend to select HMM_MIRROR, but it is *not* obvious that he/she
> should also select DEVICE_PRIVATE. So Kconfig should do it for them.
> 
> In fact, I'm not even sure if the DEVICE_PRIVATE and DEVICE_PUBLIC actually
> need Kconfig protection, but if they don't, then life would be easier for
> whoever is configuring their kernel.
> 

We do need Kconfig for DEVICE_PRIVATE and DEVICE_PUBLIC. I can remove HMM_MIRROR
and have HMM mirror code ifdef on DEVICE_PRIVATE.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
