Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3958BC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:12:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB5C223427
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:12:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B0Mtxovh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB5C223427
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 815BD6B000D; Fri, 30 Aug 2019 11:12:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C7266B000E; Fri, 30 Aug 2019 11:12:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B6926B0010; Fri, 30 Aug 2019 11:12:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 49FF46B000D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:12:01 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C51DE824CA2F
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:12:00 +0000 (UTC)
X-FDA: 75879434400.11.brain47_85f0cfc2e9563
X-HE-Tag: brain47_85f0cfc2e9563
X-Filterd-Recvd-Size: 4061
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:12:00 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id j16so7322682wrr.8
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:12:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=76/UUed01Y3Y8i/aDowNMkQyy3LjmrVlq62x46O+5HI=;
        b=B0Mtxovh7YJ1xZ64U7SiGekZ9o7RHn1C7kzg4weTyPz+1pkpuPjKUVgY8eY5lVYl9K
         1S2+Z8UC8ZqTjtRFrfs9dnjTkEHQ/jZ13wgyzCCDCd7LBw+leUHYVLUPX5nTew6aZedz
         VwQWtr3NeciSNUMC69YBebngNsOpYL2Ha3bz8IYfAB91TUQyd/E5LC20BK8ghQZ82IGO
         x5HdFpGbpa+yvnKS5TBBj1ed6fr++5lxlFQ7N+0nnkILxUuQL4soAXP0u2WhLJHsuLi3
         C7Fv/QuxM3LVzCFX/s3ankIJGLWRkQZo/APO6QBQezDPGzVoCdm1yO+t9ZlkOkxzAo0o
         +M2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=76/UUed01Y3Y8i/aDowNMkQyy3LjmrVlq62x46O+5HI=;
        b=bPwXIJmjBrizBmZpwb1rZe5QZuiJpkmLFmPbHW7pNmrv5n+lIFJGPvZu3bwzf6Tfa/
         lWCwYPaV9n6FqXOQls/CGZ7uyhwKBKeh6b1pZzZWoe/Xnc71bmeBhQgeR+0s1RISlcpN
         F7NNr1xIPcIDAquGFDjMMbPiWbTI7wZX/Q2ZcP2xOEnv8K0jS1kJsLVKtecFS8kRc6TV
         DUxKkSoYUwBwxRtHHtLScDT3SNNSgUwWvi8NbucJckNBHYVHz8jXLse2KfAbJ6NJq0BN
         88gDtwra8/GiE+R2p4pCdCpddxz5qV0enWJRK70yMarjqf/jGlqjI/Pl1xzWiubrIwRp
         J+cg==
X-Gm-Message-State: APjAAAXwvuDLRB964ZcbpkZifqoMuQ7xC86Nj++yhBpiln+g3dabPkwy
	++QXMOVKyfjcS2fwe3eGCD8AekdD
X-Google-Smtp-Source: APXvYqzKBXu6wZXLHUG8+KW0xkXVfuQI1179U3Ts3qO5WmEIh6+JXMocNScNDvnxocLwtNECOiHZ4A==
X-Received: by 2002:adf:e846:: with SMTP id d6mr19068750wrn.263.1567177919401;
        Fri, 30 Aug 2019 08:11:59 -0700 (PDT)
Received: from [192.168.8.147] (95.168.185.81.rev.sfr.net. [81.185.168.95])
        by smtp.gmail.com with ESMTPSA id d69sm5515728wmd.4.2019.08.30.08.11.58
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 30 Aug 2019 08:11:58 -0700 (PDT)
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
To: Qian Cai <cai@lca.pw>, davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
Date: Fri, 30 Aug 2019 17:11:57 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567177025-11016-1-git-send-email-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000071, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/30/19 4:57 PM, Qian Cai wrote:
> When running heavy memory pressure workloads, the system is throwing
> endless warnings below due to the allocation could fail from
> __build_skb(), and the volume of this call could be huge which may
> generate a lot of serial console output and cosumes all CPUs as
> warn_alloc() could be expensive by calling dump_stack() and then
> show_mem().
> 
> Fix it by silencing the warning in this call site. Also, it seems
> unnecessary to even print a warning at all if the allocation failed in
> __build_skb(), as it may just retransmit the packet and retry.
> 

Same patches are showing up there and there from time to time.

Why is this particular spot interesting, against all others not adding __GFP_NOWARN ?

Are we going to have hundred of patches adding __GFP_NOWARN at various points,
or should we get something generic to not flood the syslog in case of memory pressure ?


