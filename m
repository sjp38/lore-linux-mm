Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBF04C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 22:16:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CFE421852
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 22:16:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="E9lDlKqG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CFE421852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1184C6B0005; Sat, 15 Jun 2019 18:16:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C92F6B0006; Sat, 15 Jun 2019 18:16:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFC288E0001; Sat, 15 Jun 2019 18:16:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B757E6B0005
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 18:16:08 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d3so4697262pgc.9
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 15:16:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=y7OY03tAUw+uDOmHm2Ryp8/+ZPSl4bmWPAKbIEJPJSw=;
        b=ES5nVKsE4l4ydYZMT9eEHuPXxnDhIyGNuKDxi54kGUuCSTDIeFa0UmK6p6lKBu/kqI
         FnzA2uDmfgpaqQdnG6duYD0le5TiwBvQU5rBrgKHeSN5Td3WfGzRUd/t166+wHlzT4hD
         A1ZzVt7mhOyrt4Ja+nDHLNIbz5UZoDwyoQvnTqXOn65Z9zOD0O6G+OXpJPgal9iSqj9p
         IJm3DjIdo02Tx1Z0skg6Ir8b+aC88VGpDL+QU8oPNGoi2psRMWPtCc9TJBAiBT5FTEW8
         drlz/7J25RXBOWnoxQEsQC9xCefC/4MBHLvn/CVzcowdwlW4zLSLPevPU4jXOKxkD+3X
         0u6A==
X-Gm-Message-State: APjAAAUViVHrSrYjvJNAtBRSWqrw/irxOo7S/JonRWRJGERhTX9HqFrs
	97ZoQ1ElYEZuhQIdLn/4DTJ1TBmG+1rqsUYo9Welg2YoTyetQOOUfnEGiJvznrBoBIGvpz0q0p+
	ehs5SbkLtc2e9G2WIizstOmkt6VcEFXpekvI1lXra25ugJi9nelzlBTSI6TRyeGZ+ig==
X-Received: by 2002:a17:90a:22aa:: with SMTP id s39mr3441115pjc.39.1560636968444;
        Sat, 15 Jun 2019 15:16:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYcd/MmEw4j6p5B9YWGXKv3sCwmAaiM4TnX7WITbblkB5+XVdt3Il3xSsTD0tolLQgvqBX
X-Received: by 2002:a17:90a:22aa:: with SMTP id s39mr3441081pjc.39.1560636967839;
        Sat, 15 Jun 2019 15:16:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560636967; cv=none;
        d=google.com; s=arc-20160816;
        b=aesUjZ9JMD8xcX7/Sw0dbaIfABz0001vCBBm2DJ+ojnQo7FwIb/+GqGGKGgMHAtnLc
         tt+9RkqkeJUswIX0NlD1iqwM+PKsgPcIlbvxdfruYeJozPFUWXBcQQq+OThhgyZ+lkEu
         01UPUf+7CW+TyL9srHiCt+C9AP94xO33Tu1COKvIqu1hN6bhqy2Ep6PTRjsCnPASa3xY
         /ppeBatgzJl5J/fe9d8SKqePXBNVtCiKADVu+UMIIc2YJl90QwPKuhOLTqGS+iW00iLt
         ZaeYKu3pTrhENq02rTxsC+kYjlsC7MisZesbW0e4+99PPu28pCbuddq4eF2XeK8JS04v
         riVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :cc:to:to:to:from:date:dkim-signature;
        bh=y7OY03tAUw+uDOmHm2Ryp8/+ZPSl4bmWPAKbIEJPJSw=;
        b=CfKCd7ATlEtPJJMXZv0JIedfaVf5kMmt/hP/g95F5+PlLmvNjLSr5BQUAdVlCsDJNn
         n5xbY+ZeQ9B0NCyoNgxBD37wk7edWjvpV3+wdG02iXnHT8ml0+NpY8hE/BZ4tct6bydI
         RhiHitXEiu1UN7g6kXH8W66bIAZPG84066Qfu1lbaA8Kin/xEU8a4orlrvojHiOTesW3
         Z5dQTeb8NS+d8fQnqpvXVI54036Xl6bMTkPM3ZCEXxkhEXIS6cEVi4XYw4L11ihuCbNn
         rgcTe+tKa6dyIS6gdvh2NdhRVrR5T3Tjb/3zsxDtz2o23E769WJ7KfUcjt0tEIHmveWb
         oDXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=E9lDlKqG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d4si6095931plj.124.2019.06.15.15.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 15:16:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=E9lDlKqG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4B44521841;
	Sat, 15 Jun 2019 22:16:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560636967;
	bh=nC3ePqc1aTbvckg96KeTDhCxv7n4xze7GhZ9thrwyBc=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=E9lDlKqGtPNsc8R+C8eF9q3XanSTxGy2re+98MUcY4P671gal5lV0J5LHrcHz6njy
	 egBlKnDSc2dE6d/5ACefu1j0qqZHi9i3i85ZblolvkbzMoD6LN3wjdbhqjMAbzVtua
	 N1lvDeoJt80W+nIkmjPtDfQmMDkZQH5qj98iz9XQ=
Date: Sat, 15 Jun 2019 22:16:06 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Nadav Amit <namit@vmware.com>
To:     Andrew Morton <akpm@linux-foundation.org>
Cc:     linux-kernel@vger.kernel.org, linux-mm@kvack.org,
Cc: Borislav Petkov <bp@suse.de>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
In-Reply-To: <20190613045903.4922-4-namit@vmware.com>
References: <20190613045903.4922-4-namit@vmware.com>
Message-Id: <20190615221607.4B44521841@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: ff3cc952d3f0 resource: Add remove_resource interface.

The bot has tested the following trees: v5.1.9, v4.19.50, v4.14.125, v4.9.181.

v5.1.9: Build OK!
v4.19.50: Failed to apply! Possible dependencies:
    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
    7a53bb309eb3 ("resource: Fix locking in find_next_iomem_res()")
    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")

v4.14.125: Failed to apply! Possible dependencies:
    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
    0e4c12b45aa8 ("x86/mm, resource: Use PAGE_KERNEL protection for ioremap of memory pages")
    1d2e733b13b4 ("resource: Provide resource struct in resource walk callback")
    4ac2aed837cb ("resource: Consolidate resource walking code")
    7a53bb309eb3 ("resource: Fix locking in find_next_iomem_res()")
    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")

v4.9.181: Failed to apply! Possible dependencies:
    010a93bf97c7 ("resource: Fix find_next_iomem_res() iteration issue")
    0e4c12b45aa8 ("x86/mm, resource: Use PAGE_KERNEL protection for ioremap of memory pages")
    1d2e733b13b4 ("resource: Provide resource struct in resource walk callback")
    4ac2aed837cb ("resource: Consolidate resource walking code")
    60fe3910bb02 ("kexec_file: Allow arch-specific memory walking for kexec_add_buffer")
    7a53bb309eb3 ("resource: Fix locking in find_next_iomem_res()")
    a0458284f062 ("powerpc: Add support code for kexec_file_load()")
    a98959fdbda1 ("resource: Include resource end in walk_*() interfaces")
    da6658859b9c ("powerpc: Change places using CONFIG_KEXEC to use CONFIG_KEXEC_CORE instead.")
    ec2b9bfaac44 ("kexec_file: Change kexec_add_buffer to take kexec_buf as argument.")


How should we proceed with this patch?

--
Thanks,
Sasha

