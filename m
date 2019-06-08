Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9DD5C468BC
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EB01212F5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="HXvVg9co"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EB01212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B94B6B0276; Sat,  8 Jun 2019 00:02:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 069CA6B027C; Sat,  8 Jun 2019 00:02:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E73EE6B027D; Sat,  8 Jun 2019 00:02:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEDBE6B0276
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 00:02:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l184so2689287pgd.18
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 21:02:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=ld9qqur+4qvQ29YBRyUFm2eutAmUIhRNEhUVQshxtq0=;
        b=Yxxdd5W92ZZ4At0v1rM/IsXoFk3FNnl8k+mWxWoRjLVTawH1irC3WIMdlm4aF+D/r8
         WHpQhtVB1Y4aZensIWdSSlJl+AwlTjj4sNOJs607pb2NNMLnu9ieHWZT4U1e41XTFEco
         Bo1WpEbh975cJfMhoPL1O8dmE/eWBnd8MpSglDeW2GtlGQRCjZdnpVYV9BnmuimAGeDx
         s+93D6wcX3Kok04ZTbsmYwkgHMb9jECB/q1Ol/Tcnj/3Fx7gJCCD/CkLHScAAfva+/3p
         sP6NSiII1FAy6NBtfQUs+6ri6ysdJ+gERWIbTKS/ftrV+PDHeH4bqp0H53670A6s8S53
         SQpQ==
X-Gm-Message-State: APjAAAX49XPHxt+48/A+tsmC6HXrRceqqEkO38nR+NRmLfZlfjP0Sfik
	EyzxG6qRnTfIDJ6AWRHdA9R1G7uiUwErqSYI7VeWMp78WcvB+MNzjqI1JKdrEMBk/+a8CW9ykbt
	nmq1e1ckEWGe930SwRgCYNmOPcpIG5jwXH+u5w5ausETdBs321in1ZyqamFQLDXGz7Q==
X-Received: by 2002:a63:81c6:: with SMTP id t189mr5787726pgd.293.1559966548313;
        Fri, 07 Jun 2019 21:02:28 -0700 (PDT)
X-Received: by 2002:a63:81c6:: with SMTP id t189mr5787653pgd.293.1559966546912;
        Fri, 07 Jun 2019 21:02:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966546; cv=none;
        d=google.com; s=arc-20160816;
        b=VXrGyorIZJ3R4buHPLbvLVRSgA+YUA7rZxggYjALdt2EKHndcRf6eQMBgw5Z+0y8ma
         FxDM3q4rKH8COWeIgFToFWHY6yaEdVCwBcWgJw8NvTG3XfBIJQ1o0V7Yy9WHA0fHdWLw
         BrvkIeviOqzc5TvLOqfwqH+uBguTfCggcTuEM/TJwyHg6NydqqirC/jIv5oQAI/vPdmr
         R61dalXQUUqdHJOgi8QimbhP15Zqjl7kuXrB2J1b1IEqseyJyKeQoN1k/aPFPotXgehc
         L940cB35TjC4zTSSOyQ29/7jXGIPb8842HFsqOISugAZxyNuw7eo417zNScGPdhsNPcc
         8IzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=ld9qqur+4qvQ29YBRyUFm2eutAmUIhRNEhUVQshxtq0=;
        b=L9b5pBKqZPvgsG5ZfwP1YJzZEIWTI5uB37sa9EZymxa/q0fq5HbPoBzGd9sMOtQzsd
         6aLA45Agf5RoI7702zhjkKBoON9LNGV/+qPQVelX4lUePcL+LpgZWp5SQxl8xBTFGDfn
         QM3jlW8/wBOJwTCABqPAlpVHvpCc93tUjFRRFyoxfwVc2fWGIZtjTpk9NncgmV71a8ig
         wXJLWhqu12KcaFvQh3d5D8YRDSzmHHqm4JGE+2x0pT/JQityaxwyrkV7lwyEPYl09RGO
         Ra9jhK6FPyxqsonoGL4doSqBByKiku14G5xG2tYUHnypFD4jkEdtUcWeajLoWzuKSAHx
         Bflw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=HXvVg9co;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 36sor4703506pla.71.2019.06.07.21.02.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 21:02:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=HXvVg9co;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=ld9qqur+4qvQ29YBRyUFm2eutAmUIhRNEhUVQshxtq0=;
        b=HXvVg9coUo1xEEGS0DwgDUYkxEz6DS1r+bnepiqG47VSO6k+SKaBqi5wnLJUzhKT0Q
         F77v/3inF5WO9KdoxanRYXG9UTvU9WuNvhZbHSnOvkwygp4/KRjUvBwoWTTXrnkExWcy
         ADu9rIK/0BZ8VaknNJsilZ7GGCNNLhX/1899U=
X-Google-Smtp-Source: APXvYqyWIU7z0h83s595E4gtAHnTw/dwV2AWdUHb9XfpIujI04l63mQHZIFAtQw1iHXTD7aat4vguA==
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr57418900plo.340.1559966546670;
        Fri, 07 Jun 2019 21:02:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id b16sm3567551pfd.12.2019.06.07.21.02.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 21:02:25 -0700 (PDT)
Date: Fri, 7 Jun 2019 21:02:25 -0700
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
Subject: Re: [PATCH v16 08/16] fs, arm64: untag user pointers in
 copy_mount_options
Message-ID: <201906072101.58C919E@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <51f44a12c4e81c9edea8dcd268f820f5d1fad87c.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51f44a12c4e81c9edea8dcd268f820f5d1fad87c.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:10PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> In copy_mount_options a user address is being subtracted from TASK_SIZE.
> If the address is lower than TASK_SIZE, the size is calculated to not
> allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> However if the address is tagged, then the size will be calculated
> incorrectly.
> 
> Untag the address before subtracting.
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

One thing I just noticed in the commit titles... "arm64" is in the
prefix, but these are arch-indep areas. Should the ", arm64" be left
out?

I would expect, instead:

	fs/namespace: untag user pointers in copy_mount_options

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  fs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index b26778bdc236..2e85712a19ed 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data)
>  	 * the remainder of the page.
>  	 */
>  	/* copy_from_user cannot cross TASK_SIZE ! */
> -	size = TASK_SIZE - (unsigned long)data;
> +	size = TASK_SIZE - (unsigned long)untagged_addr(data);
>  	if (size > PAGE_SIZE)
>  		size = PAGE_SIZE;
>  
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

