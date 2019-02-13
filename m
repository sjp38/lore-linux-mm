Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9682BC0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:42:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57404222B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:42:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57404222B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD85D8E0002; Wed, 13 Feb 2019 15:42:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C88148E0001; Wed, 13 Feb 2019 15:42:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B76AA8E0002; Wed, 13 Feb 2019 15:42:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 854DD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:42:02 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b24so2528151pls.11
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:42:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KDWDHzqzS2ucnNyfEjZQxs4uJ9iIv97IlYDgt0UMYl4=;
        b=b62NPerjadGE+8gGAmGdPqhvgvhNU9/1kRWGFUOackRlfNHJsPa44U1XOAugGfajqW
         nkv7w1r/PU2X80JU/nmDbMGGbUHwrf8CDKO5g2pJjmecEIOj6/CHgoLQNyYpEOqsy1wW
         ylnM/U2LJHU59SjXXW70NciFIi614P/DCOutobWa+gkPRyCJUTYvS4AU4yJzfOUJwhDB
         pvOP4UEuetfrXh++2KWye3qeDssE+9WpROn4fndB8jAN4TrEtfZCptAI4+ZYMZlACiyk
         WLy+qX/Vu2Aevv/Ra8Zyg4MrNxScjWCs9zy4eoNqt0wj7YWTqfdU2DT7WzzwhKNz0QAb
         Pilw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAub6Hht0E9XYK8JBRGRvqx5WOQ7lUgCVfFGg+xHMl+ATcGmFA8dO
	/kUwA7hkVxTsqCBvhK1NZuVqm8Zu+P8XQy+ULu+e6inLaGWLp1VHzmMJ1J3Rcu2yhQoSpuNwhO2
	N14hCVdnEXrDaoMz9KBPG/GzFTP09Ee1ChdRb5TVZ1HCTwlbeLPz2YaDRqx+Ybl3bRA==
X-Received: by 2002:a62:12d5:: with SMTP id 82mr5360pfs.255.1550090522219;
        Wed, 13 Feb 2019 12:42:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZen2hDacF9Yrq0Z/pj7qfdxj+58h9sm24F+hFHxRmofJjW7XU6Xhcd1cEBBDpf8qxtYR/j
X-Received: by 2002:a62:12d5:: with SMTP id 82mr5304pfs.255.1550090521603;
        Wed, 13 Feb 2019 12:42:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550090521; cv=none;
        d=google.com; s=arc-20160816;
        b=wHmmS8qWDvJaax7pInqtqeNGIIi371CAij826QOVNAeCFrKVYMCbqCVivZA/0iq7pO
         K+RPoqDnuIIyAQaedXrFjGMLIw0j4WezJhPlOXNxk9k9GZZzJONvpRPWyQS9kKR/kHnr
         W2uZpaKpZ5jp8hBTMDfoAs5jggZTmbHzn/SMctkl9gvVA0BXUl1g8LEdtGxD9+oh2L1O
         56V8ds0euNBOS8wo5pIFDM11VfzhzR9UP14KkCjQvxqg2RPKsmRjNRLBgZsDIyvQ/vrc
         iocdte/aiMbgpclFVr1tGMvCe6Vf93zEWapkWqMnLWbR0+GsLSdKwE++G6Zf6vUtx0vc
         oihA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=KDWDHzqzS2ucnNyfEjZQxs4uJ9iIv97IlYDgt0UMYl4=;
        b=bMBNNuhTT1RkCjMs8bH6iZqcqhSFH4RSSL3Xh8Wk9Nj31nNRpuvLUvvBfZzqQC1s2z
         vuAc7D5Rn69b/yEztex0DWqbd+5UsYKH5ktPRPIee0GZe4zXj+V2hCW+71D2BMvGyaj/
         fmi8ZBd5OHwB4JFVLE7MCFEEQxKLN1sa8rWHgFZ5PBJyoeDLtst4DxK5kT7QuwLzAORZ
         w5lBicOTxS23KjPVmbuV873LG30eeg02slLt6psSFn8PHcJtfNtz8BdpkgAqhs5UuPlY
         YB7AkdIrMSGmma0Pi4da2O0v46I6NZ+aUp/KwkjKXhX3Upe7jWW8Wee96zpbsALkTJRe
         6Spw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j24si258150pff.186.2019.02.13.12.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 12:42:01 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id AD693120F;
	Wed, 13 Feb 2019 20:42:00 +0000 (UTC)
Date: Wed, 13 Feb 2019 12:41:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
 <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
 <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Kostya Serebryany <kcc@google.com>, Evgeniy
 Stepanov <eugenis@google.com>
Subject: Re: [PATCH v2 0/5] kasan: more tag based mode fixes
Message-Id: <20190213124159.862d62fd5dba54da7b46e3ea@linux-foundation.org>
In-Reply-To: <cover.1550066133.git.andreyknvl@google.com>
References: <cover.1550066133.git.andreyknvl@google.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2019 14:58:25 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:

> Changes in v2:
> - Add comments about kmemleak vs KASAN hooks order.

I assume this refers to Vincenzo's review of "kasan, kmemleak: pass
tagged pointers to kmemleak".  But v2 of that patch is unchanged.

> - Fix compilation error when CONFIG_SLUB_DEBUG is not defined.

