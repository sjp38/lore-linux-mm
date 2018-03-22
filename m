Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4806B0012
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 19:37:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j8so6672393qti.23
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 16:37:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w36si499349qth.439.2018.03.22.16.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 16:37:18 -0700 (PDT)
Date: Thu, 22 Mar 2018 19:37:16 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v2
Message-ID: <20180322233715.GA5011@redhat.com>
References: <20180320020038.3360-5-jglisse@redhat.com>
 <20180321181614.9968-1-jglisse@redhat.com>
 <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
 <20180321234110.GK3214@redhat.com>
 <cbc9dcba-0707-e487-d360-f6f7c8d5cb23@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cbc9dcba-0707-e487-d360-f6f7c8d5cb23@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Thu, Mar 22, 2018 at 03:47:16PM -0700, John Hubbard wrote:
> On 03/21/2018 04:41 PM, Jerome Glisse wrote:
> > On Wed, Mar 21, 2018 at 04:22:49PM -0700, John Hubbard wrote:
> >> On 03/21/2018 11:16 AM, jglisse@redhat.com wrote:
> >>> From: Jerome Glisse <jglisse@redhat.com>
> >>>
> >>> This code was lost in translation at one point. This properly call
> >>> mmu_notifier_unregister_no_release() once last user is gone. This
> >>> fix the zombie mm_struct as without this patch we do not drop the
> >>> refcount we have on it.
> >>>
> >>> Changed since v1:
> >>>   - close race window between a last mirror unregistering and a new
> >>>     mirror registering, which could have lead to use after free()
> >>>     kind of bug
> >>>
> >>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> >>> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> >>> Cc: Ralph Campbell <rcampbell@nvidia.com>
> >>> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> >>> Cc: John Hubbard <jhubbard@nvidia.com>
> >>> ---
> >>>  mm/hmm.c | 35 +++++++++++++++++++++++++++++++++--
> >>>  1 file changed, 33 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/mm/hmm.c b/mm/hmm.c
> >>> index 6088fa6ed137..f75aa8df6e97 100644
> >>> --- a/mm/hmm.c
> >>> +++ b/mm/hmm.c
> >>> @@ -222,13 +222,24 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> >>>  	if (!mm || !mirror || !mirror->ops)
> >>>  		return -EINVAL;
> >>>  
> >>> +again:
> >>>  	mirror->hmm = hmm_register(mm);
> >>>  	if (!mirror->hmm)
> >>>  		return -ENOMEM;
> >>>  
> >>>  	down_write(&mirror->hmm->mirrors_sem);
> >>> -	list_add(&mirror->list, &mirror->hmm->mirrors);
> >>> -	up_write(&mirror->hmm->mirrors_sem);
> >>> +	if (mirror->hmm->mm == NULL) {
> >>> +		/*
> >>> +		 * A racing hmm_mirror_unregister() is about to destroy the hmm
> >>> +		 * struct. Try again to allocate a new one.
> >>> +		 */
> >>> +		up_write(&mirror->hmm->mirrors_sem);
> >>> +		mirror->hmm = NULL;
> >>
> >> This is being set outside of locks, so now there is another race with
> >> another hmm_mirror_register...
> >>
> >> I'll take a moment and draft up what I have in mind here, which is a more
> >> symmetrical locking scheme for these routines.
> >>
> > 
> > No this code is correct. hmm->mm is set after hmm struct is allocated
> > and before it is public so no one can race with that. It is clear in
> > hmm_mirror_unregister() under the write lock hence checking it here
> > under that same lock is correct.
> 
> Are you implying that code that calls hmm_mirror_register() should do 
> it's own locking, to prevent simultaneous calls to that function? Because
> as things are right now, multiple threads can arrive at this point. The
> fact that mirror->hmm is not "public" is irrelevant; what matters is that
> >1 thread can change it simultaneously.

The content of struct hmm_mirror should not be modified by code outside
HMM after hmm_mirror_register() and before hmm_mirror_unregister(). This
is a private structure to HMM and the driver should not touch it, ie it
should be considered as read only/const from driver code point of view.

It is also expected (which was obvious to me) that driver only call once
and only once hmm_mirror_register(), and only once hmm_mirror_unregister()
for any given hmm_mirror struct. Note that driver can register multiple
_different_ mirror struct to same mm or differents mm.

There is no need of locking on the driver side whatsoever as long as the
above rules are respected. I am puzzle if they were not obvious :)

Note that the above rule means that for any given struct hmm_mirror their
can only be one and only one call to hmm_mirror_register() happening, no
concurrent call. If you are doing the latter then something is seriously
wrong in your design.

So to be clear on what variable are you claiming race ?
  mirror->hmm ?
  mirror->hmm->mm which is really hmm->mm (mirror part does not matter) ?

I will hold resending v4 until tomorrow morning (eastern time) so that
you can convince yourself that this code is right or prove me wrong.

Cheers,
Jerome
