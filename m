Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 510936B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 20:31:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b9so14655749wrj.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:31:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h16sor5232471wri.89.2018.04.16.17.31.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 17:31:12 -0700 (PDT)
Date: Tue, 17 Apr 2018 03:31:09 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: repeatable boot randomness inside KVM guest
Message-ID: <20180417003109.GA10597@avx2>
References: <20180414195921.GA10437@avx2>
 <20180414224419.GA21830@thunk.org>
 <CAGXu5j+qQE-MmpB7xq6z_SsXm9AhJe2QQAEVQnenYD=iLzJqWQ@mail.gmail.com>
 <CAJcbSZGpqZB2OjqdjoPtoUJrNw9nmms+U=CKvOLLptqjBn=YMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAJcbSZGpqZB2OjqdjoPtoUJrNw9nmms+U=CKvOLLptqjBn=YMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Kees Cook <keescook@chromium.org>, tytso@mit.edu, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Apr 16, 2018 at 04:15:44PM +0000, Thomas Garnier wrote:
> On Mon, Apr 16, 2018 at 8:54 AM Kees Cook <keescook@chromium.org> wrote:
> 
> > On Sat, Apr 14, 2018 at 3:44 PM, Theodore Y. Ts'o <tytso@mit.edu> wrote:
> > > +linux-mm@kvack.org
> > > kvm@vger.kernel.org, security@kernel.org moved to bcc
> > >
> > > On Sat, Apr 14, 2018 at 10:59:21PM +0300, Alexey Dobriyan wrote:
> > >> SLAB allocators got CONFIG_SLAB_FREELIST_RANDOM option which randomizes
> > >> allocation pattern inside a slab:
> > >>
> > >>       int cache_random_seq_create(struct kmem_cache *cachep, unsigned
> int count, gfp_t gfp)
> > >>       {
> > >>               ...
> > >>               /* Get best entropy at this stage of boot */
> > >>               prandom_seed_state(&state, get_random_long());
> > >>
> > >> Then I printed actual random sequences for each kmem cache.
> > >> Turned out they were all the same for most of the caches and
> > >> they didn't vary across guest reboots.
> > >
> > > The problem is at the super-early state of the boot path, kernel code
> > > can't allocate memory.  This is something most device drivers kinda
> > > assume they can do.  :-)
> > >
> > > So it means we haven't yet initialized the virtio-rng driver, and it's
> > > before interrupts have been enabled, so we can't harvest any entropy
> > > from interrupt timing.  So that's why trying to use virtio-rng didn't
> > > help.
> > >
> > >> The only way to get randomness for SLAB is to enable RDRAND inside
> guest.
> > >>
> > >> Is it KVM bug?
> > >
> > > No, it's not a KVM bug.  The fundamental issue is in how the
> > > CONFIG_SLAB_FREELIST_RANDOM is currently implemented.
> 
> Entropy at early boot in VM has always been a problem for this feature or
> others. Did you look at the impact on other boot security features fetching
> random values? Does your VM had RDRAND support (we use get_random_long()
> which will fetch from RDRAND to provide as much entropy as possible at this
> point)?

The problem is that "qemu-system-x86_64" by default doesn't use RDRAND nor
does it use entropy from the host to bootstrap. You need "-cpu host" or
equivalent.

Given that DMI strings are acting as a seed and fixed creation order of
core kernel caches those SLAB randomization sequences may be globally
the same (I didn't check) or draw from a small set.

And of course there will be users which don't use RDRAND because it is
NSA backdoor.
