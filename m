Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 600238299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 19:18:58 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so131225779iec.2
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:18:58 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id kv2si3709429igb.19.2015.03.13.16.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 16:18:57 -0700 (PDT)
Received: by iegc3 with SMTP id c3so134194851ieg.3
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:18:57 -0700 (PDT)
Date: Fri, 13 Mar 2015 16:18:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
In-Reply-To: <20150313190915.GA12589@akamai.com>
Message-ID: <alpine.DEB.2.10.1503131613560.7827@chino.kir.corp.google.com>
References: <1426267597-25811-1-git-send-email-emunson@akamai.com> <550332CE.7040404@redhat.com> <20150313190915.GA12589@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Mar 2015, Eric B Munson wrote:

> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -1046,6 +1046,8 @@ typedef enum {
> > >  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> > >  } isolate_migrate_t;
> > >  
> > > +int sysctl_compact_unevictable;
> > > +
> > >  /*
> > >   * Isolate all pages that can be migrated from the first suitable block,
> > >   * starting at the block pointed to by the migrate scanner pfn within
> > 
> > I suspect that the use cases where users absolutely do not want
> > unevictable pages migrated are special cases, and it may make
> > sense to enable sysctl_compact_unevictable by default.
> 
> Given that sysctl_compact_unevictable=0 is the way the kernel behaves
> now and the push back against always enabling compaction on unevictable
> pages, I left the default to be the behavior as it is today.  I agree
> that this is likely the minority case, but I'd really like Peter Z or
> someone else from real time to say that they are okay with the default
> changing.
> 

It would be really disappointing to not enable this by default for !rt 
kernels.  We haven't migrated mlocked pages in the past by way of memory 
compaction because it can theoretically result in consistent minor page 
faults, but I haven't yet heard a !rt objection to enabling this.

If the rt patchset is going to carry a patch to disable this, then the 
question arises: why not just carry an ISOLATE_UNEVICTABLE patch instead?  
I think you've done the due diligence required to allow this to be 
disabled at any time in a very easy way from userspace by the new tunable.  
I think it should be enabled and I'd be very surprised to hear any other 
objection about it other than it's different from the status quo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
