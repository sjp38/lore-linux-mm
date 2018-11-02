Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39FFE6B000A
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 20:03:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a72-v6so184202pfj.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 17:03:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x87-v6si17742780pfk.54.2018.11.01.17.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Nov 2018 17:03:11 -0700 (PDT)
Date: Thu, 1 Nov 2018 17:03:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4] mm/page_owner: clamp read count to PAGE_SIZE
Message-ID: <20181102000307.GO10491@bombadil.infradead.org>
References: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
 <20181101144723.3ddc1fa1ab7f81184bc2fdb8@linux-foundation.org>
 <3c81f60ac1ff270df972ded4128a7dbf41a91113.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c81f60ac1ff270df972ded4128a7dbf41a91113.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, miles.chen@mediatek.com, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com, Michal Hocko <mhocko@kernel.org>

On Thu, Nov 01, 2018 at 04:30:12PM -0700, Joe Perches wrote:
> On Thu, 2018-11-01 at 14:47 -0700, Andrew Morton wrote:
> > +++ a/mm/page_owner.c
> > @@ -351,7 +351,7 @@ print_page_owner(char __user *buf, size_
> >  		.skip = 0
> >  	};
> >  
> > -	count = count > PAGE_SIZE ? PAGE_SIZE : count;
> > +	count = min_t(size_t, count, PAGE_SIZE);
> >  	kbuf = kmalloc(count, GFP_KERNEL);
> >  	if (!kbuf)
> >  		return -ENOMEM;
> 
> A bit tidier still might be
> 
> 	if (count > PAGE_SIZE)
> 		count = PAGE_SIZE;
> 
> as that would not always cause a write back to count.

90% chance 'count' is already in a register and will stay there.  99.9%
chance that if it's not in a register, it's on the top of the stack,
which is by definition a hot, local, dirty cacheline.

What you're saying makes sense for a struct which might well be in a
shared cacheline state.  But for a function-local variable?  No.
