Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id BFA876B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 16:32:39 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so5190480pbc.5
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 13:32:39 -0700 (PDT)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id op6si15601883pbc.158.2014.06.17.13.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 13:32:38 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id rp16so6074587pbb.10
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 13:32:38 -0700 (PDT)
Date: Tue, 17 Jun 2014 13:31:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
In-Reply-To: <CALCETrWCbc=nhK-_+=uwCpUH0ZYWJXLwObVzAQeT20q8STa4Gw@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1406171244440.3599@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <CALCETrVoE+JO2rLsBUHAOJdvescEEjxikj8iQ339Nxfopfc7pw@mail.gmail.com> <CANq1E4SaWLD=hNEc-CDJbNnrGfXE_PkxZFBhpW4tbK7wor7xPA@mail.gmail.com> <CALCETrU8N9EbnJ3=oQ1WQCG9Vunn3nR9Ba=J48wJm0SuH0YB4A@mail.gmail.com>
 <CANq1E4QQUKHabheq18AzkVZk3WDtAeC-6W66tVNB+EKgYOx1Vg@mail.gmail.com> <53A01049.6020502@redhat.com> <CANq1E4T3KJZ++=KF2OZ_dd+NvPqg+=4Pw6O7Po3-ZxaaMHPukw@mail.gmail.com> <CALCETrVpZ0vFM4usHK+tQhk234Y2jWzB1522kGcGvdQQFAqsZQ@mail.gmail.com>
 <CANq1E4QdGz6cRm2Y-vMQHV1O=VK74XNP8qCAmiAskVaVKpJuxg@mail.gmail.com> <CALCETrVerC155vzO-1Js1W8cRTYat0-+OGOxW+kSynJor6rJag@mail.gmail.com> <CANq1E4RqLLk8_Fn=e-c2g29_uiD-R59u=WKF9Tka33L5G9VA9Q@mail.gmail.com>
 <CALCETrWCbc=nhK-_+=uwCpUH0ZYWJXLwObVzAQeT20q8STa4Gw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: David Herrmann <dh.herrmann@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <greg@kroah.com>, Florian Weimer <fweimer@redhat.com>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Kay Sievers <kay@vrfy.org>, John Stultz <john.stultz@linaro.org>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel Mack <zonque@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Tony Battersby <tonyb@cybernetics.com>

On Tue, 17 Jun 2014, Andy Lutomirski wrote:
> On Tue, Jun 17, 2014 at 9:51 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
> > On Tue, Jun 17, 2014 at 6:41 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> >> On Tue, Jun 17, 2014 at 9:36 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
> >>> On Tue, Jun 17, 2014 at 6:20 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> >>>> Can you summarize why holes can't be reliably backed by the zero page?
> >>>
> >>> To answer this, I will quote Hugh from "PATCH v2 1/3":
> >>>
> >>>> We do already use the ZERO_PAGE instead of allocating when it's a
> >>>> simple read; and on the face of it, we could extend that to mmap
> >>>> once the file is sealed.  But I am rather afraid to do so - for
> >>>> many years there was an mmap /dev/zero case which did that, but
> >>>> it was an easily forgotten case which caught us out at least
> >>>> once, so I'm reluctant to reintroduce it now for sealing.
> >>>>
> >>>> Anyway, I don't expect you to resolve the issue of sealed holes:
> >>>> that's very much my territory, to give you support on.
> >>>
> >>> Holes can be avoided with a simple fallocate(). I don't understand why
> >>> I should make SEAL_WRITE do the fallocate for the caller. During the
> >>> discussion of memfd_create() I was told to drop the "size" parameter,
> >>> because it is redundant. I don't see how this implicit fallocate()
> >>> does not fall into the same category?
> >>>
> >>
> >> I'm really confused now.
> >>
> >> If I SEAL_WRITE a file, and then I mmap it PROT_READ, and then I read
> >> it, is that a "simple read"?  If so, doesn't that mean that there's no
> >> problem?
> >
> > I assumed Hugh was talking about read(). So no, this is not about
> > memory-reads on mmap()ed regions.
> >
> > Looking at shmem_file_read_iter() I can see a ZERO_PAGE(0) call in
> > case shmem_getpage_gfp(SGP_READ) tells us there's a hole. I cannot see
> > anything like that in the mmap_region() and shmem_fault() paths.
> 
> Would it be easy to fix this just for SEAL_WRITE files?  Hugh?
> 
> This would make the interface much nicer, IMO.

I do agree with you, Andy.

I agree with David that a fallocate (of the fill-in-holes variety)
does not have to be prohibited on a sealed file, that detection of
holes is not an issue with respect to sealing, and that fallocate
by the recipient could be used to "post-seal" the object to safety.

But it doesn't feel right, and we shall be re-explaining and apologizing
for it for months to come, until we just fix it.  I suspect David didn't
want to add a dependency upon me to fix it, and I didn't want to be
rushed into fixing it (nor is it a job I'd be comfortable to delegate).

I'll give it more thought.  The problem is that there may be a variety
of codepaths, in mm/shmem.c but more seriously outside it, which expect
an appropriate page->mapping and page->index on any page of a shared
mapping, and will be buggily surprised to find a ZERO_PAGE instead.
I'll have to go through carefully.  Splice may be more difficult to
audit than fault, I don't very often have to think about it.

And though I'd prefer to do the same for non-sealed as for sealed, it
may make more sense in the short term just to address the sealed case,
as you suggest.  In the unsealed case, first write to a page entails
locating all the places where the ZERO_PAGE had previously been mapped,
and replacing it there by the newly allocated page; might depend on
VM_NONLINEAR removal, and might entail page_mkwrite().  Doing just
the sealed is easier, though the half-complete job will annoy me.

I did refresh my memory of the /dev/zero case that had particularly
worried me: it was stranger than I'd thought, that reading from
/dev/zero could insert ZERO_PAGEs into mappings of other files.
Nick put an end to that in 2.6.24, but perhaps its prior existence
helps give assurance that ZERO_PAGE in surprising places is less
trouble than I fear (it did force XIP into having its own zero_page,
but I don't remember other complications).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
