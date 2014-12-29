Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5E50E6B006E
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 14:33:16 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id k48so7314wev.19
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 11:33:15 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id fz7si74877639wjb.100.2014.12.29.11.33.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 11:33:15 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so22890315wid.15
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 11:33:15 -0800 (PST)
Date: Mon, 29 Dec 2014 20:33:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: get rid of radix tree gfp mask for
 pagecache_get_page (was: Re: How to handle TIF_MEMDIE stalls?)
Message-ID: <20141229193312.GA31288@dhcp22.suse.cz>
References: <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <20141229174030.GD32618@dhcp22.suse.cz>
 <CA+55aFw5uQpHkSWnKy-CKGgg1QQ6-kix+kfqEcQWKXx2bU1q4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw5uQpHkSWnKy-CKGgg1QQ6-kix+kfqEcQWKXx2bU1q4A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <dchinner@redhat.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 29-12-14 10:45:22, Linus Torvalds wrote:
> So I think this patch is definitely going in the right direction, but
> at least the __GFP_WRITE handling is insane:
> 
> (Patch edited to show the resulting code, without the old deleted lines)
> 
> On Mon, Dec 29, 2014 at 9:40 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > @@ -1105,13 +1102,11 @@ no_page:
> >         if (!page && (fgp_flags & FGP_CREAT)) {
> >                 int err;
> >                 if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
> > +                       gfp_mask |= __GFP_WRITE;
> > +               if (fgp_flags & FGP_NOFS)
> > +                       gfp_mask &= ~__GFP_FS;
> >
> > +               page = __page_cache_alloc(gfp_mask);
> >                 if (!page)
> >                         return NULL;
> >
> > @@ -1122,7 +1117,7 @@ no_page:
> >                 if (fgp_flags & FGP_ACCESSED)
> >                         __SetPageReferenced(page);
> >
> > +               err = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
> 
> Passing __GFP_WRITE into the radix tree allocation routines is not
> sane. So you'd have to mask the bit out again here (unconditionally is
> fine).

Good point!
--- 
