Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 485F8C06510
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D23D3218EA
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:42:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dzT2FZTy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D23D3218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11E856B0003; Tue,  2 Jul 2019 20:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CED18E0003; Tue,  2 Jul 2019 20:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFF648E0001; Tue,  2 Jul 2019 20:42:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B94556B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 20:42:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a20so336570pfn.19
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 17:42:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3+88rqRK28VKisC+37wlmaYyoSMpDKjaXlPRwLTc81A=;
        b=NmwPdHddHzl+Cn/OzmZtuE0ixa7Wi6WGI2/5AxJc+6yXIhtuL7GMzeTZeokvH137YG
         qfaFmgvky0sjkZVL2xSuyVG9UxTzodK22F/38h6vpWrrenJ+khkGqztCbFfT2mTxFzh1
         VteSRE49/6wx4OUmbYn8Qt2KXKQRGeUptdh+CjvoBv35EPJ+bhZwP2+E413iWNAuU+6A
         bVRwK9Ni5pfSrDSWHMSGLfJnABuLTCaEn9SMbWKDOAqCZc44s+rDrVnGtKPjsvLSRUYM
         ZdEM0y5nhfk7oo31N6vQNyHwv3nNe/EOAPlaxuiCILQORDErr/rcjVk7ra8Quh3OACDx
         +Tyw==
X-Gm-Message-State: APjAAAWA8efi6Or50oL9R+4WnhJOa7CjEl9upBXw4y1YV6FfUlDxIuaG
	LUmuH8dKhsUyf3n6NxLZqwX+AfrRfgJrza29nZEzO0oWXkauTGnE2T3nQagVL0AEPLYdSmRYZFL
	lCEX9qfjFR4W65cWXs9hJzkTj6vPNEpxjSXCE7U5tFF+Q7fsnnQJmIrE3HDenZZbrgg==
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr9149059pjr.116.1562114565142;
        Tue, 02 Jul 2019 17:42:45 -0700 (PDT)
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr9148999pjr.116.1562114564283;
        Tue, 02 Jul 2019 17:42:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562114564; cv=none;
        d=google.com; s=arc-20160816;
        b=bxjYBz3uB+qI1jibL49hOiqAaicWJDE9AeqCAnoA5asEEL2JdP/eeuV+YDnttoToH2
         8KuaiXeWz8El7SH6qConKTuLZb9rwq8Gehvr8HZm/Si/UjlkO63AR4FWUwjhu6k2ku1f
         ifgiDUt0EkStQMEfmW79Qobg1Bdw7DycsBqmQpheLoglQG/hdCzM9ur4V5Y5r3DrLNl7
         +dAdbohxPSV29MPEUCrN0NFc6L0gQrIdcDrO0uxTexC92WVZuKnfndr4wZaw8EmSoLcV
         /RzY0NACFvM/Xmdv7wecjfc1C2NKo4YW/VN74NG2F046ScTX1OkUy1X7IcOSdHX3Io5Z
         /ghg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3+88rqRK28VKisC+37wlmaYyoSMpDKjaXlPRwLTc81A=;
        b=J/SrS7eBg8v+/CE/4B3TqMDKDiA24XhERC5bSkkGONxnTF5JfPaoXj3VtyMRBRjqsE
         M0t+QroARLyylbHtZ+Hh/l5sv/bXlbgBi8IwbHdQT7xYmsdjDD50mQ4/PbLpTjnXYrrL
         bvLsxTJzu28fd0Lmv/V3bhfnBug4GEvV8/xcJpd2nU+3njqU75skmeGbCg9lSmZHc67z
         AyMyZxGfrPIJ3e9IBbmkuLfbMR8kUjnaPfwh2JTAVrHBfplVYHBQBDP+PUjrG+OceFrq
         vWq646iLiDSmn9AFOI8RP4BMSKJDgQEXxc5K+fjlPrkg0ooaYOGN4EaaKgOK/E2eYmtN
         6tAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dzT2FZTy;
       spf=pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minwoo.im.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a21sor165097pgh.0.2019.07.02.17.42.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 17:42:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dzT2FZTy;
       spf=pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minwoo.im.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3+88rqRK28VKisC+37wlmaYyoSMpDKjaXlPRwLTc81A=;
        b=dzT2FZTy6mtiH9VhpzQzcGg9srgeIi7ULRstbUxhYdbumgVyC/BccJNUTeeqM1JxeU
         /aJ5Yh18Qhitb2uNCOgrqAJCQJCooh5kppJeFISYa3vTW8w8SZxXSzU3q+z+Y8nFvLFm
         7UmoIeMOk9x4NdUuGct6yT4j/uqa59drJqUwOsnG7+WOlDf9pYrCXpOMAb1Ug0jw04yr
         SAPFSsgeuDtEdJsxFXFieMadb9VHG15xWRp9t7JYXycs9+fXJ9FIhQsAwh+12iAX31ay
         fdkmhF4pBle4Q3xXpB/fyTvqk4KZ8o4Aea0TaSNKPkeiHJQDb+qfydVF0WnF17USk+zV
         1U4A==
X-Google-Smtp-Source: APXvYqy4XjIjmrg7EOdGeLB40liOwbHKiGqRa8PnbMoJxGCcXUMnLbqCHk5S0oYvRWhq9TvOZCkYow==
X-Received: by 2002:a63:6883:: with SMTP id d125mr34024381pgc.281.1562114563831;
        Tue, 02 Jul 2019 17:42:43 -0700 (PDT)
Received: from localhost ([123.213.206.190])
        by smtp.gmail.com with ESMTPSA id p1sm250858pff.74.2019.07.02.17.42.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jul 2019 17:42:43 -0700 (PDT)
Date: Wed, 3 Jul 2019 09:42:40 +0900
From: Minwoo Im <minwoo.im.dev@gmail.com>
To: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org, bvanassche@acm.org,
	axboe@kernel.dk, Minwoo Im <minwoo.im.dev@gmail.com>
Subject: Re: [PATCH 1/5] block: update error message for bio_check_ro()
Message-ID: <20190703004240.GA19081@minwoo-desktop>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
 <20190701215726.27601-2-chaitanya.kulkarni@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190701215726.27601-2-chaitanya.kulkarni@wdc.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19-07-01 14:57:22, Chaitanya Kulkarni wrote:
> The existing code in the bio_check_ro() relies on the op_is_write().
> op_is_write() checks for the last bit in the bio_op(). Now that we have
> multiple REQ_OP_XXX with last bit set to 1 such as, (from blk_types.h):
> 
> 	/* write sectors to the device */
> 	REQ_OP_WRITE		= 1,
> 	/* flush the volatile write cache */
> 	REQ_OP_DISCARD		= 3,
> 	/* securely erase sectors */
> 	REQ_OP_SECURE_ERASE	= 5,
> 	/* write the same sector many times */
> 	REQ_OP_WRITE_SAME	= 7,
> 	/* write the zero filled sector many times */
> 	REQ_OP_WRITE_ZEROES	= 9,
> 
> it is hard to understand which bio op failed in the bio_check_ro().
> 
> Modify the error message in bio_check_ro() to print correct REQ_OP_XXX
> with the help of blk_op_str().
> 
> Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
> ---
>  block/blk-core.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 5d1fc8e17dd1..47c8b9c48a57 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -786,9 +786,9 @@ static inline bool bio_check_ro(struct bio *bio, struct hd_struct *part)
>  			return false;
>  
>  		WARN_ONCE(1,
> -		       "generic_make_request: Trying to write "
> -			"to read-only block-device %s (partno %d)\n",
> -			bio_devname(bio, b), part->partno);
> +			"generic_make_request: Trying op %s on the "
> +			"read-only block-device %s (partno %d)\n",
> +			blk_op_str(op), bio_devname(bio, b), part->partno);

Maybe "s/Trying op %s on/Tyring op %s to" just like the previous one?
Not a native speaker, though ;)

I think it would be better to see the log which holds the exact request
operation type in a string.

Reviewed-by: Minwoo Im <minwoo.im.dev@gmail.com>

