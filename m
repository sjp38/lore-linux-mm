Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70D01800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 16:56:44 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id e4so7131340ote.7
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:56:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p44si6298861ota.261.2018.01.22.13.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 13:56:43 -0800 (PST)
Date: Mon, 22 Jan 2018 16:56:40 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/hmm: fix uninitialized use of 'entry' in
 hmm_vma_walk_pmd()
Message-ID: <20180122215640.GB5522@redhat.com>
References: <20180122185759.26286-1-jglisse@redhat.com>
 <20180122125836.1aebb001d4c2c4e93029db35@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180122125836.1aebb001d4c2c4e93029db35@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>

On Mon, Jan 22, 2018 at 12:58:36PM -0800, Andrew Morton wrote:
> On Mon, 22 Jan 2018 13:57:59 -0500 jglisse@redhat.com wrote:
> 
> > From: Ralph Campbell <rcampbell@nvidia.com>
> > 
> > The variable 'entry' is used before being initialized in
> > hmm_vma_walk_pmd()
> > 
> > ...
> >
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -418,7 +418,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >  		}
> >  
> >  		if (!pte_present(pte)) {
> > -			swp_entry_t entry;
> > +			swp_entry_t entry = pte_to_swp_entry(pte);
> >  
> >  			if (!non_swap_entry(entry)) {
> >  				if (hmm_vma_walk->fault)
> > @@ -426,8 +426,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >  				continue;
> >  			}
> >  
> > -			entry = pte_to_swp_entry(pte);
> > -
> >  			/*
> >  			 * This is a special swap entry, ignore migration, use
> >  			 * device and report anything else as error.
> 
> Gee, how did that sneak through.  gcc not clever enough...
> 
> I'll add a cc:stable to this, even though the changelog didn't tell us what
> the runtime effects of the bug are.  It should do so, so can you please
> send us that description and I will add it, thanks.
> 

No bad effect (beside performance hit) so !non_swap_entry(0) evaluate to
true which trigger a fault as if CPU was trying to access migrated memory
and migrate memory back from device memory to regular memory.

This function (hmm_vma_walk_pmd()) is call when device driver tries to
populate its own page table. For migrated memory it should not happen as
the device driver should already have populated its page table correctly
during the migration.

Only case i can think of is multi-GPU where a second GPU trigger migration
back to regular memory. Again this would just result in a performance hit,
nothing bad would happen.


(I will try to keep in mind to always add a more in depth analysis even
for small patch :))

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
