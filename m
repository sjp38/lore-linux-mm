Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB9FC6B0069
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 09:15:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so2875600pff.0
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 06:15:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e9si647494plk.690.2017.12.06.06.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 06:15:36 -0800 (PST)
Date: Wed, 6 Dec 2017 06:15:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Get 7% more pages in a pagevec
Message-ID: <20171206141535.GC32044@bombadil.infradead.org>
References: <20171206022521.GM26021@bombadil.infradead.org>
 <20171206123842.GB7515@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206123842.GB7515@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Wed, Dec 06, 2017 at 01:38:42PM +0100, Michal Hocko wrote:
> On Tue 05-12-17 18:25:21, Matthew Wilcox wrote:
> > -/* 14 pointers + two long's align the pagevec structure to a power of two */
> > -#define PAGEVEC_SIZE	14
> > +/* 15 pointers + header align the pagevec structure to a power of two */
> > +#define PAGEVEC_SIZE	15
> 
> And now you have ruined the ultimate constant of the whole MM :p
> But seriously, I have completely missed that pagevec has such a bad
> layout.

It's fun to go back into the historical tree and see why.

First it was two 'int's and an array of 16 pointers.  Marcelo noticed that
was three cachelines instead of two, so he shrank it to two shorts and
an array of 15 pointers:

https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git/commit/include/linux/pagevec.h?id=afead7df5a05118052a238c54285e7119da65831

But then he found out that Pentium 2 and Pentium Pro sucked at 16-bit loads,
so he changed it to two longs and an array of 14 pointers:

https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git/commit/include/linux/pagevec.h?id=6140f8a54db42320b1d05ce2680b5619210b88ad

I wonder what would have happened if he had benchmarked it with 'char'
instead of 'short'.  I think I have a Pentium 2 in the basement somewhere;
perhaps I'll drag it out and fire it up.

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
