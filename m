Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A245C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C56902166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:15:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C56902166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF9626B0005; Fri,  9 Aug 2019 01:15:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA98D6B0006; Fri,  9 Aug 2019 01:15:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D98CB6B0007; Fri,  9 Aug 2019 01:15:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A20866B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:15:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so59576419eda.9
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=af3zhdCVdld+saS2hne4MzErwGwKjmQkdqUdjIT/Lf0=;
        b=ABDE7GALnSQih005ALhFBKIoHNWrfETT6tpZF3bywu7LFYP7sLRiFS4Zbq6FCU8JpQ
         ULWbxqqqu2J6kJfl437+CZ9B+5cj3qwhGaIn/qA/j/DJfIpS+21o80CpyQxqRp6L2tki
         xCfYApjeifowrUjChW8KdYq/zmm7WsJApo4ASsOX8M+mSx1pli+qzPHBJ1GBEO0m1Kz3
         syYc/msRQytbMJocShOeccglD5GGDcMM4hsWkxOlpvbkGImr/t/KD0WUM28Md/nYtPNB
         9AcqMbZfaqMTudB3BI/LbPaPD3L/ghPolq009rvEAOXY54hKhYqK5VQMJ361wWJ/ga1C
         L01Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAW88jWF+Abie1z+9BMrAN6HZgoaJpd+bKFQnoak4dF9SbQKE3vW
	uab/xTcmQy1HTKEp4hz12/owRaDr99gp1siNEUaFdPub/wsM72gux6P0knk+GoRxDQlC4XC0gND
	1emVmyoyJEjbfUcfJn3Q9gbMhztH58cFSlqlzoWQbEXeuHVzYnKKFryiviucJbNM=
X-Received: by 2002:a50:f599:: with SMTP id u25mr20298449edm.195.1565327748155;
        Thu, 08 Aug 2019 22:15:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxE0A/mH28pIvaK3qdInl37s5GGZ/ZdKKQ7sF0HC/xfwKWXkbM0T83b22ceXyPMqCKg91V4
X-Received: by 2002:a50:f599:: with SMTP id u25mr20298413edm.195.1565327747462;
        Thu, 08 Aug 2019 22:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565327747; cv=none;
        d=google.com; s=arc-20160816;
        b=OqrX458eLoryrjAxdbmLD2fP8O1vvBcHEQj0I1UzFdPmutf9J5tLN/OfAwaKEkfO3u
         tU83bOK8B6XOPaLmAY2n269ZaXMxhep5GX1nXH5sSrD9IF7q6yp8Iq/RDl2qR1iu2020
         8NwCWzWtbsj9wcMAjVUglkIzuIo5vXaSZSZjZn83LB53e5H/a7zyUw9f6tta5lEd6ven
         NW0s/7D+lbIzLnmsHFujnhtol1lzqyIgdndTi5JvW4tSvjGeS2z62ebeVzCpSk8/xNQN
         5HId4rTK4KWU+fGYNJdGWyDS8TE1grMr8pPkABlcS5WWtFwar9M9vIDGnWp+f0MsnGAV
         YRzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=af3zhdCVdld+saS2hne4MzErwGwKjmQkdqUdjIT/Lf0=;
        b=YMqwFnwksJvGjfQoyj4RaqNCAj5aj3atyG6SkKFp/oHiSNQvA2dgnoMTcWGVAW+QcW
         IafDd/7A8Dzf87kGPyWqGt151+WoyOkmr2rlaI4aImd/zEN5hBsye55+bL0/lGdy8a/s
         EGqsbda4ZgA/TpkRcxFNEEUDuPRaw4h9Trm7sLkXt7gmm8MVvAgej3Tq8zULpfze7m/7
         Gh+WPDaeW2G8h39LMy2suQPzlKkwLhJuBr9a1Wimaz6sFjKWVM2wILwAdqyvfrPNo5TC
         gefzRDtOKYPgMDCfAlN+qa3cdeb7JwQ3CLX0UVO9qiTnpNYukSCa4CmVa1EgcDRFgR7N
         G6xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id rh18si2244902ejb.29.2019.08.08.22.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:15:47 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 86E4912651D63;
	Thu,  8 Aug 2019 22:15:44 -0700 (PDT)
Date: Thu, 08 Aug 2019 22:15:43 -0700 (PDT)
Message-Id: <20190808.221543.450194346419371363.davem@davemloft.net>
To: jasowang@redhat.com
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V4 0/9] Fixes for metadata accelreation
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 08 Aug 2019 22:15:44 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed,  7 Aug 2019 03:06:08 -0400

> This series try to fix several issues introduced by meta data
> accelreation series. Please review.
 ...

My impression is that patch #7 will be changed to use spinlocks so there
will be a v5.

