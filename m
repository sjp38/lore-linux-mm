Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1A2FC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:25:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F0F22054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:25:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AOvHnDX1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F0F22054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0C568E0003; Tue, 12 Mar 2019 11:25:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E92998E0002; Tue, 12 Mar 2019 11:25:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D347E8E0003; Tue, 12 Mar 2019 11:25:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7598E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:25:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x23so3416842pfm.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:25:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OAThpFYHfFpJdEy8OwLPNDdww7fmMTYYWyenN4Id6uo=;
        b=Ey8kI7hVPvS51NRQ/QVVDd5Fwz5ZAB+XyttCPzX5+4cR2rqVyGVo0OQes/Os2N+NOG
         cDdD4wCWueAl6yp8l4UEoVhXlc8unATKcjKxWAR17LroF4au6qe/HQpmr2YwT1HJzRxq
         9oQlLUNTbT2pFB25rwpqErWpvLWdjK4kSRo0y7GEeeEgbrSS76zfmLbkN22t6/fGhiG5
         mMZDeh5FZwaonl9K1QjlCQT+XGaRf1RBzSiOBHhtqxek++30mGquYqJubX0ZUShYKK6Z
         qF8WONSwO+MBax5AzrQXuFwrdJHa9fN1VBm15eYRefoYVz3RMalrmbVdjbo91hd0PD0g
         8mjQ==
X-Gm-Message-State: APjAAAV+1aQePRZgo9a+VySjoh6vn7m8xojkAXcDKJvwPqpyQqgInC6T
	5X07SKdLBA8SesOWfEWJP012vyTRnQ74+Immpe5WBQaP3pcK18dSrlPcmbvF9I8D5VHYozziV1I
	6e4isfW2T5Cv/4N74RnlBpRciZumeFAyUHMQz9QORyZfvfeb4ww13pZAtPU9GfvHh1w==
X-Received: by 2002:a63:2b03:: with SMTP id r3mr550800pgr.1.1552404347917;
        Tue, 12 Mar 2019 08:25:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHPDjSyzhVW+niFz804X7nOrAw/SE0wq7R0/SRosppq++Oi31l0c03hM2Qd8618bMqZph6
X-Received: by 2002:a63:2b03:: with SMTP id r3mr550726pgr.1.1552404346864;
        Tue, 12 Mar 2019 08:25:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552404346; cv=none;
        d=google.com; s=arc-20160816;
        b=jKs+oiN7IBsURX+O+iCj83Gp63mDQxQ+zMuAKd3bTbS5bFaC67kGdohgOc/CdljGX7
         gJ5faLy/0sc4ilthlqqOvqYsIkeNaaG0v7uqU32Yv2jZsPv5bwBo7wqqg/2LKQry+HDa
         TIW+AkqToiE/zbT7HQdctKToIATtvtVAz3Y5GSy3SGSc2LWIMRIgIV+tU+EsAoZSaeL7
         WbY/wmRZ8WiR9UQOhuPHVoR7IuunrgN8elj4QKBQ7CdBT6hwiQKmJxJfV4kN4QVrtotg
         ept7lixUgUHvEyd6pdpMZSpXJvWtjgkm8U4LD8kqPes26FMXc8Y75CmFKcqGIH0rF2uG
         ovJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OAThpFYHfFpJdEy8OwLPNDdww7fmMTYYWyenN4Id6uo=;
        b=voJheVsDAesHLG085JSOJtSfPDp+IveqQX4VXpzKyfwSnayIPEXHKaB0c+Xnj07D+S
         hAF9CgDblM2iDmtw4HsLqxYMGxMUzNbwM89+smzRbE3A0ZICyOQFu7VL9pWI3/LHfSom
         XMnXxyH/O2XVQ9YZ9amPLM0kLQ8I5TktySmozaOoLYnYcQuzYlbVWi9RUxPYnbw99Wo4
         5KWbEjyhmy/gn5iiGUktOp+8c1ILLPU4mW2nOiSgiGvHg9c/Wjk/riJA170rrNrzlw07
         b4Z8VIt2fIXTepvTmxsdD+shAwD/CPVZAaE5/DRq6ZuJ/dYkBjoqy3Tys0HiwiiNF/sP
         yMHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AOvHnDX1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d3si7603041pgc.461.2019.03.12.08.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 08:25:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AOvHnDX1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=OAThpFYHfFpJdEy8OwLPNDdww7fmMTYYWyenN4Id6uo=; b=AOvHnDX1lDeBOkejHAgtcES98
	maDyEJIbh2t0zujM6b1FKExleWlsQr9ryaTezc2F7EGc7u5iLKFyUKAZt9V0EjkBysvW1PlEps+O0
	qGt6i68gN15lovw3xoNxGU2FqsVKU0FpIcGbsogl0lu64m87a7E5ZMT1PIsXOOxBecMp8i5D4/kmB
	ZThuHfu/oIyz5uRfHh0N3RZRTcRwEjSPvrIEbfIbzRlDWkPmLveIeC9Z4QCSAi6IjN8kE+v9iOU52
	x7cXj+QX1JvdxblwYJwnWvHlo6Cdyr6VVLyBsXNYJaFL/+CWtkiBDA/ZyiaVMBOc+JwkWseRE7qzF
	LVUBGt8hA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h3jHh-0004rb-E5; Tue, 12 Mar 2019 15:25:41 +0000
Date: Tue, 12 Mar 2019 08:25:41 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312152541.GI19508@bombadil.infradead.org>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312080532.GE5721@dhcp22.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> On Mon 11-03-19 15:15:35, Suren Baghdasaryan wrote:
> > Yeah, killing speed is a well-known problem which we are considering
> > in LMKD. For example the recent LMKD change to assign process being
> > killed to a cpuset cgroup containing big cores cuts the kill time
> > considerably. This is not ideal and we are thinking about better ways
> > to expedite the cleanup process.
> 
> If you design is relies on the speed of killing then it is fundamentally
> flawed AFAICT. You cannot assume anything about how quickly a task dies.
> It might be blocked in an uninterruptible sleep or performin an
> operation which takes some time. Sure, oom_reaper might help here but
> still.

Many UNINTERRUPTIBLE sleeps can be converted to KILLABLE sleeps.  It just
needs someone to do the work.

