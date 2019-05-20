Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97BF6C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49AA721479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:57:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m7aNIAIk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49AA721479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED4EB6B0006; Mon, 20 May 2019 18:57:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E85946B0007; Mon, 20 May 2019 18:57:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9B796B0008; Mon, 20 May 2019 18:57:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEB86B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 18:57:55 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 63so10652843pga.18
        for <linux-mm@kvack.org>; Mon, 20 May 2019 15:57:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rQtjqxgsh4qf6+R3w9WQYkuPaS8z+4gcRAW4fvUK8PA=;
        b=tR0n0InkaYzhiGRP2xzeCSHeyEWDouFiHn0vbyuJ4AIp7F339+b9270tMOiI75M7oS
         B9wQv6byomwuLW9bHd02r9axbTAFUFui0qlQIEvCSmpFNY67Ak032w2MKMeRDysu6ECT
         Bzl55Yw9qv+HUswWWf7WVHn0ygMV4HJMMJOo8LB6kUYGDYrFwExrWboCeiTURN9JAUTz
         J+rqt3KijDpxKSPL50mfI9zjH3x0FnPBgi1ugkf6tEEHIeFoLE51OmEpStnBMgjrh343
         Y9WlPIlRc1ex5RXfisL9omxtVNVIxtndv+Fqa6KEd/mLshDA7iYVT5D5Ppp49cD1C6OB
         hX7w==
X-Gm-Message-State: APjAAAWD7lnSpg8LcJm1qZf47DrUE/RqV/S3E6OBZEpNfzCh7oR0FAn/
	xt/IljP8qu7khQV8jYuNOUAAYfszPQJnH2YLPNhLI/1Lvr0J31vKPadG1QTwZrREHtTmqSgMtZO
	uamcSwLQyCgFQ/MqpoUPTEaSkoKhSqPpyZDAAkkVmV327FoVfpB2JeSad/Oi9bBw=
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr29187991plz.242.1558393075273;
        Mon, 20 May 2019 15:57:55 -0700 (PDT)
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr29187940plz.242.1558393074625;
        Mon, 20 May 2019 15:57:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558393074; cv=none;
        d=google.com; s=arc-20160816;
        b=iivPUaeZp0lwlvpRYhK6F8r+Y7UZRCxp3IHCFJNZVMscIKzrXwdGxcZABJ83WTqaKM
         ML1rBKO5q9r+rAev/nKWWOee4iOxQbduI7uJ5Q47R7cOeQJ/IQSNd1K1LfyQ/yW3P22r
         lndjVpkVAW9/w5ICBIe2ATM5HZY6IugkbRaC3mng2+OfRv6jeBsVw2TMfxcFddCA/P1w
         0xGhN0sgNKmT58l6xpcPi6h+Iy+jvJTrrolgx+YaErZ0NrUETPCb7LfYm7nTCeEKcEm5
         2DngwCBCan+eO45lwskq8gI89kQcoCGlH6ah3B95ZFPppoF4T4iWN9Ve6F+honu6wHAS
         /L8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=rQtjqxgsh4qf6+R3w9WQYkuPaS8z+4gcRAW4fvUK8PA=;
        b=caimGjuHRRc5YVg1o/7M3um1OfdkuoMwZz5TcopsTPWKn3a5/PW3vYiQtaLwknX6yp
         1E83v4tC32nr4rwxSaf9+18i2b15nVlE4qRzrqqLoYsslpSWxJoXjNODoIhzvWnf0U/H
         2MONzPBf0h/tVWY3OZalzr0H7dVT7/4//snVIR9EHje3eF7DtDH86Nt5ICitvppYRK4Z
         YoKkCI+5wGQZq9ZZ5oH6SmWgNQ/SdmOYtWmCGI0R8Ffm6nXjs0FEZ0JWzNJqXpPuYV/9
         Rbso08a/H/CsKbiFpRwgIRAsLqKGJwwlLaRioU1KK0Ki27O2V86RuDeSUghur6tYTJW8
         71kA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=m7aNIAIk;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p12sor18300919pgb.29.2019.05.20.15.57.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 15:57:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=m7aNIAIk;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rQtjqxgsh4qf6+R3w9WQYkuPaS8z+4gcRAW4fvUK8PA=;
        b=m7aNIAIk79+/sPSFc8fsRue1WTcfLQ8h+JWoFZXgVHRSWPcaDmTrdh2j+iJlwHBNR1
         kwey7G7A9RXpSCKWyHw8TA+JzwwkGnBZjJ0vbyimyDXjx5C1hKIVvd8Q8dX0cZ4lcJ9o
         XML8DCo/iN2IH8D7C5fERQqQoZC/nm8IcTRdNgue67JmDMKAJB3sRPErJISlHY9Ybh0r
         ZvUrzLAmJnogN16jrMiwuZQQeM0Ii6VWbaEet9CTcnlSo+16+HfcIqeSoUMaBdHr1Jxv
         xiGCrW/ywdc1H/6KqtEL1x4uKxUdk7ujhb2S+x5m3BnNVky7FhAaJ4BLr8lEsF6XFN+y
         bDsw==
X-Google-Smtp-Source: APXvYqwIpXfTnN6FB15wCLD1NBqVQmTzR/Ojff3wL4gw0pzgL9CWZ1vxbSQt9fyp/BOgC/3Ksq6cRQ==
X-Received: by 2002:a63:dc09:: with SMTP id s9mr37019321pgg.425.1558393074279;
        Mon, 20 May 2019 15:57:54 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s66sm20733434pfb.37.2019.05.20.15.57.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 15:57:52 -0700 (PDT)
Date: Tue, 21 May 2019 07:57:47 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 2/7] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Message-ID: <20190520225747.GC10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-3-minchan@kernel.org>
 <20190520165013.GB11665@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520165013.GB11665@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:50:13PM -0400, Johannes Weiner wrote:
> On Mon, May 20, 2019 at 12:52:49PM +0900, Minchan Kim wrote:
> > The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
> > as default. It is for preventing to reclaim dirty pages when CMA try to
> > migrate pages. Strictly speaking, we don't need it because CMA didn't allow
> > to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.
> >
> > Moreover, it has a problem to prevent anonymous pages's swap out even
> > though force_reclaim = true in shrink_page_list on upcoming patch.
> > So this patch makes references's default value to PAGEREF_RECLAIM and
> > rename force_reclaim with skip_reference_check to make it more clear.
> > 
> > This is a preparatory work for next patch.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Looks good to me, just one nit below.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, Johannes.

> 
> > ---
> >  mm/vmscan.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d9c3e873eca6..a28e5d17b495 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  				      struct scan_control *sc,
> >  				      enum ttu_flags ttu_flags,
> >  				      struct reclaim_stat *stat,
> > -				      bool force_reclaim)
> > +				      bool skip_reference_check)
> 
> "ignore_references" would be better IMO

Sure.

