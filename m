Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59E96C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20FAE205ED
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:00:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CUwZ43K9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20FAE205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FFEA6B0007; Mon, 15 Jul 2019 12:00:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E1A96B000C; Mon, 15 Jul 2019 12:00:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED3A6B000E; Mon, 15 Jul 2019 12:00:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473186B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:00:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so8497007plp.5
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:00:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1pf3WGwA9D7m+i0fi13et95NxKX1fwC73+4IJDRPguM=;
        b=aXupLmJhSKwLJQCC+b5YYBrx6GMvfCAy7nXrAOr9+qNMnW0KCE8E/+A/4pgGJxWEfP
         P9Nq+zR6xsLDXhU2cZFwgx2eU8rEM+KDWe8y2/9YLlw1o72nHA2OqD4+oJEqUaCCmQrE
         kP9QlEl7zeSBDxV+cxlU4OWlaMywAufnY0IKY2h5+8brc+5r0q6bcIuiVMXOeLeJkJeC
         FkZ6cXis76LAI4+yjhRnj+H26ydpNHsyTroa+7Wdz+4uCzZFpk4u2CWZnqJq3zkWSiJz
         FF5uiwvHtN0DGxmTm33faAI1URaZ1aCdxNqpEJwL3doQWd+7BiwuEXXFAtVnQcUi3gaz
         rwdQ==
X-Gm-Message-State: APjAAAXEu0Q+aKpWdSJHl4rD4b0mbO6QfJu8tXy+KsJaucwYGkqRWAO0
	kyg6Z1jY8/3I/KKXoaRN10UuRiPP7SWz8YYSIFVD/GBPlwzSiId4bgDuwXyXzbrnijqrMsr24qV
	Lzffi8s8skzYMDGPiQySgfXPp+0top0+CXqwvlNvV7Mjd3ARC3ytsT2Jn+GgrismOQg==
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr29114788plb.240.1563206417799;
        Mon, 15 Jul 2019 09:00:17 -0700 (PDT)
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr29114686plb.240.1563206416904;
        Mon, 15 Jul 2019 09:00:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563206416; cv=none;
        d=google.com; s=arc-20160816;
        b=E4YPiKXM426z06xeT3oHh+yfmb6eNgit9TRifFnZP+Nfl/Vy+uXRHRo+AuHuuRv8tD
         clNDsM1Ncopp9CERfD/BPaGk9ujtdXWWV4YKizdQeEbVSS2NckaMd5ug9eA754n+TOo7
         XBimR/hUmNU23zjfoyPQJzHHxEBq0YSHmqse0YqVvbMJhHofYTxDS0Uof9YtikMKbQLL
         M4SQ8ChcJHckRTNkx+NBhXSC0UMXhCILXKtCKG3zIHihHlFLTrpa6vVTG4VJNBSKk76q
         wh8IsZEp9StBaUen+do3zcgYznSoPyNDEFx8tbBzQ/sBpYcq/g8aGPxFdFGc7z+ykSyC
         Au2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1pf3WGwA9D7m+i0fi13et95NxKX1fwC73+4IJDRPguM=;
        b=jTk96fP1IZ4I5cYLfT44rduJLTOb2iLyX03J3ufHK4if7mrMBUdlLx7Vo/6xDUAkJ/
         IvT2tOgxXsIwX5QaV1PbJDwR/AS94+d3uxwSL7WAVAaI2SE8b5ry2vRWtIZ/dpgT+tzC
         VVCGvayUeClVhFrBVpKrWi8fnZZbnCg+VGMA/Bmaiy8cZKhJzaSgfHv3M2eTrrGoOf62
         zeDl3h1ApctNGjvyQRi+GFE7CF/oaXF496Ima2xawb11OvbcHgpGOuOqD9SdY7sHe0wa
         N1dIbsnOAfGHdKyUjPmXNqDXx2Pz4qeZvc2cEJY9DRS3Xm2leKpGOUohQwX47CNmdEI1
         BxcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CUwZ43K9;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1sor22326597pjr.9.2019.07.15.09.00.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 09:00:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CUwZ43K9;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1pf3WGwA9D7m+i0fi13et95NxKX1fwC73+4IJDRPguM=;
        b=CUwZ43K9ybSDvf08eErRqtarzGQdiyDymnpU0KIK2JQh0T9Sup32mLmqjhs/VSqLrM
         MYwEWnD1tZLcOi15wredI/8U9xLO31vPqZvI1nsgvE8QGayvfGS4zJ8DFpd8xTqTB2Uu
         X0XI38pv45yv7xUlijhdFuvP2joPIHdZCt3wPU6yGKh7zI1+RsRJeph15u1MMAsHXsmU
         N/CNSsdTxOBDr+vJzIQZq74ITN4H5tRoqeyXjfz14O98vHdJyS9nZdunI9ZY16WRAzUr
         aDjqrcEfrIeCTuDiF5a0mq44jqMLnJJxVYJo2ivJup10466XLsZAPQUB28/H/OHw+0N1
         yN/g==
X-Google-Smtp-Source: APXvYqxUxnVJIFmSjF/fduDJIdHHtTu2E7rs0M1v5DQsmsjwZzuX9klo19X53kLCG4pNPCe3wIEdLnHCwqNb7FnoP6U=
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr29852919pjp.47.1563206415768;
 Mon, 15 Jul 2019 09:00:15 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <41e0a911e4e4d533486a1468114e6878e21f9f84.1561386715.git.andreyknvl@google.com>
 <20190624175009.GM29120@arrakis.emea.arm.com>
In-Reply-To: <20190624175009.GM29120@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 15 Jul 2019 18:00:04 +0200
Message-ID: <CAAeHK+x2TL057Fr0K7FZBTYgeEPVU3cC6scEeiSYk-Jkb3xgfg@mail.gmail.com>
Subject: Re: [PATCH v18 07/15] fs/namespace: untag user pointers in copy_mount_options
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 7:50 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 24, 2019 at 04:32:52PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends kernel ABI to allow to pass
> > tagged user pointers (with the top byte set to something else other than
> > 0x00) as syscall arguments.
> >
> > In copy_mount_options a user address is being subtracted from TASK_SIZE.
> > If the address is lower than TASK_SIZE, the size is calculated to not
> > allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> > However if the address is tagged, then the size will be calculated
> > incorrectly.
> >
> > Untag the address before subtracting.
> >
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  fs/namespace.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/fs/namespace.c b/fs/namespace.c
> > index 7660c2749c96..ec78f7223917 100644
> > --- a/fs/namespace.c
> > +++ b/fs/namespace.c
> > @@ -2994,7 +2994,7 @@ void *copy_mount_options(const void __user * data)
> >        * the remainder of the page.
> >        */
> >       /* copy_from_user cannot cross TASK_SIZE ! */
> > -     size = TASK_SIZE - (unsigned long)data;
> > +     size = TASK_SIZE - (unsigned long)untagged_addr(data);
> >       if (size > PAGE_SIZE)
> >               size = PAGE_SIZE;
>
> I think this patch needs an ack from Al Viro (cc'ed).
>
> --
> Catalin

Hi Al,

Could you take a look and give your acked-by?

Thanks!

