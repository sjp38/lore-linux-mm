Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8025CC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:36:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38528208CA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:36:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GDzbgDhO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38528208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92C26B0006; Wed, 12 Jun 2019 07:36:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C436A6B0007; Wed, 12 Jun 2019 07:36:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B325D6B0008; Wed, 12 Jun 2019 07:36:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1576B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:36:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a13so11190160pgw.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:36:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MhkB743oojqt0jCijE6DsOt5IqaBpxqgWof9mFxCLr0=;
        b=rou39Aq3lfaFm5N+hKOvu76XVfd5W/zVYfC5FRDYXsrwEPgdX+8Vf/PI1Wy+UL4FTj
         wrjFOVz+hvU8bqhyyvJJbbFQUzGo2SQAph6wPW4SDIoAJ+vchct4Qi+9PZQRe20/epbw
         Y0j8EWAeigjlhnJWcpyzmFpUaXdhzvpOfVRGvZi0WlBZShcanhNGNSgEKc4avSbEaY25
         H8kZKcvgTJff5SeCHRfTdQ4Nj52Nesfz81n7/i+JSHlv6XelUuCJ8BYVTh/MsDFQETCt
         XcJns3mzseE96XNrwCXMuAd/+WEBUv9+tILIwIWNGjRdXe4vkEupeWvp36bzHxDnK+/B
         CG/A==
X-Gm-Message-State: APjAAAUm3wWQQ6UnGhHZ/jv1Y4q9u6IoutGLaUw3IwfKiKsuxSJqFgck
	ilFZHBNzXFpsqQ/43bUQ90L9+VgFTsDuIlM3sKFIqhtDwCJzNFDEKoDIsXnW29Ak0HCOV+R23so
	iCK68TM6TuXEoI3ZyQCIh5aSbtiJIbQxWw3ce+baMEhybU1SR4Y7I/YdDb4yMTWxjJw==
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr79640854pln.226.1560339409166;
        Wed, 12 Jun 2019 04:36:49 -0700 (PDT)
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr79640798pln.226.1560339408376;
        Wed, 12 Jun 2019 04:36:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339408; cv=none;
        d=google.com; s=arc-20160816;
        b=ecTLHucd2IVNBQbqxpvFl9l7TI5jb8OxqwGAdgp/EUdvTuKbr7ZT7LDZZ0rMCv6y11
         SgijaCs/+6Xuh3LwvTN1ILOfHTjYn7wBWR3QubDh+Q9ojt3MJqGoWLIS1aIBbMIM9h66
         T9cMGqDXAi+2lJCKCDtL5WFYYNipbFiYmaYNwbfaJq/4pWl9h8Mmc21+empqqMupQgMW
         l7cSZV+Xde3DNMKn4a+IyNWPVdQ5fUmV6xjUb907XQRr7yCHQy0HRU/phKJYZ0l7hLPe
         DvQ7o9fi2zTrDa8G5cbCx7Aql0MFSS1td9kdTZhwetp2j3UL5KGK5kQ3Fy/tLPX/ldGU
         DOMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MhkB743oojqt0jCijE6DsOt5IqaBpxqgWof9mFxCLr0=;
        b=WdvacKLafiXlnu0pf39WE+1LijjRqingL8nB/6mhjd8D5Y5R13vij3UKntRA3izm0Z
         RTEMHCuMWjNf+6YOrKKIFMlwh8mOTAn/6GSB0U3TYpFy7kLAyJQQngLvzLbBCMBV4Vfj
         GO19s5s9Cej1oxzi3Q+PEO+jOecO0/rgT4dAQKVkA+2dIsrMki4P4pQ4q/OzC6kRpSbs
         alXoWpuxhAA4YkH0mZazXk0SWZwa0ZhmDcPXcHkGnJ/QaKiUDF1Hip8Qn+R12wBXdujP
         HwRN/IeTrOB6n+QWeFFIEYHz3OmPdgCz9YQnVcqFMD0VrGQjRu0wiWFyq6BaqzNVh3lV
         odLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GDzbgDhO;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c138sor16062833pfc.38.2019.06.12.04.36.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:36:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GDzbgDhO;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MhkB743oojqt0jCijE6DsOt5IqaBpxqgWof9mFxCLr0=;
        b=GDzbgDhOafy14R/X43UkUN/+wf8bZdqGlFyPynLyOoG20vlQgN7zE9jZaanLyn3zx5
         qQhhso2gb34OxP/u3xHSg6zS8JjJRY1rM9k4rX+82IiHVqiDxz7X2a893Yf4graw7TMN
         nSUF/2Gtu0ZiA9FjJgluVZwCMm/sY7nIvA/8cwZyNRO0pWttZ9rn4SJm4NDG5Og1LJ7q
         69ebVQ9hxBQQPUib1nigJuccodsU3NmYrSrnehuErfe4YWQQvRoySvoE3IbFgIm+u5mm
         oszynkP2bKoPt4/Zv/VgvQYlSIXKjNdvA3RFAgK5OHTEZyvWErx96s2gVUjdKfd7KRLc
         uonQ==
X-Google-Smtp-Source: APXvYqzGzjPmF8qGtciCMiJ8cvvmFlnWp+2d9nBudQ86r37IgxuDA/rPCLSSJ3M+cA0egqf1SPnYkN9tXts/BubXkpo=
X-Received: by 2002:aa7:97bb:: with SMTP id d27mr18575219pfq.93.1560339407628;
 Wed, 12 Jun 2019 04:36:47 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <51f44a12c4e81c9edea8dcd268f820f5d1fad87c.1559580831.git.andreyknvl@google.com>
 <201906072101.58C919E@keescook> <CAAeHK+y8CH4P3vheUDCEnPAuO-2L6mc-sz6wMA_hT=wC1Cy3KQ@mail.gmail.com>
In-Reply-To: <CAAeHK+y8CH4P3vheUDCEnPAuO-2L6mc-sz6wMA_hT=wC1Cy3KQ@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 12 Jun 2019 13:36:36 +0200
Message-ID: <CAAeHK+xCmc-x=Mvs8RC+xJOCw6AnEUgUzXXjjS3NJXeLwJkyqg@mail.gmail.com>
Subject: Re: [PATCH v16 08/16] fs, arm64: untag user pointers in copy_mount_options
To: Kees Cook <keescook@chromium.org>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:38 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> On Sat, Jun 8, 2019 at 6:02 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Mon, Jun 03, 2019 at 06:55:10PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > In copy_mount_options a user address is being subtracted from TASK_SIZE.
> > > If the address is lower than TASK_SIZE, the size is calculated to not
> > > allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> > > However if the address is tagged, then the size will be calculated
> > > incorrectly.
> > >
> > > Untag the address before subtracting.
> > >
> > > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >
> > One thing I just noticed in the commit titles... "arm64" is in the
> > prefix, but these are arch-indep areas. Should the ", arm64" be left
> > out?
> >
> > I would expect, instead:
> >
> >         fs/namespace: untag user pointers in copy_mount_options
>
> Hm, I've added the arm64 tag in all of the patches because they are
> related to changes in arm64 kernel ABI. I can remove it from all the
> patches that only touch common code if you think that it makes sense.

I'll keep the arm64 tags in commit titles for v17. Please reply
explicitly if you think I should remove them. Thanks! :)

>
> Thanks!
>
> >
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> >
> > -Kees
> >
> > > ---
> > >  fs/namespace.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > >
> > > diff --git a/fs/namespace.c b/fs/namespace.c
> > > index b26778bdc236..2e85712a19ed 100644
> > > --- a/fs/namespace.c
> > > +++ b/fs/namespace.c
> > > @@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data)
> > >        * the remainder of the page.
> > >        */
> > >       /* copy_from_user cannot cross TASK_SIZE ! */
> > > -     size = TASK_SIZE - (unsigned long)data;
> > > +     size = TASK_SIZE - (unsigned long)untagged_addr(data);
> > >       if (size > PAGE_SIZE)
> > >               size = PAGE_SIZE;
> > >
> > > --
> > > 2.22.0.rc1.311.g5d7573a151-goog
> > >
> >
> > --
> > Kees Cook

