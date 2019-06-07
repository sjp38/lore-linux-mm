Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10637C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:31:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB57020B7C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="XgOcttxF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB57020B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A4A66B000C; Fri,  7 Jun 2019 09:31:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4562C6B000E; Fri,  7 Jun 2019 09:31:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343A06B0266; Fri,  7 Jun 2019 09:31:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2486B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 09:31:10 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so1851797qtb.5
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 06:31:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zyyI11Z3twoMqyf467AVpMwpHxurGKneH7RYfifhIWc=;
        b=lidyLE2AZf057JjKOm3uC34JPEjJp9e5UL2sjfdVDb4DOrR1oxjdi0RU3mxEjRqy7/
         GPcvU0+IAUqAsyCikavg/feyl0C9MXyqxc4JE1oLGijsaMfIDCbWUdAcYb8lYwnDBi6t
         IgN8/++9bUBrzuar402MzSfWbfuTLHsZDO1fj6OfoljIBqLwle5gqlX/C+eBfx3Iqpas
         l5xOxOx27qOA5Ay3WJcAd5ozS2noUtGt7oSAZqH1CmcyHoybBH4KzN9JAoOjXX8F0Hlx
         IJufRej//uyBOxKF/Hsdmorf2a4/pf1nLtEs2B8WHtCBL8Ei6d8YMY54JoFm8odFs7eq
         3Uhw==
X-Gm-Message-State: APjAAAXu8po0QR9sM3Od7e9ZbYKgtm3d746s9oe2xLd4TkVHrhZxA1DR
	4nA9j/c4N8GG0tafAhgQYsb8f6ALp0PHJhrkwWuC8Qhynoa5oA7iMuW9SPDCOVIuUTM8tpYzOcN
	C6o8SKVMANGh7m2+8jVuKOZNlYrLR8nqEZU1nFEcYPObqHsnxf86emu/fKgdnfrXmJA==
X-Received: by 2002:a0c:99d5:: with SMTP id y21mr43824354qve.106.1559914269823;
        Fri, 07 Jun 2019 06:31:09 -0700 (PDT)
X-Received: by 2002:a0c:99d5:: with SMTP id y21mr43824262qve.106.1559914268752;
        Fri, 07 Jun 2019 06:31:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559914268; cv=none;
        d=google.com; s=arc-20160816;
        b=LFUr3cukBSiLORYTyaL7ChMp0rF55bIutweGsVUebWGdJC/T5rxz0i0DkDb770Tv/k
         p+DhD3eDjVKf7hPFZhQrqCsCT5TtDdsgYRVxNXvTdQzOzDEq0Tn6T4FsmHHuUAPWEd5L
         dkSnwZ3p3rV2TMYGirRKNXpCi2nY8gCMvCbRlSRfvlnIMIE1aj7jbRMYC2WWPJ1lo42S
         zYVLlYdShxVTE4uqEdANlRHDX26hRbWMivIBLX9SBp8UTneL4TOT9XdV3Wqf31E6air6
         9cu6iQm++Anj3p+MeoeduivQTSpgU/h18eCxbnrh460c9O5QpmGTAa8mYySKYaO4vNqc
         opJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zyyI11Z3twoMqyf467AVpMwpHxurGKneH7RYfifhIWc=;
        b=jNUajf5B2mk7rLsgfNmr9fMwe4AUFFl4G6+00NX9XliBNe6uWFtc7GQCmk13Rn29Um
         js3VyRGzs5z09SwZcq+/o+uEwfIFTOO7DMqaZtXEkj/A4Y3guhV+UDHj+fOITBG1pjAW
         eOwhqIut2IZYCWeozjVvS3KVEJvdSSm/rvHUZvj4cANWJYhp7CGhPNz0wuueZXlnJFAZ
         FRyH/EiNkN6o3uA/FaIJ0nUrx2sgmATYn8Xitr46/xjTEUYwGZPGW/kkbl0Z9wA9FLc0
         xoc+uenJB9lOcpz8HYKjihQXh1J6t6uQqwA6kQma6imaTrCA3s537Hw4fq/gMQDWfMPP
         lRJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=XgOcttxF;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q127sor1088502qkf.13.2019.06.07.06.31.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 06:31:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=XgOcttxF;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zyyI11Z3twoMqyf467AVpMwpHxurGKneH7RYfifhIWc=;
        b=XgOcttxFtSt4H5m5uTCUVVYtTNFhZHmzuEIcILLOVnJTu+kol297oc8jfVHnMOgYN9
         KVEhxjN9bHA5zi86oSYRpPBOLol1xW6VGzKyzKOv70gX/o8vASgRfjhKpeATGGiqi8p2
         XV9oIhpp7n0dBZ+VcT3Ff1tVvGN74BzHYOdaSZZrBG0ZxI7UWy4T5qOcP/C4WH3Ycm4Y
         lP9tn3aHO6VWRdFJP59ZySBW8Q29pZmHb8PDxgcfNSvjw/TLR1TF/3PqNNu/lSeFsfDM
         CdiCDVyFP6EYfwN3gNesdEq1ky1h+HmPF/DKvbPP6G+zZ68XUx8LDhlgAyCmkYu0Z+ko
         Ll/w==
X-Google-Smtp-Source: APXvYqxiNRSOLULUOOVL1v/Vkw7sprKOSUyk24LlCfBwSCfz+nugTDkDj+dcDkV3fQgXrssqVlWltA==
X-Received: by 2002:a37:5d44:: with SMTP id r65mr36792567qkb.73.1559914268352;
        Fri, 07 Jun 2019 06:31:08 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id z12sm920156qkf.20.2019.06.07.06.31.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 06:31:07 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZExX-0007wK-Fu; Fri, 07 Jun 2019 10:31:07 -0300
Date: Fri, 7 Jun 2019 10:31:07 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: [PATCH v3 hmm 05/11] mm/hmm: Remove duplicate condition test before
 wait_event_timeout
Message-ID: <20190607133107.GF14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The wait_event_timeout macro already tests the condition as its first
action, so there is no reason to open code another version of this, all
that does is skip the might_sleep() debugging in common cases, which is
not helpful.

Further, based on prior patches, we can now simplify the required condition
test:
 - If range is valid memory then so is range->hmm
 - If hmm_release() has run then range->valid is set to false
   at the same time as dead, so no reason to check both.
 - A valid hmm has a valid hmm->mm.

Allowing the return value of wait_event_timeout() (along with its internal
barriers) to compute the result of the function.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
v3
- Simplify the wait_event_timeout to not check valid
---
 include/linux/hmm.h | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1d97b6d62c5bcf..26e7c477490c4e 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -209,17 +209,8 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
 static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
 					      unsigned long timeout)
 {
-	/* Check if mm is dead ? */
-	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
-		range->valid = false;
-		return false;
-	}
-	if (range->valid)
-		return true;
-	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
-			   msecs_to_jiffies(timeout));
-	/* Return current valid status just in case we get lucky */
-	return range->valid;
+	return wait_event_timeout(range->hmm->wq, range->valid,
+				  msecs_to_jiffies(timeout)) != 0;
 }
 
 /*
-- 
2.21.0

