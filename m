Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4E136B0279
	for <linux-mm@kvack.org>; Sun, 11 Jun 2017 19:28:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a82so45933285pfc.8
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 16:28:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m132sor4010416pfc.31.2017.06.11.16.28.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Jun 2017 16:28:13 -0700 (PDT)
Date: Sun, 11 Jun 2017 16:28:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Sleeping BUG in khugepaged for i586
In-Reply-To: <20170610080941.GA12347@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706111621330.36347@chino.kir.corp.google.com>
References: <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org> <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz> <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net> <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz> <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz> <20170608170557.GA8118@bombadil.infradead.org> <20170608201822.GA5535@dhcp22.suse.cz> <20170608203046.GB5535@dhcp22.suse.cz> <alpine.DEB.2.10.1706091537020.66176@chino.kir.corp.google.com>
 <20170610080941.GA12347@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, 10 Jun 2017, Michal Hocko wrote:

> > > I would just pull the cond_resched out of __collapse_huge_page_copy
> > > right after pte_unmap. But I am not really sure why this cond_resched is
> > > really needed because the changelog of the patch which adds is is quite
> > > terse on details.
> > 
> > I'm not sure what could possibly be added to the changelog.  We have 
> > encountered need_resched warnings during the iteration.
> 
> Well, the part the changelog is not really clear about is whether the
> HPAGE_PMD_NR loops itself is the source of the stall. This would be
> quite surprising because doing 512 iterations taking up to 20+s sounds
> way to much.

I have no idea where you come up with 20+ seconds.

These are not soft lockups, these are need_resched warnings.  We monitor 
how long need_resched has been set and when a thread takes an excessive 
amount of time to reschedule after it has been set.  A loop of 512 pages 
with ptl contention and doing {clear,copy}_user_highpage() shows that 
need_resched can sit without scheduling for an excessive amount of time.

> So is it possible that we are missing a cond_resched
> somewhere up the __collapse_huge_page_copy call path?

No.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
