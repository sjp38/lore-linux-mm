Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5EFCC5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:43:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DA9C218B0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:43:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IGZ30bM1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DA9C218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 192516B0005; Tue,  2 Jul 2019 20:43:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 143308E0003; Tue,  2 Jul 2019 20:43:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05A038E0001; Tue,  2 Jul 2019 20:43:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C55BA6B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 20:43:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so344575pla.7
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 17:43:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6y6EFOhHrVmqN2XOhvdXRL5MBH9KN4a7EwEf4TQ0LK0=;
        b=oE5McNB9wBRZkaagJaov9y9wHeJU1yUMyWQY+0S6+Jq/kBGZOIde3vFzhni/FKWeU6
         KmxYnt13uNa/50mfaLg6pWmfqyh3AJakt6QmnimDkVO8yAJ1+j0AzEhKYF1G5/WWbweA
         eYuaSe+OGp0upKTC4sybv3LtwFQIfyNabrajhPRB7FAK2tIgo5/kSIWuyquV/5PJpMp9
         33BAFgDyM++ih2IX7QwlQyX1OYQRpsK6WKU+/UVc9uTkJpo2jXeBenuEu6R/V7qNGwrQ
         NCYiE+naj58LOLQRXK7+atrVGsHowvPZgtpXknXS1QYwcQ+EGhrXhc+rchCq4DkK8uan
         nakQ==
X-Gm-Message-State: APjAAAXBWPNWGER2/4uUXX2HmT7oT/J46lWzz9kf9crLIIlRxxn5Fp4T
	Z2HQEqcXa6bTyoNSocxoD51vWtzI3d+QSqAX/XZG/y+YTNoWp/ann4Jb6jQtHyk6Rws0ROl5ky/
	PJ+WFPp2+6nhEnpZcnAHoGvgA8+D8FD3O5opJCWlcFq4bhkXmO3DLsKjN+sL0Yq2E5A==
X-Received: by 2002:a63:4404:: with SMTP id r4mr33023290pga.245.1562114624247;
        Tue, 02 Jul 2019 17:43:44 -0700 (PDT)
X-Received: by 2002:a63:4404:: with SMTP id r4mr33023224pga.245.1562114623089;
        Tue, 02 Jul 2019 17:43:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562114623; cv=none;
        d=google.com; s=arc-20160816;
        b=Rsm6cU2TRJj2SfsVio2swxoad7P9eqqJ4r0xT3/mLe826lHuNUZnvroI13zhSWwZZ5
         8CPZnC94PYM0Tibgxaux5u5c19WinwjO7kHhOcdYCkBw1VQfI7Pq9fnSVMdiVByhthtp
         Km2aZ3DvtjwoZoTfAqBYanV0LUjFfMSx1CuhWLNUrDR9XwxyWCPv1NlG2HQEfHO1+bz6
         7U4k9eh/pxK7SrgRE4yCCOcGRd3XVH5pONv9mSwThj+THJ2PF7iqWK+5ZxBYFCpEMUtE
         rKKGqbnsqalQb3e8zwzMQEst04xD/ciTo0SypiAtjYhzzfd/ra/Za6Lqp7/dCusmDwmt
         fyYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6y6EFOhHrVmqN2XOhvdXRL5MBH9KN4a7EwEf4TQ0LK0=;
        b=Hu+QuEPZA0g+OZKgiJzTu0bmrP20ySSWBeBB5F3R5B+099aFYQ5Ek8oyudSSDv/K5K
         McVGwzLHAfCv463lEnknH72sqlPcpfzDS1Ul5G1HkeoP4NM1I5a8tkY2DeLSMwVmH+pi
         21RfeI6BML+WhllZTHg69Qv79V0SFk/Sc/4hgjdckrtcCEEk8ILa2/g1zl6qSm2+wkvG
         //cFYkkdl3e+qx+oKE1jhGR8PkIHKmyZEENo+lcsFAg5aCt59GGOQt6KCeT/T+z67nYu
         aAaavVnixYRadZH8dz2U+j+cUWqN2sWMQseLvmVJcSAd/0RhhOFFjhpU29VADfYjUMji
         c3OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IGZ30bM1;
       spf=pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minwoo.im.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor585721pjn.7.2019.07.02.17.43.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 17:43:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IGZ30bM1;
       spf=pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minwoo.im.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6y6EFOhHrVmqN2XOhvdXRL5MBH9KN4a7EwEf4TQ0LK0=;
        b=IGZ30bM1JVOPOn2JA+NtaBwtZCElZa9uYzP2ylrANUFzTjF3Dkq+iNvLaqjj6ix+aI
         nA9de5UEkcculTGHTzdEEqH86BophVqKEYvPU/4MzbqKfjg5aNWMPotTKTUCCJfYv4GC
         Sqki0kHHRXESEW/X/WuNKhTc7IwRgrT5Wq63SJFIDle/UzSEKQNVu43wzYot67CTK+w8
         khrhvDwxf3kLs+57Lp9vhz8bFX4E+0eleOJGyivbAE7Y47ZUxmvjGcu8vitfSedQfwS7
         9ZblMYQvJWsSx7YNwQSS2rziLFiGrVIbLCMChwYj8jsga+TpenASB/ufRQ4vCyekZjkd
         vfwg==
X-Google-Smtp-Source: APXvYqwXN0YlGyDKipGp+Wa48c4rIIsx1oMVVP+Ah7qzo/SOpMyEZfZSGlOaFzcqOjVgqeCapgZUug==
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr8626932pjo.97.1562114622776;
        Tue, 02 Jul 2019 17:43:42 -0700 (PDT)
Received: from localhost ([123.213.206.190])
        by smtp.gmail.com with ESMTPSA id h18sm262259pfr.75.2019.07.02.17.43.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jul 2019 17:43:42 -0700 (PDT)
Date: Wed, 3 Jul 2019 09:43:39 +0900
From: Minwoo Im <minwoo.im.dev@gmail.com>
To: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org, bvanassche@acm.org,
	axboe@kernel.dk, Minwoo Im <minwoo.im.dev@gmail.com>
Subject: Re: [PATCH 2/5] block: update error message in submit_bio()
Message-ID: <20190703004339.GB19081@minwoo-desktop>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
 <20190701215726.27601-3-chaitanya.kulkarni@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190701215726.27601-3-chaitanya.kulkarni@wdc.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19-07-01 14:57:23, Chaitanya Kulkarni wrote:
> The existing code in the submit_bio() relies on the op_is_write().
> op_is_write() checks for the last bit in the bio_op() and we only
> print WRITE or READ as a bio_op().
> 
> It is hard to understand which bio op based on READ/WRITE in
> submit_bio() with addition of newly discussed REQ_OP_XXX. [1]
> 
> Modify the error message in submit_bio() to print correct REQ_OP_XXX
> with the help of blk_op_str().
> 
> [1] https://www.spinics.net/lists/linux-block/msg41884.html. 
> 
> Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>

It looks good to me.

Reviewed-by: Minwoo Im <minwoo.im.dev@gmail.com>

