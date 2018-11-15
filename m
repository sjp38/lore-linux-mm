Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD986B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 21:07:49 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a22-v6so6535554plm.23
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:07:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q128si11427277pfc.179.2018.11.14.18.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 18:07:47 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAF1wlTO130772
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 21:07:47 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nrve5pqkp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 21:07:47 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 15 Nov 2018 02:07:44 -0000
Date: Wed, 14 Nov 2018 18:07:26 -0800
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH RFC 2/6] mm: convert PG_balloon to PG_offline
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-3-david@redhat.com>
 <20181114222321.GB1784@bombadil.infradead.org>
 <b4668081-5aa3-d7f5-6880-d01c75cfc6ae@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b4668081-5aa3-d7f5-6880-d01c75cfc6ae@redhat.com>
Message-Id: <20181115020725.GC2353@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Jonathan Corbet <corbet@lwn.net>, Alexey Dobriyan <adobriyan@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Hansen <chansen3@cisco.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Miles Chen <miles.chen@mediatek.com>, David Rientjes <rientjes@google.com>

On Wed, Nov 14, 2018 at 11:49:15PM +0100, David Hildenbrand wrote:
> On 14.11.18 23:23, Matthew Wilcox wrote:
> > On Wed, Nov 14, 2018 at 10:17:00PM +0100, David Hildenbrand wrote:
> >> Rename PG_balloon to PG_offline. This is an indicator that the page is
> >> logically offline, the content stale and that it should not be touched
> >> (e.g. a hypervisor would have to allocate backing storage in order for the
> >> guest to dump an unused page).  We can then e.g. exclude such pages from
> >> dumps.
> >>
> >> In following patches, we will make use of this bit also in other balloon
> >> drivers.  While at it, document PGTABLE.
> > 
> > Thank you for documenting PGTABLE.  I didn't realise I also had this
> > document to update when I added PGTABLE.
> 
> Thank you for looking into this :)
> 
> > 
> >> +++ b/Documentation/admin-guide/mm/pagemap.rst
> >> @@ -78,6 +78,8 @@ number of times a page is mapped.
> >>      23. BALLOON
> >>      24. ZERO_PAGE
> >>      25. IDLE
> >> +    26. PGTABLE
> >> +    27. OFFLINE
> > 
> > So the offline *user* bit is new ... even though the *kernel* bit
> > just renames the balloon bit.  I'm not sure how I feel about this.
> > I'm going to think about it some more.  Could you share your decision
> > process with us?
> 
> BALLOON was/is documented as
> 
> "23 - BALLOON
>     balloon compaction page
> "
> 
> and only includes all virtio-ballon pages after the non-lru migration
> feature has been implemented for ballooned pages. Since then, this flag
> does basically no longer stands for what it actually was supposed to do.

Perhaps I missing something, but how the user should interpret "23" when he
reads /proc/kpageflags?

> To not break uapi I decided to not rename it but instead to add a new flag.

I've got a feeling that uapi was anyway changed for the BALLON flag
meaning.
 
> > 
> > I have no objection to renaming the balloon bit inside the kernel; I
> > think that's a wise idea.  I'm just not sure whether we should rename
> > the user balloon bit rather than adding a new bit.
> > 
> 
> Can we rename without breaking uapi?
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb
> 

-- 
Sincerely yours,
Mike.
