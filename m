Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BF7EE6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 12:12:55 -0500 (EST)
Received: by werf1 with SMTP id f1so2936509wer.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 09:12:54 -0800 (PST)
Date: Tue, 20 Dec 2011 18:14:37 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
Message-ID: <20111220171437.GC3883@phenom.ffwll.local>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <201112121648.52126.arnd@arndb.de>
 <CAB2ybb_dU7BzJmPo6vA92pe1YCNerCLc+bv7Qi_EfkfGaik6bQ@mail.gmail.com>
 <201112201541.17904.arnd@arndb.de>
 <CAF6AEGtOjO6Z6yfHz-ZGz3+NuEMH2M-8=20U6+-xt-gv9XtzaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF6AEGtOjO6Z6yfHz-ZGz3+NuEMH2M-8=20U6+-xt-gv9XtzaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, "Semwal, Sumit" <sumit.semwal@ti.com>, Daniel Vetter <daniel@ffwll.ch>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Dec 20, 2011 at 10:41:45AM -0600, Rob Clark wrote:
> On Tue, Dec 20, 2011 at 9:41 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Monday 19 December 2011, Semwal, Sumit wrote:
> >> I didn't see a consensus on whether dma_buf should enforce some form
> >> of serialization within the API - so atleast for v1 of dma-buf, I
> >> propose to 'not' impose a restriction, and we can tackle it (add new
> >> ops or enforce as design?) whenever we see the first need of it - will
> >> that be ok? [I am bending towards the thought that it is a problem to
> >> solve at a bigger platform than dma_buf.]
> >
> > The problem is generally understood for streaming mappings with a
> > single device using it: if you have a long-running mapping, you have
> > to use dma_sync_*. This obviously falls apart if you have multiple
> > devices and no serialization between the accesses.
> >
> > If you don't want serialization, that implies that we cannot have
> > use the  dma_sync_* API on the buffer, which in turn implies that
> > we cannot have streaming mappings. I think that's ok, but then
> > you have to bring back the mmap API on the buffer if you want to
> > allow any driver to provide an mmap function for a shared buffer.
> 
> I'm thinking for a first version, we can get enough mileage out of it by saying:
> 1) only exporter can mmap to userspace
> 2) only importers that do not need CPU access to buffer..
> 
> This way we can get dmabuf into the kernel, maybe even for 3.3.  I
> know there are a lot of interesting potential uses where this stripped
> down version is good enough.  It probably isn't the final version,
> maybe more features are added over time to deal with importers that
> need CPU access to buffer, sync object, etc.  But we have to start
> somewhere.

I agree with Rob here - I think especially for the coherency discussion
some actual users of dma_buf on a bunch of insane platforms (i915
qualifies here too, because we do some cacheline flushing behind everyones
back) would massively help in clarifying things.

It also sounds like that at least for proper userspace mmap support we'd
need some dma api extensions on at least arm, and that might take a while
...

Cheers, Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
