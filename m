Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FA53C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:55:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61BCC26032
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:55:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61BCC26032
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7C166B026B; Thu, 30 May 2019 14:55:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D05B26B026D; Thu, 30 May 2019 14:55:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1A876B026E; Thu, 30 May 2019 14:55:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 758666B026B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 14:55:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so9906330edi.13
        for <linux-mm@kvack.org>; Thu, 30 May 2019 11:55:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=blOabJQ3Hfr/F5mYHOO4GIvSwCgZXr8eOTRVkbxWWsE=;
        b=jyIVheJ9JEw/XIuBKAi+0S6CxmcvnOHyQ7KRa0xmx0dSKNO3JTAKcp7yaETd5yMoSz
         If+K06EZVbkXU2RUJem6ymCqcH8+reHpOV7sTkoZpE4ka8K3zYBIa0RvZCfqBYjYPoW2
         QU9ZslaFVe/hucMUnj23UG7+waQJftR7jnw5qo+N+yZhbnGs+lMDY3/DgZruD1qBodLO
         fM/9Jt7XH4yGtbFFhrp9Pa/yaSS+frCKdmaXRKemeJIEYBT/XudYUtXnapQDt2qBuog3
         +kkw4Qfawh8Q5JMEHHNem9DnTY4HbrfzT/3MWDKGkkTBKEp+BSVd23T5g0ZzvbekUPZ9
         uPiA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAX/v/Yize/71zVtIdo1YbyYhAP3S6QCUQhCDdy+eJYy5X8C0MMA
	dJagnsdpJPJflVaZeKfMjbAsRmO7mu2Gx8iVxhNC36aiAob5Ngm1odnak16tyYZ+apUGbM8LmqU
	Bdo/Shulos8L2IO7HuRMgg0WP8LifncE0IAmUMQXiVxVEmmB13yIusuBYdmClF3I=
X-Received: by 2002:a17:906:58c8:: with SMTP id e8mr5061187ejs.268.1559242552896;
        Thu, 30 May 2019 11:55:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx77tQn6Wrmn+6Nj4XdBVkM2hA3zdc928mwoa6swoGdZ/3ZIbxcb6fhbNUhYsGqwVerZ+Q9
X-Received: by 2002:a17:906:58c8:: with SMTP id e8mr5061138ejs.268.1559242551896;
        Thu, 30 May 2019 11:55:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559242551; cv=none;
        d=google.com; s=arc-20160816;
        b=CIWvuR4OkUbVQjC6vpTAWPy+/y6WO/WZHE/Kyi8Wtcki6r6Q0bdGr6BNq4CegLPMq6
         hmuu9+DnhFvSLLCrjNiZuwFbZA1UGEf6/SoWNy/a5BIkBv4mL4TJ9ypl4XYsBNaxaZ4q
         3MDsylKCVEBE8HJL2C9/M9iCzSV6CabLnmM2uSW8lcyPy9K6Zxyly5OqxnkAVY+M6p0n
         WpoBN+5creAzERoO5EuBPGRkOiJSvPaMPtpL0TnTekNaSxLmvaFJf29IbTcIuRuVskLT
         jPGpR09q+XW8Tv5e1fEG7xXb+jH+FiqRXTewlXscfaKFfQ6uzk5LV8jYNUJYYx+imebc
         Vskw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=blOabJQ3Hfr/F5mYHOO4GIvSwCgZXr8eOTRVkbxWWsE=;
        b=zMPsqCG97z0Cwga8DXv/fS2o9FFkeN7Q1Lsp/H29jFUK6rO2P2y+KHkQUkUDYoXDnE
         0CxxC0P5wgEQbrsluVA0h4I80D5R6n+Gk6uxKyv2+E8E/FV7cts/7ivZvoZrO2HJyzCQ
         /tvhsv767CRVB9+Vs5RJvm5H5y2D9+MNaB813/MMg0bGI8vlk/bkpcf4uOMUU9819Te4
         9vUVpcNijsMUahR5vQlQCZpvuRHEdvOvxjDEfgrTSnZn554dPTaoNTCBIYkyDiQkP9lM
         e2WyQ/IRtsCWCp4rXzabmdM4hVJEUm7Ja/VMRSU8pwfig9TW4Wr3oXnmDIH5BFV46u2R
         6W/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id m16si455905ejd.347.2019.05.30.11.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 11:55:51 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D87A914D9DD5B;
	Thu, 30 May 2019 11:55:49 -0700 (PDT)
Date: Thu, 30 May 2019 11:55:49 -0700 (PDT)
Message-Id: <20190530.115549.1509561180724590494.davem@davemloft.net>
To: mst@redhat.com
Cc: jasowang@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com,
 James.Bottomley@hansenpartnership.com, hch@infradead.org,
 jglisse@redhat.com, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org,
 christophe.de.dinechin@gmail.com, jrdr.linux@gmail.com
Subject: Re: [PATCH net-next 0/6] vhost: accelerate metadata access
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190530141243-mutt-send-email-mst@kernel.org>
References: <20190524081218.2502-1-jasowang@redhat.com>
	<20190530.110730.2064393163616673523.davem@davemloft.net>
	<20190530141243-mutt-send-email-mst@kernel.org>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 30 May 2019 11:55:50 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 30 May 2019 14:13:28 -0400

> On Thu, May 30, 2019 at 11:07:30AM -0700, David Miller wrote:
>> From: Jason Wang <jasowang@redhat.com>
>> Date: Fri, 24 May 2019 04:12:12 -0400
>> 
>> > This series tries to access virtqueue metadata through kernel virtual
>> > address instead of copy_user() friends since they had too much
>> > overheads like checks, spec barriers or even hardware feature
>> > toggling like SMAP. This is done through setup kernel address through
>> > direct mapping and co-opreate VM management with MMU notifiers.
>> > 
>> > Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
>> > obvious improvement.
>> 
>> I'm still waiting for some review from mst.
>> 
>> If I don't see any review soon I will just wipe these changes from
>> patchwork as it serves no purpose to just let them rot there.
>> 
>> Thank you.
> 
> I thought we agreed I'm merging this through my tree, not net-next.
> So you can safely wipe it.

Aha, I didn't catch that, thanks!

