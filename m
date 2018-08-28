Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 686056B4866
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:03:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so1572306pff.12
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:03:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b1-v6si1993525plc.168.2018.08.28.16.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 16:03:30 -0700 (PDT)
Date: Tue, 28 Aug 2018 16:03:29 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Tagged pointers in the XArray
Message-ID: <20180828230329.GE11400@bombadil.infradead.org>
References: <20180828222727.GD11400@bombadil.infradead.org>
 <fc15502d-8bf3-b7e3-af82-4645dc84e9cd@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fc15502d-8bf3-b7e3-af82-4645dc84e9cd@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Aug 28, 2018 at 03:39:01PM -0700, Randy Dunlap wrote:
> Just a question, please...
> 
> On 08/28/2018 03:27 PM, Matthew Wilcox wrote:
> > 
> > diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> > index c74556ea4258..d1b383f3063f 100644
> > --- a/include/linux/xarray.h
> > +++ b/include/linux/xarray.h
> > @@ -150,6 +150,54 @@ static inline int xa_err(void *entry)
> >  	return 0;
> >  }
> >  
> > +/**
> > + * xa_tag_pointer() - Create an XArray entry for a tagged pointer.
> > + * @p: Plain pointer.
> > + * @tag: Tag value (0, 1 or 3).
> > + *
> 
> What's wrong with a tag value of 2?

That conflicts with the XArray's internal entries and you get a WARN_ON
when you try to store it in the array.

> and what happens when one is used?  [I don't see anything preventing that.]

Right, there's nothing preventing you from using the value 5 or 19
or 16777216 either ... I did put in a WARN_ON_ONCE to begin with, but
decided that was unnecessary.

Right now our only user uses 0 and 1, so even documenting 3 as a
possibility isn't _necessary_, but some day somebody is going to want
to add FILE_NOT_FOUND
https://thedailywtf.com/articles/What_Is_Truth_0x3f_
