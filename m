Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E101C41517
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:50:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 043352084F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:50:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="lXrxUu2G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 043352084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 834586B0007; Wed, 14 Aug 2019 10:50:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E64D6B000A; Wed, 14 Aug 2019 10:50:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FBB76B000C; Wed, 14 Aug 2019 10:50:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE456B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:50:37 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F12818248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:50:36 +0000 (UTC)
X-FDA: 75821319672.25.push21_226b562245f3a
X-HE-Tag: push21_226b562245f3a
X-Filterd-Recvd-Size: 3824
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:50:36 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id m24so29960895otp.12
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:50:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=cWx0cFqnOpCViIJ4tMHIiuLTvCAxlz9fs3eE3H38dRE=;
        b=lXrxUu2GbQ/3WBKNQg6bGoE9vwtRUCP4SFYSH0scEDD89DaRziNNmLBjE0vttmjUe/
         O4oi/JbfzfFG5Xw+9gyej9xa8Hxo6VT5l/5Uhu6Ny65juAt0JRUAzvszKia3iSP6nh2r
         cE0Ny9xPzGSah2fDAN6DN8EjpM8B6mh5i7nhJfiWPFDueWS5tsen90BhvNf8os6QfOaB
         R9wxOqDAIO9Yz9t6d1bMDRQ3gDdzZeohh4mmfilwhiOUUe/mDlQ6e3WFeK9AEwQGx/YF
         rY1tFBsimehN69v0SOIHFcLiMcb9eRNPzSfZvNrcyjLsWDG+3r2rJKdeGRUyQs6JW23U
         vFbA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=cWx0cFqnOpCViIJ4tMHIiuLTvCAxlz9fs3eE3H38dRE=;
        b=FjNtRx48CkdMJcy9CXL/VE18l5A6j2pq6S8/n26WQw8k3uVRb9XLrNkphNdvCP48gJ
         E80BeWfzfZzF0i7+Y8wC4HMpituJugBLqoNqZ8fv0K5lFYmBl5sOhI6eNG1kEZgC+edw
         3FPa116apMULnku/x/pTnTrJ53fVOWcWZzhjJ0kSIOedG9n6OmfJ+IYlnHjtK/le6Rzn
         OlRF7Hww6Wc52bCy1R0HtS858lzSbChgMYx9Lo1FUQMYM3ksP5ECfrV8xFD3oxdYTuZg
         ya7QX+DO4xNMMVvuzJXs/pstIbDrcJWzgCWzCs9cGtEJn1GzTDCGhVW7lm5DDH/AMSu2
         uI5g==
X-Gm-Message-State: APjAAAXnD2TtQizAdRQMHpB2jocg7VE5OnK+mXO8SExNtkxt7MaF5jBe
	TuYs1KRM9iTL/jVPW+g+TF6lkw==
X-Google-Smtp-Source: APXvYqzQoRGPHjcNHC/V15omIqsc2Ze631e9qimSe/1ZAhI9YzS7mHKxHhdIL75MIuw/sd9unwIaTQ==
X-Received: by 2002:a5e:834d:: with SMTP id y13mr288968iom.79.1565794234700;
        Wed, 14 Aug 2019 07:50:34 -0700 (PDT)
Received: from [192.168.1.50] ([65.144.74.34])
        by smtp.gmail.com with ESMTPSA id e22sm101663iog.2.2019.08.14.07.50.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 07:50:33 -0700 (PDT)
Subject: Re: [PATCH RESEND] block: annotate refault stalls from IO submission
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <20190808190300.GA9067@cmpxchg.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <4ad47b61-e917-16cc-95a0-18e070b6b4e0@kernel.dk>
Date: Wed, 14 Aug 2019 08:50:32 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808190300.GA9067@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 1:03 PM, Johannes Weiner wrote:
> psi tracks the time tasks wait for refaulting pages to become
> uptodate, but it does not track the time spent submitting the IO. The
> submission part can be significant if backing storage is contended or
> when cgroup throttling (io.latency) is in effect - a lot of time is
> spent in submit_bio(). In that case, we underreport memory pressure.
> 
> Annotate submit_bio() to account submission time as memory stall when
> the bio is reading userspace workingset pages.

Applied for 5.4.

-- 
Jens Axboe


