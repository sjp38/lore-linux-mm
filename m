Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0FBB6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 03:42:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p86so155714462pfl.12
        for <linux-mm@kvack.org>; Tue, 23 May 2017 00:42:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d8si20261058pgn.60.2017.05.23.00.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 00:42:41 -0700 (PDT)
Date: Tue, 23 May 2017 00:42:34 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] ib/core: not to set page dirty bit if it's already set.
Message-ID: <20170523074234.GE29525@infradead.org>
References: <20170518233353.14370-1-qing.huang@oracle.com>
 <20170519130541.GA8017@infradead.org>
 <9f4a4f90-a7b1-b1dc-6e7a-042f26254681@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f4a4f90-a7b1-b1dc-6e7a-042f26254681@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qing Huang <qing.huang@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, dledford@redhat.com, sean.hefty@intel.com, artemyko@mellanox.com, linux-mm@kvack.org

On Mon, May 22, 2017 at 04:43:57PM -0700, Qing Huang wrote:
> 
> On 5/19/2017 6:05 AM, Christoph Hellwig wrote:
> > On Thu, May 18, 2017 at 04:33:53PM -0700, Qing Huang wrote:
> > > This change will optimize kernel memory deregistration operations.
> > > __ib_umem_release() used to call set_page_dirty_lock() against every
> > > writable page in its memory region. Its purpose is to keep data
> > > synced between CPU and DMA device when swapping happens after mem
> > > deregistration ops. Now we choose not to set page dirty bit if it's
> > > already set by kernel prior to calling __ib_umem_release(). This
> > > reduces memory deregistration time by half or even more when we ran
> > > application simulation test program.
> > As far as I can tell this code doesn't even need set_page_dirty_lock
> > and could just use set_page_dirty
> 
> It seems that set_page_dirty_lock has been used here for more than 10 years.
> Don't know the original purpose. Maybe it was used to prevent races between
> setting dirty bits and swapping out pages?

I suspect copy & paste.  Or maybe I don't actually understand the
explanation of set_page_dirty vs set_page_dirty_lock enough.  But
I'd rather not hack around the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
