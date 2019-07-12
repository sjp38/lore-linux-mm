Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91482C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:37:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06DAC20863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:37:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06DAC20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 534C58E016C; Fri, 12 Jul 2019 19:37:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BD9F8E0003; Fri, 12 Jul 2019 19:37:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 385C58E016C; Fri, 12 Jul 2019 19:37:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 159C88E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 19:37:04 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l5so4884442oih.3
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 16:37:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=BzVnowWmZKaU2AvNWtcRY3w51Qkf1HDA4esK2SVsbOw=;
        b=BadCevPSd6n5+S3W5fShZxmimzWGagLV/xJqGuDBzBtcQQyYiIXkBcHACEcrjkPBLP
         yAkZTEj+0hbImx9561+6VcRvE3cOYFZq2fc9MCOLAqpPYiVEdHcCmVQno3HMd30NIsDa
         7fK9E/3b1MJAMNDry4Puhw9cTAgsiW6ZVDYU3aK7vMvCDDotUmB2p8zIU+3ayoFOlkjL
         IXkhEzi/2+E48IJu/6cQwa8hvQ+z/EdgwKYJbKZ7G8JCgd0+OA+rPxWATSR5CMy/OXWI
         WuZejyWs6PIjZMT/vaJIj2qDBO7eCpslnePoLIJLKhspj2Mz8E87pkRuBhP7J8yciKH+
         mbgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
X-Gm-Message-State: APjAAAXojxGWT4w+afiqPiPV1SynnIlP6yoFGsogtkScbDfaiizTaDAR
	k6nBDm+zey0Q+lnh7h1sDBvqFY3Ajk4g3fT20ssrFVvKDjiTJWCCOQdWzhLzLJf7RUPIOLjEV8D
	3M12xNdq1f7gFE188r48d2FhTiPLDsvWhPQ5h4GR6yGEhK/5s2Rtr9UsRQK5Zf1fbAg==
X-Received: by 2002:a05:6830:2119:: with SMTP id i25mr10884228otc.282.1562974623614;
        Fri, 12 Jul 2019 16:37:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDsAmRToHWGfjihJJkGLKU5ZgX1Z8afOAcH6iAzFcp7+GYOg9UoatVczsM42OK+tlPwJwe
X-Received: by 2002:a05:6830:2119:: with SMTP id i25mr10884198otc.282.1562974622839;
        Fri, 12 Jul 2019 16:37:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562974622; cv=none;
        d=google.com; s=arc-20160816;
        b=qI5503tl6c3wKEgXFPrLeA57WPd890G2WR6qRZQFXoBdSYqY9lpFzXxyELW8nh0K3m
         4Apdfil38IpAnCc6qvXlUMNoAF6uMdkqIqs2OjKvWAPDRsrN6nHYN6kVm4nzRkDyTgvP
         DGMVv++qpLU9/iDLrB8A6TIsWHx6qfzbfxSk104paR4B55hmbFLrUJdz+8dcvVaoO6HI
         V28FW8vmGzcohghxkg77wE3/Iisi8H5xeSnV1vLQoig+MBbgXw9q75Qe3xltEUmE5Ywo
         2k9WTXsB+Gpd08krJOssRFA/WtSWd8nF9A+CNawXYhU/Cm6bNZGmzba2rZnWKlkqK3i5
         sZhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=BzVnowWmZKaU2AvNWtcRY3w51Qkf1HDA4esK2SVsbOw=;
        b=M1lRTelBkse9Ezsr0u3F5O9A/NPmamriE3fPkzGOGCqIHuv/4uZz2T8qPdNTdEjaWE
         kQUuYz5Lhm9bRxMYO6XD1Wf7IM3Ry+9K5Dp4Q+9hq1Bo5eLUtq6n8ZnvTMhuhrrxk5D2
         e6ULQXFbln5IgyWYkrv4izyoBWg5liqeQ/k9jZLKTTpD+Zrxj5VkwXhlvY6LGVWm914K
         JdGSr8RsvsMjgxpqewQvW64FVzs+aXIfD8hlwwa70vaUdMTydoAvGCrimoLUzTcI2MW6
         TlxYFObtvr3h405EOnGE2Hq6ktSoYsTynEmkWfRSnY7xCH/ao4HId6PUG6jDMeAVxrfg
         A/9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from namei.org (namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id g124si6482076oib.204.2019.07.12.16.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 16:37:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) client-ip=65.99.196.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from localhost (localhost [127.0.0.1])
	by namei.org (8.14.4/8.14.4) with ESMTP id x6CNZroi024242;
	Fri, 12 Jul 2019 23:35:53 GMT
Date: Sat, 13 Jul 2019 09:35:53 +1000 (AEST)
From: James Morris <jmorris@namei.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
cc: linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, linux-security-module@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Brad Spengler <spender@grsecurity.net>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Christoph Hellwig <hch@infradead.org>, Jann Horn <jannh@google.com>,
        Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v5 03/12] S.A.R.A.: cred blob management
In-Reply-To: <1562410493-8661-4-git-send-email-s.mesoraca16@gmail.com>
Message-ID: <alpine.LRH.2.21.1907130921580.21853@namei.org>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com> <1562410493-8661-4-git-send-email-s.mesoraca16@gmail.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Jul 2019, Salvatore Mesoraca wrote:

> Creation of the S.A.R.A. cred blob management "API".
> In order to allow S.A.R.A. to be stackable with other LSMs, it doesn't use
> the "security" field of struct cred, instead it uses an ad hoc field named
> security_sara.
> This solution is probably not acceptable for upstream, so this part will
> be modified as soon as the LSM stackable cred blob management will be
> available.

This description is out of date wrt cred blob sharing.

> +	if (sara_data_init()) {
> +		pr_crit("impossible to initialize creds.\n");
> +		goto error;
> +	}
> +

> +int __init sara_data_init(void)
> +{
> +	security_add_hooks(data_hooks, ARRAY_SIZE(data_hooks), "sara");
> +	return 0;
> +}

This can't fail so make it return void and simplify the caller.



-- 
James Morris
<jmorris@namei.org>

