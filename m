Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 624C5C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 19:34:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03B0B229EB
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 19:34:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="RdXequCW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03B0B229EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45FB28E0003; Tue, 23 Jul 2019 15:34:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 410B38E0002; Tue, 23 Jul 2019 15:34:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 325A48E0003; Tue, 23 Jul 2019 15:34:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 138F38E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:34:54 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e20so48004518ioe.12
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:34:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HC9PR3HC0XNWdkabk4UND96yybABreQPrLWbCiZycdU=;
        b=ZqIvdxxjI53CcWwTlRoNAddc7xSh0+XDJLuK2TtZbU+95ofLbDHjM7c346nNBh5EHb
         LtR89vheUc7QWgvIpy2eNYEAf/fuKBfSn+wwtXi3gaaSq6k+rVeUsS9jmKf4zdXZjHJI
         NcshCBsQntS8m6xlx9RX7uGjH/kwqAXvyCBYohIAhsKW7xeqc3QWExZA9ewUvmspSBVT
         92LARWcL7LKU/+4optHe1vWt+6OSnMB0p8ZdJJ68Dx/2yYjc2qMPDV8NEcFbqw+XOVeV
         CTNo9T/tVbBphT1sfRCleXoDCpRw69WkSb2LEDSRQd0nGL/DkeA5SnTpC/iNcuWsrqXh
         2p3Q==
X-Gm-Message-State: APjAAAXfZ4lWv5ri7pRCkeuuoJKCEG8F3G9H43RmsCy9dnyaIycWaUpi
	8IPqHM8j4o7v1VNjkHhrInrBQNz+FJ5YFOg4DCmT+Xt34EhqmW2V/CkCQzQPaoMZgqvppobIrGg
	4MGFC1g9qpjKRtFZT1dbRKpG59STHpM6wH1PlIhGdNzHjERI59ZqFhJY9Vt7fo9vqfw==
X-Received: by 2002:a5d:9613:: with SMTP id w19mr35288938iol.140.1563910493764;
        Tue, 23 Jul 2019 12:34:53 -0700 (PDT)
X-Received: by 2002:a5d:9613:: with SMTP id w19mr35288878iol.140.1563910492916;
        Tue, 23 Jul 2019 12:34:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563910492; cv=none;
        d=google.com; s=arc-20160816;
        b=IvrIfZ2wEqy4ueN7S9D3XN3Ga3YvYM/9JXHEMy2wPwgKz8lkmvqRZ7xzpgDMZQnyyI
         dxqVFq8m/5QHwy0ztnJCZ2HXfAxGznMZKPHWj18YcQ0GbW0MWNx1hci5FLs3CdmiVaNT
         H1BavYyQMfQ2m5mLMK/tlei7sXpj+lrAP5GzW50cWGYSsKvQBef94/RGEUCtkIw958uE
         ej+wZ11re0Ph3/XKEXg7Z2vkRoumeoEvMbV0BM2Xzy3W99SbT4ZGl71DygLDkgIgQ/X+
         IjPZhaJm1c4WJ7GRyO+c1B11cAq81M5vpw7QOWJXD6IAOeiO9HgB24CQvp2u0TI1i820
         8fCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=HC9PR3HC0XNWdkabk4UND96yybABreQPrLWbCiZycdU=;
        b=fO+hmkcpU/SddyLTXTrsh2bSaA06Nkdz8XoecXhFveZedsZeBPt3B/y1WOcziS1eQF
         YgfphoUgpe9qbSZ1+Z/b6Wyr/4PCTt17/nPQOLumSHm5JbV/fQop4SDVZ50qA9xLlFHO
         OEYFzzHVJzNyFGkuzqhA22Bo1iRa35ihj9ZaA+NSyRXccY/y8C37wf24AkIrEpFIvh+j
         cw7ncmr/LbUO4dCr9RX7uxjae1sAhScC2WvAxK+2S6rnTJwBs9KGYoARwzPbYMw33l6x
         t0oQlrS2FgaycuYHl0q9/ZnMhJ2SAhYEfym2RBw+emSFXunaxWMIDocDOKQ3iJtPdONM
         G9Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=RdXequCW;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor29490466ioo.94.2019.07.23.12.34.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 12:34:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=RdXequCW;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=HC9PR3HC0XNWdkabk4UND96yybABreQPrLWbCiZycdU=;
        b=RdXequCWyR/MYSqoeWE3d4DVUYvWt1fsLVPUvc4/yXClPOv6ZH1oBt1z3F9vFnFc7j
         Lj/EemlmGQ3ZvawWDxi0OdLkvJFGenk7XmpL+CbNMqzmyrcBGuYX1hCgpNKWznzpTcgR
         OpHJAOuq9h/o+TBDRTrVRgma4vEk0u5LKGo6tkvhoVjZLtP7eAdS8MqdPXPv4dNiMgUn
         yJ5mptb5Qua5yHRvs4J8mnyCcmwg98hipsXMVp023D7H8/tj2WjJvwGBqrwKJiThn1CP
         /dvFvqref+R5OXx+n/QKk3m21C45oLPUmy28GAXZ+9KvtAR7ogW7ZCq71AlpoX/TSmi7
         X6Sg==
X-Google-Smtp-Source: APXvYqzxE7jhc8AxcWQlAt3hGFl+0bPDjzWyakCps5e/JZAo++vrSZLfUDW31Xh0OBMnpBTpJsD9VA==
X-Received: by 2002:a6b:3883:: with SMTP id f125mr24197ioa.109.1563910492289;
        Tue, 23 Jul 2019 12:34:52 -0700 (PDT)
Received: from [192.168.1.158] ([65.144.74.34])
        by smtp.gmail.com with ESMTPSA id w23sm39726873ioa.51.2019.07.23.12.34.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 12:34:51 -0700 (PDT)
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
To: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <20190722201337.19180-1-hannes@cmpxchg.org>
 <20190723000226.GV7777@dread.disaster.area>
 <20190723190438.GA22541@cmpxchg.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <2d80cfdb-f5e0-54f1-29a3-a05dee5b94eb@kernel.dk>
Date: Tue, 23 Jul 2019 13:34:50 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723190438.GA22541@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 1:04 PM, Johannes Weiner wrote:
> CCing Jens for bio layer stuff
> 
> On Tue, Jul 23, 2019 at 10:02:26AM +1000, Dave Chinner wrote:
>> Even better: If this memstall and "refault" check is needed to
>> account for bio submission blocking, then page cache iteration is
>> the wrong place to be doing this check. It should be done entirely
>> in the bio code when adding pages to the bio because we'll only ever
>> be doing page cache read IO on page cache misses. i.e. this isn't
>> dependent on adding a new page to the LRU or not - if we add a new
>> page then we are going to be doing IO and so this does not require
>> magic pixie dust at the page cache iteration level
> 
> That could work. I had it at the page cache level because that's
> logically where the refault occurs. But PG_workingset encodes
> everything we need from the page cache layer and is available where
> the actual stall occurs, so we should be able to push it down.
> 
>> e.g. bio_add_page_memstall() can do the working set check and then
>> set a flag on the bio to say it contains a memstall page. Then on
>> submission of the bio the memstall condition can be cleared.
> 
> A separate bio_add_page_memstall() would have all the problems you
> pointed out with the original patch: it's magic, people will get it
> wrong, and it'll be hard to verify and notice regressions.
> 
> How about just doing it in __bio_add_page()? PG_workingset is not
> overloaded - when we see it set, we can generally and unconditionally
> flag the bio as containing userspace workingset pages.
> 
> At submission time, in conjunction with the IO direction, we can
> clearly tell whether we are reloading userspace workingset data,
> i.e. stalling on memory.
> 
> This?

Not vehemently opposed to it, even if it sucks having to test page flags
in the hot path. Maybe even do:

	if (!bio_flagged(bio, BIO_WORKINGSET) && PageWorkingset(page))
		bio_set_flag(bio, BIO_WORKINGSET);

to at least avoid it for the (common?) case where multiple pages are
marked as workingset.

-- 
Jens Axboe

