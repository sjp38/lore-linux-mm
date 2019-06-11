Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49FA3C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:38:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1141720896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:38:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vFVLFZFy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1141720896
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D9CF6B0007; Tue, 11 Jun 2019 10:38:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B20C6B0008; Tue, 11 Jun 2019 10:38:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AB416B000A; Tue, 11 Jun 2019 10:38:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52A1F6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:38:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d3so6337932pgc.9
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:38:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+Bb9evtnnpvJpDG7+k/xfmfwlxE7BAZZaECd7yQ/bgY=;
        b=Y01ZcUfQYqZ83t3ZfNY44pSvL0nb5795WZNJdIC9k8Xlcp+QD1kpflx5/9gO9qsKNY
         7YOkpCiJDTEF+6LrlYEtP9CxQvV6NWde2mDwJoIfpIWulcZeFzFmDNMgYKRkE7FkqoZ7
         HyvEt8xiX/NY/USojMgCnnYKyc1eHvqee7/BEINlm+Yoek4OTnsuMeHNNV1sR6LNkBtp
         zjw8LYAI/uqJDqxMHgFwibmew2WHemso1VSqy42eFADoswdO8l2EBgyjdm/Sha0eCroj
         nWh9Z1gedCWpi/BU6YFr6hbVowJu/JFBBNW6ctGNArymSLGOxcCT4t+nwYyIjRORNW2P
         SGyQ==
X-Gm-Message-State: APjAAAVS9kZ+h5OBNtIuntwt6JOfUBctUy+cTIE8JaoGQrRSGuDlsbmz
	xZizPBkTEtJjv9JNhUgP7zK0Cq6VsEuN8bHxAV0XO9J8SbeYpL2V8RyJYx5yjhTY8dfE142IWFF
	2BoArOCw6KGMbh4UwXOcishC3A6Ld57uJSDB7MWCUVTW0qM45EPuKsugMoGk8ZOeOFg==
X-Received: by 2002:a63:5462:: with SMTP id e34mr19394181pgm.400.1560263917724;
        Tue, 11 Jun 2019 07:38:37 -0700 (PDT)
X-Received: by 2002:a63:5462:: with SMTP id e34mr19394125pgm.400.1560263916624;
        Tue, 11 Jun 2019 07:38:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560263916; cv=none;
        d=google.com; s=arc-20160816;
        b=ol/8Tt3NXZVKq65LobenWnBJfJxL5wFFqA2iiN2E8mslCf+iSsBOphIZuvcNUJT5Eb
         loRd3H6XeX7OqCwplHXb/wAAJbJAWUtKdeYhFvvVcJiJ1DT4d0Y2Hu2cBnjhyO9LmtHE
         hs9nveIESCT684ZGATuJR/4uMuQfv3Gxi0vtSgmCGC/pkBwYcPLont/lDRBTg8Up7/tf
         M1aW5is/lkbRoAC8PE3+7Y6Mzm4307cgkVmggrNvWbUamiGdGks8n8csvt17Rj4Cf6lb
         JRccbPUdmVaLoz07/T8VTAMyNq3QiW9Ai44Ct1vH9jjoU/7tgtBpHh1r2eTvKiNt005z
         QzMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+Bb9evtnnpvJpDG7+k/xfmfwlxE7BAZZaECd7yQ/bgY=;
        b=NOE5s5RpzW9zuIRV0SmVgcwSF1RmoCXIheUB8RXvlXgk/jIoKsdljsPL/S/epeN1lP
         SdsRSA3kPSKGbb5Xo2taTSn80wmeRvVks8USQX2nRXyjYg6oZZAvAFKAxE3nSLskabTx
         6KyTvwJ7m1cRtHa62Fy1J07QT8HI8NnkXHcH2I1G/yRTNkdkie131SM51yUTsKBIwgLn
         cEofHWME3SeOEhzhGWPlzczfQOkLvdmrApN4PwDuJYmiX88b8WBASl39cgw+bw2gq3uc
         mYPdryhC0dv1fnv/av2HMDAUW5/i91CfJNo7z/0XFi8iVucuAEx+E+CKBXadKpbUSoWF
         xfpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vFVLFZFy;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m32sor15366925pld.47.2019.06.11.07.38.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 07:38:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vFVLFZFy;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+Bb9evtnnpvJpDG7+k/xfmfwlxE7BAZZaECd7yQ/bgY=;
        b=vFVLFZFyIF01TbjN+xeeME15qV8KkCRDccJHkbwPJnzYqntxAPPejl4UucLg68kkqb
         BaObH7iQP83sFpaN8IH2/Yu4t4nwUDbwn3rb15fIHqVU7geywA3LRxp1p4GflSM3qTjJ
         iWM19kJHA7FmF25W9uFiY1kMJbcO4WOESGJU61YywCA+i6Ylfs/3WF6YNj5xaMoYJ89L
         XqlvBDrbDKlYUJNKkeiCJcKNhxFQvdK51GyYrA4cNM42eSbHTJc/2qrnnTIYWyQugg14
         drUy2FSlkxzvJpoh5mj5M9w5F5osUe6J99CThZKFzYA/JvReekTQOE0mCFzBedDfUO6l
         PqJQ==
X-Google-Smtp-Source: APXvYqyIzOH5zo/01pYiY/WLl0OLwpsCvaKKuk+vDciT43wSxP3iXzYy6GsWF4y5D8CeYcDREH0+OmLOdYtg4cNrux0=
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr78131643plh.147.1560263915764;
 Tue, 11 Jun 2019 07:38:35 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <51f44a12c4e81c9edea8dcd268f820f5d1fad87c.1559580831.git.andreyknvl@google.com>
 <201906072101.58C919E@keescook>
In-Reply-To: <201906072101.58C919E@keescook>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 11 Jun 2019 16:38:24 +0200
Message-ID: <CAAeHK+y8CH4P3vheUDCEnPAuO-2L6mc-sz6wMA_hT=wC1Cy3KQ@mail.gmail.com>
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

On Sat, Jun 8, 2019 at 6:02 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Mon, Jun 03, 2019 at 06:55:10PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > In copy_mount_options a user address is being subtracted from TASK_SIZE.
> > If the address is lower than TASK_SIZE, the size is calculated to not
> > allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> > However if the address is tagged, then the size will be calculated
> > incorrectly.
> >
> > Untag the address before subtracting.
> >
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>
> One thing I just noticed in the commit titles... "arm64" is in the
> prefix, but these are arch-indep areas. Should the ", arm64" be left
> out?
>
> I would expect, instead:
>
>         fs/namespace: untag user pointers in copy_mount_options

Hm, I've added the arm64 tag in all of the patches because they are
related to changes in arm64 kernel ABI. I can remove it from all the
patches that only touch common code if you think that it makes sense.

Thanks!

>
> Reviewed-by: Kees Cook <keescook@chromium.org>
>
> -Kees
>
> > ---
> >  fs/namespace.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/fs/namespace.c b/fs/namespace.c
> > index b26778bdc236..2e85712a19ed 100644
> > --- a/fs/namespace.c
> > +++ b/fs/namespace.c
> > @@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data)
> >        * the remainder of the page.
> >        */
> >       /* copy_from_user cannot cross TASK_SIZE ! */
> > -     size = TASK_SIZE - (unsigned long)data;
> > +     size = TASK_SIZE - (unsigned long)untagged_addr(data);
> >       if (size > PAGE_SIZE)
> >               size = PAGE_SIZE;
> >
> > --
> > 2.22.0.rc1.311.g5d7573a151-goog
> >
>
> --
> Kees Cook

