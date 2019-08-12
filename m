Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A25C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B97A32173B
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B97A32173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46CE46B0003; Mon, 12 Aug 2019 17:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41D4E6B0005; Mon, 12 Aug 2019 17:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 333486B0006; Mon, 12 Aug 2019 17:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0093.hostedemail.com [216.40.44.93])
	by kanga.kvack.org (Postfix) with ESMTP id 143766B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:00:44 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AD569180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:00:43 +0000 (UTC)
X-FDA: 75814994766.02.ant76_5d6b110fc730f
X-HE-Tag: ant76_5d6b110fc730f
X-Filterd-Recvd-Size: 7776
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:00:41 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 14:00:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="178466009"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 12 Aug 2019 14:00:14 -0700
Date: Mon, 12 Aug 2019 14:00:14 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
Message-ID: <20190812210013.GC20634@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-16-ira.weiny@intel.com>
 <6ed26a08-4371-9dc1-09eb-7b8a4689d93b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ed26a08-4371-9dc1-09eb-7b8a4689d93b@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 05:09:54PM -0700, John Hubbard wrote:
> On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > The addition of FOLL_LONGTERM has taken on additional meaning for CMA
> > pages.
> > 
> > In addition subsystems such as RDMA require new information to be passed
> > to the GUP interface to track file owning information.  As such a simple
> > FOLL_LONGTERM flag is no longer sufficient for these users to pin pages.
> > 
> > Introduce a new GUP like call which takes the newly introduced vaddr_pin
> > information.  Failure to pass the vaddr_pin object back to a vaddr_put*
> > call will result in a failure if pins were created on files during the
> > pin operation.
> > 
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > 
> > ---
> > Changes from list:
> > 	Change to vaddr_put_pages_dirty_lock
> > 	Change to vaddr_unpin_pages_dirty_lock
> > 
> >  include/linux/mm.h |  5 ++++
> >  mm/gup.c           | 59 ++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 64 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 657c947bda49..90c5802866df 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1603,6 +1603,11 @@ int account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc);
> >  int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> >  			struct task_struct *task, bool bypass_rlim);
> >  
> > +long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
> > +		     unsigned int gup_flags, struct page **pages,
> > +		     struct vaddr_pin *vaddr_pin);
> > +void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
> > +				  struct vaddr_pin *vaddr_pin, bool make_dirty);
> 
> Hi Ira,
> 
> OK, the API seems fine to me, anyway. :)
> 
> A bit more below...
> 
> >  bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *page);
> >  
> >  /* Container for pinned pfns / pages */
> > diff --git a/mm/gup.c b/mm/gup.c
> > index eeaa0ddd08a6..6d23f70d7847 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -2536,3 +2536,62 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
> >  	return ret;
> >  }
> >  EXPORT_SYMBOL_GPL(get_user_pages_fast);
> > +
> > +/**
> > + * vaddr_pin_pages pin pages by virtual address and return the pages to the
> > + * user.
> > + *
> > + * @addr, start address
> 
> What's with the commas? I thought kernel-doc wants colons, like this, right?
> 
> @addr: start address

:-/  I don't know.

Fixed.

> 
> 
> > + * @nr_pages, number of pages to pin
> > + * @gup_flags, flags to use for the pin
> > + * @pages, array of pages returned
> > + * @vaddr_pin, initalized meta information this pin is to be associated
> > + * with.
> > + *
> > + * NOTE regarding vaddr_pin:
> > + *
> > + * Some callers can share pins via file descriptors to other processes.
> > + * Callers such as this should use the f_owner field of vaddr_pin to indicate
> > + * the file the fd points to.  All other callers should use the mm this pin is
> > + * being made against.  Usually "current->mm".
> > + *
> > + * Expects mmap_sem to be read locked.
> > + */
> > +long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
> > +		     unsigned int gup_flags, struct page **pages,
> > +		     struct vaddr_pin *vaddr_pin)
> > +{
> > +	long ret;
> > +
> > +	gup_flags |= FOLL_LONGTERM;
> 
> 
> Is now the right time to introduce and use FOLL_PIN? If not, then I can always
> add it on top of this later, as part of gup-tracking patches. But you did point
> out that FOLL_LONGTERM is taking on additional meaning, and so maybe it's better
> to split that meaning up right from the start.
> 

At one point I wanted to (and had in my tree) a new flag but I went away from
it.  Prior to the discussion on mlock last week I did not think we needed it.
But I'm ok to add it back in.

I was not ignoring the idea for this RFC I just wanted to get this out there
for people to see.  I see that you threw out a couple of patches which add this
flag in.

FWIW, I think it would be good to differentiate between an indefinite pinned
page vs a referenced "gotten" page.

What you and I have been working on is the former.  So it would be easy to
change your refcounting patches to simply key off of FOLL_PIN.

Would you like me to add in your FOLL_PIN patches to this series?

> 
> > +
> > +	if (!vaddr_pin || (!vaddr_pin->mm && !vaddr_pin->f_owner))
> > +		return -EINVAL;
> > +
> > +	ret = __gup_longterm_locked(current,
> > +				    vaddr_pin->mm,
> > +				    addr, nr_pages,
> > +				    pages, NULL, gup_flags,
> > +				    vaddr_pin);
> > +	return ret;
> > +}
> > +EXPORT_SYMBOL(vaddr_pin_pages);
> > +
> > +/**
> > + * vaddr_unpin_pages_dirty_lock - counterpart to vaddr_pin_pages
> > + *
> > + * @pages, array of pages returned
> > + * @nr_pages, number of pages in pages
> > + * @vaddr_pin, same information passed to vaddr_pin_pages
> > + * @make_dirty: whether to mark the pages dirty
> > + *
> > + * The semantics are similar to put_user_pages_dirty_lock but a vaddr_pin used
> > + * in vaddr_pin_pages should be passed back into this call for propper
> 
> Typo:
                                                                   proper
Fixed.

> 
> > + * tracking.
> > + */
> > +void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
> > +				  struct vaddr_pin *vaddr_pin, bool make_dirty)
> > +{
> > +	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, make_dirty);
> > +}
> > +EXPORT_SYMBOL(vaddr_unpin_pages_dirty_lock);
> > 
> 
> OK, whew, I'm glad to see the updated _dirty_lock() API used here. :)

Yea this was pretty easy to change during the rebase.  Again I'm kind of
floating these quickly at this point.  So sorry about the nits...

Ira

> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

