Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 69E4F6B006C
	for <linux-mm@kvack.org>; Thu,  7 May 2015 11:11:41 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so29327678qkg.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 08:11:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i60si2296120qgf.41.2015.05.07.08.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 08:11:40 -0700 (PDT)
Date: Thu, 7 May 2015 17:11:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
Message-ID: <20150507151136.GH13098@redhat.com>
References: <5509D342.7000403@parallels.com>
 <20150421120222.GC4481@redhat.com>
 <55389261.50105@parallels.com>
 <20150427211650.GC24035@redhat.com>
 <55425A74.3020604@parallels.com>
 <20150507134236.GB13098@redhat.com>
 <554B769E.1040000@parallels.com>
 <20150507143343.GG13098@redhat.com>
 <554B79C0.5060807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <554B79C0.5060807@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>

On Thu, May 07, 2015 at 05:42:08PM +0300, Pavel Emelyanov wrote:
> On 05/07/2015 05:33 PM, Andrea Arcangeli wrote:
> > On Thu, May 07, 2015 at 05:28:46PM +0300, Pavel Emelyanov wrote:
> >> Yup, this is very close to what I did in my set -- introduced a message to
> >> report back to the user-space on read. But my message is more than 8+2*1 bytes,
> >> so we'll have one message for 0xAA API and another one for 0xAB (new) one :)
> > 
> > I slightly altered it to fix an issue with packet alignments so it'd
> > be 16bytes.
> > 
> > How big is your msg currently? Could we get to use the same API?
> 
> Right now it's like this
> 
> struct uffd_event {
>         __u64 type;
>         union {
>                 struct {
>                         __u64 addr;
>                 } pagefault;
> 
>                 struct {
>                         __u32 ufd;
>                 } fork;
> 
>                 struct {
>                         __u64 from;
>                         __u64 to;
>                         __u64 len;
>                 } remap;
>         } arg;
> };
> 
> where .type is your uffd_msg.event and the rest is event-specific.

So you have two more __u64.

In theory if msg.event == UFFD_EVENT_MREMAP you could have the "from"
encoded in the msg.arg and then userland could read 16 more bytes
knowing it'll get "to len" and we won't have to alter the UFFD_API for
adding new EVENT that requires bigger msg size. But it's probably not
worth it as an enter/exit kernel is way more costly than reading
16 more bytes, if we already know we need 32bytes in the end.

MADV_DONTNEED shouldn't need more bytes than mremap either.

I think it's ok if I enlarge it to 32bytes.

> 
> > UFFDIO_REGISTER_MODE_FORK
> > 
> > or 
> > 
> > UFFDIO_REGISTER_MODE_NON_COOPERATIVE would differentiate if you want
> > to register for fork/mremap/dontneed events as well or only the
> > default (UFFD_EVENT_PAGEFAULT).
> 
> I planned to use this in UFFDIO_API call -- the uffdio_api.features will
> be in-out argument denoting the bits user needs and reporting what kernel
> can.

Ok I guess in-out and checking api.features is easier than checking
the vma during the fault. That's ok for me, plus if needed the
registration flag can still be added later in addition of the in-out
api.features.

So I also need to error out the UFFDIO_API call if api.features is not
zero, ok?

After those two changes you should be ok with the same API?

We may still need a new API later of course, it's hard to predict the
future and all possible future usages of the userfaultfd... but
perhaps this will be enough...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
