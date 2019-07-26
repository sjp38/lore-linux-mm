Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,TVD_SPACE_RATIO,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18661C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:34:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7D8721994
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:34:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="SrH7L+xp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7D8721994
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAFD76B0003; Fri, 26 Jul 2019 18:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E61098E0003; Fri, 26 Jul 2019 18:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4F9B8E0002; Fri, 26 Jul 2019 18:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8CE6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 18:34:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i6so26243533wre.1
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=teW9UCbxA/etYx0sHYFoKRXSUQlEi33fuCpUJ8AOwWo=;
        b=d4gthsBgnCYyBWwZCFY+GifE3clio1Fc14Jx02IFRdZUIq5jXC321jxia2v0ujRIJ+
         z+QcSnOlIXJZsNZRsNvKEe+pP2QY21J2nHLS73Sk2uHPlWKS5rNd01ab+eyz9xcGnJ/g
         ysU9fZo4fRd6f+iDXnXzvLMc4i6VCn5DbqfLqBOLeaKRPz4VZE/HS7Fk+G9u2CPfY/3b
         fVOoDHKFKF2ho9m2Lwd2NiGZAK0WS9jzqBFTWf6Zi8ugIs0wShkxUZLkXcCkblh1G1v8
         XoB2sc4fIlM0CSCUHuhULxEbSw3IHdIjG3y16qwIhkt7CivZGy0PhaV8hjZpvVzJdIRW
         riGw==
X-Gm-Message-State: APjAAAV9vYA0fjQeGEnBrW5ur8Il1onWM8ieHxLgpL4NA085W4JtUfIf
	pnW8g1mzC1YPcWBH943JDBsWPcAOzDvHTiyQqSwz7FwMZyrstD+qa7KpXU0m1SYbqnFocqPJdDm
	8C7XBr08P6h9PeWacNUhG9DmiFZVVepTAmojhCqsPupqcr21H5mptHWD0hv0x/MXRzw==
X-Received: by 2002:a7b:c776:: with SMTP id x22mr13795903wmk.55.1564180477974;
        Fri, 26 Jul 2019 15:34:37 -0700 (PDT)
X-Received: by 2002:a7b:c776:: with SMTP id x22mr13795884wmk.55.1564180477121;
        Fri, 26 Jul 2019 15:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564180477; cv=none;
        d=google.com; s=arc-20160816;
        b=JOCSGfDwwEPczBQ2qhmvKwTlisVP/Rjx5B8BASIZepxdNLDO9OsKgZhvCC6wF/O8zi
         V8qLLbvUcZoT+P1HI0fCffwBG+Iq/l0XjJiwTLe82lHM5Zeqi0a6UQ/JLpcR7SiPYTLg
         XlwRZWwUg/C4ruCk9wURv2jxc65AZBO6unFiSzKUVMOp7V9amqHMWrAI0colYS15pGEv
         9C+XkXmeGGkZdsn9l1nr7NtRv+J/mWERfUyBS+Ye+yKnSWO07bHvQT6SdTmJJ8SvhJ5b
         9GihLTv91akQWRp78XXXwpNVIoVCbIdPCuN5JFt1FjrCwCAANXh//4r1qY2LYAyhmYmT
         mrnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=teW9UCbxA/etYx0sHYFoKRXSUQlEi33fuCpUJ8AOwWo=;
        b=bVufTtHP1cXaMeQv3DUG74YyZNe/jyaSmuGSlwyltgHhM3GcS/TJ22I5Ir1OOuWHjR
         +qsQZOKqkKbI3vgqvcbeHhQoY12vbsMy4B+dTwI7dFtJWDY7lxRHcO1onowCfZEQ+Ku1
         xeqosWPajKOkYL63NJne9u+OWftzOlwuopoEAvLLs8IRmtEuk0QLHAlhzNlrQ0T8Y4iQ
         pAmLYsEr7sIxZyXNM3EOggbm1Bbu3dgeeHe+znHAqENLmBFn3QzH3mcyhnurkMosX9Rb
         SaVjJ9+5muAqgoa91OEb4yJiNT6sC2GmQsmKYiqngWaP/axBGIqoFrhChaZJ0X8tBzIT
         JAMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=SrH7L+xp;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y134sor30054952wmc.4.2019.07.26.15.34.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 15:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=SrH7L+xp;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=teW9UCbxA/etYx0sHYFoKRXSUQlEi33fuCpUJ8AOwWo=;
        b=SrH7L+xpuU1C1Kssd1KDttlOB49IMMPtIOR5yli5S5pWcQxnZNKt5LAPavHiUwG87I
         1w++3qzt9eZqIaOwkWVxdiU/OQ2WAL7+NL+MxRzBrxYahSSwnbuLkvIiQqo9HufBxoIQ
         O2j/JBfq4sBzIMt1gIhTXPOdxamo/Nt4i4hik=
X-Google-Smtp-Source: APXvYqzoKpPSoj7/6ufA48Cus4/lJuhS4fRI6EnNvP6Zx4/+34y6jmxLY1EmlQ2icJZjpfSiQJH+bA==
X-Received: by 2002:a1c:107:: with SMTP id 7mr86911714wmb.84.1564180476668;
        Fri, 26 Jul 2019 15:34:36 -0700 (PDT)
Received: from localhost ([2620:10d:c092:180::1:602a])
        by smtp.gmail.com with ESMTPSA id 4sm123647887wro.78.2019.07.26.15.34.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 15:34:36 -0700 (PDT)
Date: Fri, 26 Jul 2019 23:34:33 +0100
From: Chris Down <chris@chrisdown.name>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [mmotm:master 49/120] mm/memcontrol.c:2418: undefined reference
 to `__udivdi3'
Message-ID: <20190726223433.GA64654@chrisdown.name>
References: <201907270424.JeLLgbe6%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201907270424.JeLLgbe6%lkp@intel.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew already kindly fixed it in 
mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix.patch.

