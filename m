Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 429176B026E
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:54:18 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 31-v6so7813627plf.19
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:54:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15-v6si88684plq.180.2018.05.28.08.54.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:54:17 -0700 (PDT)
Date: Mon, 28 May 2018 11:21:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180528092138.GI1517@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <20180524221715.GY10363@dastard>
 <20180525081624.GH11881@dhcp22.suse.cz>
 <20180527124721.GA4522@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180527124721.GA4522@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Sun 27-05-18 15:47:22, Mike Rapoport wrote:
> On Fri, May 25, 2018 at 10:16:24AM +0200, Michal Hocko wrote:
> > On Fri 25-05-18 08:17:15, Dave Chinner wrote:
> > > On Thu, May 24, 2018 at 01:43:41PM +0200, Michal Hocko wrote:
> > [...]
> > > > +FS/IO code then simply calls the appropriate save function right at the
> > > > +layer where a lock taken from the reclaim context (e.g. shrinker) and
> > > > +the corresponding restore function when the lock is released. All that
> > > > +ideally along with an explanation what is the reclaim context for easier
> > > > +maintenance.
> > > 
> > > This paragraph doesn't make much sense to me. I think you're trying
> > > to say that we should call the appropriate save function "before
> > > locks are taken that a reclaim context (e.g a shrinker) might
> > > require access to."
> > > 
> > > I think it's also worth making a note about recursive/nested
> > > save/restore stacking, because it's not clear from this description
> > > that this is allowed and will work as long as inner save/restore
> > > calls are fully nested inside outer save/restore contexts.
> > 
> > Any better?
> > 
> > -FS/IO code then simply calls the appropriate save function right at the
> > -layer where a lock taken from the reclaim context (e.g. shrinker) and
> > -the corresponding restore function when the lock is released. All that
> > -ideally along with an explanation what is the reclaim context for easier
> > -maintenance.
> > +FS/IO code then simply calls the appropriate save function before any
> > +lock shared with the reclaim context is taken.  The corresponding
> > +restore function when the lock is released. All that ideally along with
> 
> Maybe: "The corresponding restore function is called when the lock is
> released"

This will get rewritten some more based on comments from Dave
 
> > +an explanation what is the reclaim context for easier maintenance.
> > +
> > +Please note that the proper pairing of save/restore function allows nesting
> > +so memalloc_noio_save is safe to be called from an existing NOIO or NOFS scope.
>  
> so it is safe to call memalloc_noio_save from an existing NOIO or NOFS
> scope

Here is what I have right now on top

diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
index c0ec212d6773..0cff411693ab 100644
--- a/Documentation/core-api/gfp_mask-from-fs-io.rst
+++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
@@ -34,12 +34,15 @@ scope will inherently drop __GFP_FS respectively __GFP_IO from the given
 mask so no memory allocation can recurse back in the FS/IO.
 
 FS/IO code then simply calls the appropriate save function before any
-lock shared with the reclaim context is taken.  The corresponding
-restore function when the lock is released. All that ideally along with
-an explanation what is the reclaim context for easier maintenance.
-
-Please note that the proper pairing of save/restore function allows nesting
-so memalloc_noio_save is safe to be called from an existing NOIO or NOFS scope.
+critical section wrt. the reclaim is started - e.g. lock shared with the
+reclaim context or when a transaction context nesting would be possible
+via reclaim. The corresponding restore function when the critical
+section ends. All that ideally along with an explanation what is
+the reclaim context for easier maintenance.
+
+Please note that the proper pairing of save/restore function allows
+nesting so it is safe to call ``memalloc_noio_save`` respectively
+``memalloc_noio_restore`` from an existing NOIO or NOFS scope.
 
 What about __vmalloc(GFP_NOFS)
 ==============================

-- 
Michal Hocko
SUSE Labs
