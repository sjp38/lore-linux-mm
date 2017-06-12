Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 450726B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 02:29:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c52so20799666wra.12
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 23:29:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b29si8994673wrb.144.2017.06.11.23.29.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Jun 2017 23:29:21 -0700 (PDT)
Date: Mon, 12 Jun 2017 08:29:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170612062918.GA4145@dhcp22.suse.cz>
References: <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170608170557.GA8118@bombadil.infradead.org>
 <20170608201822.GA5535@dhcp22.suse.cz>
 <20170608203046.GB5535@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706091537020.66176@chino.kir.corp.google.com>
 <20170610080941.GA12347@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706111621330.36347@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706111621330.36347@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun 11-06-17 16:28:11, David Rientjes wrote:
> On Sat, 10 Jun 2017, Michal Hocko wrote:
> 
> > > > I would just pull the cond_resched out of __collapse_huge_page_copy
> > > > right after pte_unmap. But I am not really sure why this cond_resched is
> > > > really needed because the changelog of the patch which adds is is quite
> > > > terse on details.
> > > 
> > > I'm not sure what could possibly be added to the changelog.  We have 
> > > encountered need_resched warnings during the iteration.
> > 
> > Well, the part the changelog is not really clear about is whether the
> > HPAGE_PMD_NR loops itself is the source of the stall. This would be
> > quite surprising because doing 512 iterations taking up to 20+s sounds
> > way to much.
> 
> I have no idea where you come up with 20+ seconds.

OK, I misread your report as a soft lockup.

> These are not soft lockups, these are need_resched warnings.  We monitor 
> how long need_resched has been set and when a thread takes an excessive 
> amount of time to reschedule after it has been set.  A loop of 512 pages 
> with ptl contention and doing {clear,copy}_user_highpage() shows that 
> need_resched can sit without scheduling for an excessive amount of time.

How much is excessive here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
