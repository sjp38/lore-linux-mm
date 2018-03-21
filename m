Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7166B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:46:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e17so3088585pgv.5
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:46:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9-v6si4569064plo.214.2018.03.21.15.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Mar 2018 15:46:33 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:46:31 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180321224631.GB3969@bombadil.infradead.org>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 21, 2018 at 02:45:44PM -0700, Yang Shi wrote:
> Marking vma as deleted sounds good. The problem for my current approach is
> the concurrent page fault may succeed if it access the not yet unmapped
> section. Marking deleted vma could tell page fault the vma is not valid
> anymore, then return SIGSEGV.
> 
> > does not care; munmap will need to wait for the existing munmap operation
> 
> Why mmap doesn't care? How about MAP_FIXED? It may fail unexpectedly, right?

The other thing about MAP_FIXED that we'll need to handle is unmapping
conflicts atomically.  Say a program has a 200GB mapping and then
mmap(MAP_FIXED) another 200GB region on top of it.  So I think page faults
are also going to have to wait for deleted vmas (then retry the fault)
rather than immediately raising SIGSEGV.
