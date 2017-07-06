Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91A9C6B03E4
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 02:47:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so2489942wrc.7
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 23:47:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l50si896676wrc.193.2017.07.05.23.47.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 23:47:39 -0700 (PDT)
Date: Thu, 6 Jul 2017 08:47:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes
 in the stack
Message-ID: <20170706064733.GA29724@dhcp22.suse.cz>
References: <20170705165602.15005-1-mhocko@kernel.org>
 <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
 <20170705182849.GA18027@dhcp22.suse.cz>
 <20170705141849.2e0e4721d975277183eb178f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705141849.2e0e4721d975277183eb178f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed 05-07-17 14:18:49, Andrew Morton wrote:
> On Wed, 5 Jul 2017 20:28:49 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > "mm: enlarge stack guard gap" has introduced a regression in some rust
> > and Java environments which are trying to implement their own stack
> > guard page.  They are punching a new MAP_FIXED mapping inside the
> > existing stack Vma.
> > 
> > This will confuse expand_{downwards,upwards} into thinking that the stack
> > expansion would in fact get us too close to an existing non-stack vma
> > which is a correct behavior wrt. safety. It is a real regression on
> > the other hand. Let's work around the problem by considering PROT_NONE
> > mapping as a part of the stack. This is a gros hack but overflowing to
> > such a mapping would trap anyway an we only can hope that usespace
> > knows what it is doing and handle it propely.
> > 
> > Fixes: d4d2d35e6ef9 ("mm: larger stack guard gap, between vmas")
> 
> That should be 1be7107fbe18, yes?

yes. d4d2d35e6ef9 was a cherry-pick into the mmotm git tree. Sorry about
that.

> > Debugged-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
