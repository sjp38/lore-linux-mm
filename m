Date: Wed, 22 Mar 2000 22:58:58 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Q. about swap-cache orphans
Message-ID: <20000322225858.K2850@redhat.com>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org> <20000322223351.G2850@redhat.com> <20000322234531.C31795@pcep-jamie.cern.ch> <20000322224818.J2850@redhat.com> <20000322235545.F31795@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322235545.F31795@pcep-jamie.cern.ch>; from jamie.lokier@cern.ch on Wed, Mar 22, 2000 at 11:55:45PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 22, 2000 at 11:55:45PM +0100, Jamie Lokier wrote:
> [This is just a question to help my understanding, not relevant to madvise]
> 
> Stephen C. Tweedie wrote:
> > If it is the last user of the page --- ie. if PG_SwapCache is set and
> > the refcount of the page is one --- then it will do so anyway, because
> > when I added that swap cache code I made sure that zap_page_range()
> > does a free_page_and_swap_cache() when freeing pages.
> 
> I.e., zap_page_range makes sure that MADV_DONTNEED won't leave orphan
> swap-cache pages.

Not quite, but very nearly.  There are a few minor places where the 
refcount on a page is bumped up temporarily, so zap_page_range is
theoretically able to be confused into thinking that there are extra
references, and that the swap cache should remain.  However, that is
still correct behaviour, because the shrink_mmap() code will seek and
destroy the remaining swap cache references if that happens.

> > The shrink_mmap() page cache reclaimer is able to pick up any orphaned 
> > swap cache pages.
> 
> But there won't be any orphans, will there?
> Or do they appear due to async. swapping situations?

Yes, but it's harmless.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
