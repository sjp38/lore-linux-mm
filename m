Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8211CC4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D7A02175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="PzhRlRiD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D7A02175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D27DB8E003B; Thu,  7 Feb 2019 10:20:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD80F8E0002; Thu,  7 Feb 2019 10:20:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC76A8E003B; Thu,  7 Feb 2019 10:20:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 696338E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:20:41 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id o5so44802wmf.9
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:20:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Fc9DvEkHcUwCuUOY+cpjz1+btZOTY1PROVPScsLLvpw=;
        b=DMn/s/zkeQtok4oPIKmQckcQ1eR4CPVBtflZADXLH0Fxv6JurbW42thn67iipQbL4Z
         aMQm7u3jXMvcX/4l0o5Banf3ObCrDz6HLBl1vqo0OgroHkRwigg9ooaF5izfreP/rWyx
         9b61q6eEIZyQI3cmf5IsmcJUmrMKASWiBKLbeBjIBHoxLaIMP209EbNxzCweQqWEqacU
         nFk7wp4fhbbiH+YrgICfoasfTdsIEyVCtXF4QwR1lMeCU/wNyNCPyTEzlcopsOPRXral
         UVFDl09y4yf0uskJd5OTtaeIkzAgwyOBFaQoN56XuUDx9tbKXkrbCe2SyaLSQcml9qCp
         ezpg==
X-Gm-Message-State: AHQUAuYcgvrYPmf4aGT2J0Pj3xcRELpev+G7/cOxfSz1axxUw2YtjZut
	qeP7XYUkOunXpNuAirtxg/JKCGJX4ym+LJWbGwwT4EYyE5r4BwHLQGzkaNoo2ooQvlbQXnl0pOu
	5x04NR/PG8xlFu1jpkus3+qfJ6n0f2Jij8tkaeB3DrfQkS5uNVXXm5KHxa+rKbnWg9PLVcHGnd5
	jsD2/qtteU3v/g5TvMCQqi/wZOPDd1awvfYPTeExNmtyrPimySDlGNtfikRa7c0H/6J7RsicilG
	bPO75RNOah3w+tCQ8Le4/eiV3PBs33AYTGhIT+GCcBWpc2/FW/fgJodh3mvq2/2c+2PbrJg6PHq
	OXBs33bAyDUeKVErRXy1pd7KsD679t7/EyJbFqLmGw1OCQz8mtfWS6pIPlzxKwfM2TpeT5gbU8C
	M
X-Received: by 2002:adf:f8c1:: with SMTP id f1mr12449503wrq.31.1549552840955;
        Thu, 07 Feb 2019 07:20:40 -0800 (PST)
X-Received: by 2002:adf:f8c1:: with SMTP id f1mr12449439wrq.31.1549552839903;
        Thu, 07 Feb 2019 07:20:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549552839; cv=none;
        d=google.com; s=arc-20160816;
        b=VaX4KWTtZNsywg5lqaNOZfHVmd/2g+yOI//noKAMwxiFo5TEmNzsjUhTILDa5CUrtD
         sYKExYuLDJ5r+La3Z9BE/tjUj6jz+p4GSMrqDiDXUf5/kCZq1qTr1LEaLMxjhggXM7wG
         gTuRaN94fWn211siWTC7Ue1d5o38SyKKaALQJ396v2XCmxUaF0y7rgZdBpgH8qf8cx6R
         RHU8C3z30ou41AsdTrFiWXB1epGnsMAgZFfR5GYgwm79W3WUuKE19Mzsnh+bRtVSDNlO
         sRDSdy0S050O5kfdiT2M8swgYiL6ujm1KJKDWY2upa4Z6G9SiBM43pgAlBgC4UBn8tN2
         iulQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Fc9DvEkHcUwCuUOY+cpjz1+btZOTY1PROVPScsLLvpw=;
        b=B7uDBQmtc1gXtK7cfb5mLWdIW4AkvNNBeZXt6TZYU35CKevuiZN09FHFzlLOLb8/F+
         wD3QaGSeZCfHZOnv9xFM+k0Hfd7XTnXIxBbQcyChUwVZnZqPvC1vJ1hcacAZ7gfFq1wU
         hU7+bZ4ivXZ5TEHHpB4kfnecqwvNxIU+K3dU6dVJ2vn2D5aZpUnrwFpkvkWSJW+Ag7jV
         waDlJ0+FnoQtC4F164kWuQhC3JTr7h004zpqt9ZEs4biGKgEyoMj/GzAvxTm1RZWb2wn
         5DbS04waJPX6Iy+72ILPQjjsAeXuTE+p0KwZxcfdlAhR9aeN2T20TnbdiDzw+6MIAFTe
         DJMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=PzhRlRiD;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor2403608wrm.35.2019.02.07.07.20.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 07:20:39 -0800 (PST)
Received-SPF: pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=PzhRlRiD;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Fc9DvEkHcUwCuUOY+cpjz1+btZOTY1PROVPScsLLvpw=;
        b=PzhRlRiDHbKDSY4TEyF4EPGZkw2nxzdq9QrAVani2UiOmLUBH0GQWp7CqZ574ALC3/
         VHW3tzhqO/X/NS4u3jv5ESlkPOXjMwt4nafPO7y0Wvi+2nUX01aa8GzGp2nkA8G4mTNL
         sSRs8KMDI5zSgUHyapsCfIU2clxhCsONPeLPriJbew7rwPwfuRDkvG2w6wm1pdBcew3m
         Sqb7TmIw+xCKrKUmFBEnVyXVM0yr/zJMj1qpWC/n+zBxZckMCkCij49g2JBOec/h90UF
         DMKPbz7VMdkvH4Yq7kZGRQZ8wBkv0xVtrmBiHHGj7UWi283qR96wChWpKLrSCqvxCkRz
         iG9Q==
X-Google-Smtp-Source: AHgI3IagW/z4YKwVwgn5Kh0Lg5P5qgSV7tXprEIYUoqCLnxXOCYV1fRFYUB/JpVjkIZAG9mrz/12xg==
X-Received: by 2002:adf:c5cc:: with SMTP id v12mr12299552wrg.176.1549552839294;
        Thu, 07 Feb 2019 07:20:39 -0800 (PST)
Received: from apalos (ppp-94-65-225-153.home.otenet.gr. [94.65.225.153])
        by smtp.gmail.com with ESMTPSA id q21sm14133082wmc.14.2019.02.07.07.20.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:20:38 -0800 (PST)
Date: Thu, 7 Feb 2019 17:20:34 +0200
From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: brouer@redhat.com, tariqt@mellanox.com, toke@redhat.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	mgorman@techsingularity.net, linux-mm@kvack.org
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190207152034.GA3295@apalos>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207150745.GW21860@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On Thu, Feb 07, 2019 at 07:07:45AM -0800, Matthew Wilcox wrote:
> On Thu, Feb 07, 2019 at 04:36:36PM +0200, Ilias Apalodimas wrote:
> > +/* Until we can update struct-page, have a shadow struct-page, that
> > + * include our use-case
> > + * Used to store retrieve dma addresses from network drivers.
> > + * Never access this directly, use helper functions provided
> > + * page_pool_get_dma_addr()
> > + */
> 
> Huh?  Why not simply:
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 2c471a2c43fa..2495a93ad90c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -28,6 +28,10 @@ struct address_space;
>  struct mem_cgroup;
>  struct hmm;
>  
> +struct page_pool {
> +       dma_addr_t dma_addr;
> +};
> +
>  /*
>   * Each physical page in the system has a struct page associated with
>   * it to keep track of whatever it is we are using the page for at the
> @@ -77,6 +81,7 @@ struct page {
>          * avoid collision and false-positive PageTail().
>          */
>         union {
> +               struct page_pool pool;
>                 struct {        /* Page cache and anonymous pages */
>                         /**
>                          * @lru: Pageout list, eg. active_list protected by
> 

Well updating struct page is the final goal, hence the comment. I am mostly
looking for opinions here since we are trying to store dma addresses which are
irrelevant to pages. Having dma_addr_t definitions in mm-related headers is a
bit controversial isn't it ? If we can add that, then yes the code would look
better

Thanks
/Ilias

