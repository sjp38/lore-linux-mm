Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2ACA6B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 04:09:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g76so12191392wrd.3
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 01:09:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j22si3385337wre.322.2017.06.10.01.09.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 10 Jun 2017 01:09:45 -0700 (PDT)
Date: Sat, 10 Jun 2017 10:09:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170610080941.GA12347@dhcp22.suse.cz>
References: <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170608170557.GA8118@bombadil.infradead.org>
 <20170608201822.GA5535@dhcp22.suse.cz>
 <20170608203046.GB5535@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706091537020.66176@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706091537020.66176@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 09-06-17 15:38:44, David Rientjes wrote:
> On Thu, 8 Jun 2017, Michal Hocko wrote:
> 
> > I would just pull the cond_resched out of __collapse_huge_page_copy
> > right after pte_unmap. But I am not really sure why this cond_resched is
> > really needed because the changelog of the patch which adds is is quite
> > terse on details.
> 
> I'm not sure what could possibly be added to the changelog.  We have 
> encountered need_resched warnings during the iteration.

Well, the part the changelog is not really clear about is whether the
HPAGE_PMD_NR loops itself is the source of the stall. This would be
quite surprising because doing 512 iterations taking up to 20+s sounds
way to much. So is it possible that we are missing a cond_resched
somewhere up the __collapse_huge_page_copy call path? Or do we really do
something stupidly expensive here?

> We fix these 
> because need_resched warnings suppress future warnings of the same type 
> for issues that are more important.

Sure thing. I do care about soft lockups as well.

> I can fix the i386 issue but removing the cond_resched() entirely isn't 
> really suitable.

I am not calling for a complete removal. I just do not yet see what is
the source of the long processing of the the loop.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
