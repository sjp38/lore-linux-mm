Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 367DA6B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 22:16:11 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m4-v6so12933143qtn.19
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 19:16:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b187-v6si13502272qke.333.2018.06.17.19.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 19:16:10 -0700 (PDT)
Date: Mon, 18 Jun 2018 05:16:02 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v33 1/4] mm: add a function to get free page blocks
Message-ID: <20180618051145-mutt-send-email-mst@kernel.org>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
 <20180616045005.GA14936@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180616045005.GA14936@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Fri, Jun 15, 2018 at 09:50:05PM -0700, Matthew Wilcox wrote:
> I wonder if (to address Michael's concern), you shouldn't instead use
> the first free chunk of pages to return the addresses of all the pages.
> ie something like this:
> 
> 	__le64 *ret = NULL;
> 	unsigned int max = (PAGE_SIZE << order) / sizeof(__le64);
> 
> 	for_each_populated_zone(zone) {
> 		spin_lock_irq(&zone->lock);
> 		for (mt = 0; mt < MIGRATE_TYPES; mt++) {
> 			list = &zone->free_area[order].free_list[mt];
> 			list_for_each_entry_safe(page, list, lru, ...) {
> 				if (index == size)
> 					break;
> 				addr = page_to_pfn(page) << PAGE_SHIFT;
> 				if (!ret) {
> 					list_del(...);
> 					ret = addr;
> 				}
> 				ret[index++] = cpu_to_le64(addr);
> 			}
> 		}
> 		spin_unlock_irq(&zone->lock);
> 	}
> 
> 	return ret;
> }
> 
> You'll need to return the page to the freelist afterwards, but free_pages()
> should take care of that.

Yes Wei already came up with the idea to stick this data into a
MAX_ORDER allocation. Are you sure just taking an entry off
the list like that has no bad side effects?
I have a vague memory someone complained that everyone
most go through get free pages/kmalloc, but I can't
find that anymore.


-- 
MST
