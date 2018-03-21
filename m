Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 379606B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:03:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 41so3744102qtp.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:03:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s63si3668897qkd.204.2018.03.21.11.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 11:03:45 -0700 (PDT)
Date: Wed, 21 Mar 2018 14:03:42 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v2
Message-ID: <20180321180342.GE3214@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-4-jglisse@redhat.com>
 <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Tue, Mar 20, 2018 at 09:14:34PM -0700, John Hubbard wrote:
> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> > From: Ralph Campbell <rcampbell@nvidia.com>
> > 
> > The hmm_mirror_register() function registers a callback for when
> > the CPU pagetable is modified. Normally, the device driver will
> > call hmm_mirror_unregister() when the process using the device is
> > finished. However, if the process exits uncleanly, the struct_mm
> > can be destroyed with no warning to the device driver.
> > 
> > Changed since v1:
> >   - dropped VM_BUG_ON()
> >   - cc stable
> > 
> > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: stable@vger.kernel.org
> > Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> > Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  include/linux/hmm.h | 10 ++++++++++
> >  mm/hmm.c            | 18 +++++++++++++++++-
> >  2 files changed, 27 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 36dd21fe5caf..fa7b51f65905 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -218,6 +218,16 @@ enum hmm_update_type {
> >   * @update: callback to update range on a device
> >   */
> >  struct hmm_mirror_ops {
> > +	/* release() - release hmm_mirror
> > +	 *
> > +	 * @mirror: pointer to struct hmm_mirror
> > +	 *
> > +	 * This is called when the mm_struct is being released.
> > +	 * The callback should make sure no references to the mirror occur
> > +	 * after the callback returns.
> > +	 */
> > +	void (*release)(struct hmm_mirror *mirror);
> > +
> >  	/* sync_cpu_device_pagetables() - synchronize page tables
> >  	 *
> >  	 * @mirror: pointer to struct hmm_mirror
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 320545b98ff5..6088fa6ed137 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -160,6 +160,21 @@ static void hmm_invalidate_range(struct hmm *hmm,
> >  	up_read(&hmm->mirrors_sem);
> >  }
> >  
> > +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> > +{
> > +	struct hmm *hmm = mm->hmm;
> > +	struct hmm_mirror *mirror;
> > +	struct hmm_mirror *mirror_next;
> > +
> > +	down_write(&hmm->mirrors_sem);
> > +	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
> > +		list_del_init(&mirror->list);
> > +		if (mirror->ops->release)
> > +			mirror->ops->release(mirror);
> 
> Hi Jerome,
> 
> This presents a deadlock problem (details below). As for solution ideas, 
> Mark Hairgrove points out that the MMU notifiers had to solve the
> same sort of problem, and part of the solution involves "avoid
> holding locks when issuing these callbacks". That's not an entire 
> solution description, of course, but it seems like a good start.
> 
> Anyway, for the deadlock problem:
> 
> Each of these ->release callbacks potentially has to wait for the 
> hmm_invalidate_range() callbacks to finish. That is not shown in any
> code directly, but it's because: when a device driver is processing 
> the above ->release callback, it has to allow any in-progress operations 
> to finish up (as specified clearly in your comment documentation above). 
> 
> Some of those operations will invariably need to do things that result 
> in page invalidations, thus triggering the hmm_invalidate_range() callback.
> Then, the hmm_invalidate_range() callback tries to acquire the same 
> hmm->mirrors_sem lock, thus leading to deadlock:
> 
> hmm_invalidate_range():
> // ...
> 	down_read(&hmm->mirrors_sem);
> 	list_for_each_entry(mirror, &hmm->mirrors, list)
> 		mirror->ops->sync_cpu_device_pagetables(mirror, action,
> 							start, end);
> 	up_read(&hmm->mirrors_sem);

That is just illegal, the release callback is not allowed to trigger
invalidation all it does is kill all device's threads and stop device
page fault from happening. So there is no deadlock issues. I can re-
inforce the comment some more (see [1] for example on what it should
be).

Also it is illegal for the sync callback to trigger any mmu_notifier
callback. I thought this was obvious. The sync callback should only
update device page table and do _nothing else_. No way to make this
re-entrant.

For anonymous private memory migrated to device memory it is freed
shortly after the release callback (see exit_mmap()). For share memory
you might want to migrate back to regular memory but that will be fine
as you will not get mmu_notifier callback any more.

So i don't see any deadlock here.

Cheers,
Jerome

[1] https://cgit.freedesktop.org/~glisse/linux/commit/?h=nouveau-hmm&id=93adb3e6b4f39d5d146b6a8afb4175d37bdd4890
