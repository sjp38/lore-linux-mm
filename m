Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD6C5C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:47:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B2832085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:47:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X5g0JAvd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B2832085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 270DD6B0269; Mon, 10 Jun 2019 10:47:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2224C6B026A; Mon, 10 Jun 2019 10:47:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1115E6B026B; Mon, 10 Jun 2019 10:47:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D0ABB6B0269
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:47:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j26so7042703pgj.6
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:47:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=Wq53+njaY8Nizg87bnJv9I6awFz838NRdQghS0a7fkM=;
        b=HP8wO75lexD9W9s98lKDANcpW0NYU6jcC7k+o/rudlEjJVfQLEMQNXpw2e/uDlmscY
         mMEwh2D9/rvrsRpQ0d6ODjKrp+sjzneJdy6thipwhgfZyXK8Lnr6M6VhFoQjscqRdIAL
         RNzUhKIbf4cR2qHpEfeyVRcTkm2TO2yKZcRiiXhmCDKpOaHdLcjdU3jwNykqufo+Wljy
         Ae0ISgeNbgcoqzALdEX8I+46UyWnf9TspMpxSdZbmH2r3tmNRuIr9eeVRWKuxaKT3M9Y
         XWpTaj8IOZwe8nQaKvSdhg7PtXGX06msDvCi9Zxrwsid07Z1hAT8I/XQ/IyHb7tYUz9P
         AL4Q==
X-Gm-Message-State: APjAAAUh5IY5OYY+kyZdEex2q77IKGSxZzD8w72MbBQJCCcQ/zz8ldox
	fKBA0IW28whOR2kzUfP4/aCGjSL9iXfkiIO2ExxoxDimrA7YEJDqXF7JD6k3tLRtnf7BHboUjyL
	DMFY+eWmw3lrP9QscfQfz82hLNTAv8iyLIZ1xnARAVqwJkMdr9a2nlIKneqXI/a1D6g==
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr5998384pgd.259.1560178037355;
        Mon, 10 Jun 2019 07:47:17 -0700 (PDT)
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr5998329pgd.259.1560178036369;
        Mon, 10 Jun 2019 07:47:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560178036; cv=none;
        d=google.com; s=arc-20160816;
        b=qhly4ncPMk0f8DFGDj7MWMuGFQsTinZSbvS+b5tV3EDD0NdyE44ZkmUWqQ0hs81kBH
         HCNHzbeGkfSYZtU7FhNbn2MLBW1CsDhXcly0a2RJNBsWY0EuDAoyakwwFwMhWCtJeYCh
         0YgsjWcN3g0kkK9/2gTGOYGCPH+dX9d4qja0quA49svKTswVUsQnuFbquO4UEvq4p8X+
         UCc60Lt3QE2KK/kzMJb4lEKbpwKHZ6+yj82JsLbi2Tloid/e6y/1Nq1PX8MHfkW9oUqE
         rBb55734R3D8Dv0itKh0fopvjRbjG+5E0BiMeFwxMOcXT+M5O9y6mlo7qshqY9BtrATb
         pIog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=Wq53+njaY8Nizg87bnJv9I6awFz838NRdQghS0a7fkM=;
        b=AV/fZmcZ6gV36Ldip9pLaosqNkE5tC5QrTr4X/UvG89TmAZo4o9VlSDX/UNrfSO73m
         eeNE2BsN+eHtGdXpa2SmXztFR0voS6bI+TongzObUCkJd4yQywFXuCm2qUkKmGVlbi1X
         +JiEbTc1tMGcWc/hElsQWpXgsnS4TsCs3PWK0/GP6Yl57/CA1rI70hFRDUd/4/YVDwqU
         vs+TqRGxfmZnXxgIjkMGbbCOxhfeOeW+asgWVcXQw0OiCAC7QfKBP2hq4mY9BzpKhlMM
         +MvYG/yuLOcLbQ+HB/UvdJQzzFFyCWYXt6K2LrIoWIt5QO/5Yd7Iv9o30/Lwvjn1Gfbl
         NTWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X5g0JAvd;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor11858747plf.60.2019.06.10.07.47.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 07:47:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X5g0JAvd;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=Wq53+njaY8Nizg87bnJv9I6awFz838NRdQghS0a7fkM=;
        b=X5g0JAvdV1k6T8yY6ZUvrcraWM4yMrG/lxJCK+nAqRLcZyfzQtXY4ZbYz6fOYHWy3n
         Ou8dcJ4J6pIL1UEocGoC4sPgamfUWIHesWmZ8UX6rEWSdzt9ISIcx9cBiIgBO1pLSbDQ
         bhOBx/V93amqxNh29DiYEna/vlDWwPNSH0HP8kuGzL0W2dnDnjJk1o+mR2xDI146xllb
         CGKw3KHTmadPXuq8gLrXsXWVk8oNjiQOOuOZXkERDlgP23OsxNnnrUkyJ5sqo3VO0K3v
         NviZJEwFJwnWh80oqJu8/n12fYX46vxiYKwSmmxCyHZAabHAJNThB0WoxME22CohL67N
         7IJQ==
X-Google-Smtp-Source: APXvYqzO+K5a5izxxRmZJDOMMeEKbiwUXCm3sWfTX0ai2WfHFHXOFTxBzy4ayjR/yFM/5mp8uqkfJw==
X-Received: by 2002:a17:902:8f81:: with SMTP id z1mr4934200plo.290.1560178036097;
        Mon, 10 Jun 2019 07:47:16 -0700 (PDT)
Received: from localhost (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id p68sm4145337pfb.80.2019.06.10.07.47.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 07:47:15 -0700 (PDT)
Date: Tue, 11 Jun 2019 00:44:49 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-4-npiggin@gmail.com>
	<20190610141036.GA16989@lakrids.cambridge.arm.com>
In-Reply-To: <20190610141036.GA16989@lakrids.cambridge.arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560177786.t6c5cn5hw4.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mark Rutland's on June 11, 2019 12:10 am:
> Hi,
>=20
> On Mon, Jun 10, 2019 at 02:38:38PM +1000, Nicholas Piggin wrote:
>> For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc t=
o
>> allocate huge pages and map them
>>=20
>> This brings dTLB misses for linux kernel tree `git diff` from 45,000 to
>> 8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=3Dof=
f
>> (performance is in the noise, under 1% difference, page tables are likel=
y
>> to be well cached for this workload). Similar numbers are seen on POWER9=
.
>=20
> Do you happen to know which vmalloc mappings these get used for in the
> above case? Where do we see vmalloc mappings that large?

Large module vmalloc could be subject to huge mappings.

> I'm worried as to how this would interact with the set_memory_*()
> functions, as on arm64 those can only operate on page-granular mappings.
> Those may need fixing up to handle huge mappings; certainly if the above
> is all for modules.

Good point, that looks like it would break on arm64 at least. I'll
work on it. We may have to make this opt in beyond HUGE_VMAP.

Thanks,
Nick
=

