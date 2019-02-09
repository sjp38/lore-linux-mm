Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9746DC282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 11:58:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50EBF20818
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 11:58:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50EBF20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=free.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3CA68E00C8; Sat,  9 Feb 2019 06:58:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEC658E00C5; Sat,  9 Feb 2019 06:58:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E00758E00C8; Sat,  9 Feb 2019 06:58:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1928E00C5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 06:58:57 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id l17so2486136wme.1
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 03:58:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=lDiAmvNZI57Q3r0C3ZjmudAWP4A+WSo8G997ohCbb2s=;
        b=litFQ1jbwN7l7b58bAvLz/xh8qJb7pKbs0SkyVzLOjTwaFVzvtgVtxkWC4C7R9MwUU
         9rYKr8LmJoOeGW8Qe3J+iY1AoQfczC6jIJvDAzdOa9jsSmL7Tj/0yrTXiNBQCXgX9tSt
         +pUYJHbKjVd21OUK5vhinjaWctxt8h4PFGCXSnnnFeFToRWrmrQkcvsbvS3WREiw2Zny
         2z8bEi8EAdmXfYJm8HhNVmnZfn02EWYw20CgrcgzBESY8hCcgQee3QZre18iWsFADdgv
         8qex/zOImftjFAzpPBg4vyALRSUiBfnmTWmq6owAUp0kITuwTFugg5d2naXD5DuDRL2l
         FtYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::13 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
X-Gm-Message-State: AHQUAuZjU2GPsOq35RDwobC2mgLfzrMp6RspsmIgs7kvKCOcmc4eZMup
	6kT8jcKcZYi3MDVxrJYr2AyrRxIwt+a/iFmTx9a6z71vEpTAlvf/Mq27JuzTPHKNhkVpPO839Z4
	mPOYttWd5QwhNBkTdVbaGBzh6ZWdEZtUoysrDCOVNuGkbP2+rQ3wXiVxbNTDmx5btMw==
X-Received: by 2002:adf:f28d:: with SMTP id k13mr21341473wro.78.1549713537055;
        Sat, 09 Feb 2019 03:58:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbbSFKFHNJ/hI3whtNZptNw/SycrLPH7Y/HEFJ8J04ZVpDQlXvbgRo4/aRUNS/Sdn/0kRsW
X-Received: by 2002:adf:f28d:: with SMTP id k13mr21341436wro.78.1549713536251;
        Sat, 09 Feb 2019 03:58:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549713536; cv=none;
        d=google.com; s=arc-20160816;
        b=ny+LV4NuE3XXRF2Huk3ukWpm87oD9kUVQYXQsbi6ZWv48OsL/4r0GNDKZVcj4WJEWJ
         jk+KP+QEWlEyRGIV4bACvIpkC5xdD+pGtF53Uo0CT1sBY3Ve5bTk+a96L0QQ0nJ55WVm
         8KG9z0IMOvHzxqipxR7PGK6v44dXb78jKgXQzHc8IhSJ4AU1yg3GzvG+QxZywZ8UPmj6
         M39Zy8mC46703tWEt7ZovCDfj5PotwYwyj2tc4tMlVfYNsOPBvBu5yKq+787c++JRn09
         ghkeM529Xn1xkFugqXmLRRnBMb+hHbslJ15yc/lCoSec0yVBUBE2pF/yRDNdBkZEWyvc
         PWMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=lDiAmvNZI57Q3r0C3ZjmudAWP4A+WSo8G997ohCbb2s=;
        b=cG2j2PTC7NSEWAiVMqwWWyB80w/z6t4FAoUo003lXFXo3prpZVvtTYZYB5x1hOERX0
         LzRmwwTWJTFZBSC8DcEdaI9qUFtFcmoBAjO2EsGoY7U52x1kKtti4lVh2NYuFsNewmLw
         GZ5hmJ0RPG/HzHgExoHtf9BChmd9czDjkvCKCxVpxAgcl9gFEVb5aJc7SsuDdBcimTpe
         EZjd4whoDfUCXqCC4155/NjmuX0+oKUr3CJZHHO2GII15VhArE4WscxEKn1H+G8UqPql
         sA06TnyZMDexv9XbdcQn/vDwscPmYoU1UfmaGnnMr/OFsb8kZrpl+RKRWAKggYtLG09P
         gfqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::13 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from smtp4-g21.free.fr (smtp4-g21.free.fr. [2a01:e0c:1:1599::13])
        by mx.google.com with ESMTPS id v17si3477534wrw.241.2019.02.09.03.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 03:58:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::13 as permitted sender) client-ip=2a01:e0c:1:1599::13;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 2a01:e0c:1:1599::13 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from [192.168.1.42] (unknown [77.207.133.132])
	(Authenticated sender: marc.w.gonzalez)
	by smtp4-g21.free.fr (Postfix) with ESMTPSA id 3D6D619F59E;
	Sat,  9 Feb 2019 12:57:59 +0100 (CET)
Subject: Re: dd hangs when reading large partitions
To: Bart Van Assche <bvanassche@acm.org>, linux-mm <linux-mm@kvack.org>,
 linux-block <linux-block@vger.kernel.org>
Cc: Jianchao Wang <jianchao.w.wang@oracle.com>,
 Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
 fsdevel <linux-fsdevel@vger.kernel.org>, SCSI <linux-scsi@vger.kernel.org>,
 Joao Pinto <jpinto@synopsys.com>, Jeffrey Hugo <jhugo@codeaurora.org>,
 Evan Green <evgreen@chromium.org>, Matthias Kaehlcke <mka@chromium.org>,
 Douglas Anderson <dianders@chromium.org>, Stephen Boyd
 <swboyd@chromium.org>, Tomas Winkler <tomas.winkler@intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Alim Akhtar <alim.akhtar@samsung.com>, Avri Altman <avri.altman@wdc.com>,
 Bart Van Assche <bart.vanassche@wdc.com>,
 Martin Petersen <martin.petersen@oracle.com>,
 Bjorn Andersson <bjorn.andersson@linaro.org>, Ming Lei
 <ming.lei@redhat.com>, Omar Sandoval <osandov@fb.com>,
 Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>
References: <f792574c-e083-b218-13b4-c89be6566015@free.fr>
 <398a6e83-d482-6e72-5806-6d5bbe8bfdd9@oracle.com>
 <ef734b94-e72b-771f-350b-08d8054a58f3@kernel.dk>
 <20190119095601.GA7440@infradead.org>
 <07b2df5d-e1fe-9523-7c11-f3058a966f8a@free.fr>
 <985b340c-623f-6df2-66bd-d9f4003189ea@free.fr>
 <b3910158-83d6-21fe-1606-33e88912404a@oracle.com>
 <d082bdee-62e5-d470-b63b-196c0fe3b9fb@free.fr>
 <5132e41b-cb1a-5b81-4a72-37d0f9ea4bb9@oracle.com>
 <7bd8b010-bf0c-ad64-f927-2d2187a18d0b@free.fr>
 <0cfe1ed2-41e1-66a4-8d98-ebc0d9645d21@free.fr>
 <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
 <27165898-88c3-ab42-c6c9-dd52bf0a41c8@free.fr>
 <66419195-594c-aa83-c19d-f091ad3b296d@free.fr>
 <1549640986.34241.78.camel@acm.org>
From: Marc Gonzalez <marc.w.gonzalez@free.fr>
Message-ID: <5aff492a-9aca-0517-264f-c0eb95f1a87f@free.fr>
Date: Sat, 9 Feb 2019 12:57:46 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Firefox/52.0 SeaMonkey/2.49.4
MIME-Version: 1.0
In-Reply-To: <1549640986.34241.78.camel@acm.org>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/02/2019 16:49, Bart Van Assche wrote:

> On Fri, 2019-02-08 at 16:33 +0100, Marc Gonzalez wrote:
>
>> Does anyone see what's going sideways in the no-flag case?
> 
> Does this problem only occur with block devices backed by the UFS driver
> or does this problem also occur with other block drivers?

So far, I've only been able to test with UFS storage.
The board has no PATA/SATA. SDHC is not supported yet.

With Jeffrey's help, I was able to get a semi-functional
USB3 stack running. I'll test USB3 mass storage on Monday.

FWIW, I removed most (all?) locks from the UFSHC driver,
by dropping scaling and gating support. I could also
drop runtime suspend, if someone thinks that could help,
but I'm thinking the problem might be in the mm or block
layers?

(It doesn't look like a locking problem, but more a memory
exhaustion problem.)

Regards.

