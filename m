Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0116C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 03:35:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84E4320679
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 03:35:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84E4320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA18C6B0003; Sun, 23 Jun 2019 23:35:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E29D28E0002; Sun, 23 Jun 2019 23:35:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF1888E0001; Sun, 23 Jun 2019 23:35:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAAB56B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 23:35:20 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q62so6426809qkb.12
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 20:35:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q7r1SCrGj+cABhAsdI9scHILzcZN9C8bHg5KYKCxm9U=;
        b=bL5ONyUXoGlrPLgy22e1IJ90O06h7jPC4TCBRSKpqFVP17WG8kt5hHWpyzLGP0FIig
         VwxNsBYBokyCgl/obGnOiex6Cz93ZkE8nG8G6R/C/1atRp2VD56t88Hy8jQrsAMv7ctH
         3ryYMytNMRwV6gqdbrxcwsllVgv2ICt7SyJKRKG3amw2GNDdktC0pPr4+UucxcQiTPi9
         lHHgbhv43IzMUSemL1Cr8RpFcMZ09vJOiHka7mEI5Q51TrswSpUqckeio08QDCfrjXJD
         sUXJ96zFb0ZMbME6HCMbElNm3tHQ56Y8hu+UbxWhuI0NpdBiA3aFMZBmOXQJkIyErH0v
         cnnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUz9BtTpSUyHRIw6RR/EjRdxM2ZKEQx7qYh4qz6V2Pd4sBtxrFw
	MnP5kKuPzM4tJVh8X4momerzecY2O6NdymCXSWimwo7dPTQu91J7+NnrDkaoNHAkniHktxj2Oic
	jC+svmkdMGtYD2mU405y+F0v5dgTzVaPpSI1PZ0c70UVlinsKnQS8xv2bTkEqmbW9jQ==
X-Received: by 2002:a37:e40a:: with SMTP id y10mr41239097qkf.303.1561347320455;
        Sun, 23 Jun 2019 20:35:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8WMojbCzzwAqZ5EGb/EbRtL/sMNs3ZFB1GL2pPt1MO6HWZlj7YLJMqpZM77yRu1jYW8IG
X-Received: by 2002:a37:e40a:: with SMTP id y10mr41239082qkf.303.1561347319812;
        Sun, 23 Jun 2019 20:35:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561347319; cv=none;
        d=google.com; s=arc-20160816;
        b=EkVkHqorrnTNMKmZh8H+FS8+8fKk4JY1zhMOYQoZQ5RWhJcQTxmtjUyFP1WN/8y9Qo
         +Rtgp6XA2Sm0HSqMPUsHy0sXA0KMAGzaseOCqFomd7hNnqlDW0ek6GRITXuXg52tS91u
         soCi9wvoVKQ4FPyU1xleEn0rv/gO77sG+4xzMoO9tv5MlyrWxd/7sUQgPwExROiRMC2P
         ZGudxzRa2wJ/uFFCZJlvSGusvy+JR8c6uA7V2WIhc5BFhnGQxeMAb7wUhDTjJ5PbiDOi
         EN+Vg96NURmPDpwGCAPQ75vtCbcYrcD0+k/cLVKWMtuv2VJqILx+TtR335UpsbgLILN+
         CkKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q7r1SCrGj+cABhAsdI9scHILzcZN9C8bHg5KYKCxm9U=;
        b=fTkiYlGKeriBYKobKV1usjkivGLYpa6YHSY3uYqcjRYuHhVodlHUuIF8DlFkOPYkYJ
         /uMhVh1m6uagxqZh6DCMOni+lfcCDbOPMfAveELpTXJ1M0dyupipTALvIWhSFPkC/TRi
         lkazcjL/8xfHvbdTmVvuXz/r0hijq19SEq/DK2bnIa9Lq6pl7nw8BPxlamXhVmDDyjSg
         Foi+wCT5M/wKBePfNSQ3wHaqJ3vECOSBoGPmPPUmsmP8ile6QO87BlUSaYcdXRAAs+CR
         bORacBCCgbEBSqXtI4Y/xJEiPaV83AwjKh32bKJkT1xBsaVGrvYE5p5E/ZQcDih1TvH8
         tSHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 75si5492262qkf.358.2019.06.23.20.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 20:35:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8A6FD85546;
	Mon, 24 Jun 2019 03:35:04 +0000 (UTC)
Received: from ming.t460p (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 953A719C65;
	Mon, 24 Jun 2019 03:34:45 +0000 (UTC)
Date: Mon, 24 Jun 2019 11:34:40 +0800
From: Ming Lei <ming.lei@redhat.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>,
	Rik van Riel <riel@redhat.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm] mm, swap: Fix THP swap out
Message-ID: <20190624033438.GB6563@ming.t460p>
References: <20190624022336.12465-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624022336.12465-1-ying.huang@intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 24 Jun 2019 03:35:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Huang Ying,

On Mon, Jun 24, 2019 at 10:23:36AM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> 0-Day test system reported some OOM regressions for several
> THP (Transparent Huge Page) swap test cases.  These regressions are
> bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
> 256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
> is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
> fail when swapping out THP.  That causes the OOM.
> 
> As in the patch description of 6861428921b5 ("block: always define
> BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
> THP to swap space.  So the issue is fixed via doing that in
> get_swap_bio().
> 
> BTW: I remember I have checked the THP swap code when
> 6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
> and thought the THP swap code needn't to be changed.  But apparently,
> I was wrong.  I should have done this at that time.
> 
> Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Ming Lei <ming.lei@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  mm/page_io.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 2e8019d0e048..4ab997f84061 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -29,10 +29,9 @@
>  static struct bio *get_swap_bio(gfp_t gfp_flags,
>  				struct page *page, bio_end_io_t end_io)
>  {
> -	int i, nr = hpage_nr_pages(page);
>  	struct bio *bio;
>  
> -	bio = bio_alloc(gfp_flags, nr);
> +	bio = bio_alloc(gfp_flags, 1);
>  	if (bio) {
>  		struct block_device *bdev;
>  
> @@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>  		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
>  		bio->bi_end_io = end_io;
>  
> -		for (i = 0; i < nr; i++)
> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);

bio_add_page() supposes to work, just wondering why it doesn't recently.

Could you share me one test case for reproducing it?

> -		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
> +		__bio_add_page(bio, page, PAGE_SIZE * hpage_nr_pages(page), 0);
>  	}
>  	return bio;

Actually the above code can be simplified as:

diff --git a/mm/page_io.c b/mm/page_io.c
index 2e8019d0e048..c20b4189d0a1 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -29,7 +29,7 @@
 static struct bio *get_swap_bio(gfp_t gfp_flags,
 				struct page *page, bio_end_io_t end_io)
 {
-	int i, nr = hpage_nr_pages(page);
+	int nr = hpage_nr_pages(page);
 	struct bio *bio;
 
 	bio = bio_alloc(gfp_flags, nr);
@@ -41,8 +41,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
 		bio->bi_end_io = end_io;
 
-		for (i = 0; i < nr; i++)
-			bio_add_page(bio, page + i, PAGE_SIZE, 0);
+		bio_add_page(bio, page, PAGE_SIZE * nr, 0);
 		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
 	}
 	return bio;


Thanks,
Ming

