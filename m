Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 734AA6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 10:40:55 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u64so26729818lff.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 07:40:55 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id xt8si10825326wjc.129.2016.05.18.07.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 07:40:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id C33891C13B8
	for <linux-mm@kvack.org>; Wed, 18 May 2016 15:40:53 +0100 (IST)
Date: Wed, 18 May 2016 15:40:52 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 13/13] mm, compaction: fix and improve watermark handling
Message-ID: <20160518144052.GH2527@techsingularity.net>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-14-git-send-email-vbabka@suse.cz>
 <20160516092505.GE23146@dhcp22.suse.cz>
 <20160518135004.GE2527@techsingularity.net>
 <20160518142753.GJ21654@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160518142753.GJ21654@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, May 18, 2016 at 04:27:53PM +0200, Michal Hocko wrote:
> > > > - __compaction_suitable() then checks the low watermark plus a (2 << order) gap
> > > >   to decide if there's enough free memory to perform compaction. This check
> > > 
> > > And this was a real head scratcher when I started looking into the
> > > compaction recently. Why do we need to be above low watermark to even
> > > start compaction. Compaction uses additional memory only for a short
> > > period of time and then releases the already migrated pages.
> > > 
> > 
> > Simply minimising the risk that compaction would deplete the entire
> > zone. Sure, it hands pages back shortly afterwards. At the time of the
> > initial prototype, page migration was severely broken and the system was
> > constantly crashing. The cautious checks were left in place after page
> > migration was fixed as there wasn't a compelling reason to remove them
> > at the time.
> 
> OK, then moving to min_wmark + bias from low_wmark should work, right?

Yes. I did recall there was another reason but it's marginal. I didn't
want compaction isolation free pages to artifically push a process into
direct reclaim but given that we are likely under memory pressure at
that time anyway, it's unlikely that compaction is the sole reason
processes are entering direct reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
