Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B349C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 20:00:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E634B2075E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 20:00:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E634B2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E35F6B0003; Thu, 27 Jun 2019 16:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 492D88E0003; Thu, 27 Jun 2019 16:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A8DD8E0002; Thu, 27 Jun 2019 16:00:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4476B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 16:00:19 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id u9so5789210ybb.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 13:00:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=lLxrc7xEoBSrymgYPKgaweS2ex9fu+AkNik8CpIjWS4=;
        b=X/ChOvjSOyyAyQJqDTxNpIWc+WoGPweSCRLJx89Vr/CY3yiTsGXUsua9KeOuNIALsn
         AuSuMQueotHLh/cFf/iRELlPGPkxFOB21pAaStdV5CF2x8lKjpd9BApHlDCLY4vMM/tL
         GHx78eoTOnzWYaOAjqFEYPA2DgEcYxhXWSky5rwh7QKlAqHDlc/VZodMuzU5ddxTFGCA
         wcpz/bb0BiRdIPJyNJNg7fvZ8wvmgHzGdgtItMxxEObWsR7sGvUyV0LJWdA2Cwrl+0kd
         /ZFmaRJMHFFelhbGY11GE6L4hRuRiXpOyjbjW4VesV1J+50YuW9OKK+9/cFPl3gqSw+H
         nxWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
X-Gm-Message-State: APjAAAW3jN4tjtTVcCjR5pgRbJsGiMlZoI6VJWoBZtHD/uGnZKuU7keo
	uH0aFiIBZXMrHdOVIxYI1pHmY2K6aSE3glmqUmDbWjxy7S7w6Xc2JuOrwdn7htO1eTOV8qrTvQg
	LTubCqfJZGxulz9jBlikSz3xLk60RuujAWnpZVXhJ5jW42sF5nf2jeNC2LZWqvrd2DQ==
X-Received: by 2002:a0d:e942:: with SMTP id s63mr3614979ywe.511.1561665618892;
        Thu, 27 Jun 2019 13:00:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqIrBcnG4ecbvnRLTk7yB0rdy/KC32buS9uYKHEHXx0mpnfcH6Fwv1M0/2qdqKrgLpSQv0
X-Received: by 2002:a0d:e942:: with SMTP id s63mr3614946ywe.511.1561665618178;
        Thu, 27 Jun 2019 13:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561665618; cv=none;
        d=google.com; s=arc-20160816;
        b=HK7WnNrS6B19AqnrtYEKupRYQHHy7GJJjF55jh95jrWu3uUFYxOgMOSHuumehvQVih
         RrNMxUb7hfT6pNsIoe4LYXr0ZvlUSbuybh5nyfSJVfBt7Uo2v0pkygBBRm/hMAIhy2oj
         YqUdAOgoGN/LtI/MD74OOQoTTOsnwBaG4spnE2w8PV+xrmnSOv2tMxAds9yHXu8z26zP
         0Z7wf56PRE3UNeXApVv9N6l6HEACNwOAefZ0PeR9GDsuCAJ9W2Loe5vEXsANiMimKqTO
         3Q/IdqieepViC1yuVrlhF6qy9wCEGGYL/MLJ+S27KooxifZksXh6IrAW2vlnKzaQAaj8
         XEmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=lLxrc7xEoBSrymgYPKgaweS2ex9fu+AkNik8CpIjWS4=;
        b=Un88s/0FQhoHWi3FWgariGV1Zy154AQWhAhOWjdLSH3Mt/bIP+vqV+YapXT72K2lic
         3QfpypNLhar414WFIDoq4avwBvuV48GQb9MpGg3HV8QTcB8GSMvKownBnRzp72OQm2oA
         hPTVAKO7ie8rwR3+wVvyrMy4LVGZhcj4YsuFMftev7Bn4Iy1UnpdOw0uJPbrw55yhpGB
         3DunXOuAG6c5FnzHhukpeG9RnouotT2uuBVOz2kQJYmHL96/G3KXYXj3AD8JkgxzHT3x
         IuTm+nL6XkECz4JxRzWBuJ7nudzOAe+ZLRSsai41TJajlakRxp/BKs5aA+B63vbmHW1P
         bRhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from namei.org (namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id 135si45815ybf.74.2019.06.27.13.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 13:00:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) client-ip=65.99.196.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from localhost (localhost [127.0.0.1])
	by namei.org (8.14.4/8.14.4) with ESMTP id x5RJxmjG023654;
	Thu, 27 Jun 2019 19:59:48 GMT
Date: Fri, 28 Jun 2019 05:59:48 +1000 (AEST)
From: James Morris <jmorris@namei.org>
To: Alexander Potapenko <glider@google.com>
cc: Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Hocko <mhocko@kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>,
        Sandeep Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>,
        Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
        Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
        Qian Cai <cai@lca.pw>, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v9 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
In-Reply-To: <20190627130316.254309-2-glider@google.com>
Message-ID: <alpine.LRH.2.21.1906280559270.18880@namei.org>
References: <20190627130316.254309-1-glider@google.com> <20190627130316.254309-2-glider@google.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jun 2019, Alexander Potapenko wrote:

> Signed-off-by: Alexander Potapenko <glider@google.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> To: Kees Cook <keescook@chromium.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Marco Elver <elver@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>


Acked-by: James Morris <jamorris@linux.microsoft.com>


-- 
James Morris
<jmorris@namei.org>

