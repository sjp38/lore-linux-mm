Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C233AC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:56:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADE3E206C1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:56:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="jKImgL1r";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="jKImgL1r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADE3E206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 128EB6B0006; Thu, 25 Apr 2019 17:56:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DA4C6B0007; Thu, 25 Apr 2019 17:56:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F32D56B0008; Thu, 25 Apr 2019 17:56:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D13EF6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:56:50 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d71so989023ywd.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:56:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GjlhbQEFVkVAzSjNGRO8jQxcNslOiIPReH4fy2mw04Y=;
        b=fNAy1LRPaWERpSS/2WqTXwi4U8C27P66y4DYrA4cClAxW7jzGtt7u1/4vx8jQuinBR
         +SIiVto1QS2yYWGA1sA9p1qsvCk9+yZ/HcDrG9YnNOcfrRM5sQMd53zM4DbsJwb3Xipa
         KwdC8RWHLYOZwdu1iSzzY+Y3X5h59iPyonF/Uw7k8rY9ydvRZzyqLRhA7RwLnQc9Zpp9
         q/Qf+mANeY/ysVPKNw1qHKHBjQRLjj5STReYw6ud4xDCf035GwJ9Aax04A8pSfdiF8E+
         1WurqR4ytUGUtNNKV11+4ge9dna1qvk3q1pTYt0tEcyEdGgqAHTjwcVqKlG5UXV3YDo5
         XXhw==
X-Gm-Message-State: APjAAAXHze4v0YLTLqAQngb7N9+VF3PN33U6q7mA0gayDP08fM8HNABv
	p206PSEuHUxRksLwu56b3PWPUhIsscComSpUUM/w3t0JRv1WmeBMl/nkbaBP4CiZQWJCvFRdXQU
	FqJsAEmaeNinCKKdLl1ZA91VigJ/HjGWoqk0I3KIvH3xxyxth/U+DIM+b9P2QnCgXVQ==
X-Received: by 2002:a81:3ac7:: with SMTP id h190mr34132553ywa.351.1556229410595;
        Thu, 25 Apr 2019 14:56:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxt+E2W8K4AC6vyiJk+jlxt6FikEzL1oy10ubH9MAW/0urhDiaklFZdVy2TUUwAnoopjlpj
X-Received: by 2002:a81:3ac7:: with SMTP id h190mr34132522ywa.351.1556229410011;
        Thu, 25 Apr 2019 14:56:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556229410; cv=none;
        d=google.com; s=arc-20160816;
        b=EJG+IGAmS7Tjktjx5kut0W1hnqAMCG1A6zajP92vaehFkYdcTBqPJVVt9WeuSuQh05
         ZoD1LAc//QNALgDAp4EWfCwbEIt5ovPEVwwINsFG2DecUjV8xXImvQxbtXGtxRzELoXf
         XaKMLBgIbL2C2xHYAxiVE7iraClKfgRTM0c27rienGBieaHH8HaqPzVnHEL9Mlxd8EUl
         KZ7cbEInQtMQbMkK3QScmt3wBoyQpSxkvewdCOIE+/3c1z64rf6gGJJ3piaMvzTZxk+q
         OpuIWPK2O24Y6bBSUfFGBuxFx48AveLfM1/Dlodyo6n3aQdZdclg5J+ESffp8JOttpiE
         MXMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=GjlhbQEFVkVAzSjNGRO8jQxcNslOiIPReH4fy2mw04Y=;
        b=Ufn0VsINgnscMUvPNl7XdJKLz8iSuJBsuTtcNckYOjsuhxenlnj7EVnLCdqS2OGrjv
         0BfR+n8aI498PeByK+OmZU/F1g24XBpGrUsg54fCu67Ve6P+d3qODOEAgEKxDcvgpXyH
         3bR47raW7V6R+x2wjgdqpkNYkxn61LrcPUBJZEUJuoMPu4ItRS/TteUWLgfigMcRYMux
         O6HRjD6byoiVVj9vku4v9TpxYIKRni+luNWZL7x9tarVjcMR7kC3+qbpTlOY2WqxCcZ+
         0BdPZDHsGCqQV6yIgx+BAtrDSHcYqXu7U4/qDwUUJavZaICklgfo17ju04LcCAkqEwLH
         JuwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=jKImgL1r;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=jKImgL1r;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id d81si15463469ywa.337.2019.04.25.14.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 14:56:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=jKImgL1r;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=jKImgL1r;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 6CDE08EE128;
	Thu, 25 Apr 2019 14:56:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556229408;
	bh=GjlhbQEFVkVAzSjNGRO8jQxcNslOiIPReH4fy2mw04Y=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=jKImgL1rvUv7Cwx7ej2nXLIWxWqQpKYxfnIICSG8Yn6l8kTStFzVEFeLQvZ63qQPA
	 pqPJ9Ff1HMWc4yp3hc6ZIESmjowLzAj0oEzTm1/vilY+4DSB5VaqxCzGHyNmNJJkpC
	 GfkGjFv6LosdFcAMUm0p3sSUKC8a5Arj6fa3GvTw=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6vLsy5r2Rzfa; Thu, 25 Apr 2019 14:56:48 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id D37B88EE0AB;
	Thu, 25 Apr 2019 14:56:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556229408;
	bh=GjlhbQEFVkVAzSjNGRO8jQxcNslOiIPReH4fy2mw04Y=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=jKImgL1rvUv7Cwx7ej2nXLIWxWqQpKYxfnIICSG8Yn6l8kTStFzVEFeLQvZ63qQPA
	 pqPJ9Ff1HMWc4yp3hc6ZIESmjowLzAj0oEzTm1/vilY+4DSB5VaqxCzGHyNmNJJkpC
	 GfkGjFv6LosdFcAMUm0p3sSUKC8a5Arj6fa3GvTw=
Message-ID: <1556229406.24945.10.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Jonathan Adams <jwadams@google.com>, Paul Turner <pjt@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Mike Rapoport
	 <rppt@linux.ibm.com>
Date: Thu, 25 Apr 2019 14:56:46 -0700
In-Reply-To: <CA+VK+GOOv4Vpfv+yMwHGwyf_a5tvcY9_0naGR=LgzxTFbDkBnQ@mail.gmail.com>
References: <20190207072421.GA9120@rapoport-lnx>
	 <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
	 <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
	 <CA+VK+GOOv4Vpfv+yMwHGwyf_a5tvcY9_0naGR=LgzxTFbDkBnQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-04-25 at 13:47 -0700, Jonathan Adams wrote:
> It looks like the MM track isn't full, and I think this topic is an
> important thing to discuss.

Mike just posted the RFC patches for this using a ROP gadget preventor
as a demo:

https://lore.kernel.org/linux-mm/1556228754-12996-1-git-send-email-rppt@linux.ibm.com

but, unfortunately, he won't be at LSF/MM.

James

