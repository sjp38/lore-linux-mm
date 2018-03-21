Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 924EC6B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:41:13 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c4so4376672qtm.4
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:41:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 141si454010qkk.455.2018.03.21.16.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:41:12 -0700 (PDT)
Date: Wed, 21 Mar 2018 19:41:10 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v2
Message-ID: <20180321234110.GK3214@redhat.com>
References: <20180320020038.3360-5-jglisse@redhat.com>
 <20180321181614.9968-1-jglisse@redhat.com>
 <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Wed, Mar 21, 2018 at 04:22:49PM -0700, John Hubbard wrote:
> On 03/21/2018 11:16 AM, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > This code was lost in translation at one point. This properly call
> > mmu_notifier_unregister_no_release() once last user is gone. This
> > fix the zombie mm_struct as without this patch we do not drop the
> > refcount we have on it.
> > 
> > Changed since v1:
> >   - close race window between a last mirror unregistering and a new
> >     mirror registering, which could have lead to use after free()
> >     kind of bug
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  mm/hmm.c | 35 +++++++++++++++++++++++++++++++++--
> >  1 file changed, 33 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 6088fa6ed137..f75aa8df6e97 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -222,13 +222,24 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> >  	if (!mm || !mirror || !mirror->ops)
> >  		return -EINVAL;
> >  
> > +again:
> >  	mirror->hmm = hmm_register(mm);
> >  	if (!mirror->hmm)
> >  		return -ENOMEM;
> >  
> >  	down_write(&mirror->hmm->mirrors_sem);
> > -	list_add(&mirror->list, &mirror->hmm->mirrors);
> > -	up_write(&mirror->hmm->mirrors_sem);
> > +	if (mirror->hmm->mm == NULL) {
> > +		/*
> > +		 * A racing hmm_mirror_unregister() is about to destroy the hmm
> > +		 * struct. Try again to allocate a new one.
> > +		 */
> > +		up_write(&mirror->hmm->mirrors_sem);
> > +		mirror->hmm = NULL;
> 
> This is being set outside of locks, so now there is another race with
> another hmm_mirror_register...
> 
> I'll take a moment and draft up what I have in mind here, which is a more
> symmetrical locking scheme for these routines.
> 

No this code is correct. hmm->mm is set after hmm struct is allocated
and before it is public so no one can race with that. It is clear in
hmm_mirror_unregister() under the write lock hence checking it here
under that same lock is correct.

Cheers,
Jerome
