Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0599BC48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C122E20652
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:19:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="gJlLLhHa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C122E20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B39A8E0006; Mon, 24 Jun 2019 11:19:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 562F78E0002; Mon, 24 Jun 2019 11:19:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 451BD8E0006; Mon, 24 Jun 2019 11:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10C3A8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:19:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s195so9577121pgs.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:19:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xk9Y9/4d1P0hhiRulYC6/59GayfnrTydVvyulmj2MA0=;
        b=A3Bg5MncPZnOY/EES8v8vHwjhjXK3R4TG/bzrF7rCzaLWeMWPHP1rIemctEx5wCO/S
         aJbWhJeZKtsD2SQlP054twYRyEA80S2ZC7N8lHeivNW88NwkbkY63eu4mM1qgSomo9AX
         sbLUQTdfv4u5b1QtlSVGYaaSE9ypCyJ/8tHg2gfVgwHgH9fjHYgKKt2C9PxfklXbNxQQ
         qYPNqOPCkLcHWkf9p7Pyo0pHI+25OOCnKKGh8EJg5i/Uty+oypSXkXJLe9L0z8puA73f
         2ihYndBDki2tLSbqLfXPq52o6GEKv8bA+yF6ZWozNrQroFFmLDbGxYtv/P5XsRk9S8h7
         VI1Q==
X-Gm-Message-State: APjAAAUEv6MOCMQ+i9X8xFRTa6gRJpa95XFOjpL2vdYg3aYEabsFkY6c
	BRn6JrNPwPV5sIzzW+Jvc0VE4tgA1vut3T2HsN9tRv80vTfUjOBeCgXj6ITKZD1kqM3JHljiUH0
	W8dduWl3SJRTvemlXrK3Za7bB3ola4r62XxnpLF49qu8ETfwGAwl/R3xaxa75ORwQFA==
X-Received: by 2002:a65:6204:: with SMTP id d4mr33160808pgv.104.1561389569591;
        Mon, 24 Jun 2019 08:19:29 -0700 (PDT)
X-Received: by 2002:a65:6204:: with SMTP id d4mr33160766pgv.104.1561389568942;
        Mon, 24 Jun 2019 08:19:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561389568; cv=none;
        d=google.com; s=arc-20160816;
        b=ce7bkfT1Ekx9we0RLiqIe92XiWD+jG2eO0ZUt839FO2PRTQcI8ZliziMzFtakV8+AX
         +0OAz+VBjb4MhzVGbF6FaGloo8fI09z8dbVY7dtXXjLrta+ovK6dHP85QUu8qSUEaMTz
         9LPJtBOvWbLpYgTEDTqctfaLGpE3HUcj3DDQNmdl/YQk950ur3zGmZGxL3FgZ+bTYWQ9
         NGMGHxXKW9YY0aoFZjP4y1tD/+DVXGWrIudyISfDcPRWB/61a1cnu4hYnKFz1c15dEPd
         Z9heLWeBPF552u6+YWS3DF423fGZGGwXR/RrRDsRexlFxAS+FCj7FvG7JJD1Cnx0cW2M
         X0WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xk9Y9/4d1P0hhiRulYC6/59GayfnrTydVvyulmj2MA0=;
        b=kINCpby05F3M/xQQNWvXREgViu+N+oYmk+xbgpgMokwuk0xtAO7A/mHKPGnUalqy0a
         Me8Syws7gvibgOPJsyw2cPRgHNcfYrrPeRVx7xvwq7akKElvuF1GqYcDmp1+dY/CdYVi
         lmq9N5JXt9q4yOnZet1gy2V1Hl5Sh1aDGyIZ6iDQY8XU+l5R7sMe2cS7c8xMxEODh9mu
         b3S6gCZxP68akJkysO75HQCpq2irhXOVY95CTU/xRM1kiqNIE0Xnh414sSVcrGmpPEbJ
         jqA5SEHwTT0M0oiOaW/IWQ2ut4Oitrh6QUk3yhQoTT66OKva9sFZzjdDuTInsyzb46Cj
         lPcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=gJlLLhHa;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h70sor15337295pje.6.2019.06.24.08.19.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:19:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=gJlLLhHa;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xk9Y9/4d1P0hhiRulYC6/59GayfnrTydVvyulmj2MA0=;
        b=gJlLLhHaj6Jvm1bCaUN3ZW2zumf00y0LQxCLkUqwaGzxFCYZiFYQ8rTczXQpCRZDpw
         NtK5q/uM6I5V76gghSg5fmbJ43CHbwtS081cohfzOJ6io4WFLGOcoXgaTyWCbMrjkAsj
         xY9qHxrZFwQHzIVemFHx4ljFg0oGqYce6edkh2yeRRpwJiU/trCjsIhFgezWhFJcCgqe
         H4Scl/FXgMov4Q2yD8FeFxw798h6RqiToCrKV5Bs2iobxW0/QAamUc9TkSldXFyswImI
         Apxtk2c/8886Fs7QUpgFAYPFhvHX896Nq/69H5XW37lFOXvRa0xmPRdWgvt7Lc42nHf+
         rPsw==
X-Google-Smtp-Source: APXvYqwFHGQOnQnTXhDr9lU4NK1+H6IcL2ndUHa4gASx7rxzeny46s92Ldbi9u0yLFNEg+G6B9aOGg==
X-Received: by 2002:a17:90a:ad93:: with SMTP id s19mr25538029pjq.36.1561389566146;
        Mon, 24 Jun 2019 08:19:26 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::d3ed])
        by smtp.gmail.com with ESMTPSA id n2sm10152216pgp.27.2019.06.24.08.19.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 24 Jun 2019 08:19:25 -0700 (PDT)
Date: Mon, 24 Jun 2019 11:19:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: fix page cache convergence regression
Message-ID: <20190624151923.GA10572@cmpxchg.org>
References: <20190524153148.18481-1-hannes@cmpxchg.org>
 <20190524160417.GB1075@bombadil.infradead.org>
 <20190524173900.GA11702@cmpxchg.org>
 <20190530161548.GA8415@cmpxchg.org>
 <20190530171356.GA19630@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530171356.GA19630@bombadil.infradead.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 10:13:56AM -0700, Matthew Wilcox wrote:
> On Thu, May 30, 2019 at 12:15:48PM -0400, Johannes Weiner wrote:
> > Are there any objections or feedback on the proposed fix below? This
> > is kind of a serious regression.
> 
> I'll drop it into the xarray tree for merging in a week, if that's ok
> with you?

Hey, it's three weeks later and we're about to miss 5.2.

This sucks, Matthew. You introduced a serious regression to the MM
subsystem, whose process and patch routing you largely bypassed. When
I encountered the problem and provided a reproducer and a fix, you
gave me a hard time on cosmetic grounds. I incorporated all your
feedback, and still you show no urgency to get this patch or a fix of
your own into mainline. It's your bug, please fix it.

