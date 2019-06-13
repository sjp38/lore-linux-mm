Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73053C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:23:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28DA12147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:23:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28DA12147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C02216B000E; Thu, 13 Jun 2019 09:23:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB0C76B0266; Thu, 13 Jun 2019 09:23:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A79316B026A; Thu, 13 Jun 2019 09:23:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 51D116B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:23:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so30892040ede.0
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:23:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8J7Rih9OPMK8tvuX66sgvWf45vH20Fb6O50RqNr8AU8=;
        b=Wj6MW0KImYPOw7iRxiJyrkgDsamvMgDsQU+50MpfJXA/Dbbbu3eDOFL9v55ozoQkmK
         2VGDbwotxBtu7eX68TacyUKOG06Wirr2/gy19ARkgPR7C7WNo2je2JfTJFTS7vra3e4a
         Pgy/4eA+3iSCM5NVuuOvlyEdNIUl0aHkRjzLh4viomeR0cWpc/Es/RP3pQ30ws2Au5Bj
         2D71PU7it1rs98ANomhrHKtpE/AtX6C6h5JPe4MefliZtrhbgfq7ohdsc4f0SBhNN/9t
         VYm5LU+3+/R/ZYSOzCYYtOaO2YpJEwWMmObu+D6WKCl9uF9S8Il6g6EcpPv5h4zFZwXv
         X7eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAUQdt8g6vopGgS5eDZzC2m1lF3nvrh3AGV3xtphUZPty1I4L04g
	IE0llBf3I77epuIuRZLkerXC0A+CcOxtYCcQ+fyk1RHEccI677jInJKwbMr2/awSp8wOSwCwxRB
	EEKCo8N1JBNjUM4d/oPLd1g4CVf+vcho1wASbbKi8ARlQCVbllHxrmyT+2z/1loWYNw==
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr46061639edq.251.1560432228901;
        Thu, 13 Jun 2019 06:23:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZy7b47j2+cJcl00oB4SNf/srqOvCJQT4/l7hpOZvzCbQaH0/1Q4a0dijm3ZTA1GHDOBlB
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr46061554edq.251.1560432228093;
        Thu, 13 Jun 2019 06:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560432228; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVm0TjcROnA6HTR6vVgBqpQO8Eakwd/6b2vRoQxX/u/OhT6HFNPGLuhhVu5XugLdN/
         BLwvQdDAb5DtKwluNpE7N27r1pEluUR8UBe9Q1RSDduGPCVwCKIBm9pOpWW68CW9fsok
         /yC78aKaaQaTyvZwhm83VZPAzQZ9BnOP0O+TeuUnZ0H4jB3nRZwz5KOD0vKSOrAWyYqt
         GApSZbsclrlC76ETTaqHJR5FHU1ajlEuHfo4QgT00XJrcHoPcYteQSKiBndR7xym7hf7
         1BrkIBGAJaPGndcFGg3ygQK0xZfh6JG4oaQd8TjMe5Ty0UeD0X7QPIzSRs9zVVqh1QiX
         J/7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8J7Rih9OPMK8tvuX66sgvWf45vH20Fb6O50RqNr8AU8=;
        b=YjDzP8fV/t0Quvi4vFaGdS+4Rr9nA1+ZiKza0oiMqJNgJS9Hhjz3DkdGBtxcjIWwf9
         JFMSennKHj5G0VwiL3aaHr+pCzEayIf9Ax1SqU3PY6oSGIPzviiKyBy+ueyXN5Lfnryz
         QGjvVWPJSYAgdw3P1tzB7t5bRYl2mbXs06MQx/7DapWT5i6iJCQRzLUNhIyIYg3m+anJ
         pTu6AMap7GzjbZHD7uzZ4XNZH4RdCygcCawlWldzsYgulOFcVNj221VFocWWDkxPCJpu
         4WaUGwYP4aqg1VEra/WxCqdWTaLHk5eVTf9njVdAqftlfasqwiJ146bAkCQgZOARqqM1
         UcNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v26si2277931edy.37.2019.06.13.06.23.47
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 06:23:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3E6A63EF;
	Thu, 13 Jun 2019 06:23:47 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A51833F73C;
	Thu, 13 Jun 2019 06:23:45 -0700 (PDT)
Date: Thu, 13 Jun 2019 14:23:43 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190613132342.GZ28398@e103592.cambridge.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <20190612153538.GL28951@C02TF0J2HF1T.local>
 <141c740a-94c2-2243-b6d1-b44ffee43791@arm.com>
 <20190613113731.GY28398@e103592.cambridge.arm.com>
 <20190613122821.GS28951@C02TF0J2HF1T.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613122821.GS28951@C02TF0J2HF1T.local>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 01:28:21PM +0100, Catalin Marinas wrote:
> On Thu, Jun 13, 2019 at 12:37:32PM +0100, Dave P Martin wrote:
> > On Thu, Jun 13, 2019 at 11:15:34AM +0100, Vincenzo Frascino wrote:
> > > On 12/06/2019 16:35, Catalin Marinas wrote:
> > > > On Wed, Jun 12, 2019 at 03:21:10PM +0100, Vincenzo Frascino wrote:
> > > >> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
> > > >> +                             Address ABI.
> [...]
> > Is there a canonical way to detect whether this whole API/ABI is
> > available?  (i.e., try to call this prctl / check for an HWCAP bit,
> > etc.)
> 
> The canonical way is a prctl() call. HWCAP doesn't make sense since it's
> not a hardware feature. If you really want a different way of detecting
> this (which I don't think it's worth), we can reinstate the AT_FLAGS
> bit.

Sure, I think this probably makes sense -- I'm still getting my around
which parts of the design are directly related to MTE and which aren't.

I was a bit concerned about the interaction between
PR_SET_TAGGED_ADDR_CTRL and the sysctl: the caller might conclude that
this API is unavailable when actually tagged addresses are stuck on.

I'm not sure whether this matters, but it's a bit weird.

One option would be to change the semantics, so that the sysctl just
forbids turning tagging from off to on.  Alternatively, we could return
a different error code to distinguish this case.

Or we just leave it as proposed.

Cheers
---Dave

