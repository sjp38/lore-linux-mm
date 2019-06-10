Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A0F3C28CC5
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 03:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECF2420820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 03:51:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECF2420820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3745E6B0003; Sun,  9 Jun 2019 23:51:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FDB76B0007; Sun,  9 Jun 2019 23:51:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EBF86B0008; Sun,  9 Jun 2019 23:51:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F002A6B0003
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 23:51:04 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n126so7192936qkc.18
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 20:51:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=o0rPw/ReGTQe8kSks/rZJ1m18hpK55fGqZ7UD69Pikw=;
        b=Jbuh8BMDxffk630+FnLxpLdadWXSvV8oPLoY/wm02qyysI6MFv2EnU9XNxroV0Tr8c
         AiY9W5E0Vno9yMIKCKFJ8wBF0LKZ2eJrYyLJ6/IcWY1IvEuBCmXWphM2TMHSHJWGq5lm
         3AfKTzOw5m6jCKP6jTam8Ydej5AymwauQf+EA9LCvip2wSZGxZJ3ckGp7B4VjYWtcjfY
         PCZYl1Z6jOXPO/MZ0zTfeKV8x8lGVP96MDsGnD+J3ZLAqbSABY68QtxRfkiRqQ0TQuP0
         Tt8oVFpkreSB279fzuy5dsedPGGWUpglEEMBKZDy3DEasc8M4bnw7mppX3ANZZVKEXno
         80Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRph4RX3uwXvVOcoBWdkxQWUByWwcByYb+MrEV1rUtpov8bbwx
	hx6pK0gkuhA5N7H6lAa8H6ScKy/kZU8IwTbRHFj1uMUaQBbB5bNWw4o6uhkuM5SoneDeT56yXkU
	RDdfgQ3HYr4XD4KnlNNEjBLFzHCf2IxwDFDzO3nQrT6QCDimhw0VhYYuyZWkqfXU8lw==
X-Received: by 2002:ae9:ec0d:: with SMTP id h13mr26810161qkg.26.1560138664740;
        Sun, 09 Jun 2019 20:51:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXlkbOmKs2yKk4gMm/6R+Yu/AEjGZpbL2s3z/91CU2eas/+940rJUUaF2/Vd6CLtCh0hnh
X-Received: by 2002:ae9:ec0d:: with SMTP id h13mr26810136qkg.26.1560138664068;
        Sun, 09 Jun 2019 20:51:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560138664; cv=none;
        d=google.com; s=arc-20160816;
        b=ZmU7LSBH4NnLePzpaKsPPIKH+JTm1ZtBzyf8N6b+/umaDGqGuuhRBuLUGTQbctxpry
         rrPXh0ToCPvJSoJ17IAdwFBwxxvv+0cTiEJ+Xodj8Ru+47baR1Y6Tk+L11nNHYdD6Or7
         NmB3aZz9lH7IVfnpq0d+xoAohy0oK1ndRGjTWD5MuU4iMt3jvL83SCy+SyK1lM0XyyYu
         D9nB9yEioI/U3MqDeapBsM70F7oAvlsY8ae/0NpSZz3EP0GDySD5N+qvTmASwjIPYKY9
         VQ6Oxz8zD39nlLMFGbzz4zZIIIHTftZ1Tr93Yno0fBe6nOnN+R9OKSMT0M7+STV0ifaj
         PKxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=o0rPw/ReGTQe8kSks/rZJ1m18hpK55fGqZ7UD69Pikw=;
        b=dUgbGlI2rHlf0Gw73WEmDmy59TMk4i1nTG/AJRxgACqviU7Yosb38URgU4m5YP+vFD
         UVmsVIPng2FyqGK7UvqBHezQA8o2hlir9QRPO0QcJfSBaF8npncXEiS6gbyS5b8x4e59
         V229cuWXSg0LItOdES3aZ8fPGhA8mUm2cQOq374RzTgzgQKPciB/E1AKYq+Vlcxnqqf6
         kJMDPscitExAbpTXI8DeoV5bBXtOaC3NaUKiwo5Bj54HGQq9/5kl0IA7ARyFJ7vjp8M7
         UUQJJOcjkKJa41CNMragoqQcaTPmtHRHI7dmszknvGWxObTnicGP41i2aFzPLJeX345V
         FfXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l1si4549607qvn.149.2019.06.09.20.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 20:51:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D9A5D3082B15;
	Mon, 10 Jun 2019 03:50:57 +0000 (UTC)
Received: from [10.72.12.206] (ovpn-12-206.pek2.redhat.com [10.72.12.206])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1AB5660BEC;
	Mon, 10 Jun 2019 03:50:46 +0000 (UTC)
Subject: Re: [PATCH net-next 0/6] vhost: accelerate metadata access
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 James.Bottomley@hansenpartnership.com, hch@infradead.org,
 davem@davemloft.net, jglisse@redhat.com, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org,
 christophe.de.dinechin@gmail.com, jrdr.linux@gmail.com
References: <20190524081218.2502-1-jasowang@redhat.com>
 <20190605162631-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <c233324c-cb66-c0ab-45c4-6e6e0499bb22@redhat.com>
Date: Mon, 10 Jun 2019 11:50:45 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190605162631-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 10 Jun 2019 03:50:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/6/6 上午4:27, Michael S. Tsirkin wrote:
> On Fri, May 24, 2019 at 04:12:12AM -0400, Jason Wang wrote:
>> Hi:
>>
>> This series tries to access virtqueue metadata through kernel virtual
>> address instead of copy_user() friends since they had too much
>> overheads like checks, spec barriers or even hardware feature
>> toggling like SMAP. This is done through setup kernel address through
>> direct mapping and co-opreate VM management with MMU notifiers.
>>
>> Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
>> obvious improvement.
>>
>> Thanks
> Thanks this is queued for next.
>
> Did you want to rebase and repost packed ring support on top?
> IIUC it's on par with split ring with these patches.
>
>

Yes, it's on the way.

Thanks

