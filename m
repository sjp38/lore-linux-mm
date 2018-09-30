Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87CCC8E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 09:10:32 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 17-v6so11705896qkj.19
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 06:10:32 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id y68-v6si5221156qkd.226.2018.09.30.06.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Sep 2018 06:10:31 -0700 (PDT)
Date: Sun, 30 Sep 2018 06:10:26 -0700
From: Greg KH <gregkh@linux-foundation.org>
Subject: Re: [STABLE PATCH] slub: make ->cpu_partial unsigned int
Message-ID: <20180930131026.GA25677@kroah.com>
References: <1538303301-61784-1-git-send-email-zhongjiang@huawei.com>
 <20180930125038.GA2533@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180930125038.GA2533@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: zhong jiang <zhongjiang@huawei.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, mgorman@suse.de, vbabka@suse.cz, andrea@kernel.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Sep 30, 2018 at 05:50:38AM -0700, Matthew Wilcox wrote:
> On Sun, Sep 30, 2018 at 06:28:21PM +0800, zhong jiang wrote:
> > From: Alexey Dobriyan <adobriyan@gmail.com>
> > 
> > [ Upstream commit e5d9998f3e09359b372a037a6ac55ba235d95d57 ]
> > 
> >         /*
> >          * cpu_partial determined the maximum number of objects
> >          * kept in the per cpu partial lists of a processor.
> >          */
> > 
> > Can't be negative.
> > 
> > I hit a real issue that it will result in a large number of memory leak.
> > Becuase Freeing slabs are in interrupt context. So it can trigger this issue.
> > put_cpu_partial can be interrupted more than once.
> > due to a union struct of lru and pobjects in struct page, when other core handles
> > page->lru list, for eaxmple, remove_partial in freeing slab code flow, It will
> > result in pobjects being a negative value(0xdead0000). Therefore, a large number
> > of slabs will be added to per_cpu partial list.
> > 
> > I had posted the issue to community before. The detailed issue description is as follows.
> > 
> > https://www.spinics.net/lists/kernel/msg2870979.html
> > 
> > After applying the patch, The issue is fixed. So the patch is a effective bugfix.
> > It should go into stable.
> > 
> > Link: http://lkml.kernel.org/r/20180305200730.15812-15-adobriyan@gmail.com
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > Acked-by: Christoph Lameter <cl@linux.com>
> 
> Hang on.  Christoph acked the _original_ patch going into upstream.
> When he reviewed this patch for _stable_ last week, he asked for more
> investigation.  Including this patch in stable is misleading.

But the original patch has been in upstream for a long time now (it went
into 4.17-rc1).  If there was a real problem here, whouldn't it have
been resolved already?

And the patch in mainline has Christoph's ack...

thanks,

greg k-h
