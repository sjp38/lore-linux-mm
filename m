Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAEE5C46470
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89A99205F4
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:48:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="pvzGmqfn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89A99205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F208C6B000D; Wed, 29 May 2019 08:48:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED14F6B000E; Wed, 29 May 2019 08:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC03E6B0266; Wed, 29 May 2019 08:48:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9B56B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 08:48:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l3so3305980edl.10
        for <linux-mm@kvack.org>; Wed, 29 May 2019 05:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MONbMDhNRBTOrhsT93yPHwMAxRk5gJkctOPhsHPlMjo=;
        b=L6CwVlBxInMFV8uaSrn4HqVlrMpm3cDN9pG9hTokm+bxF1ZHi3xwTh3kMA9XGTbf+4
         ZfX6Ga/4L/dpF5eEWuJH/nftXMRa2Inxhk+jsQRy2xg83IbpFmnQm1+QibrGVNRktmYN
         +GGdGFvRIrbN6xRIb1IhxefyV/81Zwa4XCF0EwhuJdVRnXRPVzV+rfca82d8jFnx3r1G
         LycGTDaZSv6xmo/Yb1VeFYBslnD50QS8gDgbqXcSLANqtjExYq+R3DaE5LrEGVhzvT01
         0N4LJJB5mw/de/WgZg0JE60Mz8dAn6gN5oxf1MIuQM9iUo7QkRK88kFRDCbKAnBttqk3
         NXEg==
X-Gm-Message-State: APjAAAVdLSuGBDncxOyX9zCHUxah9dwbMlmHBKFIK5Z5n5epVKXeLLpx
	KZPjHnECGca/kaqXTNbiiE11B5hOfP0JFBnxnsMe9+I+s0KKmG3BEKQncQ0ewLsWByE1IVGf8hM
	DEOR+rwWcNSDlKJ3GJxOhxdthMEV7GBowOT9awZv+trNCMmaklctQXlkQzhGGmLxHDw==
X-Received: by 2002:a17:906:5f82:: with SMTP id a2mr72833103eju.297.1559134082025;
        Wed, 29 May 2019 05:48:02 -0700 (PDT)
X-Received: by 2002:a17:906:5f82:: with SMTP id a2mr72833030eju.297.1559134080991;
        Wed, 29 May 2019 05:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559134080; cv=none;
        d=google.com; s=arc-20160816;
        b=sWVMmWBHCplY9SIG/c/2Jmu7LEffsD+NYGe4/egft8+8pOOn7oeLYDU5KMkTIpCnmu
         i7zHifKQitdUbmcGMLuJU7fk0oaqUYCRI1vjazJPo5Yw0+8X4Fg2YOORTguZeUla6vnK
         oCR8mxlxRUUvmWVH/lJ+KVGZ6+0LQTFh+tF+dCF2ffwpPC8UgxDBEYUD/okyAn8T8HH0
         aMs8NYJvOjYuV2ROAx6U9/P1Xoras50uBjVKvNEoNT3isTG4+Gpf+x8pkWTuJtfB66wk
         1+WXdAzw0XMF84dosJ8KtlM2SbtsKxxQq8i0Q8PqGsJudIfdOfzHbLMQ0G9XklZpP9N4
         02kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MONbMDhNRBTOrhsT93yPHwMAxRk5gJkctOPhsHPlMjo=;
        b=kqSFUTjK45uUgFn3/vfKRFS3h098s1y9jB0kR1VWCoDB/U6cc2Rbq5gnNk7QnMqh4i
         o4ScImh1hm2rXxpaiJbMDCy4m4oUcLdFRI2AVV/E6yjQ0vrhQIvszxD07fIeFV8IO6pk
         wDN/+FbDWVq3z4pSPRH1SJQJ2dV0eY88YrfgVWqM6zjlE1qivsAC4fACZctqPzKkvIjJ
         KkrElQ48+2DDooiSlL/eacymV7CbH9CBXIulVbpAOGUVnHjiugp0VoYVWzb3UT4MyWJJ
         Kzpc0sKj1kPtAvUqBxCuYxTnjXgCzkkzt4iC38pmvVW8kFi5GQqTpCsFai/EZIqk4jXd
         tHLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=pvzGmqfn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m46sor488537edd.2.2019.05.29.05.48.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 05:48:00 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=pvzGmqfn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=MONbMDhNRBTOrhsT93yPHwMAxRk5gJkctOPhsHPlMjo=;
        b=pvzGmqfndke61sBQlh1oho21KJ6Iybo1zHRk74CTMX5dILmjLpgpFD9xiNkJcIkykj
         88K6WVvQaUnOZAxTaXUwsfom9gc9tKGhAlt9jDh1AvRVL2fcPUPvVciXyd+4/cfnzi6Y
         BQc+Kf6NRRPU+LUsTWAkOih+0iPrKPi5AV8QW2IPC15kto3MI2CcTIDgyW1NvpvnbaHn
         72gRT4fZtCzDKYazAwoauPiUnTinRIP0Jz8q0vmBhjkSQvKq344X6obRR8SDoPT0HYGL
         IzumjrtY2Gd+o3l7MaUv/iBxsDD93S/NUHjHNBVVcbESUuNn/24MBGAgjnldGThCL3xB
         SLRg==
X-Google-Smtp-Source: APXvYqzoaFmZ7mZVbDTqlrFuJBSNrSbiSO0d9+zexx5kswJ+G5IjO7KLQ5NjC4EQdadEnFovCFgWeA==
X-Received: by 2002:a50:86e5:: with SMTP id 34mr136814479edu.290.1559134080713;
        Wed, 29 May 2019 05:48:00 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id qq13sm2797939ejb.1.2019.05.29.05.47.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 05:47:59 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 050E01041E8; Wed, 29 May 2019 15:47:59 +0300 (+03)
Date: Wed, 29 May 2019 15:47:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 05/62] mm/page_alloc: Handle allocation for
 encrypted memory
Message-ID: <20190529124758.ojyakxdx2zf6nmtt@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-6-kirill.shutemov@linux.intel.com>
 <20190529072124.GC3656@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529072124.GC3656@rapoport-lnx>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 10:21:25AM +0300, Mike Rapoport wrote:
> Shouldn't it be EXPORT_SYMBOL?

We don't have callers outside core-mm at the moment.

I'll add kerneldoc in the next submission.

-- 
 Kirill A. Shutemov

