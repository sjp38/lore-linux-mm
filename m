Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B80A6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:32:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p37so1989171wrb.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:32:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4si7242324wrg.494.2017.09.26.09.32.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 09:32:43 -0700 (PDT)
Date: Tue, 26 Sep 2017 18:32:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
Message-ID: <20170926163241.5rd4wyzrzoso4uto@dhcp22.suse.cz>
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20170926133707.wquyw3ic5nbmfjuo@dhcp22.suse.cz>
 <20170926144710.zepvnyktqjomnx2n@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926144710.zepvnyktqjomnx2n@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 26-09-17 09:47:10, Reza Arbab wrote:
> On Tue, Sep 26, 2017 at 01:37:07PM +0000, Michal Hocko wrote:
> > On Fri 22-09-17 15:13:56, Reza Arbab wrote:
> > > The move_pages() syscall can be used to find the numa node where a page
> > > currently resides. This is not working for device public memory pages,
> > > which erroneously report -EFAULT (unmapped or zero page).
> > > 
> > > Enable by adding a FOLL_DEVICE flag for follow_page(), which
> > > move_pages() will use. This could be done unconditionally, but adding a
> > > flag seems like a safer change.
> > 
> > I do not understand purpose of this patch. What is the numa node of a
> > device memory?
> 
> Well, using hmm_devmem_pages_create() it is added to this node:
> 
> 	nid = dev_to_node(device);
> 	if (nid < 0)
> 		nid = numa_mem_id();

OK, but do all the HMM devices have concept of NUMA affinity? From the
code you are pasting they do not have to...
 
> I understand it's minimally useful information to userspace, but the memory
> does have a nid and move_pages() is supposed to be able to return what that
> is. I ran into this using a testcase which tries to verify that user
> addresses were correctly migrated to coherent device memory.
> 
> That said, I'm okay with dropping this if you don't think it's worthwhile.

I am just worried that we allow information which is not generally
sensible and I am also not sure what the userspace can actually do with
that information.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
