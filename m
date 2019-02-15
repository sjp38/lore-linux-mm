Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.2 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 756C5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 00:58:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3928F21934
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 00:58:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3928F21934
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC2168E0002; Thu, 14 Feb 2019 19:58:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C49DA8E0001; Thu, 14 Feb 2019 19:58:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B11E88E0002; Thu, 14 Feb 2019 19:58:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82BD78E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 19:58:11 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id f15so6820034otl.17
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:58:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:references:in-reply-to
         :content-transfer-encoding;
        bh=X4qRFlWvoh0RWsArKzf8jUQjGlsYyUbs124Q3nGKAuw=;
        b=hgDSZewVY+IgTZCr/YUcwvad6uAdU5I8wxIj5O3cJHdbQh1JoHeeF5VgQ/3DkVPnUY
         aE80nLUgpib5yo3/YPDxWu2jYi9R8HI1UbTvO+npG0Saxwfum/4Ju1juzGgC8VJ37MMa
         MpBLX5Tf0ZK+QFhgXPr8L7c1g5kiyfaOubSRc1ecTR4u2YcFDFqbtNtXNevlXSVL9kls
         L3rrXU20xTDcqs8MF8tfkFGcEex3xhZCmXM+oVyqr1QJT+PswzlwZGkdb0QASfeN/hTM
         CSAjA7P5KzA4QrFzLjXyzHpjdEfWqtywMtZjTKjspiThy+m5xxRZc07S7RFcKGmYXW7q
         aPBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZTVkn78DunDApnHCa1aOfLjBVi1RDEloqNyWESX9xkUNnhnsW4
	qsyJn+t34N/aT2JcLvUDdR000wTk+B7Xo25z1xzqHfomoPjRQ6YyGdhrTD8QuGD7Jo0x3VktXbs
	P+Gh7r56IsgFRv2xSFCDJwdrwdSBzAa86KndKqWx84QKYFnkcKCpArPDnsPHAWy0RMg==
X-Received: by 2002:a05:6830:2118:: with SMTP id i24mr4362191otc.224.1550192291210;
        Thu, 14 Feb 2019 16:58:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaKnqaKB/4iSQJBOWCyH4wq1H+AhyBNeKICwQym1bF2utJ++spWy0kdbAKu6X5y3ww0z4Z0
X-Received: by 2002:a05:6830:2118:: with SMTP id i24mr4362168otc.224.1550192290671;
        Thu, 14 Feb 2019 16:58:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550192290; cv=none;
        d=google.com; s=arc-20160816;
        b=PvmVlYWe0r2+ArOgc3tZ9d/LTxy8U5o7TPEiltEQzzVf+nUKP66fUEmb0pDsU9B/ZC
         p5/BdkfMtRnWTvUKBjWHAhaq7M1tI+V4jSMBx7rAtgsxA7H3UEpua/6Kg3kleonj56nR
         ZZjxr0rtW8weeyn/LB1xJ185Oe2x3J+CJrk6d2+/x8/2crMxZR0SBfaWM3D1PlVIwXDH
         60jGMm5AIPnvaLG4hzkK5T8/5y7m0bJBKOv2mpHADS2iX1yF7xo7EI7f8tlQ+zhgrwS8
         Y9O9fZ5WnAuFxZ2FnE2nRXpPYF+X/qRizMiAtiFGqauKTGcTbORY1kjyIMdzYsIOrZu4
         eyng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:date:mime-version
         :cc:to:from:subject:message-id;
        bh=X4qRFlWvoh0RWsArKzf8jUQjGlsYyUbs124Q3nGKAuw=;
        b=NHt3OE0lEti67aDODVRymFW/wF6Zv2FBlnYluw5IUDRN0EfCFf3Ukqqxk1YQOEiBEe
         QEi+iCz5S2Wf/fe2zgU7/wH35pNtbnUsy2q1B2xXDYrwosF8GPGGastWu+X9exbEx+xi
         YJCIG9wvmpkB3IANErxtl4kVeWX+/f4aDaPv7/ewSCFUcZYUL4bq0RBFBahwWHdUxGA+
         C6EcBwxp2jOMKs4hbtxLkMxwhlitBzOTzJwjOVPdgOsLTGWSRVtWND263U0MVnbx6ojt
         rwu27sjk+d7GYoDhNnsZtNTCoFsEuVN2Jyz+fDH2Pp/DuQwSsgegW0zy80phkF370UxX
         dHKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d195si1705765oih.212.2019.02.14.16.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 16:58:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav305.sakura.ne.jp (fsav305.sakura.ne.jp [153.120.85.136])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1F0vxYI076972;
	Fri, 15 Feb 2019 09:57:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav305.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp);
 Fri, 15 Feb 2019 09:57:59 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1F0vxME076967;
	Fri, 15 Feb 2019 09:57:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x1F0vxHb076966;
	Fri, 15 Feb 2019 09:57:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201902150057.x1F0vxHb076966@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: Re: [PATCH] proc, oom: do not report alien mms when setting
 =?ISO-2022-JP?B?b29tX3Njb3JlX2Fkag==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Rientjes <rientjes@google.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org,
        LKML <linux-kernel@vger.kernel.org>
MIME-Version: 1.0
Date: Fri, 15 Feb 2019 09:57:59 +0900
References: <201902130124.x1D1OGg3070046@www262.sakura.ne.jp> <20190213114733.GB4525@dhcp22.suse.cz>
In-Reply-To: <20190213114733.GB4525@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sigh, you are again misunderstanding...

I'm not opposing to forbid CLONE_VM without CLONE_SIGHAND threading model.
I'm asserting that we had better revert the iteration for now, even if we will
strive towards forbidding CLONE_VM without CLONE_SIGHAND threading model.

You say "And that is a correctness issue." but your patch is broken because
your patch does not close the race. Since nobody seems to be using CLONE_VM
without CLONE_SIGHAND threading, we can both avoid hungtask problem and close
the race by eliminating this broken iteration. We don't need to worry about
"This could easily lead to breaking the OOM_SCORE_ADJ_MIN protection." case
because setting OOM_SCORE_ADJ_MIN needs administrator's privilege. And it is
YOUR PATCH that still allows leading to breaking the OOM_SCORE_ADJ_MIN
protection. My patch is more simpler and accurate than your patch.

