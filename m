Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35A0D6B0268
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:39:53 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id f13so3017457oib.20
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:39:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b58sor1857045otj.113.2017.11.30.08.39.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 08:39:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151197873499.26211.11687422577653326365.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 30 Nov 2017 08:39:51 -0800
Message-ID: <CAPcyv4giMvMfP=yZr=EDRAdTWyCwWydb4JVhT6YSWP8W0PHgGQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] mm: introduce get_user_pages_longterm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu, Nov 30, 2017 at 1:53 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 29-11-17 10:05:35, Dan Williams wrote:
>> Until there is a solution to the dma-to-dax vs truncate problem it is
>> not safe to allow long standing memory registrations against
>> filesytem-dax vmas. Device-dax vmas do not have this problem and are
>> explicitly allowed.
>>
>> This is temporary until a "memory registration with layout-lease"
>> mechanism can be implemented for the affected sub-systems (RDMA and
>> V4L2).
>
> One thing is not clear to me. Who is allowed to pin pages for ever?
> Is it possible to pin LRU pages that way as well? If yes then there
> absolutely has to be a limit for that. Sorry I could have studied the
> code much more but from a quick glance it seems to me that this is not
> limited to dax (or non-LRU in general) pages.

I would turn this question around. "who can not tolerate a page being
pinned forever?". In the case of filesytem-dax a page is
one-in-the-same object as a filesystem-block, and a filesystem expects
that its operations will not be blocked indefinitely. LRU pages can
continue to be pinned indefinitely because operations can continue
around the pinned page, i.e. every agent, save for the dma agent,
drops their reference to the page and its tolerable that the final
put_page() never arrives. As far as I can tell it's only filesystems
and dax that have this collision of wanting to revoke dma access to a
page combined with not being able to wait indefinitely for dma to
quiesce.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
