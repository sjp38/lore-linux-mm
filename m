Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22D756B026F
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:17:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 73so5417300pfz.11
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:17:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si3551681plb.29.2017.11.30.10.17.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 10:17:46 -0800 (PST)
Date: Thu, 30 Nov 2017 19:17:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/4] mm: introduce get_user_pages_longterm
Message-ID: <20171130181741.2y5nyflyhqxg6y5p@dhcp22.suse.cz>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151197873499.26211.11687422577653326365.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
 <CAPcyv4giMvMfP=yZr=EDRAdTWyCwWydb4JVhT6YSWP8W0PHgGQ@mail.gmail.com>
 <20171130174201.stbpuye4gu5rxwkm@dhcp22.suse.cz>
 <CAPcyv4h5GUueqB-QhbWbn39SBPDE-rOte6UcmAHSWQdVyrF2Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4h5GUueqB-QhbWbn39SBPDE-rOte6UcmAHSWQdVyrF2Rw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu 30-11-17 10:03:26, Dan Williams wrote:
> On Thu, Nov 30, 2017 at 9:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 30-11-17 08:39:51, Dan Williams wrote:
> > > On Thu, Nov 30, 2017 at 1:53 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > > On Wed 29-11-17 10:05:35, Dan Williams wrote:
> > > >> Until there is a solution to the dma-to-dax vs truncate problem it is
> > > >> not safe to allow long standing memory registrations against
> > > >> filesytem-dax vmas. Device-dax vmas do not have this problem and are
> > > >> explicitly allowed.
> > > >>
> > > >> This is temporary until a "memory registration with layout-lease"
> > > >> mechanism can be implemented for the affected sub-systems (RDMA and
> > > >> V4L2).
> > > >
> > > > One thing is not clear to me. Who is allowed to pin pages for ever?
> > > > Is it possible to pin LRU pages that way as well? If yes then there
> > > > absolutely has to be a limit for that. Sorry I could have studied the
> > > > code much more but from a quick glance it seems to me that this is not
> > > > limited to dax (or non-LRU in general) pages.
> > >
> > > I would turn this question around. "who can not tolerate a page being
> > > pinned forever?".
> >
> > Any struct page on the movable zone or anything that is living on the
> > LRU list because such a memory is unreclaimable.
> >
> > > In the case of filesytem-dax a page is
> > > one-in-the-same object as a filesystem-block, and a filesystem expects
> > > that its operations will not be blocked indefinitely. LRU pages can
> > > continue to be pinned indefinitely because operations can continue
> > > around the pinned page, i.e. every agent, save for the dma agent,
> > > drops their reference to the page and its tolerable that the final
> > > put_page() never arrives.
> >
> > I do not understand. Are you saying that a user triggered IO can pin LRU
> > pages indefinitely. This would be _really_ wrong. It would be basically
> > an mlock without any limit. So I must be misreading you here
> 
> You're not misreading. See ib_umem_get() for example, it pins pages in
> response to the userspace library call ibv_reg_mr() (memory
> registration), and will not release those pages unless/until a call to
> ibv_dereg_mr() is made.

Who and how many LRU pages can pin that way and how do you prevent nasty
users to DoS systems this way?

I remember PeterZ wanted to address a similar issue by vmpin syscall
that would be a subject of a rlimit control. Sorry but I cannot find a
reference here but if this is at g-u-p level without any accounting then
it smells quite broken to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
