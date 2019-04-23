Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44CB1C282E3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:04:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01C2720693
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:04:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01C2720693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96B1F6B0003; Tue, 23 Apr 2019 12:04:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91A756B0005; Tue, 23 Apr 2019 12:04:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 793DA6B0007; Tue, 23 Apr 2019 12:04:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCDF6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:04:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b11so9962644pfo.15
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:04:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FBdyN/zGmesCEJEQawfW2McFC8juiGwayAJvNE/x3ic=;
        b=GfXksHyp7vYKa8gIhOTqpBu5DgeR/RE+xN+3wM+9Qjzjm5e8epJx+ojp18jrSw/Tp9
         9V303a00XWIQEGLKmmCghLRymUX/iUEjrJPo9cmkgwuJI8oSnEYDGuhk7dNgTSLLtD59
         XNAZQLy5uEKz223jMDM6k+23r7G8wBCiF0BMmr5xUvdfT4w6c5eV6Z6ljXUOKHqhYUT9
         cCWxXQ/k9V3wgCkDa8UENb5Fy+xEb7WX4NpWn1YoYdRwM3jsv/WfP0R7qm6PeTR/TX5V
         PMCfaD9/DPy0At45vvlWD9z2UAn+Zz4RgTZj9Qz0MpLQKn0t+y0l5OVIoJ1HHIJBqC8R
         zJIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU9Dyk2vUI6eEyskpnyn3dyQ5SJDD9sOUBJpfAiJHZcPffJ0fO7
	dhcM90MnSykGiQCalaf2URg8fVjGnQh5dDy4RYx4xYniqBoER+4a/UQYjJ5wYcUs3crvtmMdffK
	lqNiZ+ff94L/mD8obMrzFVzp25iuQjRYbFoFnGn5L4Yl13lTHfG2Az+bZpQFZK58i4g==
X-Received: by 2002:a17:902:8c97:: with SMTP id t23mr27027977plo.110.1556035486623;
        Tue, 23 Apr 2019 09:04:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuxuI/zFp03hFQ6fAc+0S350uIq1ZOtcUpbJfQGqDqovqBub63Zl1k4oGegelTJXi+CFOJ
X-Received: by 2002:a17:902:8c97:: with SMTP id t23mr27027898plo.110.1556035485769;
        Tue, 23 Apr 2019 09:04:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556035485; cv=none;
        d=google.com; s=arc-20160816;
        b=CW1yNFE4Goef3+blNJVndDLrSVDDvcTmkSr7y4BmM/r0mozMEmDM64vihyOOnfOsD2
         Jq7KcxbjCyLw24pn9rMFhiJlOt5PsRa8EAX0UakQtm4szPcs35CaUN5NdkFXw/5/QLV5
         4ws66HDgXDWhjYRv3OfCPoHLszwWBNRWDLpyBsOn1PDvUzHOtLehqTjw5Zq/UEjAtWAA
         zJMUb4AYt0bwRD5C8nfRQGQbuSVFU2lopYsXwMroYRVRoLKcR3i2RBUkF51Su08tB1xy
         M/FJBT3j0BbIUqytSUbgYux8x23j1ZfwcWxVu8zaDtJ+JYV+r1/aSls80Y7X749XCA40
         zfsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=FBdyN/zGmesCEJEQawfW2McFC8juiGwayAJvNE/x3ic=;
        b=zr1TTjuNBAuasNWvoZnSsIxiyVMMkUR5P1MjWVCIojfdJ7VkjjpX5IUqiSc332xdIt
         296KJUrvkxcLGhNfxO8wFcQLOOBuxvx6rG6adHpHmg9tGZU7QD889VWhmpz3cjTH5b60
         4JVYCF8wpCF1/SVu3xKLSx8QXTmrDwXEXuMq+m+dUh4P6cJm4CqNFGKz4fkg+Q92xpS+
         xBxojP1FxMPUeh4xKg+yzNUp4LAk9jXdECviKApdu2gOFrBEWkXQWUtkcEbNlHQmf3X7
         VG+EaipdgswoImdUBQJZhha/FBrP0fkpkycbZYcLwtZ3np+bTI9dkDBC1zCDkWUZdiC8
         ESOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w5si8086075plz.387.2019.04.23.09.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:04:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Apr 2019 09:04:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,386,1549958400"; 
   d="scan'208";a="138130319"
Received: from ray.jf.intel.com (HELO [10.7.201.133]) ([10.7.201.133])
  by orsmga006.jf.intel.com with ESMTP; 23 Apr 2019 09:04:45 -0700
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>,
 Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com,
 vbabka@suse.cz, luto@amacapital.net, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 stable@vger.kernel.org
References: <20190401141549.3F4721FE@viggo.jf.intel.com>
 <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
 <87d0lht1c0.fsf@concordia.ellerman.id.au>
 <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <4f43d4d4-832d-37bc-be7f-da0da735bbec@intel.com>
Date: Tue, 23 Apr 2019 09:04:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/23/19 4:16 AM, Laurent Dufour wrote:
> My only concern is the error path.
> Calling arch_unmap() before handling any error case means that it will
> have to be undo and there is no way to do so.

Is there a practical scenario where munmap() of the VDSO can split a
VMA?  If the VDSO is guaranteed to be a single page, it would have to be
a scenario where munmap() was called on a range that included the VDSO
*and* other VMA that we failed to split.

But, the scenario would have to be that someone tried to munmap() the
VDSO and something adjacent, the munmap() failed, and they kept on using
the VDSO and expected the special signal and perf behavior to be maintained.

BTW, what keeps the VDSO from merging with an adjacent VMA?  Is it just
the vm_ops->close that comes from special_mapping_vmops?

> I don't know what is the rational to move arch_unmap() to the beginning
> of __do_munmap() but the error paths must be managed.

It's in the changelog:

	https://patchwork.kernel.org/patch/10909727/

But, the tl;dr version is: x86 is recursively calling __do_unmap() (via
arch_unmap()) in a spot where the internal rbtree data is inconsistent,
which causes all kinds of fun.  If we move arch_unmap() to before
__do_munmap() does any data structure manipulation, the recursive call
doesn't get confused any more.

> There are 2 assumptions here:
>  1. 'start' and 'end' are page aligned (this is guaranteed by __do_munmap().
>  2. the VDSO is 1 page (this is guaranteed by the union vdso_data_store on powerpc)

Are you sure about #2?  The 'vdso64_pages' variable seems rather
unnecessary if the VDSO is only 1 page. ;)

