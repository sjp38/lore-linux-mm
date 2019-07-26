Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C22D3C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:12:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D6BD22C7D
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rapOK/5G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D6BD22C7D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C48D6B0003; Thu, 25 Jul 2019 20:12:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 075D06B0005; Thu, 25 Jul 2019 20:12:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA6258E0002; Thu, 25 Jul 2019 20:12:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C296D6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:12:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so27245892plr.2
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:12:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vKeG3Ueuc6hW4ZzS/tGEf5mXaNRlPgasvVNjyKvH9hA=;
        b=rn7TryZtO0qtp2aPMGBBxUosICc4iOt/wDvwcVJxbt0E8CxbPNiRINvpqEtCN8gpV0
         2WUy1llW1e53b5EY6Yqtgr7NsDYa6tMM+Ge6gdMkUgZsITMlzKUXnV0/XM8Z4mW/FRXU
         C7kJhJHxtMtUDrvPOy3d81wUUJszkP6+1n9OMEoC8O4rqrwvHv/rNhq1sVcwWB3kt4E+
         9R5zTF2MPf8TQWNP2YL4YXb//wzOSE1U5FgaeN6XrmJVyEq9dNUqWMCUo9GQ50m92BC8
         AOzL8WMikf4F9JbjtSJGpCx1KKcotEQoGpvFIdEBWubUJvRcuNkRt92BEeEDFKjpqBUx
         w08w==
X-Gm-Message-State: APjAAAUQ5c70+fknWBGsuG8ztz7lj07gVXJg4GnGSS3UB0OQaX58yRp/
	OKT4CJ+NLyb2YIy1FwXdlA9AUuNUgDfEczykgy46EmfgqHC29mEBFH1Mn6UnS2Bds8BttmNehdD
	oP2DSRa7dSK5/cf41c7nFrk4skv9N6K1jJhdGJnJkqMYJX7TYUhJr4Fd+i08Zf6C6Lw==
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr91639321plt.92.1564099939417;
        Thu, 25 Jul 2019 17:12:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCCL+jmt+vtzwqppRhx7O0uwpYiB1q4le1X1GBDD+vddwxUOVZsWN4hEnhNWbNQ8Xj9xhA
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr91639288plt.92.1564099938755;
        Thu, 25 Jul 2019 17:12:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564099938; cv=none;
        d=google.com; s=arc-20160816;
        b=Xd5BtawrR097KP/GBKdmpwy6qDmGsZvH+uQ1BzQEQdDJ7yzsN+7C3nsyjnsv1PYjqq
         sylL2McgLL2+NuVuiaJ+hWp6wZ8NgEDq2AqihNhTykE/rgYJrdDGT/IhbemMpPj2q5nM
         pxXboFsYBNhfr2xESZIK4m+nCKLWZAWNkc0wLlVgPoOULUog9SZIGDPc1vfb7Ypz/Wq2
         pmst+RcRCUnzljuXQpyHtw0D837EFdZptqior1u09UK+dwzqyAzY1oPw3M+9/D0RwmBN
         uF4Z684ZVSS8VZsSrngXuJCFMwxZmRZ7QIrwXiFgmKjFcsDIDbNuV9Lql6RZUS97XTfM
         0QpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vKeG3Ueuc6hW4ZzS/tGEf5mXaNRlPgasvVNjyKvH9hA=;
        b=IyO1kmlQwH/ownK/G1QCqWeR7DYhySzKVyTn1qv0QC0RfXMqrSrGB0BmmA5rDqk3au
         1D+bHSOm09ZbWKPeYIwoH7mq79wWLEpZRKG9rOSMtKB1fZs/ZSZSk2gzELAf2Tn/R5X1
         j838h50q8lF9yNJoOWXFz+xj8tXQMeiEbKqf6jCgcxf67JprtfqR+daOGM1nHl778j8c
         tj5MyFLmPpHj8eC2Ys7BlaRkCbXojgHqSKr4KwetyfReC86Fw1wQMgme1dqUk21zXcUF
         Z8oE+K1fGxRNJOaWBaTNUQDQWOnjwQATCE8q2fATLFDP+kSnMiuWXWBpaexdjVSgCn+E
         Ro6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="rapOK/5G";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a5si18338471pgw.454.2019.07.25.17.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:12:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="rapOK/5G";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1486222C7D;
	Fri, 26 Jul 2019 00:12:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564099938;
	bh=fgxngI4vVZzf220Z66TNcWVNO6cgpS8Ouf4zCFmjJNs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=rapOK/5GQI2+UhzzzFXr/s8v8HaOl3LjoOaEZjExY74gNvUVhxFu0wpZxmIbGkaE6
	 z8VZBnxSFbBm7iQQw3WUOc01F9aSlvLkyhr6T/DENUWOfn2JfJb0CCVgUszsWo0S2p
	 kR1X6gUFP+jADqEBEWmJm6gfxqeUH82bpo1cBOH4=
Date: Thu, 25 Jul 2019 17:12:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, kbuild-all@01.org, Johannes Weiner
 <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [mmotm:master 80/120] mm/madvise.c:45:7: error: 'MADV_PAGEOUT'
 undeclared; did you mean 'MADV_RANDOM'?
Message-Id: <20190725171217.8c5b2222edd7f5650e385f8c@linux-foundation.org>
In-Reply-To: <201907251759.zSy10dLW%lkp@intel.com>
References: <201907251759.zSy10dLW%lkp@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jul 2019 17:38:27 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   79b3e476080beb7faf41bddd6c3d7059cd1a5f31
> commit: 174e3844d80cb220a226da1e5adb956c80a6d7ca [80/120] mm, madvise: introduce MADV_PAGEOUT
> config: parisc-c3000_defconfig (attached as .config)

oops, yes, a bunch of architectures don't use mman-common.h.

