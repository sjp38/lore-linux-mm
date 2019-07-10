Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7CAFC74A3A
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:59:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71D6E20844
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:59:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="G2Jp6Kw0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71D6E20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E5518E0082; Wed, 10 Jul 2019 13:59:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 096648E0032; Wed, 10 Jul 2019 13:59:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC7158E0082; Wed, 10 Jul 2019 13:59:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B36378E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:59:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so1765169pfy.20
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:59:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ES97aFmR5L44lLqRIVOCJ8hUxBvKgXhJbYiu6/Q0/Fc=;
        b=r8GfrTUHHHjsVI84ZaAzDg4qLdxYRyOYgmKjFGy4yND4Mh34Qxg5BBGZyR6Ok6/G/6
         zfN4jOnVc1WxF/b/YUlNOiCX5gALSZ9d4pVDKUS709x3lQVAgu35eVfDL434Kq8pF+vq
         sGr62eD0hGuuy7tOkWl/yxWIMsmEbjeJERymg9s/zvAcyKTWS5A3cZFztbWM/ZzSAs9Y
         z7XQ+JpKnLnBdPOT5+HxSmnPnmOxrzTwn0BjY0epA5OFp+uyWvl1+Su6dc2H2wyrrOSX
         5Uoe4taPsHp1G8rCskH2pHk/yAYbaIOYmhrK8ayAQQvkOHaLntsIDov1AyQay5G/gF2X
         CLGg==
X-Gm-Message-State: APjAAAV+hS7/+r1NoiOf9FX6ylEEDpkAunv+kVPePIIeXo/NzT9boQJn
	R6cBlQ+lBdVpTZUS15Qc8nyeabyzn2VjJlg4iZZcWnVykkCT+tNPhcPVFGdADFy8C8de/Vr0c6s
	tQnjzGUPVtHdvkaf4yWsKQ8gnYNrGzDWG3gyWg45vzgQCqRjKi+UlePH6lsvqrx4Hdg==
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr40560676plq.144.1562781552408;
        Wed, 10 Jul 2019 10:59:12 -0700 (PDT)
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr40560644plq.144.1562781551830;
        Wed, 10 Jul 2019 10:59:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562781551; cv=none;
        d=google.com; s=arc-20160816;
        b=iPPcSLcxRNaSeDuCFW1jCFhBHsgyVQhJi6aH039KjjgcI4ULC0YzeT+hhZ+AKY0ZET
         daBlS7bkAApnk3fWfcmViRHFVwwpaD97GnaDcdBQu8f5h2x27yzkqY7Nh8Drutgz3soH
         haWAsHzqLZu15OrxTf7LHUvSs/tGJttPx3I7PJXgyJq2X//PMxYrhEgk+tcHbNm9OmhZ
         hRn03qfy58Qw3GIu2oaj4riloBRUN4MA9hecexEg1l8cwrynXH6xIau4AsbFpLaXi8Wx
         vpyNGwAfx6Qfr8oAPnD68YqaKtWb9VzPmh4WD/rY+6YcvcDPpChTBSALju0qpRS6VoZs
         CaJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ES97aFmR5L44lLqRIVOCJ8hUxBvKgXhJbYiu6/Q0/Fc=;
        b=WHdzZi+oWY6fDxVK1PRuKaaYWodZONIuiDEaCaAE+qX0/2fY6qVR+hleR3ywza94wl
         LYxMih9qXNb9Il54njNbwD5IGrASVkn4rvoTb4rpYzNXDJqGPWa9pK5cboEfYFRzocU6
         IJ+MpS2+opm/vvUehShdLwKXunWJeYoowDcdjAgP2lD5LmfmjQFszlvcdsxmt4NB4qM2
         AWbxjQpt0sqXSvJOaty7OFXe6EN44zbreu5puKYLjb3EgklaTCk8NpT1ovCKMkXajSVB
         YBOLEZPxJCoJ2+C+Bsn1CFDI31tCmAM4UKVdwqK0If57E8YoqTrmLysJC2Te7pCMzdM9
         H8hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=G2Jp6Kw0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor1545765pgn.85.2019.07.10.10.59.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 10:59:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=G2Jp6Kw0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ES97aFmR5L44lLqRIVOCJ8hUxBvKgXhJbYiu6/Q0/Fc=;
        b=G2Jp6Kw0GGV35fsgDKNHqJfaM2heLRlNcrWhIIyjt3IJlC+NnRqCSKz3hZP4Fu887z
         dLBsxgJdCYEXhvDJAp3WncuhblsZDmYVCC2kQkS4he/c15xnvz5aiyCqSdp9VDsJmtyl
         X4Xfx4ip5r0bjXUypnNqrUjDim4ROXbrVkV+AZoYurquMpsbvjV3UGR3mvY59J4Erd/Q
         HfxhW7ZRcsJPApUQIYhWqYnFzemVB04iMIOfP8a0p1Z57U4tObOxvtzDBBNj4fUP3H9H
         YllCevWMv7u9kprPq+Y6qJSXms6qEKoWNmdB8ooErkpLpmr/kzmE0sWEDfpRKKj3QL55
         8WVA==
X-Google-Smtp-Source: APXvYqyO4Vg3ye0b1RbrpmbLDKJYF/6XJJtpfFq/5KqsBldN0dxT158xtqFfP0Z4CzvYy6JnEEB0wQ==
X-Received: by 2002:a63:eb56:: with SMTP id b22mr38678975pgk.355.1562781548877;
        Wed, 10 Jul 2019 10:59:08 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id m5sm3325435pfa.116.2019.07.10.10.59.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 10:59:08 -0700 (PDT)
Date: Wed, 10 Jul 2019 13:59:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 3/6] mm,thp: stats for file backed THP
Message-ID: <20190710175905.GD11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-4-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-4-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:43PM -0700, Song Liu wrote:
> @@ -413,6 +413,7 @@ struct mem_size_stats {
>  	unsigned long lazyfree;
>  	unsigned long anonymous_thp;
>  	unsigned long shmem_thp;
> +	unsigned long file_thp;

This appears to be unused.

Other than that, this looks good to me. It's a bit of a shame that
it's not symmetrical with the anon THP stats, but that already
diverged on shmem pages, so not your fault... Ah well.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

