Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 06B586B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 12:49:23 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so2330511pab.28
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 09:49:23 -0700 (PDT)
Date: Thu, 28 Mar 2013 12:49:19 -0400
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH v6 1/2] mm: limit growth of 3% hardcoded other user
 reserve
Message-ID: <20130328164919.GA1459@localhost.localdomain>
References: <20130318214442.GA1441@localhost.localdomain>
 <20130327142832.8505be7276064bf4b1daab5c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327142832.8505be7276064bf4b1daab5c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Wed, Mar 27, 2013 at 02:28:32PM -0700, Andrew Morton wrote:
> On Mon, 18 Mar 2013 17:44:42 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:
> 
> > Add user_reserve_kbytes knob.
> > 
> > Limit the growth of the memory reserved for other user
> > processes to min(3% current process size, user_reserve_pages).
> > 
> > user_reserve_pages defaults to min(3% free pages, 128MB)
> 
> That was an epic changelog ;)

I didn't want to err on the side of brevity again :)
But I definitely don't want to be annoying, so I'll work 
on being concise without sacrificing important detail.
 
> >
> > ...
> >
> > +int __meminit init_user_reserve(void)
> > +{
> > +	unsigned long free_kbytes;
> > +
> > +	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
> > +
> > +	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
> > +	return 0;
> > +}
> > +module_init(init_user_reserve)
> 
> Problem is, the initial default values will become wrong if memory if
> hot-added or hot-removed.
> 
> That could be fixed up by appropriate use of
> register_memory_notifier(), but what would the notification handler do
> if the operator has modified the value?  Proportionally scale it?

If the operator changed it to a greater value, then I imagine that would
be because the applications they use to recover require a bigger reserve 
to function. Then proportionally scaling down the value on hot-removal 
might mean that the operator can't recover when they expected to be able 
to. Maybe the best thing would be to leave it be in that case, or 
print a message telling them they need to re-evaluate the reserve size?

I won't be able to look at this again until next week, but I'll work on a 
version that handles hot-addition and hot-removal.

Thanks,

Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
