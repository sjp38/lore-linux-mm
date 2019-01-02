Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1479C43612
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 21:44:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63FF4218FC
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 21:44:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JUy/Pig7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63FF4218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED1018E0049; Wed,  2 Jan 2019 16:44:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7F8E8E0002; Wed,  2 Jan 2019 16:44:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6FD58E0049; Wed,  2 Jan 2019 16:44:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98E388E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:44:00 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so33483356pfq.8
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:44:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=aC05bBCoXxIm2KIVwsPfjJVh2Mlak6ps4N17wDzsk8k=;
        b=nvwLZSQLSaBKwZOfOHPAG2MtphjQidNfxoaK/3TJrCxuGZjsdF8iuGxBgXZFolAxek
         Zr+dNjqehf3xU7NtkaASmU1e+M4TJQwWMZShsqRyJcEMThbOR1+QAWzCkUmfVoUET1tl
         Cmshh0RanNRFFz/pgGyTr7GbyVGWlS4cfERwlIZoJWoW5+plofIexKScu0P7OERUW7jt
         GpvbEX/VkzwQVUBhDVjxbDmdhRsBBIDFF3cH8sGLf6uyZSm9svdLkMr9lyod5jtEKsv9
         M6raSXgIQFwUm7y0Vb3m378x/61Bd6GXe5IbWejEIp/4BYuKyNooZSrdFHg4gv2038Sm
         aCIw==
X-Gm-Message-State: AA+aEWZGeeBSi3o6vpwKaFS3YJfAe5rAPKch1CVANDankpMb5kvvt6uq
	/wnCDglkQ0QYcpgStAFUb2a6+Y/nqvCdlliBi1J7hDq86WG6c4Dxq0pI6FpZt7A3V2aXdWbCApF
	Pi9NudhOXpnnvK4h5Bo3T5HY1po3zJ2MklGkpG+Ao86DaWeXuh/JReKeJu9EUZOvgmJRm3VsNyP
	Oq8iwxWijr7y8WRLtLoKAoW+LgYL8y1sNPSFPud5RgQPCfcjHjKZK0KsrI2EOumlBDj8xpdaXON
	tZQMX6HbJDX3B9iWE3tW3cFKFIoKDWeZzGs5RlgKJBiOrKZsInVpeSRGAPLPbTBgc4erxXFA60X
	x819qehYhbhTf9LoOtT9vVi7bBHgps0G5Pzx9t2yKDbTpSoITHuxNdjfL2LQoLM4cApBKvamDpQ
	M
X-Received: by 2002:a62:42d4:: with SMTP id h81mr45840273pfd.259.1546465440297;
        Wed, 02 Jan 2019 13:44:00 -0800 (PST)
X-Received: by 2002:a62:42d4:: with SMTP id h81mr45840256pfd.259.1546465439685;
        Wed, 02 Jan 2019 13:43:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546465439; cv=none;
        d=google.com; s=arc-20160816;
        b=1LNtN/vczDtZhmnGA8/Krsca4Ux0WLlHrus0xINRGkGdtSth22gCmBYimekJwt0nTJ
         OE2rG+P0kvMX9SDvO7jCGkd37V4rnhRoMsaFPz4CMjaq6nb7jZvzzZbHDdEKoM7XxrTm
         oOA8QellDwc6d4coZRxAsjrzPaj0kC7Ngjm9cH8xrk/jkcpvhrTY1SwSw80tT0bKvk7E
         jOEFalhC/qjMfzccvOML3SfaOP+qscnmYTnRIONasF4Tnop+P0VIiCy9+crAsTv6KZi1
         DxRIlfU2T8pS++5oCIsLZomZhDt/rRViIA6CkVY+Dmux+2Z7vXk9vi+oINRM144Hv72W
         oWjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=aC05bBCoXxIm2KIVwsPfjJVh2Mlak6ps4N17wDzsk8k=;
        b=klvv/t2J+Vug++rkRkbkR5RdYYai3yCGja/qYGcm9jOyqCyF31RVhOr9G4fmSWwhUg
         m9/Bi7xvHp2MTe1KB7GJ/fLVwQE0hMmEQkrY0UIjs32C3hR+Ja6RpLzQ8USnJtcxJEK9
         eDr6B5NDXdFou6OFrth79igkz2YbqpahjO8nrdhQxxSyaDT11aMRkZgF4I6OfeoW6iKy
         NdqTrKf1Qp/vAhSTX/ZieJrV267UeOkynlDs2imdjhRKQsWQOg3VJjgmOfRQsLgClWgn
         oSIte24w/50nedhsHEyC539idesECxy1NXpjgwoaEySIS+Er0eE8YZ5TQDn8DbeYAWgU
         Urjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="JUy/Pig7";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor20302912plh.10.2019.01.02.13.43.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 13:43:59 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="JUy/Pig7";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=aC05bBCoXxIm2KIVwsPfjJVh2Mlak6ps4N17wDzsk8k=;
        b=JUy/Pig7HV75nP+QMn6qhkRF4ZCABun+cxsU/CA/130gkin3Yo7Zc9Mc7RtV9rM/PF
         HvWeb4uN6ojbyCNFpR9+mMYkw88c4qPsJmGotCNZVsGDid/XIT0NX8sUqkb81A8XBXjw
         mKsVtILVAd6ytEptK6opTO3CLlmrvmHxCZ+EOrifVlMHJ0v4ABWlXjR15eiVcplPa+dy
         BtS59Fu1ZGnLtXVQszEA1z7yKAgn9TpmC6SwuuzV086n6dguGqY8EjenF1y//t80gXZb
         TLQK6e+nXGC7bfh1mPzEET9AcjPXb3kyb7lnxYzPPq8SsOq4nFyY75EtwvIkDQ/b9u7A
         YgoA==
X-Google-Smtp-Source: ALg8bN79rTlMx9iwdBrKizw1SDk6ntuqOXNAbk/3h/mLUneCoGmUqeAKq6+JWBxzUtitwAletvkWPw==
X-Received: by 2002:a17:902:b943:: with SMTP id h3mr45345949pls.12.1546465439044;
        Wed, 02 Jan 2019 13:43:59 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id l70sm61172314pgd.20.2019.01.02.13.43.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 13:43:58 -0800 (PST)
Date: Wed, 2 Jan 2019 13:43:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Peng Wang <rocking@whu.edu.cn>
cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, 
    akpm@linux-foundation.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slub.c: freelist is ensured to be NULL when new_slab()
 fails
In-Reply-To: <20181229062512.30469-1-rocking@whu.edu.cn>
Message-ID: <alpine.DEB.2.21.1901021343450.69024@chino.kir.corp.google.com>
References: <20181229062512.30469-1-rocking@whu.edu.cn>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102214357.L2kgY5DrEUa-54UKLqY-bJVe8CGqRPGZXaqUjbHUmBg@z>

On Sat, 29 Dec 2018, Peng Wang wrote:

> new_slab_objects() will return immediately if freelist is not NULL.
> 
>          if (freelist)
>                  return freelist;
> 
> One more assignment operation could be avoided.
> 
> Signed-off-by: Peng Wang <rocking@whu.edu.cn>

Acked-by: David Rientjes <rientjes@google.com>

