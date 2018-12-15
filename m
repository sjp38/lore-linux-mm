Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2F98E0002
	for <linux-mm@kvack.org>; Sat, 15 Dec 2018 09:38:34 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id m16so6178095pgd.0
        for <linux-mm@kvack.org>; Sat, 15 Dec 2018 06:38:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q26si4203540pgk.162.2018.12.15.06.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 15 Dec 2018 06:38:32 -0800 (PST)
Date: Sat, 15 Dec 2018 06:38:24 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181215143824.GJ10600@bombadil.infradead.org>
References: <20181204020840.49576-1-houtao1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204020840.49576-1-houtao1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hou Tao <houtao1@huawei.com>
Cc: phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 04, 2018 at 10:08:40AM +0800, Hou Tao wrote:
> There is no need to disable __GFP_FS in ->readpage:
> * It's a read-only fs, so there will be no dirty/writeback page and
>   there will be no deadlock against the caller's locked page
> * It just allocates one page, so compaction will not be invoked
> * It doesn't take any inode lock, so the reclamation of inode will be fine
> 
> And no __GFP_FS may lead to hang in __alloc_pages_slowpath() if a
> squashfs page fault occurs in the context of a memory hogger, because
> the hogger will not be killed due to the logic in __alloc_pages_may_oom().

I don't understand your argument here.  There's a comment in
__alloc_pages_may_oom() saying that we _should_ treat GFP_NOFS
specially, but we currently don't.

        /*
         * XXX: GFP_NOFS allocations should rather fail than rely on
         * other request to make a forward progress.
         * We are in an unfortunate situation where out_of_memory cannot
         * do much for this context but let's try it to at least get
         * access to memory reserved if the current task is killed (see
         * out_of_memory). Once filesystems are ready to handle allocation
         * failures more gracefully we should just bail out here.
         */

What problem are you actually seeing?
