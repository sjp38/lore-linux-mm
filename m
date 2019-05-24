Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82933C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 19:44:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C34A2133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 19:44:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Er9FNhr9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C34A2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E7006B0003; Fri, 24 May 2019 15:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 897DB6B000A; Fri, 24 May 2019 15:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 786DA6B000C; Fri, 24 May 2019 15:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 588486B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 15:44:51 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id r23so9535915ywg.2
        for <linux-mm@kvack.org>; Fri, 24 May 2019 12:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ADEutigkZQvxy3EBwjlB2BuRYdbXhSOGTYdGfWJ/hgk=;
        b=M3VZFPFZoGsxbsz+xWxv/7oiYYP1fVlh1cAptX1tTZ23C4SXAkk13u9uwLOFriGTAs
         KTRUtINF2x4pqFXcdVEoTaAYHkmOKYfeMWBwEBh+yrmLtfskCqRd6ButGGVc8j02y2o8
         IZzEywbZMf/5Z3laXJgZfHvZBwosxmSqOlaWrt4//g4LuHP+EuEvz/RBrtDxl95+2R0s
         T8+OkpqzJk2XdFmUiylLosrWssZle1Ku/B8Dv7O88JyIQDl0aK4mxjHRcw+TUouMeK6m
         +DC4G6MJxh9Fgvb9/DqS/WhfzlbsvdpCbdwyWdtC8/0nsND7GBgw2yKp2Ksym0lho1+k
         YqfA==
X-Gm-Message-State: APjAAAX7Wmq6S2xCL0GoFMxZYqNey0fyrqo3RPwrjV/goYDeI6QztdZX
	fscoeeHqhna1I+CO3EBW1rv+Im9QWcpjZDVJBAY1SVxtr0ZynU8nKVMI4Xmq9G7seQy8lRfhr8y
	qwpxPFIvDt/YqT8KEjgM+kj82/KAbE0/seNmrY5RpDSGC9QmyUF5gc1N1CYJZjbXUkQ==
X-Received: by 2002:a25:f50f:: with SMTP id a15mr18242287ybe.519.1558727091069;
        Fri, 24 May 2019 12:44:51 -0700 (PDT)
X-Received: by 2002:a25:f50f:: with SMTP id a15mr18242264ybe.519.1558727090427;
        Fri, 24 May 2019 12:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558727090; cv=none;
        d=google.com; s=arc-20160816;
        b=Ud/x01Tv0eeDtry36sE9wZUIsbD029QpthEvJWogYS1KXbCW81bAvn9bde1eo1N0NI
         mL/VfAHcRo6kz2EG2mTq3NJf4A4XngzDSMtpEFVXFae9IzwPJmJeBy+TMO3zf+h9Tlke
         Uv+Cj6MhVdkE1adpBoCTpa2EgsFUZwsYzTfY6gw0ylKSQmvUWaQvKXzHfzXtHyT7DrNf
         lUxvJSQLFrbse5RTebOy8EROPAj8dALJhEEechr5lpUT1fvzWJhVsEnReWyHCS0al85R
         QKUks/M47kL1GsDBPP1U4b74q1B+h6fMyHwDQh1hDWs//noZ9GKT6jzr1dyRpF8edml7
         BSMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ADEutigkZQvxy3EBwjlB2BuRYdbXhSOGTYdGfWJ/hgk=;
        b=qWZDgbZKxBww7tBzs9fZdO3pyKn9WQ2syW0hjPoAg0oNUNwsiQzfZq/JfwazkUCwff
         qo67yFzphBOLp+Fnn29dFLCkkaZXDQlYiMcv3iuLsBwYVyDMOZU6LPyZm2y/S7TVbCfT
         OnDQViRHtsL1AX/VqoCArEaMujHYLK4zV/MxFl4sNRORLDacO1q0FDkWavkqA6EOI2r6
         zqMMbtG1CHWtX0dkAqOAY6mjhlPHdF0TTUeWrqYYmsEc5X3wfk9E6lZtWCxP6K3FzqKo
         H3b4D/IzBZiqS7bzRyBl7teHL+EhsKTXQnoK1XsoLg0FbUIE8uLGTFquKkZv17PW1yOH
         Dpug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Er9FNhr9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u205sor1811149ywf.203.2019.05.24.12.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 12:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Er9FNhr9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ADEutigkZQvxy3EBwjlB2BuRYdbXhSOGTYdGfWJ/hgk=;
        b=Er9FNhr9eg4ELo6L0x8EYqvzpTpab9TijYy1x8WYGrzCTaffnMkdDEaiQns3/5AszK
         GJXVhg7UJVB6K+VgJqeD5xsagjhKQrAvHoEqF95pUS12aIy7Mv1NLA4crNkU0onJQ1A0
         3A0FyTgXiEWKfVMcUJYDPl7FworQ1U9CfppjrlnKnX2RiqjsivzpMegz4MVi5cg7Yq7q
         HPKjoqLbxLr46mPY3lIg0TQkLEUXbclrW/GErPV4Gb75UK2cyYlMQe6E4Oal+BP2DZq+
         hGM1MnMoeGl8pJ0XCcjtJYKO3A9qvk5JEIumsdUXP9LkmpssUtdGzUKjm0Q/psK1ORYG
         lBOw==
X-Google-Smtp-Source: APXvYqypIZdiln4PLwmtk+QLb5X4U7MRP6LQ1aIjVkWxjTJtR6cQUSay/7LPwd2gr1TnddV4dndw6kAxArlu6UCxIhU=
X-Received: by 2002:a81:a6d5:: with SMTP id d204mr17941600ywh.205.1558727089835;
 Fri, 24 May 2019 12:44:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190524193415.9733-1-ira.weiny@intel.com>
In-Reply-To: <20190524193415.9733-1-ira.weiny@intel.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 24 May 2019 12:44:38 -0700
Message-ID: <CALvZod6skK6NxeRXjKS64+1jpF9NwbLp7DhpWueB0F6Tj4MNUw@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/swap: make release_pages() and put_pages() match
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 12:33 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> RFC I have no idea if this is correct or not.  But looking at
> release_pages() I see a call to both __ClearPageActive() and
> __ClearPageWaiters() while in __page_cache_release() I do not.
>
> Is this a bug which needs to be fixed?  Did I miss clearing active
> somewhere else in the call chain of put_page?
>
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  mm/swap.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a75722e68a9..9d0432baddb0 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -69,6 +69,7 @@ static void __page_cache_release(struct page *page)
>                 del_page_from_lru_list(page, lruvec, page_off_lru(page));

see page_off_lru(page) above which clear active bit.

>                 spin_unlock_irqrestore(&pgdat->lru_lock, flags);
>         }
> +       __ClearPageActive(page);
>         __ClearPageWaiters(page);
>         mem_cgroup_uncharge(page);
>  }
> --
> 2.20.1
>

