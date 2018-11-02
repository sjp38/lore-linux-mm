Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19DCC6B0007
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 09:22:59 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r68-v6so1223265oie.12
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 06:22:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7-v6sor2263643oit.116.2018.11.02.06.22.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 06:22:58 -0700 (PDT)
MIME-Version: 1.0
References: <20181031081945.207709-1-vovoy@chromium.org> <039b2768-39ff-6196-9615-1f0302ee3e0e@intel.com>
 <CAEHM+4q7V3d+EiHR6+TKoJC=6Ga0eCLWik0oJgDRQCpWps=wMA@mail.gmail.com> <80347465-38fd-54d3-facf-bcd6bf38228a@intel.com>
In-Reply-To: <80347465-38fd-54d3-facf-bcd6bf38228a@intel.com>
From: Vovo Yang <vovoy@chromium.org>
Date: Fri, 2 Nov 2018 21:22:46 +0800
Message-ID: <CAEHM+4rsV9G_cahOyyH8njOYyZc5C9b0a6CV4AH_Y7EubXBLAQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 1, 2018 at 10:30 PM Dave Hansen <dave.hansen@intel.com> wrote:
> On 11/1/18 5:06 AM, Vovo Yang wrote:
> >> mlock() and ramfs usage are pretty easy to track down.  /proc/$pid/smaps
> >> or /proc/meminfo can show us mlock() and good ol' 'df' and friends can
> >> show us ramfs the extent of pinned memory.
> >>
> >> With these, if we see "Unevictable" in meminfo bump up, we at least have
> >> a starting point to find the cause.
> >>
> >> Do we have an equivalent for i915?

Chris helped to answer this question:
Though it includes a few non-shmemfs objects, see
debugfs/dri/0/i915_gem_objects and the "bound objects".

Example i915_gem_object output:
  591 objects, 95449088 bytes
  55 unbound objects, 1880064 bytes
  533 bound objects, 93040640 bytes
  ...

> > AFAIK, there is no way to get i915 unevictable page count, some
> > modification to i915 debugfs is required.
>
> Is something like this feasible to add to this patch set before it gets
> merged?  For now, it's probably easy to tell if i915 is at fault because
> if the unevictable memory isn't from mlock or ramfs, it must be i915.
>
> But, if we leave it as-is, it'll just defer the issue to the fourth user
> of the unevictable list, who will have to come back and add some
> debugging for this.
>
> Seems prudent to just do it now.
