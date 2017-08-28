Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBF66B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 10:10:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k94so826446wrc.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 07:10:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m130si334618wma.277.2017.08.28.07.10.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 07:10:01 -0700 (PDT)
Date: Mon, 28 Aug 2017 16:09:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v15 4/5] mm: support reporting free page blocks
Message-ID: <20170828140958.GO17097@dhcp22.suse.cz>
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com>
 <1503914913-28893-5-git-send-email-wei.w.wang@intel.com>
 <20170828133326.GN17097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170828133326.GN17097@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Mon 28-08-17 15:33:26, Michal Hocko wrote:
> On Mon 28-08-17 18:08:32, Wei Wang wrote:
> > This patch adds support to walk through the free page blocks in the
> > system and report them via a callback function. Some page blocks may
> > leave the free list after zone->lock is released, so it is the caller's
> > responsibility to either detect or prevent the use of such pages.
> > 
> > One use example of this patch is to accelerate live migration by skipping
> > the transfer of free pages reported from the guest. A popular method used
> > by the hypervisor to track which part of memory is written during live
> > migration is to write-protect all the guest memory. So, those pages that
> > are reported as free pages but are written after the report function
> > returns will be captured by the hypervisor, and they will be added to the
> > next round of memory transfer.
> 
> OK, looks much better. I still have few nits.
> 
> > +extern void walk_free_mem_block(void *opaque,
> > +				int min_order,
> > +				bool (*report_page_block)(void *, unsigned long,
> > +							  unsigned long));
> > +
> 
> please add names to arguments of the prototype

And one more thing. Your callback returns bool and true usually means a
success while you are using it to break out from the loop. This is
rather confusing. I would expect iterating until false is returned so
the opposite than what you have. You could also change this to int and
return 0 on success and < 0 to break out. 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
