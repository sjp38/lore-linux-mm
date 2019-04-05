Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75345C282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 21:27:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F417621726
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 21:27:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F417621726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=vt.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583BD6B0007; Fri,  5 Apr 2019 17:27:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50D696B0008; Fri,  5 Apr 2019 17:27:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ADD06B000C; Fri,  5 Apr 2019 17:27:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15D4E6B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 17:27:47 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k13so6524609qtc.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 14:27:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:sender:from:to
         :cc:subject:in-reply-to:references:mime-version:date:message-id;
        bh=Y79cdCdF/M5lgfA1xcm93DhUSoi2n3NbM7Cae4JkvcY=;
        b=ouHcb3uz+bfYJ8raaGj0bPq4PmLLw2sZq5cj18W2TMklfff3bGYFzzdOv7U1iFTXzn
         HuAQBlQ+cSXSB7L1fcCGiO3uU7RQywygmJVCaj4mqM4GfA9hRjyDK8YBHyanl18+7H4E
         mSmkYbNIFOwYtfUWrYOn0Ic/EEqo3oQMT1YCp+ofkQ0womXwgSKtlKtfx+xZRunuhXiz
         Bvy2Z0gFq+wbMJaHnhfRPdHhHnNh3fXwm7qLX1ssTQi1E1gJcnuw8zx7SNKVMJTq+Sif
         Ozj1JWCihjUAtdkMo7vA3DmBBsPKL0hdtO66s+rkx8cW5sdIG2DPiz7Fowuy31JJRxtm
         qa3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) smtp.mailfrom=valdis@vt.edu;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=vt.edu
X-Gm-Message-State: APjAAAUW5BeS6KNj285TQ5Fhc0oMM02G5N90JiNPxIVbyo9DwwpD2zGq
	PWZb+Wl1WDYqpK53NX6HLjhDC/J5QCojDNmCbiKMB1/eGsTSdek2dd7LnNFIObnTSkXVz6olUXy
	UoArx8AkhguXjrl9SMx/N+ckvpQhbNsrMaQUPSlCCM01xx/OJzmIQ5UsxV45mk3plhcw3nHQ3FB
	RZDViHMEB4bzrC6miwjimcXSrwBsdqlB/rhTZKGfnxyI5ehf8N11gAZUOVrYhiUw==
X-Received: by 2002:aed:3c75:: with SMTP id u50mr13020884qte.128.1554499666852;
        Fri, 05 Apr 2019 14:27:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSVhEHtttyHizGkmDlfdDRKuiJjWw5gFcYVj+2N1o4LFFdJcu6evmOGat2Rsh9iadZydXT
X-Received: by 2002:aed:3c75:: with SMTP id u50mr13020851qte.128.1554499666202;
        Fri, 05 Apr 2019 14:27:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554499666; cv=none;
        d=google.com; s=arc-20160816;
        b=DS87HVMLUyDaPnG+1Ahjog7XPOFSVrgcD77IBSDeqtEEF+Fqr41qlF/Aj6wO63UX2B
         WDW3biWbbLvHDBHy4aTWNHkT5TCHG1DT/fHFLvcR1v4Ixya65s/xMP41d8aQnGPJcsg/
         DxwuFWkcEs1tw9QrochsMZqqgzQ8OXgqxeRpK2pXEAkez8Rmg35OpBtqzjY7dN25tE2l
         2iMuBXDN5nHtvktWSllzoTbKdEW14lvSLzQ7V1sD+dACB0klGAuquBIr5NBmdVlzm7bT
         ImwwdpMbOlSC6KRt5oxm+Pttn7lN8oWatIDQIxLAYgZni2p76j+cD2uj975QQwqum6Xo
         Jlqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:mime-version:references:in-reply-to:subject:cc:to
         :from:sender;
        bh=Y79cdCdF/M5lgfA1xcm93DhUSoi2n3NbM7Cae4JkvcY=;
        b=E1bfoyWByuaIvCOuywW34doCNv+e3a0KVxoH8gI+JfyllDZ7quu2ka2B2g1YJMe9AT
         GD8IsnPA84VPspBK9+fHXyLe+nUk2aY74Iqq/0sZj5VWsv/azcNtjvSfUXguBYboHC9L
         kYxQhZvf5MeLXv1UrTWKdB3XvY///HPPwfLLmLphhhzh+/pcsFgIVcfpriWDTAIlPaZ4
         63Z7d9eDwSXT5hSW3x/TZlGBVXtN2nDVdWE2R7h9wJ8wEKSOhzT9mE+YndGbDeGwYuT+
         63mO6fTENKnK2zP7jnOYE7Do3tpGcrfVVvfB9G76QadkxyFS7TA0P3f9KgsvbHujGJTL
         utvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) smtp.mailfrom=valdis@vt.edu;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=vt.edu
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id z31si661757qtz.218.2019.04.05.14.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 14:27:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) client-ip=2607:b400:92:8300:0:c6:2117:b0e;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) smtp.mailfrom=valdis@vt.edu;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=vt.edu
Received: from mr5.cc.vt.edu (mr5.cc.ipv6.vt.edu [IPv6:2607:b400:92:8400:0:72:232:758b])
	by omr1.cc.vt.edu (8.14.4/8.14.4) with ESMTP id x35LRjti017652
	for <linux-mm@kvack.org>; Fri, 5 Apr 2019 17:27:45 -0400
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by mr5.cc.vt.edu (8.14.7/8.14.7) with ESMTP id x35LReDI009007
	for <linux-mm@kvack.org>; Fri, 5 Apr 2019 17:27:45 -0400
Received: by mail-qt1-f197.google.com with SMTP id q12so6624521qtr.3
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 14:27:45 -0700 (PDT)
X-Received: by 2002:a0c:d092:: with SMTP id z18mr11840005qvg.14.1554499660598;
        Fri, 05 Apr 2019 14:27:40 -0700 (PDT)
X-Received: by 2002:a0c:d092:: with SMTP id z18mr11839994qvg.14.1554499660359;
        Fri, 05 Apr 2019 14:27:40 -0700 (PDT)
Received: from turing-police ([2601:5c0:c001:4341::9ca])
        by smtp.gmail.com with ESMTPSA id p62sm6308944qkd.27.2019.04.05.14.27.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Apr 2019 14:27:38 -0700 (PDT)
From: "Valdis Kl=?utf-8?Q?=c4=93?=tnieks" <valdis.kletnieks@vt.edu>
X-Google-Original-From: "Valdis Kl=?utf-8?Q?=c4=93?=tnieks" <Valdis.Kletnieks@vt.edu>
X-Mailer: exmh version 2.9.0 11/07/2018 with nmh-1.7+dev
To: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
cc: LKML <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "kernelnewbies@kernelnewbies.org" <kernelnewbies@kernelnewbies.org>
Subject: Re: How to calculate page address to PFN in user space.
In-reply-to: <1536252828.16026118.1554461687939@mail.yahoo.com>
References: <1536252828.16026118.1554461687939.ref@mail.yahoo.com>
 <1536252828.16026118.1554461687939@mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Fri, 05 Apr 2019 17:27:37 -0400
Message-ID: <6977.1554499657@turing-police>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.052605, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 05 Apr 2019 10:54:47 -0000, Pankaj Suryawanshi said:

> I have PFN of all processes in user space, how to calculate page address to PFN.

*All* user processes?  That's going to be a lot of PFN's.  What problem are you trying
to solve here?

(Hint - under what cases does the kernel care about the PFN of *any* user page?)

