Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 567F9C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0299B2085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:48:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GI/zuqCI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0299B2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D1588E0003; Thu, 28 Feb 2019 19:48:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880E68E0001; Thu, 28 Feb 2019 19:48:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 797CB8E0003; Thu, 28 Feb 2019 19:48:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3494A8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:48:38 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id v8so4303163wmj.1
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:48:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=WUF9upp5Sc9hpRcfHYe6o4pIknSTcuJf2d5TiQYopRI=;
        b=loFuXfBJw+gvPgZAZJqNt3x5IIqdTWJobjjkcQI4TmNNXIjn0n/YCqHdc3mOJCl9Rp
         yTFlFF5M7Rf8wXJmLiHDZf+ynUTzWgLAipsU061BzGr7L95emfgdNw6KpI16W8/DGiCB
         b6rSZUN2Nk6edOfIERs0wDveZPp6QoeqZgtDQP8uToG0L+5/CL5QmfmcP//WGShkYBEN
         DcxljzOZ1MkbQELM7UjwhCryUVDD9BB4GXVp0BpBfSjVuhhtmA3yov8N6NEQBIdcNzBN
         78T4ou649iTGkmIyplkQl+A9dTo/k9hFf5uA4/+j7TADCwbarn/QD16h7EG65rlXnRVp
         l8Aw==
X-Gm-Message-State: APjAAAV9m+p70Qp17xAur2YpTaob68i7TdRrPy/MHSoikgQmemYPrJnV
	Go8WNZuR4abtwsQTuV6p0J/XCsexRXylQ6jSNUKO5xcCODTWuhcDEinFZZ4fT0Pfr67UHarg+vC
	oL4IRjM4P3IbDFXkfLvRjBr4xYzOG2CczIXeMGoxeWru9bc4uKFHVPcEMpAkIt5RxzuV6aBOdxT
	RhI0eQTnlH1r3W/bSndz9xdNRCt/gMpQO6+m6JDftjVuEdHVSsHU8cP15L199yi1jNLnGOiDh4/
	AJzd/eChDlyvkwJxlkvq6z1gnMS7aKMKVkdoCelBldnyKCcDmzjJtajSnWW7AhLVjZrmJW0DSnk
	UvAWgM2Bc5W2N2mgYizrNJ2ESrc84KOM81NRNC80tKEVit5/ZE3Uz1mOX7xxLWL2OBXuzolMceb
	+
X-Received: by 2002:a05:6000:50:: with SMTP id k16mr1421254wrx.153.1551401317507;
        Thu, 28 Feb 2019 16:48:37 -0800 (PST)
X-Received: by 2002:a05:6000:50:: with SMTP id k16mr1421233wrx.153.1551401316672;
        Thu, 28 Feb 2019 16:48:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551401316; cv=none;
        d=google.com; s=arc-20160816;
        b=dqX48SRnqH0ss2r+cywr0kSDR5guiGiT1EYQMi/LY3+3NBWfwrru7oRdOra0z3Jku8
         D2LhOoPEOPaqhYCf/dIXHyAMcXBaw6N0bynF/iqtRTItukw4bcaP/XkQSy+gsW9RpyXI
         8lRr9pK8DwkyQrtNF9TnPt2PVU6hzAmBwRRqd2ejt5FoyO7SP6tf6vYAZWb7RI0h7/m0
         5pYMY2C3w4xGufVyoz2zfMY7U3lUgYSwryUFyo6e0DAb67SMTLHVnj1b0IxUwCFaJmlT
         IZM9fp784XHglcnUuPEdmQDtLi6G3SCn+u+c5Nk0yZisYPSLVxL+gxOJPgf7gqtU4kAL
         MOcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=WUF9upp5Sc9hpRcfHYe6o4pIknSTcuJf2d5TiQYopRI=;
        b=opFgawlG28omOevNd+g8uasRp6h/7Uk29e+fwKljx0oIOpnZH2uOx+A8k5+jDeJAr+
         Yu75LPjNVci24sLRNzjoxL95nss+86E9vsH/yRni11JFAaqsVlGuXTEthOKw7RfHDb0I
         WLTUS+qf4VVho6MilhgQzWbgZbVinIQJ6UmqTk1gGV/MFrCAUjSGdUwwCy8rgZuiHSCK
         aDsq31SSe4bZRHA+/a1slpl0rkS1V6omGgZ10zDMz/4WlBrKD96QhqtD/n97xwTJPoZT
         H4m5I04HsA7VSXvsrt4W88nMbZcERilTX8FNOzJejEV/lwvQuaaNBfXQf/SBFZoBXNXw
         xdqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="GI/zuqCI";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d8sor14235788wrv.34.2019.02.28.16.48.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 16:48:36 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="GI/zuqCI";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=WUF9upp5Sc9hpRcfHYe6o4pIknSTcuJf2d5TiQYopRI=;
        b=GI/zuqCIrPa3mlgPfUMsWv/pXF1XtAjed2MhiFwwniAk/W8jX4eTNunQ4swvo7QxN3
         W/vgt864iTN6WrVIKg8V3GbuZdo1NA1LZNuh3DY3Rtn1r7lp/3AAM7zGIeF1tKcpEGfD
         SP/scWjvlmv5A7eV7VKSmX44S1iMjw78r742NJyLrYLtZszqEUOLdwBeMnVUTkicoBo9
         k9SS7vmjqu0okD5hXd0WZaddFNsivyThherGLbJm2DpIb8EcKDJsR5AlvFvpmzIXxyZc
         At4tzJePIKG7UaUpoyaCP0I9oi+H96RmkzRmz2f9lg1CuyJK6oT/vj3vKROwrCjOcw5L
         MIwg==
X-Google-Smtp-Source: APXvYqzTrq3UcyKiv1YhEupQFKOS//qbQNxO3kQkPTK+C4boixjrQ9eQf24I+40l3q8M3DMvbPN1qIv5WWYG+D5A82s=
X-Received: by 2002:a5d:52ca:: with SMTP id r10mr1438037wrv.187.1551401315983;
 Thu, 28 Feb 2019 16:48:35 -0800 (PST)
MIME-Version: 1.0
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 28 Feb 2019 16:48:24 -0800
Message-ID: <CAJuCfpEWxuDR6uiwKfjumjxmDmtbHcLxqXBHJzonQ6=KO+OciA@mail.gmail.com>
Subject: [LSF/MM TOPIC] Usage of PSI in Android lmkd
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001365, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dear LSF/MM committee,
I would like to suggest the following topics for a discussion with
members of mm community:
* How we tackle memory pressure detection in Android using new PSI signals
* PSI monitor design that I'm trying to upstream
* Memory pressure-related issues that we are trying to solve on
Android including the best metrics to judge about memory pressure, how
to expedite process kills, how to detect when a killed process is
really dead (reclaimed its pages).

While I don't claim to be an expert in the mm area I spent
considerable amount of time researching and working on memory-related
issues on Android, used and tested psi quite extensively and
implemented psi monitors.
Thanks,
Suren.

