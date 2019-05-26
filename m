Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F180C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 17:35:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A93E2085A
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 17:35:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A93E2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1DE76B0269; Sun, 26 May 2019 13:35:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCE496B026A; Sun, 26 May 2019 13:35:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C968A6B026B; Sun, 26 May 2019 13:35:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 914376B0269
	for <linux-mm@kvack.org>; Sun, 26 May 2019 13:35:07 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id o127so4144977wmo.0
        for <linux-mm@kvack.org>; Sun, 26 May 2019 10:35:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ePNPZSRMOcEVi68F2KCel0gV8ortuSIeIHZ80HCD2wo=;
        b=bJ7UwuiXKpRBsCBNnOPEn2Feue0cCVmgb9vyp2XXToBNx1mA6tJfZjUihJMn6VI/Yb
         hndzl4ZplXrAIV++1ZrTYkIIpNvwQQlcQLzVIAXUZ9wBnqscuA4wY9gT2AmRUoT8I0bc
         hGxp77G/nXSoum+zGqvTMYjubF/8x6WjARvbt9yCFnlfHnYeAhTMjnI2cwhZfUiq2kNb
         d/2SSiZZq7QyZqaPg0cGi4Ir3DMpIij4mA8zj3ESsW07unVKDb3IhB7ohFp1LML5y26f
         sNluAehZrZ74nWa/VfOjLkWa9ffTxoHDwJ/M0megLhDenkdWq4EKCP6YvdKYbtqz4swh
         xprA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAVcDELxXsuDHTSYkZ4Q2ib2hV7HEg7bSgr5SZkftNqmZZPpifGr
	MXPZ1hxZuidajofFG6HIKFz/iiSSPv/TmRIDZocMzWNFm8uyVnaAV+1uJo0hqaCuW7ey5jzV26B
	H4MqXgovtb5nBOAQ8CSoRVEe82Y2V9I6V2IMEqJ2GuRxfeDApYmRUoQspxpf1ivLWDg==
X-Received: by 2002:a5d:400b:: with SMTP id n11mr21381158wrp.123.1558892107194;
        Sun, 26 May 2019 10:35:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/pbTHMYV2i0qTej1Fraq6snQOPIQO2qWqSibrAzmySfydjlbulPb+wpp+PELajVRNKN0Q
X-Received: by 2002:a5d:400b:: with SMTP id n11mr21381143wrp.123.1558892106615;
        Sun, 26 May 2019 10:35:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558892106; cv=none;
        d=google.com; s=arc-20160816;
        b=U2UcTCQXDwDucQc7vNJx6xo+snT5LVhoXmrOmGfTUaM2jQJjIT2pnGshpiGJw79lwg
         a+MZ5LjVglzECFhFhWbpWpvYAen6bTJyKp3x3wiuBgc9Nhu1DMQCFV91ySopDvw6HO6o
         LWO/QleERSScBQQxjca9ULxLJE26hQQCfB2ZM1/66Uvkiq8f6E/JGNZCSQtc/6EEA6vm
         YcUhLzVbLyu1umFahaZfEn66t9Fzy0jj8IsZuidSFzvdukMJCftHtL/kUyVs0fGfc3m5
         8HKtAFJ4XnL+EteML3Zm4R0/PNXE/1cpAi/+3xMb4oWFuHBFWz43SY7zx4QxgKbO7hIZ
         b9mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ePNPZSRMOcEVi68F2KCel0gV8ortuSIeIHZ80HCD2wo=;
        b=co45PCRYCaXPzHyfGB0mN7PVcIUA3j4w9Vvh5q5xGk/0brzcWqaqPiA/bwCvPgTgHe
         Y1CP3OYzVwMTsqHRnZ3q8gtuJY2CHg06WGBrqe5jja+0PozzNnjRGAQd5zVW+J6Inkk4
         NjnytY+QmRqOEkBkduwIZ50IycmNNmdHmyb4LjZrVi8fP/AaIksb3qo5KCQBB2KqMYCS
         ES0oD9V3j2pnTxuom2ete1mx6NSnzW8EbcrX50/h6J9Jo5PmRQIa1s8c/uf/UkoMy1cL
         tpC2C1EgifrKviAuRLCbh/KtEjeVSqOJ7FUPxP9fSv+y0tgaId4oMi4RM6DARrIVZ6d0
         MhSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c18si7559347wrn.27.2019.05.26.10.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 May 2019 10:35:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hUx2z-00027N-Gj; Sun, 26 May 2019 19:35:01 +0200
Date: Sun, 26 May 2019 19:35:01 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Hugh Dickins <hughd@google.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>,
	Pavel Machek <pavel@ucw.cz>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] x86/fpu: Use fault_in_pages_writeable() for pre-faulting
Message-ID: <20190526173501.6pdufup45rc2omeo@linutronix.de>
References: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-26 19:33:25 [+0200], To Hugh Dickins wrote:
> From: Hugh Dickins <hughd@google.com>
=E2=80=A6
> Signed-off-by: Hugh Dickins <hughd@google.com>

Hugh, I took your patch, slapped a signed-off-by line. Please say that
you are fine with it (or object otherwise).

Sebastian

