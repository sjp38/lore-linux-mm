Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 902F4C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:14:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59D220828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:14:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f4csicVe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59D220828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004C86B0271; Thu,  5 Sep 2019 11:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF7756B0273; Thu,  5 Sep 2019 11:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0D726B027D; Thu,  5 Sep 2019 11:14:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id BF50D6B0271
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:14:19 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 58BF6824CA39
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:14:19 +0000 (UTC)
X-FDA: 75901213038.18.skate13_42bf1ca6d9d2a
X-HE-Tag: skate13_42bf1ca6d9d2a
X-Filterd-Recvd-Size: 4806
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:14:18 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id r17so5238837wme.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 08:14:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=dfUO9a7E9R+fOWFokuwHNXPizB7LWxoWz7TwHKPJeKA=;
        b=f4csicVeVdbTjTLkGvuU0mio8k0xnxfoLTmb8gdYb5QJnAEFROnPSH7xc73HYN+ixy
         e7gsFYRoSkO7Br2jflzTOhyh3rBXVyvrUz6DglZJyLAz55fNeDFqYRKseYc5o5YYmG9X
         9EH6/ZINv9WZapt2Lac5IXHUER+zSZ8KE5NYwoWAMtg+lG2QKlwMyc5entzeSaE+ljVK
         SaVxAbTmwbe+Lz2ctOldV92jLUOuBjwE6ipjqOdeWVnYpT2TFYkopT5bgHkmRtBU3hPo
         PrrkIH3ne82+4DNJs2FLPJ3tAQarRkLp+JhsT7jjovcykTPt5+3w0RpXc3x76k90mUlq
         CFCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=dfUO9a7E9R+fOWFokuwHNXPizB7LWxoWz7TwHKPJeKA=;
        b=Q2WS2iRqmouYsNxtlLvCFyidPZKgNKp67Lg/Y3wnJ+QSTQWDksoS7GZsHr0vPefRel
         MCrsHd7lePeC0IlfbnZvmsRILA2d6gpWCoXsfxXALGLusGsCDxWgtrjYI/Fxj/bvhC3I
         qv18v9FbYQVXBmo0aMiSM9WRfvqpQ7M7gV/ChrxHbNo0IT3jBQ9PCtBXdhAUzcREtr3f
         EvJ6hXnLcllFFm8e7lmwKgJ42mTExwA6diGgzFSeMyAMhJH6SoDlQhiYZ5ghIpoQCW0v
         9TAMIR18K/0O1Ko6cNJMN1AxUVtVSH8zJTdO+1KsM4k22hg3RDATEb76nuZmKslkx6Oj
         qUaA==
X-Gm-Message-State: APjAAAWOOD/PNAh/VVGcsKBcs55RxtTQoxtro5iOuzlMqTO1OwxnNWN5
	egaNrekRsY3ivGoG+NqlgGk=
X-Google-Smtp-Source: APXvYqzYIkx/gnO7fVC7G+fRVIplybcIMoud+HvMrsXB+dAIK4P1jN6ol9+wQvapxKMmcT0X7chTUA==
X-Received: by 2002:a1c:9950:: with SMTP id b77mr3552791wme.46.1567696457429;
        Thu, 05 Sep 2019 08:14:17 -0700 (PDT)
Received: from [192.168.8.147] (163.175.185.81.rev.sfr.net. [81.185.175.163])
        by smtp.gmail.com with ESMTPSA id y14sm3817913wrd.84.2019.09.05.08.14.15
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Sep 2019 08:14:16 -0700 (PDT)
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
To: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
 Michal Hocko <mhocko@kernel.org>, davem@davemloft.net,
 netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
References: <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw> <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw> <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw> <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <165827b5-6783-f4f8-69d6-b088dd97eb45@gmail.com>
 <1567692555.5576.91.camel@lca.pw>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <5405caf6-805b-d459-c447-15a23d0d71dd@gmail.com>
Date: Thu, 5 Sep 2019 17:14:15 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567692555.5576.91.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/5/19 4:09 PM, Qian Cai wrote:

> Instead of repeatedly make generalize statements, could you enlighten me with
> some concrete examples that have the similar properties which would trigger a
> livelock,
> 
> - guaranteed GFP_ATOMIC allocations when processing softirq batches.
> - the allocation has a fallback mechanism that is unnecessary to warn a failure.
> 
> I thought "skb" is a special-case here as every packet sent or received is
> handled using this data structure.
>

Just  'git grep GFP_ATOMIC -- net' and carefully study all the places.

You will discover many allocations done for incoming packets.

All of them can fail and trigger a trace.

Please fix the problem for good, do not pretend addressing the skb allocations
will solve it.

The skb allocation can succeed, then the following allocation might fail.

skb are one of the many objects that networking need to allocate dynamically.


