Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0546B00B3
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:19:59 -0400 (EDT)
Received: by wesx3 with SMTP id x3so25689802wes.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 13:19:58 -0700 (PDT)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com. [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id dh7si4735280wjc.45.2015.03.13.13.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 13:19:57 -0700 (PDT)
Received: by wevk48 with SMTP id k48so25612366wev.7
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 13:19:57 -0700 (PDT)
Date: Fri, 13 Mar 2015 21:19:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
Message-ID: <20150313201954.GB28848@dhcp22.suse.cz>
References: <1426267597-25811-1-git-send-email-emunson@akamai.com>
 <550332CE.7040404@redhat.com>
 <20150313190915.GA12589@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150313190915.GA12589@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-03-15 15:09:15, Eric B Munson wrote:
> On Fri, 13 Mar 2015, Rik van Riel wrote:
> 
> > On 03/13/2015 01:26 PM, Eric B Munson wrote:
> > 
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
> pages, I left the default to be the behavior as it is today. 

The question is _why_ we have this behavior now. Is it intentional?

e46a28790e59 (CMA: migrate mlocked pages) is a precedence in that
direction. Vlastimil has then changed that by edc2ca612496 (mm,
compaction: move pageblock checks up from isolate_migratepages_range()).
There is no mention about mlock pages so I guess it was more an
unintentional side effect of the patch. At least that is my current
understanding. I might be wrong here.

The thing about RT is that it is not usable with the upstream kernel
without the RT patchset AFAIU. So the default should be reflect what is
better for the standard kernel. RT loads have to tune the system anyway
so it is not so surprising they would disable this option as well. We
should help those guys and do not require them to touch the code but the
knob is reasonable IMHO.

Especially when your changelog suggests that having this enabled by
default is beneficial for the standard kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
