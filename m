Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 730F26B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:02:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id t10-v6so2201542wre.19
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:02:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p9-v6si2320849wrg.306.2018.07.04.00.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 00:02:24 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w646x2lC065751
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 03:02:23 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0nk681v0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 03:02:23 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 08:02:21 +0100
Date: Wed, 4 Jul 2018 10:02:14 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
Message-Id: <20180704070214.GA4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>

On Tue, Jul 03, 2018 at 12:57:22PM -0700, Andrew Morton wrote:
> On Tue,  3 Jul 2018 20:05:06 +0300 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > Most functions in memblock already use phys_addr_t to represent a physical
> > address with __memblock_free_late() being an exception.
> > 
> > This patch replaces u64 with phys_addr_t in __memblock_free_late() and
> > switches several format strings from %llx to %pa to avoid casting from
> > phys_addr_t to u64.
> >
> > ...
> > 
> > @@ -1343,9 +1343,9 @@ void * __init memblock_virt_alloc_try_nid_raw(
> >  {
> >  	void *ptr;
> >  
> > -	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
> > -		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
> > -		     (u64)max_addr, (void *)_RET_IP_);
> > +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
> > +		     __func__, (u64)size, (u64)align, nid, &min_addr,
> > +		     &max_addr, (void *)_RET_IP_);
> >  
> 
> Did you see all this checkpatch noise?
> 
> : WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead
> : #54: FILE: mm/memblock.c:1348:
> : +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
> : +		     __func__, (u64)size, (u64)align, nid, &min_addr,
> : +		     &max_addr, (void *)_RET_IP_);
> : ...
> : 
 
Sorry, my bad...

>  * - 'S' For symbolic direct pointers (or function descriptors) with offset
>  * - 's' For symbolic direct pointers (or function descriptors) without offset
>  * - 'F' Same as 'S'
>  * - 'f' Same as 's'
> 
> I'm not sure why or when all that happened.
> 
> I suppose we should do that as a separate patch sometime.
> 

-- 
Sincerely yours,
Mike.
