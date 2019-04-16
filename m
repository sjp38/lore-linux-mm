Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70742C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:44:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3053520880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:44:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3053520880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5BA16B026D; Tue, 16 Apr 2019 19:44:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE1A46B026E; Tue, 16 Apr 2019 19:44:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AAD16B026F; Tue, 16 Apr 2019 19:44:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 620F66B026D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:44:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a3so15035403pfi.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:44:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kdaYqmOmNPBrD9uwwZGImYyNGxdiFicSxP0Ckl6sH/I=;
        b=CKzxaHLUM3GhVZkKnzCFio8NgseYErlkDQOpsBBev2G9Q+ykZpRLAmPdnZrrvfnpGv
         UO96ojQHz59+96Wfmy/dGOcldXzEAmJIhMf0/GtEkdx3ZxMkHEOzLtjebRL8HIur6RH5
         9Ak0Ubvd0Lbru1RWz4DeTX/7mc1CrQrR73UKysJYs+/rwY/BXLq2UCiCp/gLCN/oz6Ed
         QwEs4GuaaMCOoXZRHyh8LsW1yCOjFCB0LOrOyiDV8pHfJL7rKcmt+EUCU3CVEcMrmcar
         j8y3BWO1drXezUXrOJSzIjhEWXY4zIJpxwZ81ObU5EQaecodPxAAwS/ZIhvgkVWaulup
         0d4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWQb86HTWalmPpYdaxnhmiHKWRHUydqT3Uq3jydUEnZkI5R5hdu
	DL7LE/m2WtmU4ktxrtw6u50XVbz4I4xUGDYi3XOJd8vryeIiQEIXFuVWQU9Ty59pxs0g2T8GE0N
	3VU/dWZLkCCXYCqEGf6BEIbK8Kg75cMwT3UGWyR+xocQJ01+ddWKqhMXEpC+yEuOLHg==
X-Received: by 2002:aa7:8384:: with SMTP id u4mr85227629pfm.214.1555458261022;
        Tue, 16 Apr 2019 16:44:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3CnKgnk7XcESnANELD2DHknb9uYZ1p66pvh9vee2VKO9OJ9YNkMhqGf/s7tRijRfJ5YWp
X-Received: by 2002:aa7:8384:: with SMTP id u4mr85227600pfm.214.1555458260290;
        Tue, 16 Apr 2019 16:44:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555458260; cv=none;
        d=google.com; s=arc-20160816;
        b=jnkPGh7YaHgN/SBWsKX+Xrho0usA4utOaQ2MRHS3bfQ6aroKgaj3RMjBW6B/F9AaqQ
         3murFZIFYJ8LJTSYtFMQjd/jebWBsmGNT3lMn0VpZ6GEbnJgmoSw136wvPPQusH/OSqy
         KRJ3cPyfDHLG8TnvpG5Rj+3qUN0NfMAJATJMu2Jw2SdTpAw+NsxdiSnCEjqCop74wLiU
         d4Qttn8J7dYk0esBv3ps6KU3PidqGBjqkwPivdimlqsuSDS5gZYbiMN4rsFYnFs+i6qa
         O0eEm+ujeLabsmgM45Wv/319zOMR4tXfgNED6hh72uZRhTYV/LKwaFa+4iIHqqOgDazs
         0EQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=kdaYqmOmNPBrD9uwwZGImYyNGxdiFicSxP0Ckl6sH/I=;
        b=D5VHBs3nYizDOzFpCf3dYq4PVPvKfGVKjO8gcWLH/JDk18u8vnKL7w/VC8rxqmo0RQ
         ppphmATpNf5vmwjnCzJdliGrzFVooRH5UFF8ccGKhf2r9Uu3M8JOLLW20lnXBGiPw184
         0NQWY6OVn8r2Mq1fOK9KfVqKDwowbceOIkFGYwqET/viMcE2/m0KvzLQUtOQmD+0spfR
         4PSurwBEf8osApRHDsxRUYNTzjt2CnDI96DE2fHPyYcn4xvJVtIZn54r3Qrb0R5ZtJtI
         AA+oGBhmXnXGT8Gsp5j2UHOwmMQYqQoF71AjV2YpJYpfq5qhsZ5xob0wha+d29EXF7LP
         7vsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z10si47274393pgu.172.2019.04.16.16.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:44:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9EDA425A;
	Tue, 16 Apr 2019 23:44:19 +0000 (UTC)
Date: Tue, 16 Apr 2019 16:44:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, Guenter Roeck <groeck@google.com>, Mathieu
 Desnoyers <mathieu.desnoyers@efficios.com>, Thomas Gleixner
 <tglx@linutronix.de>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org
Subject: Re: [PATCH] init: Initialize jump labels before command line option
 parsing
Message-Id: <20190416164418.3ca1d8cef2713a1154067291@linux-foundation.org>
In-Reply-To: <155544804466.1032396.13418949511615676665.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155544804466.1032396.13418949511615676665.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019 13:54:04 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> When a module option, or core kernel argument, toggles a static-key it
> requires jump labels to be initialized early. While x86, PowerPC, and
> ARM64 arrange for jump_label_init() to be called before parse_args(),
> ARM does not.
> 
>   Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1 console=ttyAMA0,115200 page_alloc.shuffle=1
>   ------------[ cut here ]------------
>   WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
>   page_alloc_shuffle+0x12c/0x1ac
>   static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
>   before call to jump_label_init()
>   Modules linked in:
>   CPU: 0 PID: 0 Comm: swapper Not tainted
>   5.1.0-rc4-next-20190410-00003-g3367c36ce744 #1
>   Hardware name: ARM Integrator/CP (Device Tree)
>   [<c0011c68>] (unwind_backtrace) from [<c000ec48>] (show_stack+0x10/0x18)
>   [<c000ec48>] (show_stack) from [<c07e9710>] (dump_stack+0x18/0x24)
>   [<c07e9710>] (dump_stack) from [<c001bb1c>] (__warn+0xe0/0x108)
>   [<c001bb1c>] (__warn) from [<c001bb88>] (warn_slowpath_fmt+0x44/0x6c)
>   [<c001bb88>] (warn_slowpath_fmt) from [<c0b0c4a8>]
>   (page_alloc_shuffle+0x12c/0x1ac)
>   [<c0b0c4a8>] (page_alloc_shuffle) from [<c0b0c550>] (shuffle_store+0x28/0x48)
>   [<c0b0c550>] (shuffle_store) from [<c003e6a0>] (parse_args+0x1f4/0x350)
>   [<c003e6a0>] (parse_args) from [<c0ac3c00>] (start_kernel+0x1c0/0x488)
> 
> Move the fallback call to jump_label_init() to occur before
> parse_args(). The redundant calls to jump_label_init() in other archs
> are left intact in case they have static key toggling use cases that are
> even earlier than option parsing.

Has it been confirmed that this fixes
mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
on beaglebone-black?

