Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2F66C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:38:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C2762183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:38:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C2762183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FCAC8E0005; Wed, 27 Feb 2019 13:38:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8FF8E0001; Wed, 27 Feb 2019 13:38:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 199118E0005; Wed, 27 Feb 2019 13:38:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B979F8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:38:42 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v8so8271567wrt.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:38:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=91FNbJgK9Kz8YKrwF3lHruGDyhxdjpp/AkW7uhJm7RM=;
        b=G7rrM1ATgV7itwwRMyVZZyKCt7EX91rsIdwdmMI9XrDbvKDguclLGPP9iPECrQFDbN
         TSw35IFPqWwttmlwcWHXYIWihGWzXAlwHXVknFhuVpVCrZc/rM9UOk6IDJ6icMSlCCoK
         P+5nIT+SjTnx+CCEe5QaQnneaYOnTi4HLpWFVyowqbBXbtAstov/wQQzg2xvcocJbj0T
         5nsyofulEVYTVnNPGYagMcFP8+gnnBGKXVSTOzWmrw4lmoGdOOaMHVSc0P8DTWDh3F86
         lqjU5H7VILPgWN0+GE/YdOBn2vCmCo2naAHSQv+K14PyQ9h9iB6VrFKCB0V2rTQUFQO2
         ahCw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: AHQUAuZz2HWoTb8+556899RfMtpIk0OPlk0uTZcgbuOxzMyzJYR7i6lK
	nhNoWk/6ieG1PGZs6B+Z2B9AtjHA9Me7iDvsP7uIbDQOCEllPsucjj9XKR2a2Z+1JmxIWP3MyH0
	koqj/GWnrtPKBSKcOOQGIbwVHM8iy6PgTRkboZI1E7/XTWeacdmCujBGPoMPpoBw=
X-Received: by 2002:a1c:9810:: with SMTP id a16mr405792wme.37.1551292722247;
        Wed, 27 Feb 2019 10:38:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqxSkEaYenxCZbu8TPvK1M/AUmNGMAvyrkejvRJ+Uf6/IIsN6bdTRsvFzTx2I7VVC4z0gwvW
X-Received: by 2002:a1c:9810:: with SMTP id a16mr405753wme.37.1551292721183;
        Wed, 27 Feb 2019 10:38:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551292721; cv=none;
        d=google.com; s=arc-20160816;
        b=wCUdXXgE7BvSiFlbMjx1QaYO4Uaq7i4/3MbnPUsoqsP9zhyjq+fbfZfMiZbP3h44+b
         /r4XVR3Dm1VzdCqBpXDQ2sMoO7PwZzM4zPPIlnz351WXRPyrPxHZIswauysw0LvKrHeE
         rC5Wm8+PXo6P42FQo+UpUKmcTFoDSYn5BxonfTL3u8te2Es5q+BlQ+yPxKEk7sUq4Hoj
         MIZxkUT4QJN3auXLsGdmA7PPQYmPuqKZcRgADujYfuQ7rKTPhnqZmydsn8L2DbRdNhCb
         fHm76vDh5hLAjkP1Trnqess+ZE9orzkFyWy43nxDlv8U9fA+nPUMoBx0L8Df432SV/lz
         MyGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=91FNbJgK9Kz8YKrwF3lHruGDyhxdjpp/AkW7uhJm7RM=;
        b=atE1oNHbxP/oB+m5GH2zQpLkl71a+T9Lbihp/qnRZf3u/CsxHkhS3pVjlvzTQtfwcG
         z+FdDqdnzzmzs1KgmFA+fMHOMLZmEIhYeMNo86Zh93SZw+odBaL3Uji7eI0vwsBjdWoW
         5NadFCj+NsuqrKXls5GE/jN3nhn0WQtV1G9FEpwTDnDQ6G7e/qe/K3TvtjcQoILIu3zx
         7h9Wp9RNn0SWNy+DLXIxE+v+RGnzmkalxy0HJwsoUB1vdRpJt/8YD84Uxnq93DiYyp+k
         sTrNg/QkvUkeHN43KFXYY9gwnlBff2IqXcKBPJAfgGWV3foJtKY+MhSotFh53FPx+/yQ
         bA1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id r141si1703775wme.99.2019.02.27.10.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 10:38:40 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::bf5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 157C214010634;
	Wed, 27 Feb 2019 10:38:38 -0800 (PST)
Date: Wed, 27 Feb 2019 10:38:37 -0800 (PST)
Message-Id: <20190227.103837.668255833945043179.davem@davemloft.net>
To: steven.price@arm.com
Cc: linux-mm@kvack.org, luto@kernel.org, ard.biesheuvel@linaro.org,
 arnd@arndb.de, bp@alien8.de, catalin.marinas@arm.com,
 dave.hansen@linux.intel.com, mingo@redhat.com, james.morse@arm.com,
 jglisse@redhat.com, peterz@infradead.org, tglx@linutronix.de,
 will.deacon@arm.com, x86@kernel.org, hpa@zytor.com,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark.Rutland@arm.com, kan.liang@linux.intel.com, sparclinux@vger.kernel.org
Subject: Re: [PATCH v3 20/34] sparc: mm: Add p?d_large() definitions
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190227170608.27963-21-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
	<20190227170608.27963-21-steven.price@arm.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 27 Feb 2019 10:38:38 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Steven Price <steven.price@arm.com>
Date: Wed, 27 Feb 2019 17:05:54 +0000

> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For sparc, we don't support large pages, so add stubs returning 0.
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: sparclinux@vger.kernel.org
> Signed-off-by: Steven Price <steven.price@arm.com>

Sparc does support large pages on 64-bit, just not at this level.  It
would be nice if the commit message was made more accurate.  Other than
that:

Acked-by: David S. Miller <davem@davemloft.net>

