Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA534C468BD
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75C04208C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:05:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="FihBxmn2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75C04208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12D136B027C; Sat,  8 Jun 2019 00:05:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B59B6B027D; Sat,  8 Jun 2019 00:05:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E98386B027E; Sat,  8 Jun 2019 00:05:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADE5E6B027C
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 00:05:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w31so2682390pgk.23
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 21:05:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=7MRDr4KJ8a0CcLFRNA6a6rBwJKdO40+h9uyHwhos1XY=;
        b=VRo6pXEaUV8GxBUKpksr+4wueiwaoLu+Y9k0SvjT+qBtizXLB8NcHfHAxjGk7nNw0G
         UQYBYNKHn1a9V8zGYSpuGwS+tyj3t5X7c+8kn8GEpt6eexoHs7tOqNhRrVVmSIaDyHjP
         XeBlSxB3wj5XppyRI+UTt1jw+9AClKklDTSg24qs53gofHHRAJVRp4Z/+fW8EJnIMVPQ
         W1PNflwW+WqV3Q42eSnHRgF7xq37WFu5UtVcAGqD6ITvibJK41h1TzyWv4Ks2WxAy7UC
         1YUJNWiTc/XhF5E478/SskslfPNKQKET+TzIjx6z57/8hhuWE/kRzVNx4qm/5mTni5Hj
         P2lw==
X-Gm-Message-State: APjAAAXBEh8AVITUYMhfWPFVlaDI8zhg+Job++/rcVr8reLoc4/cdweZ
	yV6KFTUWEZMvRlVUHBn5nWTMbFWJ4BubkSIGAV8flSvXPnvZRiXJle/CF+DOkz+yvnV6CqUmB87
	g1lmZmr1IIdxoLSGNTnyhDgKaViz7cFOIdTsTHQzmV1LRFPZx62ql3IJOyg7D212kTA==
X-Received: by 2002:a62:ac1a:: with SMTP id v26mr40367168pfe.184.1559966705362;
        Fri, 07 Jun 2019 21:05:05 -0700 (PDT)
X-Received: by 2002:a62:ac1a:: with SMTP id v26mr40367133pfe.184.1559966704788;
        Fri, 07 Jun 2019 21:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966704; cv=none;
        d=google.com; s=arc-20160816;
        b=L66TqFPP0Z95olu9plq+Ku6a1NTOb1jns2Qo0zIA+brmeXp2YPuV7XvgW1e68v0oF4
         /cTlC9zuiCRgtyoxwORakWCaMy8Og3XNj4WrE9n3lyeyuMawTk9zS6py6Xkm79gNnZfz
         ipShODklE0t8TfJMhhfYdJU7JjQcrpfOdf9RX1n4sz934rLTURBanwRk3nYK2xe9/BUt
         jxCgtoycAlN/azipEcgls7CxdCrVeHZ9S6M56xjfkcIRoo3ZBfgFnrwA1i8+XgssopNT
         ui3A+cnksQNhFDKDKF0lvUlVDV2fQn5/Tg3rX8pjR14Vi9YeCHCcn+Qml3Wq9Cz/jkLq
         DsdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=7MRDr4KJ8a0CcLFRNA6a6rBwJKdO40+h9uyHwhos1XY=;
        b=gjajtU73NqxiL3SxWqRhXIj37WDKHnURVaZRY3wrFZ1PnnTbUjISuqS78lMf+PFoZ1
         MkfSXrgFvP1PVQxDb2t59rrm2cC3xUHk32AAjL3Qv/5WFJaeCoI4LBrVlC6p1y3bPtid
         2pCr2n5pjjnI6uwOh0JhSdr0YdECerVnSoDSEzMpvj4dVaA8E7K9hGClCxorIl10K+eN
         jjWutQk0ruDiBiZwaImHD6Sfr+WnJMUyzUjOw4SP6+CqlXsYps0T4ml/6Ywfv/95fbar
         6qDS2oQ9j012kLFjZEtUaKWa44RPjeJIopPXuePMXapefzGNwTyDLSyAZ7HMX/F+RfNX
         ylgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=FihBxmn2;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor2200334pgj.54.2019.06.07.21.05.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 21:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=FihBxmn2;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=7MRDr4KJ8a0CcLFRNA6a6rBwJKdO40+h9uyHwhos1XY=;
        b=FihBxmn2dVJ6Rw2WItUxtjZpswcNWCrx4UusJNMmjDUeSXGlPeke41oTHXObrS9v9s
         auz9bPPxx2drUDHwQFTWyjmSfE251zoGthyYFhJV5WSoJ0SYpqwBy7GNBhwklPOXO6Qg
         gWZEmprLR6lDNUGcv9V07ySSkX/PEr3KR97+4=
X-Google-Smtp-Source: APXvYqwInYsY/wUHZ9P1C1XrBfyqppKEaGOwIlzHhH7Qkl6+K82Iixjx8HiJ+/il/stbMYBMbkFxfA==
X-Received: by 2002:a63:4045:: with SMTP id n66mr5882121pga.386.1559966704443;
        Fri, 07 Jun 2019 21:05:04 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id z14sm3301959pgs.79.2019.06.07.21.05.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 21:05:03 -0700 (PDT)
Date: Fri, 7 Jun 2019 21:05:02 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 14/16] tee, arm64: untag user pointers in
 tee_shm_register
Message-ID: <201906072104.B6A89D8CB@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <dc3f3092abbc0d48e51b2e2a2ca8f4c4f69fa0f4.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dc3f3092abbc0d48e51b2e2a2ca8f4c4f69fa0f4.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:16PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
> user pointers for vma lookups (via __check_mem_type()), which can only by
> done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

"tee: shm: untag user pointers in tee_shm_register"

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  drivers/tee/tee_shm.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
> index 49fd7312e2aa..96945f4cefb8 100644
> --- a/drivers/tee/tee_shm.c
> +++ b/drivers/tee/tee_shm.c
> @@ -263,6 +263,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
>  	shm->teedev = teedev;
>  	shm->ctx = ctx;
>  	shm->id = -1;
> +	addr = untagged_addr(addr);
>  	start = rounddown(addr, PAGE_SIZE);
>  	shm->offset = addr - start;
>  	shm->size = length;
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

