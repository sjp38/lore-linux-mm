Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C4C566B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 22:34:45 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so31717449pdb.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 19:34:45 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id i17si12088703pdj.142.2015.07.09.19.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 19:34:45 -0700 (PDT)
Received: by pacws9 with SMTP id ws9so161666002pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 19:34:44 -0700 (PDT)
Date: Fri, 10 Jul 2015 11:34:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710023437.GB18266@blaptop>
References: <1436491929-6617-1-git-send-email-minchan@kernel.org>
 <20150710020624.GB692@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710020624.GB692@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 10, 2015 at 11:06:24AM +0900, Sergey Senozhatsky wrote:
> On (07/10/15 10:32), Minchan Kim wrote:
> >  static struct page *isolate_source_page(struct size_class *class)
> >  {
> >  	struct page *page;
> > +	int i;
> > +	bool found = false;
> >  
> 
> why use 'bool found'? just return `page', which will be either NULL
> or !NULL?

It seems my old version which had a bug during test. :(
I will resend with the fix.

Thanks, Sergey!

> 
> 	-ss
> 
> > -	page = class->fullness_list[ZS_ALMOST_EMPTY];
> > -	if (page)
> > -		remove_zspage(page, class, ZS_ALMOST_EMPTY);
> > +	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
> > +		page = class->fullness_list[i];
> > +		if (!page)
> > +			continue;
> >  
> > -	return page;
> > +		remove_zspage(page, class, i);
> > +		found = true;
> > +		break;
> > +	}
> > +
> > +	return found ? page : NULL;
> >  }
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
