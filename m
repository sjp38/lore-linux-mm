Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03F4B6B0003
	for <linux-mm@kvack.org>; Sun, 27 May 2018 08:47:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f188-v6so6552211wme.2
        for <linux-mm@kvack.org>; Sun, 27 May 2018 05:47:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j9-v6si8470544wra.424.2018.05.27.05.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 05:47:32 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4RChjQx071898
	for <linux-mm@kvack.org>; Sun, 27 May 2018 08:47:31 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2j7mg3mpp3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 27 May 2018 08:47:30 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 27 May 2018 13:47:29 +0100
Date: Sun, 27 May 2018 15:47:22 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <20180524221715.GY10363@dastard>
 <20180525081624.GH11881@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525081624.GH11881@dhcp22.suse.cz>
Message-Id: <20180527124721.GA4522@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Fri, May 25, 2018 at 10:16:24AM +0200, Michal Hocko wrote:
> On Fri 25-05-18 08:17:15, Dave Chinner wrote:
> > On Thu, May 24, 2018 at 01:43:41PM +0200, Michal Hocko wrote:
> [...]
> > > +FS/IO code then simply calls the appropriate save function right at the
> > > +layer where a lock taken from the reclaim context (e.g. shrinker) and
> > > +the corresponding restore function when the lock is released. All that
> > > +ideally along with an explanation what is the reclaim context for easier
> > > +maintenance.
> > 
> > This paragraph doesn't make much sense to me. I think you're trying
> > to say that we should call the appropriate save function "before
> > locks are taken that a reclaim context (e.g a shrinker) might
> > require access to."
> > 
> > I think it's also worth making a note about recursive/nested
> > save/restore stacking, because it's not clear from this description
> > that this is allowed and will work as long as inner save/restore
> > calls are fully nested inside outer save/restore contexts.
> 
> Any better?
> 
> -FS/IO code then simply calls the appropriate save function right at the
> -layer where a lock taken from the reclaim context (e.g. shrinker) and
> -the corresponding restore function when the lock is released. All that
> -ideally along with an explanation what is the reclaim context for easier
> -maintenance.
> +FS/IO code then simply calls the appropriate save function before any
> +lock shared with the reclaim context is taken.  The corresponding
> +restore function when the lock is released. All that ideally along with

Maybe: "The corresponding restore function is called when the lock is
released"

> +an explanation what is the reclaim context for easier maintenance.
> +
> +Please note that the proper pairing of save/restore function allows nesting
> +so memalloc_noio_save is safe to be called from an existing NOIO or NOFS scope.
 
so it is safe to call memalloc_noio_save from an existing NOIO or NOFS
scope

>  What about __vmalloc(GFP_NOFS)
>  ==============================
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
