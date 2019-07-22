Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C9C3C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:46:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49A8521911
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:46:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="VX6SSuVo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49A8521911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4A378E0001; Mon, 22 Jul 2019 12:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD35F6B000C; Mon, 22 Jul 2019 12:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A73B78E0001; Mon, 22 Jul 2019 12:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4206B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:46:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o6so20167489plk.23
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:46:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=F8BugWPvgcU2u1kFFZKMyP/IOkg4/qodeykECt+PCWA=;
        b=WgsRyFiLCa7OJqxHLY/QIlgKUSFa9WW70G6TIkuzMJW3j2lR5h5kpVBJ4x5Hljuy+w
         XxzqI+DE7+Tce3ltphJJVT4Ttu+wnuTyd604VVX+sDwfcBg21olaO0q8h9jvOVdiSy2P
         j6GcqWNuci+SC/6miEyov3y1HEvFMtPyw8E/P5swfNj3q5xeFH3ehcjg1nvKDQECzYCX
         aODZIuLWKkh2cr1BdtLEdXTCJfVlzyxbIST4VxOw6GZrPFDP6Z4KbU+teCXGh1cQUBwa
         CKIyxOlHx2n6sB7XwTpecQSm/IFZdjI81jL4IYEWDepyxMCGV9fCU+NJF5ITabgucHpp
         x4Mg==
X-Gm-Message-State: APjAAAUHjAE7vzYhp7lgL5hxlGaN4ywcvjuJBtGh17TUQk/mQJCzp0Km
	C8A4wKfNhWfjiK8q93CoeYVVFdchmFRF+8030ADVBxYADH+HjXrYShLtJKLx9CqRJvr5AI3EYJ8
	qiHuU3jn1DbPPfaW6wvc0O2NXlVc2hmLwR0E8MpRFaliTQxBwCNEvoIHGFHwh7FFXDA==
X-Received: by 2002:a62:e815:: with SMTP id c21mr1198430pfi.244.1563813969997;
        Mon, 22 Jul 2019 09:46:09 -0700 (PDT)
X-Received: by 2002:a62:e815:: with SMTP id c21mr1198376pfi.244.1563813969194;
        Mon, 22 Jul 2019 09:46:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563813969; cv=none;
        d=google.com; s=arc-20160816;
        b=C7a22hdgv36YLsyqEZqQyxaK5udxCDqpI6/MXq9ns2TXcdluwYplvQcrGgIsNiQGGE
         5QI2wKkLcJmnOZez4iUEAsj0KMom9YuiFlAB/bMG0xBoPwLD+dHKbIjbu0Ry10BsysL7
         A+z+EqFEmQDtd05/u4RPAdcOPTnjBeeh0lmOAQzRoG1VVG5iJwf+77s+0Zsn/cZAQgDM
         sFikUD1rGOjkgcpqfmYZxN95FIBjE1tRLNhT7zWo7bufDbknGYOiRdBcmhmkpFZaByE8
         2U/t1OOVG6uXPhIEIe/deZ38xPpo8+gMnpxycPdZkJlrJ3qSmNppEzRKy+LhQcaE8kzc
         aokA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=F8BugWPvgcU2u1kFFZKMyP/IOkg4/qodeykECt+PCWA=;
        b=v7awzW5JlrmItFjrFqYaNuqALVlDxx4EpRQ3Rs0e0qO2Oqrxjq74YbZw5UeBSzq0so
         ZwqjMIXUutGPdpk4OHJew+elhyq1AdYepqEPn0h1QaE6pzWl+7cCfEtxfk4tNB7hMOmu
         zU1GD039fHVlP5QEgz6hcrAmpV4LLi5xb+ofjfy+UPZVJpZZ0DzbnzrXCqP2Mnc4ekaE
         hTGu+AZgffc1GHg8wslQ68QXQZbwmvPKN2H3JWIzDTMVk2r1bkAmcCFV612LADrrqJUi
         AXqXBwc+RPKh+bY8zCXmFfUCyGKTUsBCIrnEy82j8xesY2G/LtMxXsbD1CMx80Vx4N+k
         6dvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=VX6SSuVo;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o39sor48643373pjb.10.2019.07.22.09.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 09:46:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=VX6SSuVo;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=F8BugWPvgcU2u1kFFZKMyP/IOkg4/qodeykECt+PCWA=;
        b=VX6SSuVoSHuo5NAioif+DJtSSs1RJl179j5hlo4DTfAYF66Jgcx0vpiJB8eR+9HEL8
         +f/45Mc4lQN3jKnZezfzKg+yOPAVpcviTazcgmREFQYvaP41eWd/rYtiTmOP5jut4IGW
         UsbCxeU7Nx57xcR3YkKPrTzMk7AWS/2VcXYuY=
X-Google-Smtp-Source: APXvYqzl1okfrN5zPZDspTEQta/i5+YABh20qrSg3GL1AN5406TswuRoR6v+V+I5B+11TbFoYh/o0Q==
X-Received: by 2002:a17:90a:ff17:: with SMTP id ce23mr77676431pjb.47.1563813968675;
        Mon, 22 Jul 2019 09:46:08 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id 4sm48411440pfc.92.2019.07.22.09.46.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Jul 2019 09:46:07 -0700 (PDT)
Date: Mon, 22 Jul 2019 09:46:06 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Eric Biederman <ebiederm@xmission.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v18 07/15] fs/namespace: untag user pointers in
 copy_mount_options
Message-ID: <201907220944.5821C92518@keescook>
References: <cover.1561386715.git.andreyknvl@google.com>
 <41e0a911e4e4d533486a1468114e6878e21f9f84.1561386715.git.andreyknvl@google.com>
 <20190624175009.GM29120@arrakis.emea.arm.com>
 <CAAeHK+x2TL057Fr0K7FZBTYgeEPVU3cC6scEeiSYk-Jkb3xgfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+x2TL057Fr0K7FZBTYgeEPVU3cC6scEeiSYk-Jkb3xgfg@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Eric Biederman too, who might be able to Ack this...

On Mon, Jul 15, 2019 at 06:00:04PM +0200, Andrey Konovalov wrote:
> On Mon, Jun 24, 2019 at 7:50 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> >
> > On Mon, Jun 24, 2019 at 04:32:52PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > tagged user pointers (with the top byte set to something else other than
> > > 0x00) as syscall arguments.
> > >
> > > In copy_mount_options a user address is being subtracted from TASK_SIZE.
> > > If the address is lower than TASK_SIZE, the size is calculated to not
> > > allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> > > However if the address is tagged, then the size will be calculated
> > > incorrectly.
> > >
> > > Untag the address before subtracting.
> > >
> > > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > > Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > > Reviewed-by: Kees Cook <keescook@chromium.org>
> > > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > ---
> > >  fs/namespace.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > >
> > > diff --git a/fs/namespace.c b/fs/namespace.c
> > > index 7660c2749c96..ec78f7223917 100644
> > > --- a/fs/namespace.c
> > > +++ b/fs/namespace.c
> > > @@ -2994,7 +2994,7 @@ void *copy_mount_options(const void __user * data)
> > >        * the remainder of the page.
> > >        */
> > >       /* copy_from_user cannot cross TASK_SIZE ! */
> > > -     size = TASK_SIZE - (unsigned long)data;
> > > +     size = TASK_SIZE - (unsigned long)untagged_addr(data);
> > >       if (size > PAGE_SIZE)
> > >               size = PAGE_SIZE;
> >
> > I think this patch needs an ack from Al Viro (cc'ed).
> >
> > --
> > Catalin
> 
> Hi Al,
> 
> Could you take a look and give your acked-by?
> 
> Thanks!

-- 
Kees Cook

