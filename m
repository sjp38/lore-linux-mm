Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37B668E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 19:03:59 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o9so27916439pgv.19
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 16:03:59 -0800 (PST)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id c4si16409938pfi.110.2019.01.02.16.03.57
        for <linux-mm@kvack.org>;
        Wed, 02 Jan 2019 16:03:58 -0800 (PST)
Date: Thu, 3 Jan 2019 11:03:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [BUG, TOT] xfs w/ dax failure in __follow_pte_pmd()
Message-ID: <20190103000354.GM4205@dastard>
References: <20190102211332.GL4205@dastard>
 <20190102212531.GK6310@bombadil.infradead.org>
 <20190102225005.GL6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102225005.GL6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, akpm@linux-foundation.org

On Wed, Jan 02, 2019 at 02:50:05PM -0800, Matthew Wilcox wrote:
> On Wed, Jan 02, 2019 at 01:25:31PM -0800, Matthew Wilcox wrote:
> > On Thu, Jan 03, 2019 at 08:13:32AM +1100, Dave Chinner wrote:
> > > Hi folks,
> > > 
> > > An overnight test run on a current TOT kernel failed generic/413
> > > with the following dmesg output:
> > > 
> > > [ 9487.276402] RIP: 0010:__follow_pte_pmd+0x22d/0x340
> > > [ 9487.305065] Call Trace:
> > > [ 9487.307310]  dax_entry_mkclean+0xbb/0x1f0
> > 
> > We've only got one commit touching dax_entry_mkclean and it's Jerome's.
> > Looking through ac46d4f3c43241ffa23d5bf36153a0830c0e02cc, I'd say
> > it's missing a call to mmu_notifier_range_init().
> 
> Could I persuade you to give this a try?

Yup, that fixes it.

And looking at the code, the dax mmu notifier code clearly wasn't
tested. i.e. dax_entry_mkclean() is the *only* code that exercises
the conditional range parameter code paths inside
__follow_pte_pmd().  This means it wasn't tested before it was
proposed for inclusion and since inclusion no-one using -akpm,
linux-next or the current mainline TOT has done any filesystem DAX
testing until I tripped over it.

IOws, this is the second "this was never tested before it was merged
into mainline" XFS regression that I've found in the last 3 weeks.
Both commits have been merged through the -akpm tree, and that
implies we currently have no significant filesystem QA coverage on
changes being merged through this route. This seems like an area
that needs significant improvement to me....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
