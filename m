Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC4C1C10F0E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 01:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 146E420879
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 01:23:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="Zbc+c/tj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 146E420879
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 517856B0005; Sun,  7 Apr 2019 21:23:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49E736B0006; Sun,  7 Apr 2019 21:23:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38E046B0007; Sun,  7 Apr 2019 21:23:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2FBD6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 21:23:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t17so8803541plj.18
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 18:23:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:content-disposition:dkim-signature:date:from:to
         :cc:subject:message-id:references:mime-version:in-reply-to
         :user-agent;
        bh=Ux048TmV854h+e950bXokICm1VWZROCck0ccAamUXr0=;
        b=r2YrthpkKi9BiQiNeE9I1qdiPwnKXOY7gAMXZMJcSAKv7YOkC7TvG6tyTUZjbXRQGl
         E5f7vsFLc5K9CbRFJdyvBwvobgH29F4ZhxSjgZKwE5XVX0LMgQOrz2hNzflQRk4piPfK
         nAJ4r60KpYFyN9Pe1MyMZOkRrESdj+MgydJDBBlW9ZLkxybARybmVR0OTWvo3tAC4Pfx
         LkBL+CgzX8wN5fxxjqjIxgJojEUrOZZ9TLlv1JLIkJGuV5Uxf12Ca3AcZgRIW/ACfccf
         k8+/SniC0iei3IZtkqUZmLCGKsZLN4OY9pAz1yIQ5ng7GkmLHeGXbf9gkfo8eCsfXrpv
         8fTw==
X-Gm-Message-State: APjAAAV2RQI0zXGW3SlqwmIWaNF72gtQni0+Dm7RM7HyP5+uO6okuoBS
	9A/fbhsemF/bhIOWrVH52M9JAREwyzhb77DJH7sVua3K4b8QSVn76EYwYVSfIkBPvlU7BJ6ahn8
	M2JlZbCTAIwXADHmyeE6MF4SAzbbMZvz16ZgeCSEt4K35nqf8tMOp8Vl5Kh3yh029UA==
X-Received: by 2002:a63:945:: with SMTP id 66mr24473619pgj.128.1554686606437;
        Sun, 07 Apr 2019 18:23:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxObPIvxDa2KEISXYWPo43t3nMoNk/wPR/u+CdGe4vqrcEHOJCHlMAdeeayHDez1f3NK6Aw
X-Received: by 2002:a63:945:: with SMTP id 66mr24473558pgj.128.1554686605437;
        Sun, 07 Apr 2019 18:23:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554686605; cv=none;
        d=google.com; s=arc-20160816;
        b=So3CfPIHQ9/+3pi575x2JwdEYGk1JVB/m++HN08U5u0vN24DEZhJQ/8As+wgehpedb
         Vp0KNkWWCdYChmJdA3NDnoU1AaZklSqF+1IQqVXURyrA9it5Ttn5cLTXrc1ZSjBeXZOc
         VoT5QqDPF/hUW7k0dXFVZP0UN9z3q94D0hm8+86tCSseuGY1qinCfHkFKRNzDm35ZxNu
         IAnVVAJCCacs20erNOP92k3sNav33X63pFK2flTX8JXMd3yh195HnoPcP4Zi4sTMaxe2
         QPXvJvHr5i/qj4CYFfvd/v2Ld4kw1qJWF0mDqc4Y2WGSWJAP+QAmHlYw7qqRliePW1rn
         7KNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:mime-version:references:message-id:subject
         :cc:to:from:date:dkim-signature:content-disposition;
        bh=Ux048TmV854h+e950bXokICm1VWZROCck0ccAamUXr0=;
        b=R9Rf5aeVIUompCmXYT9PXXDqayF4nYjnraKUrZrhsF2Vd5HuhFRdafm2gt1FSdpYnF
         xSVwz/kfLdsEIVaCiKZeSRFvqmpbhDhIwKviCIwP6cwSp7CPY13lEY+ZkccTJ/VYiv5n
         ziH+vyKxTCDiczKbVRO+sOjQSqU6900ulvZxkQduSO44CjuKtundCUKCLV3ftir83naQ
         5Ubh+iZvf/5DlgcyEkT5OSHHZMuxB9d7FWEeNmQLZ78MaiBb+rK4YCVb8G76yxZhNlMM
         GPE6Q0ElUhRznJQjpKwuYQfr9AlqZu7F5zECZzfXtsa+Jj0i1o+rSixdr96KpLAtQVFp
         v6sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b="Zbc+c/tj";
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id h187si11314923pgc.287.2019.04.07.18.23.24
        for <linux-mm@kvack.org>;
        Sun, 07 Apr 2019 18:23:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b="Zbc+c/tj";
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-78bff700000078a3-78-5caaa28bd427
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id 22.E3.30883.B82AAAC5; Mon,  8 Apr 2019 09:23:23 +0800 (HKT)
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554686603; h=from:subject:to:date:message-id;
	bh=Ux048TmV854h+e950bXokICm1VWZROCck0ccAamUXr0=;
	b=Zbc+c/tjn6VUUGy7gHT+rvKNJnbSpGkvqNlxx5CXMucMs21p//6rIXdkO+/THtZae3SDSXz+hZM
	AloXWfy1olhnocsuAnEPf1MhRrZfCCkRpesAd+0Fl6WMgQfap04teimdi94j/nLFVieD0OgWKFIqA
	lCZ/bjkmFE2Rm3TjdhQ=
Received: from hsj-Precision-5520 (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Mon, 8 Apr 2019 09:23:23 +0800
Date: Mon, 8 Apr 2019 09:23:21 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: Ira Weiny <ira.weiny@intel.com>
CC: <akpm@linux-foundation.org>, <sfr@canb.auug.org.au>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/gup.c: fix the wrong comments
Message-ID: <20190408012320.GA11988@hsj-Precision-5520>
References: <20190404072347.3440-1-sjhuang@iluvatar.ai>
 <20190404165046.GB1857@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
In-Reply-To: <20190404165046.GB1857@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-105.iluvatar.local (10.101.1.105) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFnrNLMWRmVeSWpSXmKPExsXClcqYptu9aFWMQesJDYs569ewWex/+pzF
	4vKuOWwW99b8Z7XYuvcquwOrR+ONG2wei/e8ZPLY9GkSu8eJGb9ZPD5vkgtgjeKySUnNySxL
	LdK3S+DK+HaMrWAHR8XO1sUsDYxn2LoYOTgkBEwkjk7i72Lk4hASOMEosX9XP2MXIycHs4CO
	xILdn8BqmAWkJZb/4wCpYRF4yyTxfPELZoiGb4wSy6Z/ZAdpYBFQkVi29zqYzSagITH3xF1m
	EFtEQFni9L+rbBBD8yUe3ZvNDDJUWMBU4s/GDBCTV8Bc4uhGf5AKIYFsidWXPoB18goISpyc
	+YQFxOYUsJN483ED2GmiQBMPbDvOBNIqJKAg8WKlFkhYQkBJYsneWUwQdqHEjIkrGCcwCs9C
	8swshGdmIVmwgJF5FSN/cW66XmZOaVliSWKRXmLmJkZIDCTuYLzR+VLvEKMAB6MSD++N7FUx
	QqyJZcWVuYcYJTiYlUR4d04FCvGmJFZWpRblxxeV5qQWH2KU5mBREuctm2gSIySQnliSmp2a
	WpBaBJNl4uCUamCaOV3o6p1NBisO9qzcL1O4fstiTe1vL1xUFTd83KEi0b6i7IpZ9pIXjBW+
	5+S/HX1jejbrrpf0bNaLNW9d/tk+vXsnc5XWnQyRLWJFN7deZzsheaS72f60XcXT4g9+9Tvt
	O6dvc7Bcv2PGrFOfjx2zTp//zdNngYvC0g3ZXlV/24LTBV3VlX6wf7ueeXDBL5t/J/ieyEgf
	3cTe4lPQfWZi11nlojVlx+u4P7fvZvDauPHkhnkVT5q/c0pGVAb+XDj/UKld4IfKayc+bpe9
	uNGvqUHD+aZ1T8JJCY6pa55N4d22y9+Zg3VWn/15cevgeboMDs/Xnvr06P0TwS3S/DqurWls
	G086WpiX2RpJyLtOUWIpzkg01GIuKk4EALCAxvD+AgAA
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000009, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 09:50:47AM -0700, Ira Weiny wrote:
> On Thu, Apr 04, 2019 at 03:23:47PM +0800, Huang Shijie wrote:
> > When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> > get_user_pages_fast().
> > 
> > In the following scenario, we will may meet the bug in the DMA case:
> > 	    .....................
> > 	    get_user_pages_fast(start,,, pages);
> > 	        ......
> > 	    sg_alloc_table_from_pages(, pages, ...);
> > 	    .....................
> > 
> > The root cause is that sg_alloc_table_from_pages() requires the
> > page order to keep the same as it used in the user space, but
> > get_user_pages_fast() will mess it up.
> 
> I wonder if there is something we can do to change sg_alloc_table_from_pages()
> to work?  Reading the comment for it there is no indication of this limitation.
The sg_alloc_table_from_pages() cannot work if the page order is wrong...

> So should we update that comment as well?
Okay.

I will create a DMA patch to add more comment for sg_alloc_table_from_pages().

Thanks
Huang Shijie

