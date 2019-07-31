Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70CBEC41514
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 20:25:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A4392171F
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 20:25:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="nhwHsvp/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A4392171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24A38E0003; Wed, 31 Jul 2019 16:25:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D52C8E0001; Wed, 31 Jul 2019 16:25:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4208E0003; Wed, 31 Jul 2019 16:25:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55B098E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 16:25:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so43987636pfn.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:25:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=0pLvL4XoGYF6/S/bO4KhBdgKs6/M0DxlhP6T+btdb0E=;
        b=a+FPFeueIWxsXod05CN7WpR96pta94lAs6L1t5mjmeZK4wbSf4Tbq4GlZmNQxitWTx
         5fCOBkRi2ZluRqxFKIvFOmRcCPqMa28R0GQoikK52bzLQPhFg7UzbY0N0DLsgF8KZe7C
         rXbzpIo9zjnRHMebOBNiO8O8be9maLLChPl+XxNtCFHKyNpPsFLrzj+dqOnt3A08a4Ht
         hLfAFIWbmx+5qSawhgkbOSL0JVYF2UKz+nUpKgBnkPUF9qFWI0oIyY+n2CC8nOxJLX3B
         oNUZOt7ZTxBLHV6YOEzB0SeuKRkxgv6xiHltDPfu1PXnQoDdJA86Bz0RjCaaQqQ8XXTK
         VExw==
X-Gm-Message-State: APjAAAXWuhOI745ScaC8eDgBeU/qZvgA0UxqyTPE6GaBww4b1p4Mfmh0
	BPLW3+bsWhPgr++EEp79oJlxWDRDm5O0MleuvflLu1xrNVbeNI2BFuhi9fZF3NafEaqTxvSFUOJ
	VMtdf3IslBh6BkhmdISQo6y6FcgzAV0DOKVsiGD05ULVSxR+PIjzk1TVETfmIj9ZGLw==
X-Received: by 2002:aa7:85d8:: with SMTP id z24mr40606351pfn.218.1564604711982;
        Wed, 31 Jul 2019 13:25:11 -0700 (PDT)
X-Received: by 2002:aa7:85d8:: with SMTP id z24mr40606298pfn.218.1564604711156;
        Wed, 31 Jul 2019 13:25:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564604711; cv=none;
        d=google.com; s=arc-20160816;
        b=T40gHu50j0eIm8+w9AefJ53OzbY/n81vhux3pp4PsdaFxlL1IXoliRkNXXB4ErzUu7
         0E8JPSyszPNtNJ3chBvIaCbwK4JQwxqari9dRBbJkgb9uaZrGRk/rvVPJGxECGApQFZo
         yrwbHW+MQ4qDZ6x7nzFNgvsq8CIaZO+5l6JNDTosRF/FDW1+ln6lXiWBa5sBajc6y1Dr
         7R0kbJ85TSRdUxVFOs20k+0V0ddc2bvDuk40X1CTQcpJL3Mxt+wQDtoy0EJpZXd0KcNl
         Ge40+EuxH4ED45l+dUrS0neyNMNfGOvMDx1mnlI3t7YLadAwnJTE3Nd1tfxHUucrgOfr
         hfRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=0pLvL4XoGYF6/S/bO4KhBdgKs6/M0DxlhP6T+btdb0E=;
        b=QIB9eW0oaOKySI8sO3/DWwtvwPvqXfiDJF1WuhIhTNwspGeogMmVviZCD0iLgPLd2i
         qs9M2JWuuoNvMkohmMymrIp28e0A/zuSZ4clEBtxCs+vm16Qbwxd+VFF1ptk4yY/K42J
         HluDvKU1diOg/m0pknbFmAULJMljtuQxjYmlPcoZRHwNOr13K4QHM7nCjRkWonM+YnTJ
         2KTWemXIgwd6BlY5mXWRn1g0y7RwkSRkhuLzQuKQpbRnNST1kEk65I4INu0q/Lo7T7jc
         odunEc3K1CnKETaGpF46/4kwwjtvv+Jo/UAp3MII8bcIAjkEDRhLg9X52g27k7H1ZVA/
         Ah0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="nhwHsvp/";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u184sor50935065pfc.69.2019.07.31.13.25.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 13:25:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="nhwHsvp/";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=0pLvL4XoGYF6/S/bO4KhBdgKs6/M0DxlhP6T+btdb0E=;
        b=nhwHsvp/32LnkrUUYeFQVJf6a5XG0VbCeyqdOhNKuGjJPAEI+E8IajZXhfy7iku3Nt
         GXQW8AaA5AJ6NNU8XIXmhoOriXYI/zGZfxRpnj3GAYC0ps7JvrlOec9TzP8ptbdIwQYv
         DKXypv6Fq73h5SZxLpblvCN/RVEvKIWxs0yCY=
X-Google-Smtp-Source: APXvYqwwz4QXBj6X4jmRiK5RdWk3VtwUDMP0wQe48ogv57D0i040spqUEUMSR5b2sInVDU1XTItkNg==
X-Received: by 2002:a62:ce8e:: with SMTP id y136mr49994255pfg.29.1564604710841;
        Wed, 31 Jul 2019 13:25:10 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id p23sm74797789pfn.10.2019.07.31.13.25.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 13:25:09 -0700 (PDT)
Date: Wed, 31 Jul 2019 13:25:08 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Isaac J. Manjarres" <isaacm@codeaurora.org>, crecklin@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, psodagud@codeaurora.org,
	tsoni@codeaurora.org, eberman@codeaurora.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
Message-ID: <201907311323.2C991F08@keescook>
References: <1564509253-23287-1-git-send-email-isaacm@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564509253-23287-1-git-send-email-isaacm@codeaurora.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 10:54:13AM -0700, Isaac J. Manjarres wrote:
> Currently, when checking to see if accessing n bytes starting at
> address "ptr" will cause a wraparound in the memory addresses,
> the check in check_bogus_address() adds an extra byte, which is
> incorrect, as the range of addresses that will be accessed is
> [ptr, ptr + (n - 1)].
> 
> This can lead to incorrectly detecting a wraparound in the
> memory address, when trying to read 4 KB from memory that is
> mapped to the the last possible page in the virtual address
> space, when in fact, accessing that range of memory would not
> cause a wraparound to occur.
> 
> Use the memory range that will actually be accessed when
> considering if accessing a certain amount of bytes will cause
> the memory address to wrap around.
> 
> Fixes: f5509cc18daa ("mm: Hardened usercopy")
> Co-developed-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Signed-off-by: Isaac J. Manjarres <isaacm@codeaurora.org>
> Cc: stable@vger.kernel.org
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> Acked-by: Kees Cook <keescook@chromium.org>

Ah, thanks for the reminder! (I got surprised by seeing my Ack in this
email -- next time please use "v2" or "RESEND" to jog my memory.) This
got lost last year; my bad.

Andrew, can you take this or should I send it directly to Linus?

-Kees

> ---
>  mm/usercopy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 2a09796..98e92486 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -147,7 +147,7 @@ static inline void check_bogus_address(const unsigned long ptr, unsigned long n,
>  				       bool to_user)
>  {
>  	/* Reject if object wraps past end of memory. */
> -	if (ptr + n < ptr)
> +	if (ptr + (n - 1) < ptr)
>  		usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
>  
>  	/* Reject if NULL or ZERO-allocation. */
> -- 
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project
> 

-- 
Kees Cook

