Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57AC5C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24CF620645
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:02:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24CF620645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B846D8E0006; Wed,  6 Mar 2019 14:02:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31F38E0002; Wed,  6 Mar 2019 14:02:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48DE8E0006; Wed,  6 Mar 2019 14:02:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51D138E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:02:29 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t133so2742983wmg.4
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:02:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xlXhxq5QjLuwSydDOTnCxUICWg03oZk9wuOr4Glednw=;
        b=sm16oHbUryb771Um6bKekZ65yf7mdMLHbD2aTM57KfQDsSRe2hfKFSDRZQur4Q59qB
         M2LIJxHNd9Eo73wHkj0gBG8nAOx2+lypLqMhcTOIhNpsLlgH74QFAsm+4d4RyYTLjMYj
         A//OT+ZQGTARG04+SSUVXVsg3xazrekQmzMBFEOTsRRGV8YQfqA8acz/XwPPaf7THLYX
         AikgY/2SRJIhAumscL3KMlFZHnks7ozJZwo0t+7uxx+ii8oD5oOOPkUit/XMilKLS1+F
         pbsp/9ZwwMPpCgw4N47+NKqFtzIK/UITosBwiS5AfC8mvY4ZWmDijYfOxh0qaL9Hjogp
         A12A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAU7ZOtRnjk2rqYxGoCq7YnJOy9FkQiOadauzPVJmyDGJc7voTB/
	LW2Lz+iJcmjAyjcFAn1Kmo/9OB9ixRn6ZhASfbAf3Sbda6nhTRPs/Sdu5PjcJsHhrVEjOIjum9G
	5m8FZgBhB+QiQ0zgRq+EEz4UuP+VscbtYLc9hnBI/xPkbro0ETS91jumEqQDG2uA=
X-Received: by 2002:adf:ec07:: with SMTP id x7mr3951034wrn.174.1551898948895;
        Wed, 06 Mar 2019 11:02:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqzUPvpvTVws+5KNOMRo12Qv03jPNVGZnYxvHap/130cPnvAjtzrlzppms4zUsUJ6kP4ctqL
X-Received: by 2002:adf:ec07:: with SMTP id x7mr3951001wrn.174.1551898948211;
        Wed, 06 Mar 2019 11:02:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551898948; cv=none;
        d=google.com; s=arc-20160816;
        b=PLXobxCdRTJ9VrhkGmZSZgDjSo3KucHpdafCkPx+tzisBIddVRdT3bhApcPtl0urXK
         47rHidC2ZYhxbnS/ioZhSxs7uBupaX4vYERWKSP5vGIDI3DEZaWIEGpyUeYgkJ5kPbHB
         CLjQ1sP9iiXZ9kYaWKOeTTw2I7F//jgY1Hf2ho3fWTY9NUltnrYvfJm1k36HivOqZikX
         31V/bN48K6QWJWyyf7Uv/972//c6111GPisGN5m5N2GAeKFsUYAbcfsQI2J5Lo+6+UKe
         BXCQulmJQjYKMtB/kxqPrljUCh/ZCZNHnO5cZ2avtIqIaB1jig0kWpw9vl+adQwE2wFN
         9MBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=xlXhxq5QjLuwSydDOTnCxUICWg03oZk9wuOr4Glednw=;
        b=A9S+AWa8kBrCJ3VxVkfY4Y/F61Py4IRykPNWksAkFpLQrXy6mQ/3JX+pKseqSKPM5K
         u0IOVs61R0fkriDiyhdC6tpJb/6SkyDTUIDZMqAqt6n/h8mZxgxHVn48VPEM26I5Q+2p
         +8xewinZui1gJ3trLmAKaV6NQ1EAagEcR41wdGYWSUEYkh0x18F4KZUloloSpkZJYhNd
         RAypitHTnKbF6ZfUvaRipnoWf68AZmGfCoi00GL0zH88vTqGWhA1OYb38N0Hm7Ktbu3I
         hOBrWtEO0faODM6m5uibt6zvwbSeSYKWfzEIktQni4Eq5XImCYnNOjF9AHLp9pFH2pCQ
         mKwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id y2si1553597wrd.281.2019.03.06.11.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 11:02:28 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 610A7105D26D5;
	Wed,  6 Mar 2019 11:02:24 -0800 (PST)
Date: Wed, 06 Mar 2019 11:02:23 -0800 (PST)
Message-Id: <20190306.110223.879768694292631517.davem@davemloft.net>
To: steven.price@arm.com
Cc: linux-mm@kvack.org, luto@kernel.org, ard.biesheuvel@linaro.org,
 arnd@arndb.de, bp@alien8.de, catalin.marinas@arm.com,
 dave.hansen@linux.intel.com, mingo@redhat.com, james.morse@arm.com,
 jglisse@redhat.com, peterz@infradead.org, tglx@linutronix.de,
 will.deacon@arm.com, x86@kernel.org, hpa@zytor.com,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark.Rutland@arm.com, kan.liang@linux.intel.com, sparclinux@vger.kernel.org
Subject: Re: [PATCH v4 07/19] sparc: mm: Add p?d_large() definitions
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190306155031.4291-8-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
	<20190306155031.4291-8-steven.price@arm.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 06 Mar 2019 11:02:25 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Steven Price <steven.price@arm.com>
Date: Wed,  6 Mar 2019 15:50:19 +0000

> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For sparc 64 bit, pmd_large() and pud_large() are already provided, so
> add #defines to prevent the generic versions (added in a later patch)
> from being used.
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: sparclinux@vger.kernel.org
> Signed-off-by: Steven Price <steven.price@arm.com>

Acked-by: David S. Miller <davem@davemloft.net>

