Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5955A6B00F3
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:01:16 -0400 (EDT)
Date: Thu, 10 May 2012 17:00:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned
 buffers
Message-ID: <20120510150058.GC8588@quack.suse.cz>
References: <20120502091837.GC16976@quack.suse.cz>
 <CAHGf_=qfuRZzb91ELEcArNaNHsfO4BBMPO8a-QRBzFNaT2ev_w@mail.gmail.com>
 <20120502192325.GA18339@quack.suse.cz>
 <CAHGf_=oOx1qPFEboQeuaeMKtveM2==BSDG=xdfRHz+gFx1GAfw@mail.gmail.com>
 <CAKgNAkjybL_hmVfONUHtCbBe_VxQHNHOrmWQErGWDUqHiczkFg@mail.gmail.com>
 <CAHGf_=p4py5m1Pe1xon=9FcEEyf6AxW+Pc9Yy9gCvNtbXM_40A@mail.gmail.com>
 <CAPa8GCCh-RrjsQKzh9+Sxx-joRZw4qkpxR9n4svo+QopxAj_XQ@mail.gmail.com>
 <CAKgNAkh5TkwSzFVKVo5JUvkDWkzY8EaQNxJSQnv3fTHTdj0+FQ@mail.gmail.com>
 <CAPa8GCCaGQdOZoWCCLBLNtOV5_VS+sNvdC_PzrWauF0gSyizYg@mail.gmail.com>
 <CAKgNAkjLGqMyaeZsDpLUW+re2ViYcpVKOoh33vEJn5keBNLVXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKgNAkjLGqMyaeZsDpLUW+re2ViYcpVKOoh33vEJn5keBNLVXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Nick Piggin <npiggin@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

On Wed 09-05-12 19:18:16, Michael Kerrisk (man-pages) wrote:
> On Wed, May 9, 2012 at 7:01 PM, Nick Piggin <npiggin@gmail.com> wrote:
> > On 9 May 2012 15:35, Michael Kerrisk (man-pages) <mtk.manpages@gmail.com> wrote:
> >> On Wed, May 9, 2012 at 11:10 AM, Nick Piggin <npiggin@gmail.com> wrote:
> >>> On 6 May 2012 01:29, KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
> >>>>> So, am I correct to assume that right text to add to the page is as below?
> >>>>>
> >>>>> Nick, can you clarify what you mean by "quiesced"?
> >>>>
> >>>> finished?
> >>>
> >>> Yes exactly. That might be a simpler word. Thanks!
> >>
> >> Thanks.
> >>
> >> But see below. I realize the text is still ambiguous.
> >>
> >>>>> [[
> >>>>> O_DIRECT IOs should never be run concurrently with fork(2) system call,
> >>>>> when the memory buffer is anonymous memory, or comes from mmap(2)
> >>>>> with MAP_PRIVATE.
> >>>>>
> >>>>> Any such IOs, whether submitted with asynchronous IO interface or from
> >>>>> another thread in the process, should be quiesced before fork(2) is called.
> >>>>> Failure to do so can result in data corruption and undefined behavior in
> >>>>> parent and child processes.
> >>>>>
> >>>>> This restriction does not apply when the memory buffer for the O_DIRECT
> >>>>> IOs comes from mmap(2) with MAP_SHARED or from shmat(2).
> >>>>> Nor does this restriction apply when the memory buffer has been advised
> >>>>> as MADV_DONTFORK with madvise(2), ensuring that it will not be available
> >>>>> to the child after fork(2).
> >>>>> ]]
> >>
> >> In the above, the status of a MAP_SHARED MAP_ANONYMOUS buffer is
> >> unclear. The first paragraph implies that such a buffer is unsafe,
> >> while the third paragraph implies that it *is* safe, thus
> >> contradicting the first paragraph. Which is correct?
> >
> > Yes I see. It's because MAP_SHARED | MAP_ANONYMOUS isn't *really*
> > anonymous from the virtual memory subsystem's point of view. But that
> > just serves to confuse userspace I guess.
> >
> > Anything with MAP_SHARED, shmat, or MADV_DONTFORK is OK.
> >
> > Anything else (MAP_PRIVATE, brk, without MADV_DONTFORK) is
> > dangerous. These type are used by standard heap allocators malloc,
> > new, etc.
> 
> So, would the following text be okay:
> 
>        O_DIRECT I/Os should never be run concurrently with the fork(2)
>        system call, if the memory buffer is a private  mapping  (i.e.,
>        any  mapping  created  with  the mmap(2) MAP_PRIVATE flag; this
>        includes memory allocated on the heap and statically  allocated
>        buffers).  Any such I/Os, whether submitted via an asynchronous
>        I/O interface or from another thread in the process, should  be
>        completed  before  fork(2)  is  called.   Failure  to do so can
>        result in data corruption and undefined behavior in parent  and
>        child processes.  This restriction does not apply when the mema??
>        ory buffer for the O_DIRECT I/Os was created using shmat(2)  or
>        mmap(2)  with  the  MAP_SHARED flag.  Nor does this restriction
>        apply when the memory buffer has been advised as  MADV_DONTFORK
>        with  madvise(2), ensuring that it will not be available to the
>        child after fork(2).
  This text looks OK, to me. Thanks for putting it together.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
