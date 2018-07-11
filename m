Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12E236B0272
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:48:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b25-v6so6508450eds.17
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:48:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8-v6si1809921edk.369.2018.07.11.05.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 05:48:02 -0700 (PDT)
Date: Wed, 11 Jul 2018 14:48:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hugetlb: don't zero 1GiB bootmem pages.
Message-ID: <20180711124801.GO20050@dhcp22.suse.cz>
References: <20180710184903.68239-1-cannonmatthews@google.com>
 <20180711124711.GA20172@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711124711.GA20172@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com

On Wed 11-07-18 14:47:11, Michal Hocko wrote:
> On Tue 10-07-18 11:49:03, Cannon Matthews wrote:
> > When using 1GiB pages during early boot, use the new
> > memblock_virt_alloc_try_nid_raw() function to allocate memory without
> > zeroing it.  Zeroing out hundreds or thousands of GiB in a single core
> > memset() call is very slow, and can make early boot last upwards of
> > 20-30 minutes on multi TiB machines.
> > 
> > To be safe, still zero the first sizeof(struct boomem_huge_page) bytes
> > since this is used a temporary storage place for this info until
> > gather_bootmem_prealloc() processes them later.
> > 
> > The rest of the memory does not need to be zero'd as the hugetlb pages
> > are always zero'd on page fault.
> > 
> > Tested: Booted with ~3800 1G pages, and it booted successfully in
> > roughly the same amount of time as with 0, as opposed to the 25+
> > minutes it would take before.
> 
> The patch makes perfect sense to me. I wasn't even aware that it
> zeroying memblock allocation. Thanks for spotting this and fixing it.
> 
> > Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
> 
> I just do not think we need to to zero huge_bootmem_page portion of it.
> It should be sufficient to INIT_LIST_HEAD before list_add. We do
> initialize the rest explicitly already.

Forgot to mention that after that is addressed you can add
Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs
