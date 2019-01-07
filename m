Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 207AEC43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 11:08:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A300C2147C
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 11:08:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="YQRAJf+Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A300C2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 172828E001B; Mon,  7 Jan 2019 06:08:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F80F8E0001; Mon,  7 Jan 2019 06:08:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02CE8E001B; Mon,  7 Jan 2019 06:08:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA4C38E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:08:15 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v24so19123997wrd.23
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:08:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=gXpZZ6SFxyXnrfrvC8VrZ/fh/rDZL5wrUi47RNWSjgM=;
        b=iCaydorNo3wcXQHPgaD5kCaU3MaM9rTwlunNEF4S7p+oVI/gJatwX8ydbSEC9Prb74
         hd6UT23CB0fDJK6NR3gwsHdIXIrsyCb6/w21Q+68p9ocWpOs38wZ/JMk50FkIZeQPzQi
         GWdozDTwQKCDZ8mVh8mddZ7+miIPIrUx9MYAsDT9oMGweUrCqwYwXg9yvZbzy8pOOAam
         nDVIhopP65Cm8ijhkcRUFOpCqXyQNWVcflEkI9WVQuGap3nG3zhd1MfHGWBhwAZRH74a
         Kqb0Digw471pOw00IrSBbSCd674BIzk48zKxaanTPTA/BiJ7FwrO4DI3qGJthWmSEtWj
         s4hQ==
X-Gm-Message-State: AJcUuke/G3ZGOsW/C78RnY4EqDW8pwFYUt/pLR60tPUzJ2fb4LRpHdpL
	h+84oD9oiOSh0dwKacMGzK7WHxLB77ftIkiIyLoV26yy1bnvUDswpFB7CBZbB7lUCla7wvEQGzj
	w6Bc2VrMpXPsi9jxnlHk9h8TQ5eYuG2hQbAys67B7ClwFzrHgttmK64M6TgOXPTa7AktEKdED75
	ri96npI7zy0KlsJiAfkr7I14BSqU8xxHb6WlwzS8ONydC5grLojRlrvZKBsV0z3p5urGjrPFWIs
	LkBwnwVFfoDQjn1HmZCwTD4GtrQBs3tG7/xkhYUhxhQ7X3vkNZa8jTH010YavJyvfQwkmuRd8ua
	remQWNDNlf1mqCZqXNzpbbB81AG+4wtcN5upxoutftmBlNyGPdulyp3T0tVMpn7yinwvjToUfIo
	W
X-Received: by 2002:a1c:1688:: with SMTP id 130mr7967620wmw.86.1546859295129;
        Mon, 07 Jan 2019 03:08:15 -0800 (PST)
X-Received: by 2002:a1c:1688:: with SMTP id 130mr7967587wmw.86.1546859294303;
        Mon, 07 Jan 2019 03:08:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546859294; cv=none;
        d=google.com; s=arc-20160816;
        b=yNrrAItidXCxfLV3bEmg0/lYIKseXaJCbmyt73ShvsRNm9NYOWBkw50F43IQxCuoZy
         2fDr6x4hsAnLco6F84BOhNQSSdcGUXRop1u7zeUHJqdFn9a6jRQBpwFneCGpgXptUvZH
         vrHA+ZKRmCbg6aa1gSXm0rqEYifcPjWqPd5Iwrcap0s4uyw65ySurzdEjVA3ertaocXc
         zbwnjolIDVwRXxQ1OOaG/k96gtF3gNIo97APz32xTdcSmbCRcKI9Lwv9g8/G5++ep+zo
         IVnFUzT070E6ibYU9/uPZgiyM4kE8nVb34KRR7uA/qYZCOkYepPfNOuFy9Cu59WSVJrI
         SmLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=gXpZZ6SFxyXnrfrvC8VrZ/fh/rDZL5wrUi47RNWSjgM=;
        b=JRUgibpehDwrM1bcbgOWcbC7mL0OL92r5/W4WReQidAGXL+kZlgBcnCpnqkZUB1++/
         UYhw2NpFhiiyJDlnWyQGqcmAVWb37p9o4ROfDaPaM7UJwfyZHoBCOX9jwsUSqn7+NPEh
         cbJm6m9ScpQ68amujV7U7mQMlnRxO2x2r85ui3Z4+BzNosj5MHir6rxvbIzQSxl/RFcL
         sY/V/VeWM2LAXY2AAOqDpOholklm0lxEoYiVPKyJzUk2Uy+ycZKtp4CN1Y5i2//IvwTR
         7A2MGVzPvQoPtNZEzLMTL5b5OyTDyMHaOdALL0bxtIwGzEwDljFECS553iEJai7xhDJg
         rLUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=YQRAJf+Q;
       spf=pass (google.com: domain of amit.pundir@linaro.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=amit.pundir@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h7sor35119406wrv.20.2019.01.07.03.08.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 03:08:14 -0800 (PST)
Received-SPF: pass (google.com: domain of amit.pundir@linaro.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=YQRAJf+Q;
       spf=pass (google.com: domain of amit.pundir@linaro.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=amit.pundir@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=gXpZZ6SFxyXnrfrvC8VrZ/fh/rDZL5wrUi47RNWSjgM=;
        b=YQRAJf+QSmY/ouH+cYnSkHfDzQMVKI7jYMimUvDh2/JFfQiibsfXigS1QFJ1PKk+sD
         OZikbzJgHlUxJE6+whrVaMF0QM/ySg//q98tdf9LEXog/X7iGh2qzBNXqByeramBTT4i
         l5xXb2KmrodGwxU2Pz3NMY1JYw2gsShjxOOWE=
X-Google-Smtp-Source: ALg8bN65ulkd6D09CCmq3NOjXhjRfOOoQDfTRn88+4F+Nawc5NT7b8Oja70QQ9G4mPafBtyhFG7k843XEmonDIFDuDI=
X-Received: by 2002:adf:9542:: with SMTP id 60mr49427704wrs.60.1546859293841;
 Mon, 07 Jan 2019 03:08:13 -0800 (PST)
MIME-Version: 1.0
From: Amit Pundir <amit.pundir@linaro.org>
Date: Mon, 7 Jan 2019 16:37:37 +0530
Message-ID:
 <CAMi1Hd0fZwp7WzGhLSmWG3K+DS+nwT9P9o=zAOGRFDDhjpnGpQ@mail.gmail.com>
Subject: [for-4.9.y] Patch series "use up highorder free pages before OOM"
To: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107110737.YMjGpSK6g4hdzwmoC-XXbBgzSVY6IhJB9VdMng6RUpo@z>

Hi Minchan,

Kindly review your following mm/OOM upstream fixes for stable 4.9.y.

88ed365ea227 ("mm: don't steal highatomic pageblock")
04c8716f7b00 ("mm: try to exhaust highatomic reserve before the OOM")
29fac03bef72 ("mm: make unreserve highatomic functions reliable")

One of the patch from this series:
4855e4a7f29d ("mm: prevent double decrease of nr_reserved_highatomic")
has already been picked up for 4.9.y.

The original patch series https://lkml.org/lkml/2016/10/12/77 was sort
of NACked for stable https://lkml.org/lkml/2016/10/12/655 because no
one else reported this OOM behavior on lkml. And the only reason I'm
bringing this up again, for stable-4.9.y tree, is that msm-4.9 Android
trees cherry-picked this whole series as is for their production devices.

Are there any concerns around this series, in case I submit it to
stable mailing list for v4.9.y?

Regards,
Amit Pundir

