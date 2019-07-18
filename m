Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE935C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 01:21:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 642A221783
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 01:21:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 642A221783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8E936B0005; Wed, 17 Jul 2019 21:21:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B195C6B0007; Wed, 17 Jul 2019 21:21:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A07CF8E0001; Wed, 17 Jul 2019 21:21:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66B2D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 21:21:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so18965599edr.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 18:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+OOMqPurO+VIzQUiBNLMzJdobRhRWqLqHE8xUwcRX8M=;
        b=WHcF+dCw25ZOTwp3xyplxkYnGNgk/zqH0A89ptBpuySLLDFZ3IxtcNnHw9G2+zArzy
         CO6BYir7VTywX0P/3JkZDtC6CxN1i5UoHxEszF4yGys3uy5hvb5fI2aOFKWGkCmaLQC8
         +pKMC881Qz6Nh6652FkcqVtQ0wWtYZO2p3SWaqeBMnGHWRQRfByxoQK2P8LCFsByADm3
         3pFoKKDipgo+gNb4eYnXAogq+mTDpUqE1v7270FhyAmL40Af80PltwJ3OqgKkmrA9kIC
         wY7QRTpHqE24R1+3wOxjtbPNWSEIEDbBYT6cc4dfvnZgOdhGbXf6OOCIst2HCHhsN/B4
         0KQQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAV06Px1+yYD8bb62JZF6OpNJlE2V+Sfy0P6VxUWrZmG0k/EZI7p
	ulLjZxAfBUJWcTqoHGPybTsQX2l8BxxPlVmbkntm0kn/KjxRumtYEccED5tBp2eO9P9rhRxa3AG
	fELS3ow6yJDA3AEAMtqUbo/9xBAr2R2FVAbkR8XO3DkvuWi0zv6Tb6ZHajG6Fhv0=
X-Received: by 2002:a50:ad45:: with SMTP id z5mr37450291edc.21.1563412887981;
        Wed, 17 Jul 2019 18:21:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeceMg5MIACSvPF1CAzeHxwIq5vBIh9pROL32QU2vQwnppASERMynGPT0nI3Xb7/Pu8JI0
X-Received: by 2002:a50:ad45:: with SMTP id z5mr37450242edc.21.1563412887098;
        Wed, 17 Jul 2019 18:21:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563412887; cv=none;
        d=google.com; s=arc-20160816;
        b=RJkidQKuGm8PRfq61ofUBfbC3s6+NSQux/1ouTpbGtS70XOeQsIKOSYVOwo2bkcxoN
         sBTcysTdP86I5gtfnorMC2sCcCCC21BYojnygp+1ui/WpDIuEYJfcZYNyvG9REovVM6k
         W89Ihh9aY2i6xztq0JGhdX2dbdXkMxvtr9OKCdb62M1iyGprLcH+waj53fiSm3nMemvU
         yBPPmOsjLJeWlZ1fl7B13ua1v++7MDNHx0kmrLpOmNBo1c+J2KwsGHGIfAUIDDimU9C7
         TLcO1TZn5nHRef3Y8uEF3OaJUxwYoXiOkCQU/2SKtJuEnfI3RETuQSAHc/Abk1gZo50L
         x7Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=+OOMqPurO+VIzQUiBNLMzJdobRhRWqLqHE8xUwcRX8M=;
        b=UVicCNo6f8W24wThpzuGIckTLdQNi9D/V2nOsKIzYSpTZMkdhlc0/igjf/uI3HUfR3
         AGo0T/4bui/yQtgCJSl9ttZUu9QBUJxmB4MjxxokAzZ2MCPHKlFUsoj9CLGdvkVUOdIT
         8JPjLNrqn5bxrd/U7euqD4oaS260/fPvJzHmWkCz6TMVcn9UaFJvjDqYpdHzNavCFbxb
         JMKHKhWFfYsJxTkqw3a/BYvqE4Z4nEQIOqdtWZshYVyjiNJHQvUf+LEJKfCtLwQKJgab
         ymyV+CPhfqtEli89QTVDpDpi5Nnwnrs8eV5oZfQeLHe+xNn2zP6v5FynKduanlrtIuGf
         QKnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id ck2si219367ejb.258.2019.07.17.18.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 18:21:26 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1529F1264D596;
	Wed, 17 Jul 2019 18:21:24 -0700 (PDT)
Date: Wed, 17 Jul 2019 18:21:21 -0700 (PDT)
Message-Id: <20190717.182121.54176691060371062.davem@davemloft.net>
To: torvalds@linux-foundation.org
Cc: ldv@altlinux.org, hch@lst.de, khalid.aziz@oracle.com,
 akpm@linux-foundation.org, matorola@gmail.com, sparclinux@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAHk-=wgjmt2i37nn9v+nGC0m8-DdLBMEs=NC=TV-u+9XAzA61g@mail.gmail.com>
References: <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
	<20190717233031.GB30369@altlinux.org>
	<CAHk-=wgjmt2i37nn9v+nGC0m8-DdLBMEs=NC=TV-u+9XAzA61g@mail.gmail.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 17 Jul 2019 18:21:24 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jul 2019 17:17:16 -0700

> Anyway, I suspect some sparc64 person needs to delve into it.

I'll take a look at it soon if someone doesn't figure it out before
me.

