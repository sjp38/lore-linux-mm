Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA31B6B0010
	for <linux-mm@kvack.org>; Fri, 25 May 2018 04:16:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f21-v6so2797014wmh.5
        for <linux-mm@kvack.org>; Fri, 25 May 2018 01:16:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m23-v6si889969edd.448.2018.05.25.01.16.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 01:16:25 -0700 (PDT)
Date: Fri, 25 May 2018 10:16:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180525081624.GH11881@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <20180524221715.GY10363@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524221715.GY10363@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Fri 25-05-18 08:17:15, Dave Chinner wrote:
> On Thu, May 24, 2018 at 01:43:41PM +0200, Michal Hocko wrote:
[...]
> > +FS/IO code then simply calls the appropriate save function right at the
> > +layer where a lock taken from the reclaim context (e.g. shrinker) and
> > +the corresponding restore function when the lock is released. All that
> > +ideally along with an explanation what is the reclaim context for easier
> > +maintenance.
> 
> This paragraph doesn't make much sense to me. I think you're trying
> to say that we should call the appropriate save function "before
> locks are taken that a reclaim context (e.g a shrinker) might
> require access to."
> 
> I think it's also worth making a note about recursive/nested
> save/restore stacking, because it's not clear from this description
> that this is allowed and will work as long as inner save/restore
> calls are fully nested inside outer save/restore contexts.

Any better?

-FS/IO code then simply calls the appropriate save function right at the
-layer where a lock taken from the reclaim context (e.g. shrinker) and
-the corresponding restore function when the lock is released. All that
-ideally along with an explanation what is the reclaim context for easier
-maintenance.
+FS/IO code then simply calls the appropriate save function before any
+lock shared with the reclaim context is taken.  The corresponding
+restore function when the lock is released. All that ideally along with
+an explanation what is the reclaim context for easier maintenance.
+
+Please note that the proper pairing of save/restore function allows nesting
+so memalloc_noio_save is safe to be called from an existing NOIO or NOFS scope.
 
 What about __vmalloc(GFP_NOFS)
 ==============================
-- 
Michal Hocko
SUSE Labs
