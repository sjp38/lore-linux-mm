Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6060CC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13321205C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:04:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KTfyAoLB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13321205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B42886B000D; Tue,  7 May 2019 17:04:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFBA66B000E; Tue,  7 May 2019 17:04:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BB416B0010; Tue,  7 May 2019 17:04:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 659FF6B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:04:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so11097471pgo.14
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:04:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Tp9MHM6S82XiPQpC6c6jLekBkf9kgfqCZQyGw89KOqE=;
        b=XvRpTTg1OPxic0noeJUOCJkX8JzX9esEAx7yznSVJC16CK1GCN62tpdnFAybwQNmJg
         A5w5o0sFshhN9YUyBSV3qABKFfXWg9q1Q4BP1ZWeYc/cmIVnvnmVPJ35uMi05FoqkXYE
         nYPB4FaV92goqAhKJMpH6Ng+xYKeuk5A/gGzujXpg6+wNcPrFFyKrtEYM0vNsDajD9FX
         2EMsvQD9Jz9oIIsYy975AVkNCpaMwdlFncHVAJvzFL0RPVz5WtQKay73hN+rVOp5bUwI
         EsN+fdf4Qim0y0+iaQdvzxrMZRBdTdJMuG5wt7zHBB4G6S8B42ekkIUI9NqYwrQkHBV1
         5nAg==
X-Gm-Message-State: APjAAAWyPTk+hycMPjD8GcZWqVttbAXIqpAYKL54lUIIiHXnMGR48dqF
	/rhCXSQ7s//S/CnRFRj0pVWZRNiwzlQ/hYC6uVwQMYtV7tqrrDMmyvSQLrPtCvNbLRU+qc7vqfu
	97J51u8vRJ6asYIp/3dT+1yHM81j+G8Lzlj+zaxgojGHc8cOGYxX+wBv30MSLdKruKQ==
X-Received: by 2002:aa7:8e55:: with SMTP id d21mr43563917pfr.62.1557263087950;
        Tue, 07 May 2019 14:04:47 -0700 (PDT)
X-Received: by 2002:aa7:8e55:: with SMTP id d21mr43563852pfr.62.1557263087243;
        Tue, 07 May 2019 14:04:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557263087; cv=none;
        d=google.com; s=arc-20160816;
        b=hoGkrcB/gAKLF44EII+Og9W4GoaGjfDJMgvBKShuL5HcjlLjsDT6Vt0tLUifOXmmoq
         JGwHvph+TRfsz3+MMLKHr0D7VZesCY/wBPUoFiqRvFmS4mffryAFD6uud2BjnDTK9mKf
         IM5rphwugrkEi0Dimc9g7mU/MVw6jYT2Ul1184Hr98zbDsW1+s/qrQJYE6sZD8kf4k0e
         +cAOyOlaFtFniezNkYr4OUwx67ZsLfuVuneMGYrZeHmgF9171UImdRHUM4NtDLQaOR1n
         LBwO1KS6xV4HariMKYcy3/Alzh1QVCjhcbMXnrPPv8nv4oo0Ul2+s7Mwsxltju4V6k2D
         EzYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Tp9MHM6S82XiPQpC6c6jLekBkf9kgfqCZQyGw89KOqE=;
        b=pKsLUA/8gnec5x0xhlf93hGKT+Nn/++4Xq9+jjlw974EYQ1EkOY8jmJP+jVxUFcMEa
         7ARRIlp3OhL6XJ423QEYXRJ9A12c5mOeUekjdzWI4F0g+lGUJ9kOAKSa0EZnmfvWueup
         7OWwsloObjcgzcVaKk6QeuQfKoBfB6aXiUx2AdBaiYIEnqBAZEtSutkdfwADTD8khxWr
         akvL2jVVTJwe7o+Di+6Rpq1MWIFm6WyjvbEPa7nX56PQ5i2BJTqVIFGXaTUfM/BUUQG/
         wElBm8+hpVWsb8ZQgqnWkfC4spuhTQ5+L3ifAOkVGLuOL7ims0BgFvmz2gkzYDUdbjxd
         0r9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KTfyAoLB;
       spf=pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yury.norov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor10594721pgb.31.2019.05.07.14.04.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 14:04:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KTfyAoLB;
       spf=pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yury.norov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Tp9MHM6S82XiPQpC6c6jLekBkf9kgfqCZQyGw89KOqE=;
        b=KTfyAoLB21CgLn4vV+DeWm27Z0NxxbAZXzSaXHMVtSC6cam9l8ioBG5uvVhsSKhamD
         5O8P15XSzgMcT/aYJ6UID2M634g4V0M18eMkOog2O/53+5MJUBFoNjUQ9F7KCvtIlc4F
         B7frY+UwvuCyqkixc99UccY4Q4r/WBFLetyaU1tp/0auaUSzitr5YJbs0NRr/EXsA/jO
         Qyum4xwKpBUibLnDJd56JqbnQhzMKlTw48Fm+bceoOk5CPJFQlg4L/CGlS/yDMrG3cxg
         d0npEcAiUhLIsWEerZF+tsXsVCqSY4NIlXXm2r0szlHmhPy19eJTu1TlNSwo9/sG4/Cs
         +ZSw==
X-Google-Smtp-Source: APXvYqzflAmUTQydzxJ4cjPRW0WIecf2bKx2yQBktISYk/b4xLlIZ0c6pxz/B7pjskqQcN+h0MZuiQ==
X-Received: by 2002:a65:6496:: with SMTP id e22mr42445689pgv.249.1557263086677;
        Tue, 07 May 2019 14:04:46 -0700 (PDT)
Received: from localhost ([2601:640:2:82fb:19d3:11c4:475e:3daa])
        by smtp.gmail.com with ESMTPSA id u66sm5867753pfa.36.2019.05.07.14.04.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 14:04:45 -0700 (PDT)
Date: Tue, 7 May 2019 14:04:44 -0700
From: Yury Norov <yury.norov@gmail.com>
To: Aaron Tomlin <atomlin@redhat.com>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Yury Norov <ynorov@marvell.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slub: avoid double string traverse in
 kmem_cache_flags()
Message-ID: <20190507210444.GB8935@yury-thinkpad>
References: <20190501053111.7950-1-ynorov@marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190501053111.7950-1-ynorov@marvell.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 10:31:11PM -0700, Yury Norov wrote:
> If ',' is not found, kmem_cache_flags() calls strlen() to find the end
> of line. We can do it in a single pass using strchrnul().

Ping?

> Signed-off-by: Yury Norov <ynorov@marvell.com>
> ---
>  mm/slub.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 4922a0394757..85f90370a293 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1317,9 +1317,7 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
>  		char *end, *glob;
>  		size_t cmplen;
>  
> -		end = strchr(iter, ',');
> -		if (!end)
> -			end = iter + strlen(iter);
> +		end = strchrnul(iter, ',');
>  
>  		glob = strnchr(iter, end - iter, '*');
>  		if (glob)
> -- 
> 2.17.1

