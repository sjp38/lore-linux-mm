Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61D44C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:40:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 228CF206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:40:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="QCkR8nbv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 228CF206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E8066B0269; Thu,  4 Apr 2019 12:40:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 871A86B026A; Thu,  4 Apr 2019 12:40:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739666B026B; Thu,  4 Apr 2019 12:40:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51C596B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:40:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d131so2606904qkc.18
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:40:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=28+09XFOqkmUno0MP/WfSRXRXy04JRnokQl+mHKKxO4=;
        b=EEwiNpo/mU9eK2wqb/NZPX94soU6x9vDBgNxYjn4SzTcUpNNlEKsLY1kNyvE0O8S7I
         VgRS8wAjPB25Y5OJn39YRiWTh0r+qW832lkRcPUrjFlheUKwAYKYegC67UtxARrfuiCw
         I7m8JMfMv4zgY8qLL9cSX1jki1JQE70p+Tct1RKRAjTDni491jRTHL3ZUmuMQNa4Bd73
         zzViSGUAFmoPablvzpBC3CewNyYy8ZfNxsgC4eRDmoBkIgdjl1MDcDB0mqmBkTsK+owU
         UcCyxrDcUgjmY6u9X0pyCuFKW8AS5XUAK/rm4FSse3uXCqukOL3LQjJkUZZyU7Wws4kt
         agMw==
X-Gm-Message-State: APjAAAWW+QQCFQHimXO48CXZU5BB6DDPCtuMATCt5F2YYefXQKrC0dcx
	n7m7NC4SlJIc5pX9wmUsc4JF8opPLWKXynvt33NKrOIXNmYt5PJC4yoXuxF9sji7CZM8iwS+XxR
	YxjuMuwcZz5qg3C+f2MUy2M3svriLj/PWhpIqXuiM+rjFOUeB3TY2lfGLpnJ+71o=
X-Received: by 2002:a37:6615:: with SMTP id a21mr5841539qkc.64.1554396054110;
        Thu, 04 Apr 2019 09:40:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2yUmt64a326tFz16mJHoPEJRl3nFQYMVeFxyLeADC3CpWgns4ZsS0nYSoXrsoAGlP5I/u
X-Received: by 2002:a37:6615:: with SMTP id a21mr5841481qkc.64.1554396053538;
        Thu, 04 Apr 2019 09:40:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554396053; cv=none;
        d=google.com; s=arc-20160816;
        b=KHQyCaJs6X7UHbaYVwGC1sw4WWSn/WK4FU0+6PysmANsSuK3kDHPcW+pqHUeoIYPyQ
         FZ7m7/vrQxWveDb5XvAJPU5uZSFBaADO0CKsZy8Rq7NjFeNvc8I5wvx320vyLA0fddVj
         GynFMft0sZ7ozJe7mvqZzjqi2YpehLSBvtvscU48u97msPqo5FwoJIQaQKHK5haBNibk
         Z0hjgX6Y9gu3UNzmoA60AIIQ/ZDh5Qh62IVOFTu6vguXaNCiFAAuwymjLqhIP02aKYBN
         PplDfLhn3E7hYJk+SqlTSOG3E7OoXxJgkQsWZlEGIgyIP2aT7ksXGgKJbHoJtIt5fEWo
         oakQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=28+09XFOqkmUno0MP/WfSRXRXy04JRnokQl+mHKKxO4=;
        b=zOo4Dsb0spSmKLpsIcyHPkwkTU9OQvbRK0R3EcBFkySm70AfHQFJX+EgsGXOD6n/sZ
         dQ8SPU+q4Ublb+KGu+TWc7QRvSsJ8uOWr9UJ6mikcXZZVlk2/ovONpjN4QR+gJppJqCR
         FvU+ThCBjh5sKXTjK+G+cqjZ8JyUkBhdmS059MCFY9UcH4mly0RPH6+z4PIKAmnuY0zr
         d1vzKb6ZaxWxo2bOglos82M1EwGHd2ElPoMXXSx9NWam0R5gkCopMeyKiyjkIBil1aXN
         pybmbxLyoRxvwm+ro4IQFeLRFewmMCL/paZzXzXaFEp1wJkZfV0VpDZ5N/Gj9WeP4nyD
         Iv+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=QCkR8nbv;
       spf=pass (google.com: domain of 01000169e9397c8b-5e09e11d-50f7-4622-b369-d684d17856c9-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000169e9397c8b-5e09e11d-50f7-4622-b369-d684d17856c9-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id g22si260067qta.80.2019.04.04.09.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Apr 2019 09:40:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e9397c8b-5e09e11d-50f7-4622-b369-d684d17856c9-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=QCkR8nbv;
       spf=pass (google.com: domain of 01000169e9397c8b-5e09e11d-50f7-4622-b369-d684d17856c9-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000169e9397c8b-5e09e11d-50f7-4622-b369-d684d17856c9-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554396052;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=28+09XFOqkmUno0MP/WfSRXRXy04JRnokQl+mHKKxO4=;
	b=QCkR8nbvGPc46188u3FKsmfoRKR+C8SJcpzLMQepDco+/v/jNbIM1i9oRzKcsRGJ
	u4bwBFfxfBEwpyaeWRQUN77Wh7CMdEUPsGcX/QH5IPyDlUTiZjZS9yRsV10kZfiS1On
	C2yv3QO2mEYO/RwYRw5MUIOZhGdUdYfLEenOnXIk=
Date: Thu, 4 Apr 2019 16:40:52 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org
Subject: Re: [RFC 2/2] mm, slub: add missing kmem_cache_debug() checks
In-Reply-To: <20190404091531.9815-3-vbabka@suse.cz>
Message-ID: <01000169e9397c8b-5e09e11d-50f7-4622-b369-d684d17856c9-000000@email.amazonses.com>
References: <20190404091531.9815-1-vbabka@suse.cz> <20190404091531.9815-3-vbabka@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.04-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019, Vlastimil Babka wrote:

> Some debugging checks in SLUB are not hidden behind kmem_cache_debug() check.
> Add the check so that those places can also benefit from reduced overhead
> thanks to the the static key added by the previous patch.

Hmmm... I would not expect too much of a benefit from these changes since
most of the stuff is actually not on the hot path.

