Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDEE6B0037
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:02:47 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id y10so10389262wgg.20
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:02:47 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id g16si29914405wjn.140.2014.07.01.17.02.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 17:02:46 -0700 (PDT)
Date: Wed, 2 Jul 2014 02:02:45 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining
 v2
Message-ID: <20140702000245.GM5714@two.firstfloor.org>
References: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
 <20140701152716.b9b4b04ee67cf987844b1aa4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701152716.b9b4b04ee67cf987844b1aa4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1168,6 +1168,16 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
> >  	lock_page(hpage);
> >  
> >  	/*
> > +	 * The page could have changed compound pages during the locking.
> > +	 * If this happens just bail out.
> > +	 */
> > +	if (compound_head(p) != hpage) {
> 
> How can a 4k page change compound pages?  The original compound page
> was torn down and then this 4k page became part of a differently-size
> compound page?

Yes or it was torn down and now it's its own page.

> 
> > +		action_result(pfn, "different compound page after locking", IGNORED);
> > +		res = -EBUSY;
> > +		goto out;
> > +	}
> > +
> > +	/*
> 
> I don't get it.  We just go and fail the poisoning attempt?  Shouldn't
> we go back, grab the new hpage and try again?

It should be quite rare, so I thought this was safest. An retry loop
would be more difficult to test and may have more side effects.

The hwpoison code by design only tries to handle cases that are
reasonably common in workloads, as visible in page-flags.

I'm not really that concerned about handling this (likely rare case),
just not crashing on it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
