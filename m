Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 013E0C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:27:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B28C923E96
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:27:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dcNC7Umt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B28C923E96
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39A506B026B; Tue,  4 Jun 2019 08:27:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34BAE6B026C; Tue,  4 Jun 2019 08:27:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2136F6B026E; Tue,  4 Jun 2019 08:27:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E569C6B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:27:17 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n126so3383417qkc.18
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:27:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wnsJg5IBUcpd0uvGih9L7zWjhXAHb1EJO0yOEExZSzo=;
        b=IHvcuXUYJODRF4r2Y5aDr3wnOkUf0CM7NlQrKntXwc+MYuM1fx7TogltPJLyuxIu3Q
         IInF88TKZUmFYeNTHcTF3NX4KqjHyzh7AoI9z5ut1j2pnql58PhWHyDqIj5P9bQFgLp9
         JKMGnQXNsbv7qN9G0mXn1058PCFVXDcdJzITBIIxooC8s/ifOZCjTdOktL3YhbHPqfwt
         TYrqvCcpaNC6vqekF3y2Xvsv/ZFZEC5fMeRO8nw/NRBz5494X466UTypvAMEobm+MUiB
         +TnUTm+bGCyJ7GS+IGzdci/cWnm3xWUYNxihMn0XL/zZuUv9lHFSAfsdPCDbQCMkpZoi
         OL4g==
X-Gm-Message-State: APjAAAXOVMUWg2ozH4submkQGJ8eHcZN0H6e6bi4GrWGGQfYILTRPMrc
	ESsJOb2P2p3e9ui15NenfJxM185zO4EQUZ73C2vwKVOAjA2szgzR/bbL+WWSXoTHd2Hz9O56GWe
	nuGsDc0zuEK6tpVFcvWG43I6tqfXdmYdvmyQxmMvlZxG7sAtBgZnWIuPD+GHOctJvGQ==
X-Received: by 2002:a37:9481:: with SMTP id w123mr7857830qkd.319.1559651237271;
        Tue, 04 Jun 2019 05:27:17 -0700 (PDT)
X-Received: by 2002:a37:9481:: with SMTP id w123mr7857785qkd.319.1559651236646;
        Tue, 04 Jun 2019 05:27:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559651236; cv=none;
        d=google.com; s=arc-20160816;
        b=iwhKZaw56OB2ToTwNzEugU1wHte9TWq+LUcXttcAygLBFDRl7lJSomPG55F/NnfYyS
         tALm7bmtWIwy0bHWHD8va5R1YkybEwPmdha3wmy1F3ATbyNCE9FspZxJTruWX2n+xvv/
         RS9E2+9UGPHYwc08v3n6RYQO9BT1UcrcUNltNWyfV+oFJK945/2RGd28hqsBADtbOCF9
         Pp6V8b3g1/Bjw2ExN2A8sbfaIwOKP+9sl6OtSRNW0377MQKsg8KOGVYcY2yuJrUeS7ey
         qwpoTVOt+uuVAj6iedo+mZjQaass7e+bXq1W5MxlOdnPek0dNJdZ0P0R6bM8ipJBZtJ1
         yPcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wnsJg5IBUcpd0uvGih9L7zWjhXAHb1EJO0yOEExZSzo=;
        b=MBD1yHUX/K8eWXQMR5X5WpAsUPT0OCtG1+p7INPaksA60t13YPB3ndZYVn661V6j5c
         TymekRjmJxmhdma/UixDnxyWuO81mwycLWJ0vIgpiW+h6ZSYs62xUrbeLdcnXbvTn7kt
         cuxaBKLymfsB74ckRYzC3pOsCRTQhXVUOufc+dd7KDpSkWTKr6s2VMgqlUrEMCNCupZn
         pnCWZrwnLZjhO2VjvZzeEK8p/YJDKApFI50MIQRl4s66jwapyamA6EShgxF648PHTlLv
         2N4HxJid+NhxFzfATVrbhRGMb4XdzAG3C9lnskcaPkkzRN3hrAnDwnlQ7tuIC6kbewq5
         gsrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dcNC7Umt;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor5889720qto.54.2019.06.04.05.27.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:27:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dcNC7Umt;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wnsJg5IBUcpd0uvGih9L7zWjhXAHb1EJO0yOEExZSzo=;
        b=dcNC7UmtypwgYv25SVviVAOUG7URTCQh95rjKD+gc1HkGG0jrMjWKvaHqgOqnkLXCe
         CmoljchytuIVIDVbprMz3tL0S5wF3BfmVPwpXMEcKwEKuopvqQDwmPbpLySBrTe+5P0P
         +zjXSkVABYGjw15OrEI3UNK6X3hEEYJ5lmU4VodgY1OGgetHeu4xf6gu/Drrr5PoUFZD
         NGszqORq933qFqUy4wxVOf9PkDJzNBd6Vt6SxvMrx9KcQhBJruI+UAnsanyndNgyFsW8
         SfJHC+U7tiqZ4PP8CoYnZCXFGYoMymsmvspjQbzELX76TfLMwbqeFyJLFyTuqJIB4Dhp
         ZF+A==
X-Google-Smtp-Source: APXvYqyQKZsajkt/gWb5hfUpWdj5TzMt6KfoFh/bz/W6aTLwqi1dm4Rk21CH5MrcGrt3uoh1Lu64hg==
X-Received: by 2002:aed:3a87:: with SMTP id o7mr27583430qte.310.1559651236150;
        Tue, 04 Jun 2019 05:27:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c18sm4454633qkm.78.2019.06.04.05.27.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 05:27:15 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hY8X4-000416-LN; Tue, 04 Jun 2019 09:27:14 -0300
Date: Tue, 4 Jun 2019 09:27:14 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 12/16] IB, arm64: untag user pointers in
 ib_uverbs_(re)reg_mr()
Message-ID: <20190604122714.GA15385@ziepe.ca>
References: <cover.1559580831.git.andreyknvl@google.com>
 <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
 <20190603174619.GC11474@ziepe.ca>
 <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 02:18:19PM +0200, Andrey Konovalov wrote:
> On Mon, Jun 3, 2019 at 7:46 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> > >
> > > Untag user pointers in these functions.
> > >
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> > >  1 file changed, 4 insertions(+)
> > >
> > > diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> > > index 5a3a1780ceea..f88ee733e617 100644
> > > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > > @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
> > >       if (ret)
> > >               return ret;
> > >
> > > +     cmd.start = untagged_addr(cmd.start);
> > > +
> > >       if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
> > >               return -EINVAL;
> >
> > I feel like we shouldn't thave to do this here, surely the cmd.start
> > should flow unmodified to get_user_pages, and gup should untag it?
> >
> > ie, this sort of direction for the IB code (this would be a giant
> > patch, so I didn't have time to write it all, but I think it is much
> > saner):
> 
> Hi Jason,
> 
> ib_uverbs_reg_mr() passes cmd.start to mlx4_get_umem_mr(), which calls
> find_vma(), which only accepts untagged addresses. Could you explain
> how your patch helps?

That mlx4 is just a 'weird duck', it is not the normal flow, and I
don't think the core code should be making special consideration for
it.

Jason

