Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24B136B0010
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:32:36 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id l204-v6so14231664oia.17
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:32:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5-v6sor6793659otl.147.2018.10.15.15.32.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 15:32:35 -0700 (PDT)
MIME-Version: 1.0
References: <153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153922180696.838512.12621709717839260874.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGXu5j+PStxYhiJaWM-mt4+WWbS_WAfvyHoyZYD5ndDLN2SY6w@mail.gmail.com>
In-Reply-To: <CAGXu5j+PStxYhiJaWM-mt4+WWbS_WAfvyHoyZYD5ndDLN2SY6w@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 15 Oct 2018 15:32:23 -0700
Message-ID: <CAPcyv4jQ2A7cDJ65+wzR=O3aabuh8p_yu9VNbpRF0A3QLUdGpA@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] mm: Shuffle initial free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Oct 15, 2018 at 3:25 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Oct 10, 2018 at 6:36 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> > caches it leaves vast bulk of memory to be predictably in order
> > allocated. That ordering can be detected by a memory side-cache.
> >
> > The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> > pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> > 10, 4MB this trades off randomization granularity for time spent
> > shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
> > allocator while still showing memory-side cache behavior improvements,
> > and the expectation that the security implications of finer granularity
> > randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.
>
> Perhaps it would help some of the detractors of this feature to make
> this a runtime choice? Some benchmarks show improvements, some show
> regressions. It could just be up to the admin to turn this on/off
> given their paranoia levels? (i.e. the shuffling could become a no-op
> with a given specific boot param?)

Yes, I think it's a valid concern to not turn this on for everybody
given the potential for performance regression. For the next version
I'll add some runtime detection for a memory-side-cache to set the
default on/off, and include a command line override for the paranoid
that want in on regardless of the presence of such a cache.
