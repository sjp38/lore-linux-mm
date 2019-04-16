Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F0CFC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 17:55:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 403D82183E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 17:55:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="haQ6q1Ao"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 403D82183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B768B6B026C; Tue, 16 Apr 2019 13:55:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFEA76B026D; Tue, 16 Apr 2019 13:55:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0DF6B026E; Tue, 16 Apr 2019 13:55:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB4B6B026C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 13:55:28 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id j20so11235153otr.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:55:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Rggm1Kxj05oLW+KL1Dix3OtkMuVAkLzMX1FlGZIH8ZA=;
        b=fy/noxNbxm1Xep2v6cJO+MnOBpCmSjy99R9OVnKhkFcVGEPBcxtIwfNt/vKQdIALgb
         qFeQOEDoVZpqXzov+hFZTvnJUawcN631IMEOE8f5krVw9vPlJ/tHJ7hZU/Imk4zvyCt1
         cy0BmXE5DfwKXdgcqoaj8Ow7uxqnloVWW4AE9CM/pe38+rW6ksF+lncbWOyzE9OZAaUN
         Qmu4g8Rpnyvh332xBL2UOjlRVrjQmXRtZoT5tEkXtRRrLt1r82Sw2bUzvG7KFTf7vOdd
         6xMsiqt7tp/pE/6mre0TrOyFHUxmPtv5SzukL401hxf216kjWx8FQAUbpOVkSo26Ry+O
         Xyqg==
X-Gm-Message-State: APjAAAXBh1XbAhxQBDNy7Mb4Pr8j/5+r6RrHFIgcGeZ/JwosqciqXTQA
	BPCflKrOobmRFWHMj8PuxwDEy18AaPChn9Yae50/mxrP1JGcW6qITPoEt0ok4XN7TB1di7EAjXN
	O426awDEyLClSjoY3GY0smBmfvOvWp+ffoy9sVCjarwp6fDQZwgFFIZ1sjoLDpaZr1w==
X-Received: by 2002:a05:6830:11c2:: with SMTP id v2mr51527133otq.161.1555437328075;
        Tue, 16 Apr 2019 10:55:28 -0700 (PDT)
X-Received: by 2002:a05:6830:11c2:: with SMTP id v2mr51527093otq.161.1555437327145;
        Tue, 16 Apr 2019 10:55:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555437327; cv=none;
        d=google.com; s=arc-20160816;
        b=Wc6hX/bH2l1UE9VuVi0f3QCKvnoSyZEhE9eBQZuQAlXVsa7b5IHGpKUQEiEXppje3W
         1d4Gx4jNnU7KxMmwo1pGShEZELV7fV9IlSi756yu8Q46Nh9vb3/q4svqswTcBvQamD17
         1AxXXyxBxaGPIX5xxGUFMDLQ0LyTW/Od7CaY/Dq/LMBHE1DbRwdXqp96uDDmD4o331Zr
         6adxLMieoS9d2oKkB50XgvU6EaWSJidkrdDXRLUZJgyz586lDHT/dMiBN8ooLUISUXP7
         M3bj0e/3NkVJSQ4hWVt9ZG/VAKDmU+8XsSDO+HZD6/TnyAW2huYfpMsi06IN9OXN1tk4
         7iYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Rggm1Kxj05oLW+KL1Dix3OtkMuVAkLzMX1FlGZIH8ZA=;
        b=JtSGvSvsBWaTqOcXgCeZ3BUMCzmk2Vdg67mwnEFMT5fHbFWC+AbeMwHH+FIG9ha7bl
         yrhlbxXy/WkYeB5dy5686na3WzHbPh6TLsrEMjxCXJBqc93bJmehqVnfcF6kHu1f92pK
         LG4lLLs7/4Y1MSDr7GUwWFc1utHA3Nn0LcBjFY4ejhp73wotV5TExbAzJ4lYzOOOcmRz
         NJsC3LJ1e4hfCHGOtZhbsATiHj3l4NjPh/K3eln69bjWLygZ6x32OQN5PQDLnb46RBuR
         WSe0zk6Q1BIwBzOuR9qFedq0aAfTr19qhJdCkLVaU9+m0oF2ZzgUFlwDQ/1ZpwwNdA0R
         fxoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=haQ6q1Ao;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s125sor25773431oif.105.2019.04.16.10.55.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 10:55:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=haQ6q1Ao;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rggm1Kxj05oLW+KL1Dix3OtkMuVAkLzMX1FlGZIH8ZA=;
        b=haQ6q1Ao7eAttMhzROptXuOk6UCHBp9JLawViZNxngHGb80kOGxmW1IxoEoBYKyKNO
         T3EB46aTrzEyWNgQu8u70h3DVUo3HU+qbEtJT7oYTiQ25S7LxDQ5ulOd3eVd+tVrx004
         1RYHxryN4wfRutFTo9bd+68a1AGDfMLEeZCxYlYtCEx9xoTQ7+EcYxHy1ho59/pdXj1P
         pC+Me5o62B9Za8dL1uv89zGHJ6tozpALgcDBo7mgQaZPzKe2n4TVkbn1lin7illoHKgW
         kbU2yYdCqzMq4sgW9yVmYOPNqS+aoSXAlVoBIEBzz+6nnIxfwUecxP6A93VPAb+tcDin
         NGKA==
X-Google-Smtp-Source: APXvYqyYFZypH449B/ExTKV2GpUf5HF/8jTIQoEX4L0LNHe2Jk3bL0Ar20kmaYYm5163IdcoJFOJ9qTmlHiWTeEVG2Q=
X-Received: by 2002:aca:cc8c:: with SMTP id c134mr25211836oig.172.1555437326583;
 Tue, 16 Apr 2019 10:55:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190415142229.GA14330@linux-8ccs> <20190415181833.101222-1-trong@android.com>
 <20190416152144.GA1419@linux-8ccs>
In-Reply-To: <20190416152144.GA1419@linux-8ccs>
From: Tri Vo <trong@android.com>
Date: Tue, 16 Apr 2019 10:55:15 -0700
Message-ID: <CANA+-vDxLy7A7aEDsHS4y7ujwN5atzkGrVwSvDs-U3Oa_5oLFg@mail.gmail.com>
Subject: Re: [PATCH v2] module: add stubs for within_module functions
To: Jessica Yu <jeyu@kernel.org>
Cc: Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann <ghackmann@android.com>, linux-mm@kvack.org, 
	kbuild-all@01.org, Randy Dunlap <rdunlap@infradead.org>, 
	kbuild test robot <lkp@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Petri Gynther <pgynther@google.com>, willy@infradead.org, 
	Peter Oberparleiter <oberpar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 8:21 AM Jessica Yu <jeyu@kernel.org> wrote:
>
> +++ Tri Vo [15/04/19 11:18 -0700]:
> >Provide stubs for within_module_core(), within_module_init(), and
> >within_module() to prevent build errors when !CONFIG_MODULES.
> >
> >v2:
> >- Generalized commit message, as per Jessica.
> >- Stubs for within_module_core() and within_module_init(), as per Nick.
> >
> >Suggested-by: Matthew Wilcox <willy@infradead.org>
> >Reported-by: Randy Dunlap <rdunlap@infradead.org>
> >Reported-by: kbuild test robot <lkp@intel.com>
> >Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> >Signed-off-by: Tri Vo <trong@android.com>
>
> Applied, thanks!

Thank you!

