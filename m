Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97463C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:31:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4096D212F5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:31:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4096D212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2ACF6B000D; Thu, 25 Apr 2019 09:31:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8A976B000E; Thu, 25 Apr 2019 09:31:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D02B06B0010; Thu, 25 Apr 2019 09:31:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A30676B000D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:31:20 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o64so6946475qka.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:31:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Os27Q1N7uIEDMdjyagtGHHZ8S/wqWoS+Aa8tn1g2wKQ=;
        b=mTP64qTKTx4ugAm2YbGksTJVoPGSCJGu1AR4mgWQgMcIGoB9gPXLTBx+vn9GkbAcyf
         nmGRHYmsHQnRpg/II0m6wP3BzkwjomTijrcWOQPr4PKMX9At1/bVCfWexCBAV2U88K0R
         2GM47s5ix3T4KKyvEDTp+Eac9M+H/0smoT/38QlJMopqydUEb7cKMQN8uM7rv4KFwmaT
         4fmTjYrXVWnLHo3L8DOatkAYQ6s4zNJHWqNXzlHdHl06J+YSQ/2kXHdNp9z61FRzEGXw
         kDgt8KFmAhV7lo9Lbqkw3/OdlJSeMCrMtHYLEOlN1Ksq9koE8qyTlpeM0Gw7k6szYNBf
         XhvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVesQk1MTzgqIUTebDOaXEYa9BCLsRLmk6us2ESpHMYr4mUCi2J
	t59BoF3E4iDd+N/H9BAOrICn8VeaFvzalGY1sfuoAdEp3pvVG0tZcTtgylBwQEoJ5p7uYpGFiKO
	6EoVwlYHgfiVPvEDy/p6f/wm+mNv01k6LgQ88mum2B50UF8gm8Qm8dOi2DGzzvx8RGw==
X-Received: by 2002:a0c:b7a5:: with SMTP id l37mr29661797qve.94.1556199080389;
        Thu, 25 Apr 2019 06:31:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhCyExeq5SPbeQoDBUUIjegHw7D0O+mRVw1lH/j6ZqOeL5kuHdQ+eWJMlcSPgIOu74IqUR
X-Received: by 2002:a0c:b7a5:: with SMTP id l37mr29661551qve.94.1556199077060;
        Thu, 25 Apr 2019 06:31:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556199077; cv=none;
        d=google.com; s=arc-20160816;
        b=TQ5QEK3M+yRCRMGDTtkBQ4pCRY6FeAEUC5BgV84kNvRjTN37SZfZwfI8qxuCZV0PMf
         GzIG4ysT9BZgvG5oCGPWFMajhizNyd5CUv4aoY0YBGdL+8XRxH5/CNIdidnj9c8XH0jk
         iIcyeWzPfL7fLLn9x3P95mr+G3oBqoZdA18q4P/CWIn6mIsNsC51j1mGkDiJdgLX5wBv
         8USMZdXVLNdaIEWEaw/i5MFS0m65UVo7h9ldwxnaUYoWwR8q9vP72HnkditAOuFua9am
         IcdcO3gT2u/gN4TjKOIJTWToqq4Ed4rgItnHVBuL4CG1t2PZA+CrDPTDolvQ5Yc+6MQP
         UOKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Os27Q1N7uIEDMdjyagtGHHZ8S/wqWoS+Aa8tn1g2wKQ=;
        b=GE8ViUHNQAfZAQaiVXOFggAIG18DchN+1j8/H4sBa+aCA+5iGXIT6takmPDSFrYvdM
         WlN/+r7nG0MFsZZXgJ2JkYzq1VpM/zqsbU7umYK1qrJLYfj3Lr5M3DEFHYKGHviB8Q1K
         drBXdpnySRpwC5riYwKxT5CAk/NsjeKNoU5fq3IX+HC7oViI0aCNLPsoPcLMBpY+Vi9M
         hZYc6lV7wQJIYcVcZi9y3DQMOSbyC1heuDlgVsWbKlvPAY0GRkXzz3dwqaOK3xEd/0jc
         TUHkEYm1jQnqbYsR81y9TUH/ArkOehYlOZcvwwcaYXJSXmfPo0y6PBJKKhJkTb4x6Sz8
         08dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l186si2586053qkc.229.2019.04.25.06.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 06:31:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E5D545944C;
	Thu, 25 Apr 2019 13:31:15 +0000 (UTC)
Received: from treble (ovpn-123-99.rdu2.redhat.com [10.10.123.99])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6DABB5C652;
	Thu, 25 Apr 2019 13:31:07 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:31:05 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Miroslav Benes <mbenes@suse.cz>, linux-arch@vger.kernel.org
Subject: Re: [patch V3 00/29] stacktrace: Consolidate stack trace usage
Message-ID: <20190425133105.54uyebwcdkxx5trg@treble>
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190425094453.875139013@linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 25 Apr 2019 13:31:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 11:44:53AM +0200, Thomas Gleixner wrote:
> This is an update to V2 which can be found here:
> 
>   https://lkml.kernel.org/r/20190418084119.056416939@linutronix.de
> 
> Changes vs. V2:
> 
>   - Fixed the kernel-doc issue pointed out by Mike
> 
>   - Removed the '-1' oddity from the tracer
> 
>   - Restricted the tracer nesting to 4
> 
>   - Restored the lockdep magic to prevent redundant stack traces
> 
>   - Addressed the small nitpicks here and there
> 
>   - Picked up Acked/Reviewed tags

Other than the 2 minor nits:

Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>

-- 
Josh

