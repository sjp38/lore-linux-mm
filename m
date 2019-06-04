Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97B24C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 524B4248B9
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:01:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Y9IUVHZG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 524B4248B9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E07D86B0010; Tue,  4 Jun 2019 09:01:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDF3D6B026B; Tue,  4 Jun 2019 09:01:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA7166B026C; Tue,  4 Jun 2019 09:01:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEDB6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 09:01:22 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t11so10572228qtc.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 06:01:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JItJDb1hCe3PXbM5CDMidmb7xSzfnBwGQJaUWCGmqxo=;
        b=ZluYgY2yFyXnwATWvAaYNL47Z5SPUCG0IyN1/zsy9QRsodq/P6aX3bjBSocJIfi69O
         oanmKM9z2SHFGjHfAmEvHzyU6E/wrhgFR8z0wEkVBR0ZseYkf49KYnHSEylslRH9uaq1
         K4S5R2iy7yK4BzJ8uZ9wrhTNtQWclm9MbPRONNkSTlK98gl3OLMjJkNpTZo7BbcynD0n
         ZsB3/0CxCG2C9cTmkiN0rTYy/+PSl3HEg4oHXGq7nmnODb2jGE5zjLb1ldhAghCPYiF1
         FdBbFlXieNtakEYH2ysLFItRjpxAtcNwWCKUHVXzU4Zlx0WZF5JHyEMpifM2hja428z0
         R3NA==
X-Gm-Message-State: APjAAAUb+j7shyxQXzNtRv2clmdRwaSnnnuob3pB4Kv8UpBZcvVl0xhh
	F49HQtyeNLkzAWvG2B4EG7USh45FWCk9lvVddG4K1MItnV104BVrXfdu83l6U16QFiF1YWvSoAe
	ZoYjMI5igZOdzHIgXfC7+r0YlTmdamjQq/C+svxDq6Vr0s8T+yENTLj27GsBTSDOTDQ==
X-Received: by 2002:ac8:16a2:: with SMTP id r31mr27993192qtj.302.1559653282095;
        Tue, 04 Jun 2019 06:01:22 -0700 (PDT)
X-Received: by 2002:ac8:16a2:: with SMTP id r31mr27993125qtj.302.1559653281440;
        Tue, 04 Jun 2019 06:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559653281; cv=none;
        d=google.com; s=arc-20160816;
        b=TsVyqhMJXIBkErAeBZgYAGVN6h62zbtgarIUxK0WzYLEabLkqtqAbainAdrV2VeVvc
         /lmmQEGUTLAOnqAK8OZb9nxAQOF8wptS+nOA92Ra8LTHv23mRop6K9Mqh7cgTAe43yGX
         Wbl/+sn8DAy01ehTiwZk7WnM5tPok2wDThPJAVXdyV+r51solDXThoTWBx4aOwZrJZeD
         zwndW6KuHSBxht8oXQvSB9LIQ09IvgZPdEGK+Nn2xtcrKzjTwbMqgj46q/rfTVUE3fV6
         A5EZvacAPF+xbzpho/WgOkhXyTh7nzK3iqrrLpD/ZWFE3S17U9pBHQF7sNU1z57PExpC
         orsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JItJDb1hCe3PXbM5CDMidmb7xSzfnBwGQJaUWCGmqxo=;
        b=y6NejmSXNlgWrtYFPHtbYwJtKzRh0qSwgqOsH5a0xhNJO3KjhgoT4Qs+s56R/C+8Ro
         P3b5YDb4exa2qcOTZ9MTR3OVIFSnCrP94K9sOVRAe+RmYEtZWErqpi8XiSh6GpAedsk5
         nScfxGiwp/zOReG1FVITc35Rn5Y23igvmjYlcssuLRSn/eEBXNzJd81iUXxpQLCNJWNG
         CjmlvimvUOv4bctW21lVZQq16SZutJk4cZ0uc7zjTDeSTs18lhOkdnWEQqxDh1XVuw3Q
         4v9H7jYZD9+P9Esgp1hJskSpsICJRl/ZlaS0UiKx/odhn2zRjQ2yK8B+/C1LHBBW41tc
         oY4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Y9IUVHZG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor2508606qtl.39.2019.06.04.06.01.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 06:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Y9IUVHZG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JItJDb1hCe3PXbM5CDMidmb7xSzfnBwGQJaUWCGmqxo=;
        b=Y9IUVHZGqeU0HCJUHFiWu6pa9R1aTN7kulR/wN6MqxmpXYzOa0TiCqua5LiZ4hEwEz
         ev2Sj3xyes2144LjjuyOexSqeqSKWlt3WMK6cSGZPGD8HxNjX+Gtgr2VjY2syXYm24yv
         pNhVi+7lsS8CkaA6Ue3uMV/Vv79a8q0c7Bx2ZKe0zrhNUNw+dh1aaTgg9nVjtt2pPP8J
         SZ03QiW2V5U/FSunjX+Di4eqhrmayy4bvd9nBAYIILU6Dw1ILE8JJqykvWw/nYFx66N/
         59mJF6D5Asld4XY9Y52qmbOm2vh94w3cf4KMuiWIudfxgAyJaXKJUsg9rxdyQ86kjKce
         JSuA==
X-Google-Smtp-Source: APXvYqzAG+mI1DPv2W+11pupnoGWNGycht5g/63Z32TRX8qAmaRQdBGY8y7MK6ZcgElkWgzp2dHDfw==
X-Received: by 2002:ac8:7c7:: with SMTP id m7mr25441539qth.28.1559653280236;
        Tue, 04 Jun 2019 06:01:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a7sm7509135qke.88.2019.06.04.06.01.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 06:01:19 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hY942-0004Su-LN; Tue, 04 Jun 2019 10:01:18 -0300
Date: Tue, 4 Jun 2019 10:01:18 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
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
Subject: Re: [PATCH v2] uaccess: add noop untagged_addr definition
Message-ID: <20190604130118.GC15385@ziepe.ca>
References: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
 <20190604122841.GB15385@ziepe.ca>
 <20190604123759.GA6610@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604123759.GA6610@arrakis.emea.arm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 01:38:00PM +0100, Catalin Marinas wrote:
> On Tue, Jun 04, 2019 at 09:28:41AM -0300, Jason Gunthorpe wrote:
> > On Tue, Jun 04, 2019 at 02:04:47PM +0200, Andrey Konovalov wrote:
> > > Architectures that support memory tagging have a need to perform untagging
> > > (stripping the tag) in various parts of the kernel. This patch adds an
> > > untagged_addr() macro, which is defined as noop for architectures that do
> > > not support memory tagging. The oncoming patch series will define it at
> > > least for sparc64 and arm64.
> > > 
> > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > >  include/linux/mm.h | 11 +++++++++++
> > >  1 file changed, 11 insertions(+)
> > > 
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 0e8834ac32b7..dd0b5f4e1e45 100644
> > > +++ b/include/linux/mm.h
> > > @@ -99,6 +99,17 @@ extern int mmap_rnd_compat_bits __read_mostly;
> > >  #include <asm/pgtable.h>
> > >  #include <asm/processor.h>
> > >  
> > > +/*
> > > + * Architectures that support memory tagging (assigning tags to memory regions,
> > > + * embedding these tags into addresses that point to these memory regions, and
> > > + * checking that the memory and the pointer tags match on memory accesses)
> > > + * redefine this macro to strip tags from pointers.
> > > + * It's defined as noop for arcitectures that don't support memory tagging.
> > > + */
> > > +#ifndef untagged_addr
> > > +#define untagged_addr(addr) (addr)
> > 
> > Can you please make this a static inline instead of this macro? Then
> > we can actually know what the input/output types are supposed to be.
> > 
> > Is it
> > 
> > static inline unsigned long untagged_addr(void __user *ptr) {return ptr;}
> > 
> > ?
> > 
> > Which would sort of make sense to me.
> 
> This macro is used mostly on unsigned long since for __user ptr we can
> deference them in the kernel even if tagged. 

What does that mean? Do all kernel apis that accept 'void __user *'
already untag due to other patches?

> So if we are to use types here, I'd rather have:
> 
> static inline unsigned long untagged_addr(unsigned long addr);
> 
> In addition I'd like to avoid the explicit casting to (unsigned long)
> and use some userptr_to_ulong() or something. 

Personally I think it is a very bad habit we have in the kernel to
store a 'void __user *' as a u64 or an unsigned long all over the
place.

AFAIK a u64 passed in from userpace is supposed to be converted to the
'void __user *' via u64_to_user_ptr() before it can be used. (IIRC
Some arches require this..)

So, if I have a ioctl that takes a user pointer as a u64, and I want
to pass it to find_vma, then I do need to write:

    find_vma(untagged_addr(u64_to_user_ptr(ioctl_u64)))

Right?

So, IMHO, not accepting a 'void __user *' is just encouraging drivers
to skip the needed u64_to_user_ptr() step.

At the very worst we should have at least a 2nd function, but, IMHO,
it would be better to do a bit more work on adding missing
u64_to_user_ptr() calls to get the 'void __user *', and maybe a bit
more work on swapping unsigned long for 'void __user *' in various
places.

Jason

