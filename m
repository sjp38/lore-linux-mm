Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4CBFC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:22:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9243A2086C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:22:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eJokrS+q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9243A2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3043F6B0003; Mon, 15 Jul 2019 17:22:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B4C36B0006; Mon, 15 Jul 2019 17:22:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A3256B0007; Mon, 15 Jul 2019 17:22:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F16376B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:22:00 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so21123670ioj.9
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:22:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mdOTdZc5CyeYXsr7PKqimgFx+Tc5tMirB8c0EaxZfps=;
        b=PWFXW5mVjdO6SNErcBuly7iQ7YDlZSbIbmyJwaKGkMuhm005v3rdTX6qYI14koTcyH
         gGDJ3KpqSY6fX2Dj7DsTy1l/nJUKv6HRbdN6H0BiYo2GBNHD4ig8Z53RDCLtLQnVrn5n
         bTLktrH+t3mKOUg1/1gl6/pbhz/tJsesBoZ72ngZn3SfFvPq3JVAMSieynh1iC61J7K4
         RiWDO90N/+L+DzkI2WN67PHOwEiBF4bv0ZZjCpw3arNLu+zo1B9rNxFFz2Svefc9D0fF
         8iWdPg4HF5psCTtO9J4bJYrFMrdxb9kAEfNrHOMAhnqW+on8fFBsem7osoywlLavq2fu
         xWEw==
X-Gm-Message-State: APjAAAVdG0m2QMGQDuDLxAz0uTVGXSkEWYYcmxv5wkttomM0F9Pw8FVB
	Kl/bQAiPq+UPfjwJNvAUTmDaLySZ2036KczqWJfiYoYgyeRGxDtpmEsCyJT5medOcLOomcAifrn
	RCWjGXhH56EK6jHFzg1b7zaFsYgcMjaUYdkG+IRPfhIANKFLhRIfNF3i14U2yReexuQ==
X-Received: by 2002:a02:c9d8:: with SMTP id c24mr31292597jap.38.1563225720325;
        Mon, 15 Jul 2019 14:22:00 -0700 (PDT)
X-Received: by 2002:a02:c9d8:: with SMTP id c24mr31292540jap.38.1563225719623;
        Mon, 15 Jul 2019 14:21:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563225719; cv=none;
        d=google.com; s=arc-20160816;
        b=FKRSIroB9gH+RKgwD/FvyhQaxEb6WNe7sW+7CD6BITYtr4yAbrPNlJQJJrqL6e/wiL
         RE8oeSj19WTj8stKXYrX9jsUMEQSvGfsjf2Yu2bcUMz0jijaafSLVzkgs2+vRWphbZTt
         PS7gV7VISXybD1oBxYTHK/qE4C/zZfBv+rKAy77jzMT18Tp7ZIR4trBeVh0lZ28tjsvB
         fhRapBrLNlySCG/VpxjruDFtAeZWBRgdxATn+6OhiUWxwZrwOG1Qp7hAx92Xr9kl2pIX
         cE7f70Uc2dwqyM5ewc7YvUFDOMCUyvXnV2uhqCgzEiiPAy/vTBWUeRV651ov5nV4tkPc
         CwKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mdOTdZc5CyeYXsr7PKqimgFx+Tc5tMirB8c0EaxZfps=;
        b=fCQdQXCQ5fBHw+XkYb3ubEMUa9Br8ADZW2ktDrSwNrf0aDojeSpbsitPy9TGhvpDwO
         NAdf7dQ69mW+/q4AUPdXib2c7uHB12mLzcKfEBWR+v0jw2rZP8/2OROrAOBH0T+7f02h
         A2ki+DTi2dI3iS5tAlaNFtNx9Ep6FifmJfs6VpLsoUuyNUD0iCwk7JfvAvcEIrV08FTC
         miL/kxXRq8WuiZHDZbqsO6rSuwYXX+eoVnrjmWAnzqF3oFkPrRlzpU/e/6fCO01hUP7h
         GOHYEjNLvoNQHoZ7RwrJmYuyMP+gVhz79uNexsB+QvHa0nndGVihLbIQfhYI5jS8c19V
         cYew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eJokrS+q;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b24sor12869987ior.93.2019.07.15.14.21.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 14:21:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eJokrS+q;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mdOTdZc5CyeYXsr7PKqimgFx+Tc5tMirB8c0EaxZfps=;
        b=eJokrS+qweBYwEYADF8KXz0DydkvuxL7otsgtyRyCanPQKsKOfn3u/uDhYyLSBfVwa
         Q5MQRIquyye74WtDNDemfSmWLMYiTpUK1MhSsguWyGjTy8Pcgvoa9UUCOSFxzt1qDVQX
         XZ9seouy0h2ch6g7KFchGKAjF7seWmOZBzX3DijQpcGtF2UdWlgoiMqDlawVCpGm8GVw
         qcO7104wiEL4VfTuYGIjBmyZdY0xfTkyCO9mlQ9YWeRqBzFdRYpjJ0G1udbNEzzJnSw7
         BAubZPVq3+P/tsVOum40eTx/KfqXNii6z5xFsNKLDrfnUU4gAP0OJ9LUtLq2mEJ6j+/h
         YwBQ==
X-Google-Smtp-Source: APXvYqyk5yE7MCphZkXr/9c9UskEoQtlnOLxlTpMfuJThBn/u/uKw55tSMEuGdBGOKm+L6zdGS9zT6NItKfbobLd6Uk=
X-Received: by 2002:a5e:9e03:: with SMTP id i3mr26607453ioq.66.1563225719176;
 Mon, 15 Jul 2019 14:21:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190715164705.220693-1-henryburns@google.com>
 <CAMJBoFMS2BiCdBFBEGE_p5fovDphGqjDjaBYnfGFWhNvCnAvdQ@mail.gmail.com> <CAGQXPTh-Z664T3Uxak-CiRn6Mc-s=esRzURLpwQaN+v0RgxFyg@mail.gmail.com>
In-Reply-To: <CAGQXPTh-Z664T3Uxak-CiRn6Mc-s=esRzURLpwQaN+v0RgxFyg@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Mon, 15 Jul 2019 14:21:23 -0700
Message-ID: <CAGQXPTi9qMCujvkM67Y28KiTP7xyGiR01ci9Yb6fgq8pW_tcFg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Reinitialize zhdr structs after migration
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry Vitaly, I had the wrong impression from your email that
INIT_LIST_HEAD() was being ensured directly in migrate and got
confused. (I thought you were saying it happened through the call to
do_compact_page() queued).

That being said, I don't see where in migrate new_zhdr->buddy is being
checked. We do check for new_zhdr.work with
 if (work_pending(&zhdr->work)) {
...
}

Is that what you were referring to?

