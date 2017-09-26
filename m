Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9926B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:20:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b1so11675558qtc.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:20:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a9si768284qtg.553.2017.09.26.09.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 09:19:59 -0700 (PDT)
Date: Tue, 26 Sep 2017 09:19:42 -0700
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
Message-ID: <20170926161941.GB3216@redhat.com>
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20170926133707.wquyw3ic5nbmfjuo@dhcp22.suse.cz>
 <20170926144710.zepvnyktqjomnx2n@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170926144710.zepvnyktqjomnx2n@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 26, 2017 at 09:47:10AM -0500, Reza Arbab wrote:
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
> 
> I understand it's minimally useful information to userspace, but the memory
> does have a nid and move_pages() is supposed to be able to return what that
> is. I ran into this using a testcase which tries to verify that user
> addresses were correctly migrated to coherent device memory.
> 
> That said, I'm okay with dropping this if you don't think it's worthwhile.

Just to add a data point, PCIE devices are tie to one CPU (architecturaly PCIE
lane are connected to CPU at least on x86/ppc AFAIK) and thus to one numa node.


Right now i am traveling but i want to check that this patch does not allow
user to inadvertaly pin device memory page. I will look into it once i am
back.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
