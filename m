Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDB5D6B026B
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 19:30:17 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id d12-v6so293200iof.10
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 16:30:17 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0069.hostedemail.com. [216.40.44.69])
        by mx.google.com with ESMTPS id l131-v6si17342257ioa.13.2018.11.01.16.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 16:30:16 -0700 (PDT)
Message-ID: <3c81f60ac1ff270df972ded4128a7dbf41a91113.camel@perches.com>
Subject: Re: [PATCH v4] mm/page_owner: clamp read count to PAGE_SIZE
From: Joe Perches <joe@perches.com>
Date: Thu, 01 Nov 2018 16:30:12 -0700
In-Reply-To: <20181101144723.3ddc1fa1ab7f81184bc2fdb8@linux-foundation.org>
References: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
	 <20181101144723.3ddc1fa1ab7f81184bc2fdb8@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, miles.chen@mediatek.com
Cc: Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com, Michal Hocko <mhocko@kernel.org>

On Thu, 2018-11-01 at 14:47 -0700, Andrew Morton wrote:
> On Fri, 2 Nov 2018 01:00:07 +0800 <miles.chen@mediatek.com> wrote:
> 
> > From: Miles Chen <miles.chen@mediatek.com>
> > 
> > The page owner read might allocate a large size of memory with
> > a large read count. Allocation fails can easily occur when doing
> > high order allocations.
> > 
> > Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
> > and avoid allocation fails due to high order allocation.
> > 
> > ...
> > 
> > --- a/mm/page_owner.c
> > +++ b/mm/page_owner.c
> > @@ -351,6 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
> >  		.skip = 0
> >  	};
> >  
> > +	count = count > PAGE_SIZE ? PAGE_SIZE : count;
> >  	kbuf = kmalloc(count, GFP_KERNEL);
> >  	if (!kbuf)
> >  		return -ENOMEM;
> 
> A bit tidier:
> 
> --- a/mm/page_owner.c~mm-page_owner-clamp-read-count-to-page_size-fix
> +++ a/mm/page_owner.c
> @@ -351,7 +351,7 @@ print_page_owner(char __user *buf, size_
>  		.skip = 0
>  	};
>  
> -	count = count > PAGE_SIZE ? PAGE_SIZE : count;
> +	count = min_t(size_t, count, PAGE_SIZE);
>  	kbuf = kmalloc(count, GFP_KERNEL);
>  	if (!kbuf)
>  		return -ENOMEM;

A bit tidier still might be

	if (count > PAGE_SIZE)
		count = PAGE_SIZE;

as that would not always cause a write back to count.
