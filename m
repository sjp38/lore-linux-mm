Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71CA1C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 00:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27C9326963
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 00:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27C9326963
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82DE96B0010; Fri, 31 May 2019 20:14:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DEB96B0266; Fri, 31 May 2019 20:14:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CDAF6B0269; Fri, 31 May 2019 20:14:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3830E6B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 20:14:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 93so7375241plf.14
        for <linux-mm@kvack.org>; Fri, 31 May 2019 17:14:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=n13CYKoqUKSRVD7rvJPdVnfVSUZ4sHIYYu90oPD98pg=;
        b=aBV5c5gVdpDMk9gGwNnVGaPltFO09skSQTxeS5x7jaW07ZxYlYJsNE9ON/8VzQi03g
         mp+VJpnL8yhfEKVvtvM3StAXxaFLcIKzh/xJkq3FMOt+JJl9av7Nmu3T3pIti/Znr7t8
         vl9q3zAy7i5lcpq5h8tf2rrY6c95ssNmhBP1I5KxCIRkjxBB2Ba8TCMtqmkGhCilWr4W
         A/GKpMv/yKP90mJj98gZ97XRsyq6EWS/R/D67sLCBNZ31ZDCLgomhqKTuadg5qZlw1HJ
         b5vsWZAH0C/ZZvF+6dh3EXLM3/jYm565gLggEojgphX10dLan8E0URFU5yE5lpzw6VPu
         Ns4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5NjY9kv6Ufl73YTSFkMlyNRLSS8zNepjXMiuJkakZ8pUObjfp
	l4kkm7ZI5ErQlA1oYkQZL7s5VhP3tGSmaUPx7OPJ5RCNfFURhrrwIzcDwOeifo0fJO5folr4DxB
	AbsPZzwUYWELfRgjpFGXLOTH8Me7qr46VfghgkYXdUhCkoBoW5OZUVDNEqFkBysioDQ==
X-Received: by 2002:aa7:9357:: with SMTP id 23mr3626439pfn.60.1559348073828;
        Fri, 31 May 2019 17:14:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyy3LSxdFX6uFNAMDhfBLR2EOskYTfJbzFdhDvWO5lW3u9yfZunD3UehmEy2pMt5n5pCT2T
X-Received: by 2002:aa7:9357:: with SMTP id 23mr3626331pfn.60.1559348072753;
        Fri, 31 May 2019 17:14:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559348072; cv=none;
        d=google.com; s=arc-20160816;
        b=n5OwYJLdd1jfGUtBdHrCrZ+YAA2KpqvJOs6RxxqkV6jxP+W6JTEX36FTKMkPmGTgAN
         w6FDfrdhxK52uvcWNkinTLL75aIJeNyhZyqTRYlNnQ4okBiIfociqGUkqRPKSnAi0fIS
         P+O/HXPw/kwLHYJcE91LKaYeiWVP29eoDT7rIzHAkLx9nr8PcL/8eCTzxQFDcJjIoHDj
         U7lJGgw4k+ux+BomBbqHJ2cAnAuuksDxu0Oei6kqE4t9q4J+9/NMzRI0Bm6+JoELS54b
         z8YJcmS1ZTMVHn0hrVuYmSUoUUhCJoSEQ4nPeldrDt5mhzk3mu/sC4KyomVyfzXRkTHi
         rkXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=n13CYKoqUKSRVD7rvJPdVnfVSUZ4sHIYYu90oPD98pg=;
        b=Cz03EPM7DSz+jdLisSWYskTNbJuDSerUiaisuQ58r3qTVO0+tnT2nK1I+tK1XKxL6O
         MB41kVh/IxvljhKYWdFqMVn8E6nOD5WwEKyKiifsNa/2SYAcqfLS7peFsNB5NtAOoLDP
         yHVdlwE+CjbLh9dtbdMvxjx5OstNbnCOmMLx6gU+5+l3IgdTxNxscc4Ohq9pcTwii493
         3MbItch78JaD8Aszd2/G7QeN2Df7eQusgxpiHi29QtoNOLbCMMPfV/jr+gKrVqm9d5yv
         3n7K+1c/t6y6C39vy8aEpPcrEcoxATKVNTvn9AZF4ywg5+tmg+GRpGiljnGqnFMRkszi
         svtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u7si9466501pfb.223.2019.05.31.17.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 17:14:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 May 2019 17:14:32 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga008.fm.intel.com with ESMTP; 31 May 2019 17:14:30 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Andrea Parri <andrea.parri@amarulasolutions.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim <minchan@kernel.org>,  Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
References: <20190531024102.21723-1-ying.huang@intel.com>
	<20190531061047.GB6896@dhcp22.suse.cz>
Date: Sat, 01 Jun 2019 08:14:29 +0800
In-Reply-To: <20190531061047.GB6896@dhcp22.suse.cz> (Michal Hocko's message of
	"Fri, 31 May 2019 08:10:47 +0200")
Message-ID: <87tvda40wq.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 31-05-19 10:41:02, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Mike reported the following warning messages
>> 
>>   get_swap_device: Bad swap file entry 1400000000000001
>> 
>> This is produced by
>> 
>> - total_swapcache_pages()
>>   - get_swap_device()
>> 
>> Where get_swap_device() is used to check whether the swap device is
>> valid and prevent it from being swapoff if so.  But get_swap_device()
>> may produce warning message as above for some invalid swap devices.
>> This is fixed via calling swp_swap_info() before get_swap_device() to
>> filter out the swap devices that may cause warning messages.
>> 
>> Fixes: 6a946753dbe6 ("mm/swap_state.c: simplify total_swapcache_pages() with get_swap_device()")
>
> I suspect this is referring to a mmotm patch right?

Yes.

> There doesn't seem
> to be any sha like this in Linus' tree AFAICS. If that is the case then
> please note that mmotm patch showing up in linux-next do not have a
> stable sha1 and therefore you shouldn't reference them in the commit
> message. Instead please refer to the specific mmotm patch file so that
> Andrew knows it should be folded in to it.

Thanks for reminding!  I will be more careful in the future.  It seems
that Andrew has identified the right patch to be folded into.

Best Regards,
Huang, Ying

