Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51CA3C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1627C20863
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:48:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1627C20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B7066B0007; Mon,  8 Apr 2019 15:48:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8669D6B000A; Mon,  8 Apr 2019 15:48:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 755626B000C; Mon,  8 Apr 2019 15:48:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B55B6B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 15:48:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f9so4645583edy.4
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 12:48:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=n4i76gDnjgLPnyvS+beaxEaESuZa5AHnKdJgnTPLy4k=;
        b=DD//PURCRmwHRNcAdFJUIrx0e5VdFeJAnmq/AZJqaJFCZwjFpxrCbEhleLK/7IDARa
         58CfHTjJslsmOfEaBYUqZKa0yr7dOl+KFYE0cjsngHGZR58Ic6c2hpDd8dz6iNc03lh6
         BbQV61Erk+77jdlIjZ33skokRabKrUClr30dlyeFOgcsKexVccX0OLWSTlYSKCBgxzAY
         mTbxzuDkoKE0ReQzMHOWw+j1QBwEwPwmbBO8QpnUQoG7l6I+Sk4wiGdkf8ulJ+6QaOHK
         /QoHOKGSCB8enJnV1+TA9k2ULDH9PSJm4mqd5bk2Bfo/TQqLZFh4a/XwQHANmLxIim3d
         ylFQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAWbYOfl/hNvJvjGUhHA9KQO4uBL8jGuqiZBTgwS5y7Ro7xTw37F
	ZT6GboMGtkdSicoBjx9VajLBpSZsO3EDBIITn3pSyVB8L9Aw3p1YLVFaK1sXjOf6KXaksMApu3U
	4nbm1QL6YLueIYUs9SsDSIwQzW5K/ThlZIcc2qcWnHQT5fH1dln5ssOKDKdKRfVE=
X-Received: by 2002:a17:906:883:: with SMTP id n3mr17520983eje.164.1554752906786;
        Mon, 08 Apr 2019 12:48:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7HfB+JNMpSSn/f8Df1ZnF2npjQS04MItuuuwuHjQ1ZSthnlV+TwlnBS90Mjyn4WOQ7v8j
X-Received: by 2002:a17:906:883:: with SMTP id n3mr17520948eje.164.1554752905957;
        Mon, 08 Apr 2019 12:48:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554752905; cv=none;
        d=google.com; s=arc-20160816;
        b=TvDhtW3SmxdpuNStnksT6SCW/tRbL+Qv1jAiXzPpKneM2MWpNgZseRwY/l+ciw8h+x
         DXwX+GPHh4Bs8TpZE3vfuvLP402C4VCysULMxKoufu7TnWh74h1eKZLo7ut9OuHfsdVV
         d3CUgPnpanTcEuxM0u6bvBrtYoyGEbsHnidpcyvMhlYBZ4Im0XWcc16Bfk8SZBZBVO/L
         kNyO0qSinWnkjgP63O6UfxPoQLHtNmPojN7O5WzuVZQsEbCkQrZem4VuJqxshNRxOzl1
         4fWEK5ewYssrgA7ckfRjgDqDvKAbuQUvT4plnQZ/7t0Ddxgn0IqsXuvJ9Ll3sdZfb76e
         23oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=n4i76gDnjgLPnyvS+beaxEaESuZa5AHnKdJgnTPLy4k=;
        b=ct55oFoEWTcZnYCUvcqM2Tecjj36A+mKfboDBjZ5+Mr9+0XujiYCc2W7my7EA7VBIc
         oO0EUOmrbQg5lQgweQ/FSV2oB4f6eXWuRMqvp60UdBsOkFDyBLRatZRRjqra7x9IciqR
         ZQd1F16mZKW5jfIfwfyR/S6+Uns+1oYMqsXe/Osi+f2SJhkrC7mSw0HsxuoazMHNnP3R
         G5/UiZsdTLwpjLwEjznfCRwl4BOkfhW+41/hDrNIZtb7Lg6VeyRoeNlxea9Y2snEXn/v
         /wB2esJWHKZQPlljcCnQEWfihY2x1GdWlxGqo8NJRZi/pIzKdyzup2fvoCDKgOka08No
         MOGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si513579edd.269.2019.04.08.12.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 12:48:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ACEABB0C6;
	Mon,  8 Apr 2019 19:48:24 +0000 (UTC)
Date: Mon, 8 Apr 2019 12:48:15 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/2] A couple hugetlbfs fixes
Message-ID: <20190408194815.77d4mftojhkrgbhv@linux-r8p5>
Mail-Followup-To: Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
References: <20190328234704.27083-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190328234704.27083-1-mike.kravetz@oracle.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Mar 2019, Mike Kravetz wrote:

>- A BUG can be triggered (not easily) due to temporarily mapping a
>  page before doing a COW.

But you actually _have_ seen it? Do you have the traces? I ask
not because of the patches perse, but because it would be nice
to have a real snipplet in the Changelog for patch 2.

Thanks,
Davidlohr

