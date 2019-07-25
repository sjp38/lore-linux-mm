Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78C78C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:52:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A22C229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:52:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A22C229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D82776B0003; Thu, 25 Jul 2019 18:52:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D33916B0005; Thu, 25 Jul 2019 18:52:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C22BA8E0002; Thu, 25 Jul 2019 18:52:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89AFA6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:52:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so32990257edw.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:52:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QZBEKu8MD6qd8z1Tdu0afIF0rQH0vqmE9YqP2v6A61M=;
        b=FibZFcBRkHPJBw6dVLFls9HWBvqX2rcjQI1TdppePbWM6okERRjHzlpGDDF0RXuWNn
         V9DYS1GEpKf7tkQfOhMMqmrXm2hd2girVmqmJAqxexK/pHzz97P5nzP6nucXx4BDiJo2
         2NMtepNcc7cyetLlLdECPV13jGww8mu38lVAx8AH8P/6+FoID1rEZTWqa4biBbIvWU1t
         N7mlQhsenpljY3V9dnncZVaqb4CmheNNm97i8/UH63A/q3k35D/RRnw7Y666U1eRWQG9
         02n/IB466MtTN1JQMsg4QAXFU+o6UxdjcSr84j37dzvOAFEaDcj06qqToVZlfRgz4rff
         C3pQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAXgGUdoYhm8MhwtdYYZIfPy77Jb3EZ4LU5HikJHwx1k0QL9KzgD
	RMj8SJBHRwdT8g0+gCH84IRYTCaMFfH7hEoiXg6Eu4Gy6jl7/IAMBMY1FaaQGJmoTIAzvdk0Vub
	X4BprRD8ohEEzcONo3kfsvV94J97o41enJaJDyVe7D9NTpsdWE6FPzACnVXjnCPc=
X-Received: by 2002:a50:aa7c:: with SMTP id p57mr79769905edc.179.1564095176125;
        Thu, 25 Jul 2019 15:52:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzO4TMAi24ilb/7nqZfIzR27lBNZMmjXZbhAUFH+Op/qtik6rPaV3SuzEZWP6xTKePO7dN
X-Received: by 2002:a50:aa7c:: with SMTP id p57mr79769879edc.179.1564095175520;
        Thu, 25 Jul 2019 15:52:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564095175; cv=none;
        d=google.com; s=arc-20160816;
        b=on0XrEe3JReWnWpE0ZnaYQ2PlN0sxT9YZKG+Kf5b907Wi2ihcl6l8qxQPYScwEXIgI
         ebRlUT+TuA+73H/Gc54ZBhJsOcyQo97Uj+WKiD2LFqStojO7ey13MYju5GNKmANsyAUg
         UPcKx6YmHHT2d7uNWkIUQD5nruZk+qLTGTcj/SGnsNgKv44ozfFx0R8OzDKW0GaicEog
         pnvX2sKH+KmOoxJKohx2ncuMjg2oVGnKND7HUMmS5tEJTCDZ300aFnuo3Ex8stbhWyDd
         w2DsgupZ9qWl6Ldy4cBtQkPpX3MomRX/7/k/EYitKLd8eTmi6MZUwZKsG53Mat3Q7hww
         EzhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=QZBEKu8MD6qd8z1Tdu0afIF0rQH0vqmE9YqP2v6A61M=;
        b=iDFzN5/QUkgJYDx1cCqpgXB2KRuRyo0IvASLlALfhcr59py6demamvmCR3Sj/gkwSZ
         h9/eMsMUINLVXhjwuNDTAnHTpGLRSD++b5b/YRwusl89aFOrGA9qJfRjfF/M6dk0QG1l
         HTK3TepAeZF3zJvebaIMunqdZJaGoeDwT9mC0F+6JD+qALUExrArtvvOSOqaR3wSthrp
         D+CEv7CRb0j6BCcGrjWKD/Z21LI/EzypV7au5sswdegOMoCu6gAwDE5QPNyMp8fTQ31N
         5EyfOAIjLl/wYxZi2WQlrXFwz6Pkjr8zrqLvaca8mmsDDHsZCu4Rgi5JOFv9lQl5vpeL
         M1gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id d21si9773828ejw.81.2019.07.25.15.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 15:52:55 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A490012600856;
	Thu, 25 Jul 2019 15:52:52 -0700 (PDT)
Date: Thu, 25 Jul 2019 15:52:50 -0700 (PDT)
Message-Id: <20190725.155250.1893960265343921681.davem@davemloft.net>
To: matorola@gmail.com
Cc: ldv@altlinux.org, hch@lst.de, khalid.aziz@oracle.com,
 torvalds@linux-foundation.org, akpm@linux-foundation.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <CADxRZqw0oCpw=wKUrFTOJF1dUKrCU6k5MQXj3tVGachu4zPcgw@mail.gmail.com>
References: <CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com>
	<20190724.131324.1545677795217357026.davem@davemloft.net>
	<CADxRZqw0oCpw=wKUrFTOJF1dUKrCU6k5MQXj3tVGachu4zPcgw@mail.gmail.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 25 Jul 2019 15:52:53 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anatoly Pugachev <matorola@gmail.com>
Date: Thu, 25 Jul 2019 21:33:24 +0300

> http://u164.east.ru/kernel/
> 
> there's vmlinuz-5.3.0-rc1 kernel and archive 5.3.0-rc1-modules.tar.gz
> of /lib/modules/5.3.0-rc1/
> this is from oracle sparclinux LDOM , compiled with 7.4.0 gcc

Thank you, I'll take a look.

