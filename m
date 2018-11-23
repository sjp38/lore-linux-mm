Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 605B66B3043
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:49:39 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so5344479eda.12
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 00:49:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e28sor20989593edb.24.2018.11.23.00.49.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 00:49:38 -0800 (PST)
Date: Fri, 23 Nov 2018 09:49:34 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-gfx] [PATCH 1/3] mm: Check if mmu notifier callbacks are
 allowed to fail
Message-ID: <20181123084934.GI4266@phenom.ffwll.local>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
 <154290561362.11623.15299444358726283678@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154290561362.11623.15299444358726283678@skylake-alporthouse-com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Daniel Vetter <daniel.vetter@intel.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>

On Thu, Nov 22, 2018 at 04:53:34PM +0000, Chris Wilson wrote:
> Quoting Daniel Vetter (2018-11-22 16:51:04)
> > Just a bit of paranoia, since if we start pushing this deep into
> > callchains it's hard to spot all places where an mmu notifier
> > implementation might fail when it's not allowed to.
> 
> Most callers could handle the failure correctly. It looks like the
> failure was not propagated for convenience.

I have no idea whether the mm is semantically ok if pte shootdown doesn't
work for all sorts of strange reasons. From the commit that introduced the
error code it souded like this was very much only ok in the limited case
of an already killed process, in the oom killer path, where it's really
only about trying to free any kind of memory. And where the process is
gone already, so semantics of what exactly happens don't matter that much
anymore.

And even if a lot more paths could support some kind of error recovery
(they'd need to restart stuff, at least for your i915 patch to work I
think), as long as we have paths where that's not allowed I think it's
good to catch any bugs where a nonzero errno is errornously returned.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
