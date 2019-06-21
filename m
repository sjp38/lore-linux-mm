Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86EF9C4646C
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 20:58:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 366F3206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 20:58:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cuDC9qVS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 366F3206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B695A6B0003; Fri, 21 Jun 2019 16:58:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B195B8E0002; Fri, 21 Jun 2019 16:58:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A08158E0001; Fri, 21 Jun 2019 16:58:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 649E66B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:58:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 59so4246040plb.14
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 13:58:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=8yYOqvu5kX2LRYKzF9g/pziCLKwTlUixwBsdMp/H9Nc=;
        b=W0zBqrmqGIuPe+evLWkBZyNOL7F5tdqdkgDKLcCmtLFyDDHoL1nZw2nc0KDAkpNy8y
         PgE5RZsu5XYf6dpDe7vas6kr/6wpysEaVx5750Ea51DAsRLdiaILe2uTDXyUL2wKBNfk
         wVlrYCOqRqlbDbgjbG6y75WhF9m25ia2i0uf8+W27cGYZLn6BQB55xfhxRJWIn+vq06m
         v2D3mj9P9nMvS7hwZPz3hxKwwN7+NUYRChFCsEzH7alTcPT8X81DZ2e5pugFt6P7D1t1
         EHPxL98UcwfPMALgAJePHF0vTQGd89PKcFN8fLlfKXlj7UdhQz5BHhRgOU9EoAP1fQOj
         9VWw==
X-Gm-Message-State: APjAAAUO1ywDysGBpeF4tHuahhVUgx5FiP637xvGXwaID6xcTYjyLeDe
	l/aVl/+kzFgCJ2zzP3lsroJAuISlvBlE6xBnoS0y7YlXEPCw626fnKmOQyocsVcIP8eLbNFOEu4
	EcGCem9F99Ri3x2iOKUcf4y53/q9Lw4uj3rL7P7sWmcBFSqx3WEI9Vz9c9dAx2fHJbA==
X-Received: by 2002:a63:7c4:: with SMTP id 187mr14360653pgh.90.1561150690886;
        Fri, 21 Jun 2019 13:58:10 -0700 (PDT)
X-Received: by 2002:a63:7c4:: with SMTP id 187mr14360618pgh.90.1561150690153;
        Fri, 21 Jun 2019 13:58:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561150690; cv=none;
        d=google.com; s=arc-20160816;
        b=X7QhdGDWQ5ODW6+okkTtqF+vuRXsJ3CUv4EehsPEiWoUZ9OHVcGCJjXNHbeBEmSkOV
         qZJPSVuf1/3P6ckmSjigEJbCJLJGedyy1KYnt6wBLcgZOEtrrvd0jGnuPXM3ROmbwM+M
         t/b+vTrS1A8Xxrk4Dzd/ERPICrP89pmxTZ+YRK8oleYUe5Qag7rRqzIeEhOZ/yP9OrN/
         mFk6VXsPncaKjLlcTJ8lmvRWpLp+v0yFSTHuj1P5+X7XRsu14KmVYF/bQa1xYQYMl+Dx
         vKKoLGbsSLoypqsnYqJAEQt4PxgPncOQR4PNfoy1WiN3Tp2Smo4NWK9UueYAe1rDGMEf
         XRFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=8yYOqvu5kX2LRYKzF9g/pziCLKwTlUixwBsdMp/H9Nc=;
        b=IJHWWwOZn0GuDSF6Sa+9FC4tIM8O4kapjur7Ydw6084yp98DHbYplbipAL9uWe102e
         oFGh+Jfu/DvbXNsGvirvZfqAVjQWuMTg1Epdrhczef1XXwmaKJP8iFmf5AH96srjKDZ2
         MtU7hC5DcsE6gXq7A294m169ZCMaXH3F17B602CkW5yWMaoGKoV8jo5qaQUt1nxURVdi
         K+fNT+SbLB6MgOIUPGarYSoMKn4Fhu/JrZzGhmNh8zzhsyIHyox4EmFSbkmvQ78m1cr4
         r6PaLuyaIgyZBtvfS0lSXjwRMV55RJAWSwhSGTKfNpQUpcAB/UWpvgxwVZIJlcPhZQX9
         lQHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cuDC9qVS;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor5555005pjt.20.2019.06.21.13.58.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 13:58:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cuDC9qVS;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=8yYOqvu5kX2LRYKzF9g/pziCLKwTlUixwBsdMp/H9Nc=;
        b=cuDC9qVShlq//zw6GpvnrOHJFr1tcJ4HACKd/9B6u34xyHNjsW0OOZZDRgr1qM5/Hp
         M0EB1zZM9gs5L8IJxIQGhXyVdveLkFnCOdJvfz/4XhENaTANN3GCW8/cP3RIrws83hYf
         NjmDQ0cqNT7vUgF56dqnL3z2x4Gapjcups6HVuJqAMMa/NjkniW/WC2yI0x1gkc+P1oR
         x+W55orwr1MH5BNxQsFA9adhAFgSOApJrYCp+37QsyH3D9VgVufcKKcs67USdy54C/lM
         H/QFupT5whQ6zNnOb0NQtQr+1v35QV8uptQ7kg+pJdyJOUZxnqhRROHJzPv+icVCuj+Y
         QuhA==
X-Google-Smtp-Source: APXvYqzENl1koEQxTi7C5Y8/9tx1iueVhtL6QRrM0tus5wsF6Daa6W5Dsr6LEZDlBw4XS9jAkYfZew==
X-Received: by 2002:a17:90a:2562:: with SMTP id j89mr9083829pje.123.1561150689472;
        Fri, 21 Jun 2019 13:58:09 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id h1sm4763129pfo.152.2019.06.21.13.58.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 13:58:08 -0700 (PDT)
Date: Fri, 21 Jun 2019 13:58:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Alan Jenkins <alan.christopher.jenkins@gmail.com>
cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, 
    Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, 
    Bharath Vedartham <linux.bhar@gmail.com>
Subject: Re: [PATCH v2] mm: avoid inconsistent "boosts" when updating the
 high and low watermarks
In-Reply-To: <20190621153107.23667-1-alan.christopher.jenkins@gmail.com>
Message-ID: <alpine.DEB.2.21.1906211357560.77141@chino.kir.corp.google.com>
References: <3d15b808-b7cd-7379-a6a9-d3cf04b7dcec@suse.cz> <20190621153107.23667-1-alan.christopher.jenkins@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jun 2019, Alan Jenkins wrote:

> When setting the low and high watermarks we use min_wmark_pages(zone).
> I guess this was to reduce the line length.  Then this macro was modified
> to include zone->watermark_boost.  So we needed to set watermark_boost
> before we set the high and low watermarks... but we did not.
> 
> It seems mostly harmless.  It might set the watermarks a bit higher than
> needed: when 1) the watermarks have been "boosted" and 2) you then
> triggered __setup_per_zone_wmarks() (by setting one of the sysctls, or
> hotplugging memory...).
> 
> I noticed it because it also breaks the documented equality
> (high - low == low - min).  Below is an example of reproducing the bug.
> 
> First sample.  Equality is met (high - low == low - min):
> 
> Node 0, zone   Normal
>   pages free     11962
>         min      9531
>         low      11913
>         high     14295
>         spanned  1173504
>         present  1173504
>         managed  1134235
> 
> A later sample.  Something has caused us to boost the watermarks:
> 
> Node 0, zone   Normal
>   pages free     12614
>         min      10043
>         low      12425
>         high     14807
> 
> Now trigger the watermarks to be recalculated.  "cd /proc/sys/vm" and
> "cat watermark_scale_factor > watermark_scale_factor".  Then the watermarks
> are boosted inconsistently.  The equality is broken:
> 
> Node 0, zone   Normal
>   pages free     12412
>         min      9531
>         low      12425
>         high     14807
> 
> 14807 - 12425 = 2382
> 12425 -  9531 = 2894
> 
> Co-developed-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Alan Jenkins <alan.christopher.jenkins@gmail.com>
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external
>                       fragmentation event occurs")
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: David Rientjes <rientjes@google.com>

