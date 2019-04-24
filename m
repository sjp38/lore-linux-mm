Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD06CC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:36:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0483E218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:36:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="D4Fw+Yst"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0483E218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 937E06B0005; Wed, 24 Apr 2019 12:36:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E7DA6B0006; Wed, 24 Apr 2019 12:36:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 789CF6B0007; Wed, 24 Apr 2019 12:36:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3896B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:36:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so12454275pgs.4
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:36:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bU/jX4EW0n/qwLCy74iol1YUkyqzsbWOTtyq6RpkK+o=;
        b=jFkjWVNoU5JkfzTcUyu8bdsPpew2GEJgI57AqbGNas+hvIkSgmYHPkQZDO/+TqcMQq
         myJ7Z4LQhIwy6BvJuoPOUg5RFEef8lL4fkkbQzv5MoM1/G8uXBVvsV+91psfTHHje5eO
         DUk1B4+tuVTEPg+VGEWDL2tuHcZYDKzCmyxhAZYacP39+RUlFlimoquHnE9icBCs3zJM
         1BoeAYKGBvxvnHl73r+83iwCWbaSak7P0/tQ8aJwaZUV5E+HuUvG+tmksz2g5iYbvDux
         Mn3CxbRK6asVhHDdSHIQbTDjMRj/Zqyml1eGXn04Ti+tyfz3VjoZK+ZBZfFnLQrcoHkC
         5eQg==
X-Gm-Message-State: APjAAAXIz8tVfB8WnJN7ko0pQ/18u7mmiNhZjfMZlPZ/3ND1T61g+E9R
	JCnUyI+4U6E9P2iZ9X+3qz4//2Iw8FpgshDsR5ldg2gpPkgNI2Xr8U3zQWDAFysnvtPkZQOn4nE
	jw1ClJM/WCNfsY3Lbc6K9kq8dNlDT7Eewm/X1uzqoDrBBpr3vsicV2KKRD5MGsNJy1g==
X-Received: by 2002:a62:1815:: with SMTP id 21mr34364804pfy.107.1556123815827;
        Wed, 24 Apr 2019 09:36:55 -0700 (PDT)
X-Received: by 2002:a62:1815:: with SMTP id 21mr34364737pfy.107.1556123815029;
        Wed, 24 Apr 2019 09:36:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556123815; cv=none;
        d=google.com; s=arc-20160816;
        b=DEJQCMCNH4nuJwxOfKBkk/Kf06dQ39T/Ae3GYsimY/FT0gs/YTtTNNIX2RffF+42HN
         VMVykGbBguD9rgahu+ZBMxSNDVoE26aej1jk7tgBNdaVd793VmvV+kMVb/mQVqNmWZgy
         aE/Tx9IgbTfGT0Hp/RTQcTWBNr2FjjkqpP/vuIWPSdmxwzehfkpJ9lmkaZPSlxOwr6p5
         Q0XoW8xwc3yyxdggkfH2sQUl6S1al4vkratpCLjKUXIXTL961KVX1Z8eA+UzBVik0BK8
         H1of8jPq/gAoCcA5vWy7yIIL1RpQURIhx7Hvhxr/JUapJ7fp4i1kjfiHgV6ydqR2cDND
         eAMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bU/jX4EW0n/qwLCy74iol1YUkyqzsbWOTtyq6RpkK+o=;
        b=k+I4ZKxT0HCrrq35HXCr4QqsflA+IIKmJp4CFHPVtf2esGSwZYo0A4Wp+mNv5O73+X
         K+O8tkBfMHviSMvqRY7ga5QsJmtTVVMWkemcrcqfksrvwdfu0BNnGAFGdBHSAUItOYhp
         wHJqOat2lRO5UfEBsYmEtNNkKVt/o6C4hPtI/pOMK3bjgr3NS2+w4yLfEu853yDpdy0X
         yb9rH1yuG1mc7nlKvGUZIcElSPckKrB2ZNLE9bKBai/DaokzdpYAKkBnieD5pztBpCgS
         4jFow6Z1wa8k2r+o9DhztklRorQexN1fUhF0emZwMrc2VRRbhG3DDs45lOG1vcxtyZe1
         k6Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=D4Fw+Yst;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c13sor17505255pls.34.2019.04.24.09.36.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 09:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=D4Fw+Yst;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bU/jX4EW0n/qwLCy74iol1YUkyqzsbWOTtyq6RpkK+o=;
        b=D4Fw+YstAFvEcLOXoz0+EOCMKbdFRz9+xSQITiW9brI/gN8iTqnLu8B5LRBg+QVQTw
         JYlRewnLVVwhUf5CPnOVPDNN4Z7pZKlQf3caK9zC/yjKUew/clyyCpkpJgAw0DAwGiBV
         Oh6y5cvw4G1nqWMa9SlFCcCN3Dnhz45SjnkmhhuzFWNWI0HXdVUrA1ODHEnOAKmkJemi
         hsHdPiEebqUnVcIAWySSWmkAwqyUvIzVUAmL+rmYqwg1uh3dpm06AIspDs5u+d8k9cYG
         87HfXHJSOW6CSkFGOYaZ7FsrQw+Q+6E+S+3lVuaW2kpNlmxeoyIG4AIpA3kviqiYYwDQ
         2SFw==
X-Google-Smtp-Source: APXvYqz3ZsYjN/GMH6XJGU5WPREplJK5uhzjVbCbvGUwH8+cV6tc/eInXh1rwPLRoUunccagzkonPA==
X-Received: by 2002:a17:902:a5ca:: with SMTP id t10mr33803404plq.234.1556123812238;
        Wed, 24 Apr 2019 09:36:52 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:3dcf])
        by smtp.gmail.com with ESMTPSA id s20sm23146257pgs.39.2019.04.24.09.36.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 09:36:51 -0700 (PDT)
Date: Wed, 24 Apr 2019 12:36:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Luigi Semenzato <semenzato@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: PSI vs. CPU overhead for client computing
Message-ID: <20190424163649.GA14187@cmpxchg.org>
References: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
 <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002627, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 03:04:16PM -0700, Suren Baghdasaryan wrote:
> On Tue, Apr 23, 2019 at 11:58 AM Luigi Semenzato <semenzato@google.com> wrote:
> > The chrome browser is a multi-process app and there is a lot of IPC.  When
> > process A is blocked on memory allocation, it cannot respond to IPC
> > from process B, thus effectively both processes are blocked on
> > allocation, but we don't see that.
> 
> I don't think PSI would account such an indirect stall when A is
> waiting for B and B is blocked on memory access. B's stall will be
> accounted for but I don't think A's blocked time will go into PSI
> calculations. The process inter-dependencies are probably out of scope
> for PSI.

Well, yes and no. We don't do explicit dependency tracking, but when A
is waiting on B it's also not considered productive, so it doesn't
factor into the equation. psi will see B blocked on memory and no
other productive processes, which means FULL state until B resumes.

