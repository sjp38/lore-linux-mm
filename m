Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E63B6C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:44:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 831412173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:44:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 831412173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 464926B0003; Thu,  8 Aug 2019 04:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4152B6B0006; Thu,  8 Aug 2019 04:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 304116B0007; Thu,  8 Aug 2019 04:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF6AB6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 04:44:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id r7so55074514plo.6
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 01:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NC0RD4UIANXfQyzBtydUHSmVwfUFhl9Ba01FppXoXlQ=;
        b=A1PXe739ZoDEyln2O0MB29eIXwCIKgSeamZ3JYrA1GvCmFSkwEeO5tPccTVPQ2oLp0
         Xh2bHTjK1kUUNBn/Jxh6oQjru1IKrfFtM2Gfpxt1lxKGKDpFIau5CQkBXFJb82Bm9AY0
         5mfHOpw7f65spwNVF5Hrk2ehOAVswf3DYHhojbcQQv926TDfD2ZyqnSuJfSqt7AfzwCs
         soFwmtYAlDO+gmyEYKazhYB6TJHSolwmQAM3z66+tpzBUDBTkZEN9Pi0AiUjFD7Ra+C2
         DLL65021yN+tm2hm6AdU7nrO35olEwgPEgFPGY3fLcwDV0zfDgItY/ESnHiYCHln9las
         XskQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWNfpYKvEXynFNtFfth2L49t1VEdjhB1k/86VluoLoUnokCDKeI
	3dMu7l9n/Gux5qonvFDwBCAbptQxHC0W2Oppj4b2qCsHt7XVm0OXhrGTGW2Z/PsDpwSL1+zkKO1
	TQkYcFfxIZfSZljP94I8OovgDPrjceaMyz0WdeosI8gG9iFc6U5qk1vS5oCYoEigzPg==
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr2934745pjq.142.1565253891560;
        Thu, 08 Aug 2019 01:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFzBOTy5hyHXSsTPOfMJSvgB7mFOPQGF5ZhyXZGoR5liSy8F168ir9k9N91uzjYxH/Enct
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr2934685pjq.142.1565253890609;
        Thu, 08 Aug 2019 01:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565253890; cv=none;
        d=google.com; s=arc-20160816;
        b=HYxrK+07ChSAxENu8ZctVc7DdHQUD/egIsykyk1dlzef24XHOKNphI/JapHmRX2GlI
         mw09TdHHU99J905eafKGNuTKtE+YTW1sik2KYDy9gC25gYSw5KGmMvE4oGfaRjfuWESX
         vOSo3y6TpXi+gBWTeISRV5pFwGbGniTOPD7/xbaSI6QCTEIJMntoURdRIpcubuz/W9SN
         CLuItzb7ZyPOPVjxx7yknzjoyv4TtL+xTeBoNARKKIxnyMvu3KdDo3MS4qCinCbzfLV7
         t19v3TVJo50YoeMHd56Z8fhYQXv0W9ddnkattjFXXwy6J/WrKJvX3gYbCuA7YhgJ2GdO
         A3yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=NC0RD4UIANXfQyzBtydUHSmVwfUFhl9Ba01FppXoXlQ=;
        b=BwVsxyTnwK1IaZfUFcCGKQnNfmq/KLAL7JDFDE1cX1Xk2BzcLtqvt5h2U4FQUWdO+D
         1M9uVwkeVza1lBP6EN0kd+RVZEZGlQCmOYg3gmnL3E1Nk1GvtxYksdxkgqFRowVr87XV
         AEdjfSsf21Chq+plHA/i9i8D9CIzCcqAa7/wMQM0tJfQQh8CJH5vGq5FJwRqkUzgZWyg
         xObBi/andK529douMREyZ3Ktv/7SnMBSziNIJvY+lUpwpLu7IkxpWSO/pW2qTdkbd+eS
         7EsXtCSsMGdqZpFanSDozghrYpkIk1tPQqwC0A6NfuxvsenK5fbVFdTP4G3Qp052FHJA
         NTXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h98si46784029plb.206.2019.08.08.01.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 01:44:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 01:44:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,360,1559545200"; 
   d="scan'208";a="374781621"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga006.fm.intel.com with ESMTP; 08 Aug 2019 01:44:48 -0700
Date: Thu, 8 Aug 2019 16:44:25 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190808084425.GA32524@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
 <20190807003109.GB24750@richard>
 <20190807075101.GN11812@dhcp22.suse.cz>
 <20190808032638.GA28138@richard>
 <20190808060210.GE11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808060210.GE11812@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 08:02:10AM +0200, Michal Hocko wrote:
>On Thu 08-08-19 11:26:38, Wei Yang wrote:
>> On Wed, Aug 07, 2019 at 09:51:01AM +0200, Michal Hocko wrote:
>> >On Wed 07-08-19 08:31:09, Wei Yang wrote:
>> >> On Tue, Aug 06, 2019 at 11:29:52AM +0200, Vlastimil Babka wrote:
>> >> >On 8/6/19 10:11 AM, Wei Yang wrote:
>> >> >> When addr is out of the range of the whole rb_tree, pprev will points to
>> >> >> the biggest node. find_vma_prev gets is by going through the right most
>> >> >
>> >> >s/biggest/last/ ? or right-most?
>> >> >
>> >> >> node of the tree.
>> >> >> 
>> >> >> Since only the last node is the one it is looking for, it is not
>> >> >> necessary to assign pprev to those middle stage nodes. By assigning
>> >> >> pprev to the last node directly, it tries to improve the function
>> >> >> locality a little.
>> >> >
>> >> >In the end, it will always write to the cacheline of pprev. The caller has most
>> >> >likely have it on stack, so it's already hot, and there's no other CPU stealing
>> >> >it. So I don't understand where the improved locality comes from. The compiler
>> >> >can also optimize the patched code so the assembly is identical to the previous
>> >> >code, or vice versa. Did you check for differences?
>> >> 
>> >> Vlastimil
>> >> 
>> >> Thanks for your comment.
>> >> 
>> >> I believe you get a point. I may not use the word locality. This patch tries
>> >> to reduce some unnecessary assignment of pprev.
>> >> 
>> >> Original code would assign the value on each node during iteration, this is
>> >> what I want to reduce.
>> >
>> >Is there any measurable difference (on micro benchmarks or regular
>> >workloads)?
>> 
>> I wrote a test case to compare these two methods, but not find visible
>> difference in run time.
>
>What is the point in changing this code if it doesn't lead to any
>measurable improvement?

You are right.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

