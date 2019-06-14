Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3F74C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:15:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 887EA208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:15:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="MwtAFV5y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 887EA208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2563D6B000D; Fri, 14 Jun 2019 08:15:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 206FD6B000E; Fri, 14 Jun 2019 08:15:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F6596B0266; Fri, 14 Jun 2019 08:15:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E72E46B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:15:42 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r57so1894713qtj.21
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:15:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=NyPPbZhNfqDmfzBJP+Zyu4+7by3zecVFnafl9bsTygQ=;
        b=GLHsbt52+EhQfeWbx3i0C/DDJkJLCMCrQzyoKvm1zqJQ+TV5lkxqZm8GpkFaHry4v1
         c4ZhdHTsGYl1KWbtDb90HVYtw0n6ti6ty5o7g6rEIHqRLCVPWT0d3gYWIUXQNEE3HK48
         AbwJWmKkAWFJgltHCBslKuS/kQvfK35N8WB8G57Ah1XT1GazF9Dbfw8WvRJkF7YnC4pI
         RFHhvwUlA5dMrNaYIyXJ1yM1IsflT8dpDGoC6OOrwVr5OCuyzvqIX/+McfkPZnh9vvU+
         CzVPp/qd2KLOqtD3qepvSJg31mjhXH3bEBkw3Av9d2f4xN9SzEgFOFRBIZw3HogN1ONG
         5Obw==
X-Gm-Message-State: APjAAAVzirz9zbK0Nim3J2eKbpRMbq2Xo8zvK4VZKy3gvRMLF65vmqnt
	WbDXwAtv54+j45TUu1LQ6YaXsnO11AyLhcpjHhz9bqRy8dKhFUcHrJwAQU7JASmPMq/Da+InS5j
	pn2ZVCVquxBqj/4mXcgI/6s/x65s/gZgKVCctfk2TIiVmr2BxZEKBJQ+xAdXVcCW51A==
X-Received: by 2002:aed:3e36:: with SMTP id l51mr79430415qtf.269.1560514542670;
        Fri, 14 Jun 2019 05:15:42 -0700 (PDT)
X-Received: by 2002:aed:3e36:: with SMTP id l51mr79430354qtf.269.1560514541987;
        Fri, 14 Jun 2019 05:15:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560514541; cv=none;
        d=google.com; s=arc-20160816;
        b=OpeQL8gf/rrnpa8o/AuoaA3K7LD+Sr+w/PWYjYyjzvGQWsU0EkcZyByRu9gXO0WSXe
         OPjmXKZPbJrCvdxzyQy67cS8teaVQExvDDzAwz2tkb1YCWLq1CIqV+FFgjBqH93ZW9Ol
         RVBBJo4KbuhA0wTXGGOQUeHVdg1KWg2VpBWX7jb/dfRcp+jYGd0lE8RKG5LXAJ8CbCdR
         cGta/jd2VD74lKxccWu6AtgKP251HKexxo0uWkpLBpydQ7QoGwo166rHx8FAHOzoo/Vv
         dG3wghJaMHerjx1gxu3o5JkPx+U/vF4pHbNAds0doVA1iqIzXMPHgls1qsCTXl904AJ2
         U7fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=NyPPbZhNfqDmfzBJP+Zyu4+7by3zecVFnafl9bsTygQ=;
        b=iMb0poFVDaLOH/dsTV/50MudMaG4DGegSnDfGtv6bWjJx4SLRqX5bmZuPo/3syoPr+
         XWA/3p9B4xN+Uqn5gy3EF9YxKzTtZ2Ro+uKSzcn7CTU0ySHBTz63ibzXM1csKGnYY+/i
         SqMlFocgxUZabVyg31KX5KEkaSL5yzNfr6ElFj7qmbLv/JjlS98NKSsjBf+1ajoNSjB1
         CxOxBRCSjVP3d9OcVCwZDoZoD6IbkrBqbDZn2eSTeiKFpSUDGKSgmBNDwJBwRYJzjLX2
         msqBsBrxCWMaHBuCUr44Q1fvutfEZPjlNAvkqFaznp7awxTxPyJ4LqtGUe801YdbNQFn
         Ssqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=MwtAFV5y;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor1911287qkd.25.2019.06.14.05.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 05:15:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=MwtAFV5y;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NyPPbZhNfqDmfzBJP+Zyu4+7by3zecVFnafl9bsTygQ=;
        b=MwtAFV5yKDZjuENka2cZ5Jk7AlcHqmJVvy0inE9n2UrHXv6Yj8vPyzIczqRRsPQB27
         BXZNXoSJ2asYEv3DXU1qY1m8POHEK2cReZLmvV9kMpkk91hs9Vc0TXy9slEzlW9pJTqq
         wYCQXJcJCzP7MLDmYZmoG+lIP5lo7ndpiazZx78N76/6QelZ8XrgRTgM1yZ4tLP41Xgf
         dwAKdY8Qi5IZhJxvLiYYSqAnBTNJ3KiUU0r6bPbzaxmVkLxiZgFT6DHx8/jm7J1zAC/S
         Lov76Ss/4eSiZYZBiWTtqVxluPsPVup5ZjZbQs+Sp5IG4CdrCrILC0OPRiH5mxo+Udxq
         VpbA==
X-Google-Smtp-Source: APXvYqySndvqdRYK4kC/2Q6riAnaWd2ljn8NHp1bqjNlFAW1l2MJtgQLIQJYpItdU3dRO8CgSWdUEw==
X-Received: by 2002:a37:be41:: with SMTP id o62mr64866623qkf.356.1560514541702;
        Fri, 14 Jun 2019 05:15:41 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y6sm1334495qki.67.2019.06.14.05.15.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 05:15:41 -0700 (PDT)
Message-ID: <1560514539.5154.20.camel@lca.pw>
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
From: Qian Cai <cai@lca.pw>
To: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Anshuman Khandual
	 <anshuman.khandual@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org
Date: Fri, 14 Jun 2019 08:15:39 -0400
In-Reply-To: <20190614102017.GC10659@fuggles.cambridge.arm.com>
References: <1560461641.5154.19.camel@lca.pw>
	 <20190614102017.GC10659@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.007412, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 11:20 +0100, Will Deacon wrote:
> Hi Qian,
> 
> On Thu, Jun 13, 2019 at 05:34:01PM -0400, Qian Cai wrote:
> > LTP hugemmap05 test case [1] could not exit itself properly and then degrade
> > the
> > system performance on arm64 with linux-next (next-20190613). The bisection
> > so
> > far indicates,
> > 
> > BAD:  30bafbc357f1 Merge remote-tracking branch 'arm64/for-next/core'
> > GOOD: 0c3d124a3043 Merge remote-tracking branch 'arm64-fixes/for-next/fixes'
> 
> Did you finish the bisection in the end? Also, what config are you using
> (you usually have something fairly esoteric ;)?

No, it is still running.

https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config

