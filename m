Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 664A4C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:14:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1965E2086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:14:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lUaKgKHU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1965E2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A34066B0003; Mon,  5 Aug 2019 00:14:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E4C46B0005; Mon,  5 Aug 2019 00:14:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D4196B0006; Mon,  5 Aug 2019 00:14:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5733E6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:14:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so45470229plj.19
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:14:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mva09u+yn1RWE+TO1luNzBDnrlH/Q/3QfIfoFJtdBKs=;
        b=B1rrJc87rQBUOKByF6zx2DvNtmhqGMcyx8v95C30h8t7Uts9WGd486zBXqCPW/qUg4
         pGSMmJLr0a7PXL/C8U80MbdG7vGaJ6TXyCrPzTs1JtvgRjRFe2rLafuzOSXRZ7OzmG7j
         ayVGV6CJXHgli/BMV3GKfTvWnpd+axmjKO++eu8fKPM+xBWDqX7B5e09Ug6F9qFqZFTe
         cxp+idRWf1raDi82t9EeSGxwZiubFrtI/C/FgxwxTEc4zeJfT11VLC/4IWqXbTGa8WAR
         9dBxfd3Enu9N2lrm9NpjYqNF9kUyQfUtjUOjxg4MgklTdkvT0fQE5tDmbh8Aa4pf8F+r
         fItw==
X-Gm-Message-State: APjAAAUgQmHphOJ6Cz3A1vgF56p9qwN2KSFPENbMyy84fUuHWgh44TGy
	80L5NST0e02dUNmUyy5IQuhIA+Li97mG9X2bH0Q/0yH9hz0rGjqWGt4m/cCivtT6FPiHPoYAO67
	zS4tlZFcYREmKOJpdTWLSDh7vi/T9khZpZvCxJgVKAQQK9Rw2vG0DANvZGynKcCY=
X-Received: by 2002:aa7:8102:: with SMTP id b2mr30143872pfi.105.1564978487974;
        Sun, 04 Aug 2019 21:14:47 -0700 (PDT)
X-Received: by 2002:aa7:8102:: with SMTP id b2mr30143842pfi.105.1564978487228;
        Sun, 04 Aug 2019 21:14:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564978487; cv=none;
        d=google.com; s=arc-20160816;
        b=RpWECAx4RzPdP3bPxlwkVrdETMVTpvYHdToFCAQ4ZPRXWkcXCw1VW3D7G92S0cUavo
         k0n+TaaE8zGy87Yfv3hOUwfeYc0OvXbFyvjRH1AHEYqWP0CEBt9WUVcQ8JX93hNl5bGB
         QDOKJKxmhQ/sMlVKf+HrOcLXKYNptigjokqdY2puY8IQt/eGeBTsuloUuaX8xq+QpQ7f
         t3M0EW/sqjBMpyZKQVhBuzDFU00Xr+QJ2xci83Qly5UskTr1ghyWoJpoU8cT/2aSmrTM
         4rzATmNnASan1HAOkKuxfnOpo86I2l69eGhRgx8A7Dk0u6zfzTGW6uqHs8Q9YVwqTPRf
         vHIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=mva09u+yn1RWE+TO1luNzBDnrlH/Q/3QfIfoFJtdBKs=;
        b=vJzCcdoE3f/zBZS/pMaVOzTslaiALt+SlgaLCgOB5b7JTE9jxYS0UlcbjKSwgOv0Mj
         FKOoeKZcPDnnimt9S6VX4uqYRmkXmX1KvVETn+2Fm79exhsks7ZsHfOScVV2Fbqh3KJf
         YEw2rtD4o8m0yY3qxiWAICknlU60TiSjxFzfOQZLGc+hU721tnhm9GUruxK4xIzz2RZL
         2imGLXNazjhjzAjFxKYAecVeXayXHX1kyjrwBGnUbniRZgzvZFKu93a1tY2ddKn7H+HP
         YHBwl0oQxz+R9zcOEL+OTpty9iFgMmQsIWUP0YYv0AMYaXK6osR0I+cx+dzygwtdTxZU
         MWvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lUaKgKHU;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q25sor29358901pgv.12.2019.08.04.21.14.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 21:14:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lUaKgKHU;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mva09u+yn1RWE+TO1luNzBDnrlH/Q/3QfIfoFJtdBKs=;
        b=lUaKgKHU3tYV6FVsndghO1nh62VmLyjBz+gnRDFzMtyQSKeK4kyNlKt7pfyVZI5dP0
         lCmU53u7ZoMWT0GjNCzqnOSqZsjasDVwlPCqu3E04EBsomGuC5AAi2qOnGX+T6kdDxni
         dV6o/haUzLnNpKhvlZ15NuuJvVzUEFuORq2wb6M+ExKwYLtMUDhXsmnZ6PSmWyr8PWxE
         V0kct3Svkq8vUoVZOO289g/Yw0Wqon93UAVktJZ1iuJxKV0PoU8euDaXateelJ7JSx9o
         f40OBUyRw88R3NWa2O8csPHoyge5AVZZPF8py8aCAYxVK8+Dltiuo2QpqUbwAnXmRmta
         HM1g==
X-Google-Smtp-Source: APXvYqxu85q5rU7e/DgfZCTuChdmrDTsIJLsBcmb1yRybucaAu5vmnJlY6V1Pxkezx8ce2esQ0uBSg==
X-Received: by 2002:a63:7e1d:: with SMTP id z29mr134680099pgc.346.1564978486557;
        Sun, 04 Aug 2019 21:14:46 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j1sm115888081pgl.12.2019.08.04.21.14.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 21:14:44 -0700 (PDT)
Date: Mon, 5 Aug 2019 13:14:40 +0900
From: Minchan Kim <minchan@kernel.org>
To: Henry Burns <henryburns@google.com>
Cc: Nitin Gupta <ngupta@vflare.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: Migration can leave pages in ZS_EMPTY
 indefinitely
Message-ID: <20190805041440.GA178551@google.com>
References: <20190802015332.229322-1-henryburns@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802015332.229322-1-henryburns@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 06:53:31PM -0700, Henry Burns wrote:
> In zs_page_migrate() we call putback_zspage() after we have finished
> migrating all pages in this zspage. However, the return value is ignored.
> If a zs_free() races in between zs_page_isolate() and zs_page_migrate(),
> freeing the last object in the zspage, putback_zspage() will leave the page
> in ZS_EMPTY for potentially an unbounded amount of time.

Nice catch.

> 
> To fix this, we need to do the same thing as zs_page_putback() does:
> schedule free_work to occur.  To avoid duplicated code, move the
> sequence to a new putback_zspage_deferred() function which both
> zs_page_migrate() and zs_page_putback() call.
> 
> Signed-off-by: Henry Burns <henryburns@google.com>
Cc: <stable@vger.kernel.org>    [4.8+]
Acked-by: Minchan Kim <minchan@kernel.org>

Below a just trivial:

> ---
>  mm/zsmalloc.c | 30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 1cda3fe0c2d9..efa660a87787 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1901,6 +1901,22 @@ static void dec_zspage_isolation(struct zspage *zspage)
>  	zspage->isolated--;
>  }
>  
> +static void putback_zspage_deferred(struct zs_pool *pool,
> +				    struct size_class *class,
> +				    struct zspage *zspage)
> +{
> +	enum fullness_group fg;
> +
> +	fg = putback_zspage(class, zspage);
> +	/*
> +	 * Due to page_lock, we cannot free zspage immediately
> +	 * so let's defer.
> +	 */

Could you move this comment function's description since it becomes
a function?

Thanks.

