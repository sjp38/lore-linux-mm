Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF72EC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 07:07:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFA2821BF6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 07:07:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFA2821BF6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 452978E0006; Wed, 24 Jul 2019 03:07:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DBB68E0002; Wed, 24 Jul 2019 03:07:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CA8E8E0006; Wed, 24 Jul 2019 03:07:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064848E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 03:07:46 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t196so38601058qke.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:07:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=+DeIHtbS8EJjpoOOtd+xaDuB57jqytwM1SfUmDDbCEU=;
        b=N1MZZMErwnm94joGopVney5oEGIANJePEAWwDfz9sOw9buMX9OSZvGNi7uMz+zFgDU
         eGCyX31NDtSP4ejdhhYRngSROYhlOP7Au/wny4mBA58TypIUw9I1M1DRC/aIKai7pTxq
         FVNBiKhs2rhzPrmS8MJZiLQ0MOLsTikgVAViMj+hr02YLTW6icWxEF9RRHnPIrWLpRI4
         +96fP4JTlf6DzSdN4P+/zmXvEiYTJAXbXb2YYp3YQr0ItujYBnRCYCEEQmR1PQ65p0wW
         aqCiP06Kxpw+jAtLH71N4milKBSxc8qzln3OAnLKfaIHbYMvyuhgb196GYd1MGs9cWHZ
         pw0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXOgMPGZe6Pv7ehnP2buJ14jzIzi2AWd//SxUk9szMbwc1vSek6
	oo2/l26Jacx4kMv88rqBUag9lDaY5kv4SCBSIo/SYsxfEE0xia+thLGu2xs4D+xBf1UvDT+yrGg
	j/j+cxSqjj1qlf057hu1Sj3DL5jRyE1ReItCOKAlUEdYlu3OytHTVrykW9F5kFP6dVA==
X-Received: by 2002:ac8:1750:: with SMTP id u16mr53359186qtk.90.1563952065757;
        Wed, 24 Jul 2019 00:07:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPDWRYlGdz7g6soFfn4vT2hruETHs/wJig54J8KOs9YdhVuyKpa+m7RHbfsRWsucusk2Mc
X-Received: by 2002:ac8:1750:: with SMTP id u16mr53359159qtk.90.1563952065253;
        Wed, 24 Jul 2019 00:07:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563952065; cv=none;
        d=google.com; s=arc-20160816;
        b=UVMLGfNxaCBEqD7RfKFhREXbBfFaf9IiBEu+B1k5UltRm1G3rs/eeJQ62sAXMQG3d8
         UO1JE3aO2brTWYZV65wZVnutK+c7Qr7YbXTlrHSNqCYz0eS0P0Z42jw+Q/YsuonLEaJu
         KI7FN4r5+Igxe7x8VqGsgSqLYX9edHQEQQ4QJyGYk58NL0n8y97JgqLcvXyHKWR/RhTb
         lw56OpOVtIv+Z3xnGXheBQAkCMIyOZ+Lvlf9W3idQXglzmAbK+9ObekFTK4F2RWj6d4F
         NpSLU9doByCh+BnJ+s7hG4oRD6keON6uEhrFnJ3AVWAHdP2xnnoHgv51p2ryrnjQxDBe
         do0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=+DeIHtbS8EJjpoOOtd+xaDuB57jqytwM1SfUmDDbCEU=;
        b=w1EA2DEI/bl5brVVUeJbdennlBIKaHiIU7Rk+aFQPFn5Qupe/Y2KfdFN9Z+pTaSNlt
         UtBdrLTW/vFtAoCdrX0pytTVznkinpMSyHPgdh/Jr0VKK1J5MaxC20n3hu7P4R5ynAHp
         CiE8dYcN6SZnl/ta9MmHc6sskrB0A48hK4iQ2UgmXiEg1PxSSGYwXZu6/j4gTaUDdJ56
         JVEvghRtyGy8TVbsBiYSLRdOeulFpmdi63FzdVq22gL0luUKFJCvg81T1ouRJWdQWw9H
         THLdEkLIaQstKLbQn8rMmSBz9v4HBqW9HMV/CNG1rtevqK58ci4zmZzdGAec5In323FT
         alrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a49si31076005qvh.9.2019.07.24.00.07.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 00:07:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7E16030832EA;
	Wed, 24 Jul 2019 07:07:44 +0000 (UTC)
Received: from [10.72.12.106] (ovpn-12-106.pek2.redhat.com [10.72.12.106])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 59983608A5;
	Wed, 24 Jul 2019 07:07:38 +0000 (UTC)
Subject: Re: KASAN: use-after-free Write in tlb_finish_mmu
To: syzbot <syzbot+8267e9af795434ffadad@syzkaller.appspotmail.com>,
 aarcange@redhat.com, davem@davemloft.net, hch@infradead.org,
 james.bottomley@hansenpartnership.com, jglisse@redhat.com,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, mst@redhat.com,
 syzkaller-bugs@googlegroups.com
References: <0000000000002c183d058e0e3abd@google.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e003d427-36ef-a6bc-e433-36d90080e3cb@redhat.com>
Date: Wed, 24 Jul 2019 15:07:35 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <0000000000002c183d058e0e3abd@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 24 Jul 2019 07:07:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/20 上午4:04, syzbot wrote:
> syzbot has bisected this bug to:
>
> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Fri May 24 08:12:18 2019 +0000
>
>     vhost: access vq metadata through kernel virtual address
>
> bisection log: 
> https://syzkaller.appspot.com/x/bisect.txt?x=11642a58600000
> start commit:   22051d9c Merge tag 'platform-drivers-x86-v5.3-2' of 
> git://..
> git tree:       upstream
> final crash: https://syzkaller.appspot.com/x/report.txt?x=13642a58600000
> console output: https://syzkaller.appspot.com/x/log.txt?x=15642a58600000
> kernel config: https://syzkaller.appspot.com/x/.config?x=d831b9cbe82e79e4
> dashboard link: 
> https://syzkaller.appspot.com/bug?extid=8267e9af795434ffadad
> userspace arch: i386
> syz repro: https://syzkaller.appspot.com/x/repro.syz?x=10d58784600000
>
> Reported-by: syzbot+8267e9af795434ffadad@syzkaller.appspotmail.com
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual 
> address")
>
> For information about bisection process see: 
> https://goo.gl/tpsmEJ#bisection


#syz dup: WARNING in __mmdrop

