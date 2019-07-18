Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BBD2C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:25:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E415F217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:25:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E415F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 900666B000A; Thu, 18 Jul 2019 02:25:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 889C68E0003; Thu, 18 Jul 2019 02:25:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 751518E0001; Thu, 18 Jul 2019 02:25:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3862E6B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:25:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w5so16100655pgs.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:25:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=W7fGW4+0kAy8IByT1Si76j62yb2bJq44j2advhe1ySg=;
        b=LIL41G3iANWWxHtim6XJquHjGxx9vVh+EGrB91l49o7BkL41kN7SgcGb6UOBg+b2h9
         Y3FYrOOWN3xEi5qXi8xCVhZK00PVoPjZCiXLkhQCcSGvfdCmo6vw8e8nT9oXhoWn3SGk
         TPRz52m6L57qtQ+aQNho919Dc9pcOW4XgWML0XC6mgz0oUNWexMLcIdaoUBIL2yx7V5n
         eDkBeNTysnSvxVsXOkYF2t3Wd5kbhMpMRxdBdu3TVuhoc6Jioo39SvhmuHFQCU7v3JBz
         0JLb85gmAi1xe1eG3Zj7Jvjwb3FNrwhZ5BcakCjJQxzNdlwb7v0JWC/1r67+fEGSV29B
         Qhbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVj86PUjMPI1CsdQfv/CkTWduyHaoIexftonfxpQBCrurJP3kDi
	M/Sx6I72a5OiEmhClmoLv8QfbD65K0tonsudEABA8k3JBVtFkXiIales0IOXW8ysMCvAPYRNwSI
	Tz/UN5vc4A9GYKt2SJ4RogacEL8xYYzPuSz9ooX4EVP73zT3c6QYlAsdmeYrVaWovQQ==
X-Received: by 2002:a65:64c4:: with SMTP id t4mr12104956pgv.298.1563431143808;
        Wed, 17 Jul 2019 23:25:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAsV9/QtIyk/bxpihi1uzPT1Dou6+Ri9aiBMR3ze8u+44bhZL0DN+FvJrOukqsa7rjRaxU
X-Received: by 2002:a65:64c4:: with SMTP id t4mr12104916pgv.298.1563431143205;
        Wed, 17 Jul 2019 23:25:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563431143; cv=none;
        d=google.com; s=arc-20160816;
        b=AbMkV3XIrtBtxSgVSTtJwEQUxIy369tIzt9XskOsIQtJVSHTww1vDE5tIEx24a0N/P
         ZT7lyXcuOD1gUWG/vg2b8ttAtNDfILMUpqUJkT6WFEKAvNckoaqrZ1SXLHjc6HnglZUV
         x9x7naDlnUM8Ld+J9rqJlN0iXGE0GS0NjvfuTkSllDHaiSWNA6UtpR5+oJqJN2HdBSq9
         KmAS+wIp+/jdoLCWKiheNpND9BNTkYVJz1NI+E0z+GkcfA7H94D8MsFGUdQm/VsSAF3e
         9tN/Rf4V8nvNJZvsjs51wR91pZsQ4xp3v6zxO7yX6eo5DUskOfWCnH8OEz+doeYKj//H
         PTfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=W7fGW4+0kAy8IByT1Si76j62yb2bJq44j2advhe1ySg=;
        b=u5BaXz5kY9CFH9NNRuOW3Nn9HscOb5C178j9MnasVn7ozBv1bGFNNjCRe19iQeV4EY
         qtgfT9HhypV6fMkRR8dFOkgWhbIA21OB8HkqN3ZbvkfXRA/e+k9CXUXRoi8yhtjtoZSi
         IYUcrA+ATV84wvTf087HyCnwMoFObHGW9avae2Akfb/zzz2vGCzRgOAH4+LUEHrRUa98
         KFNjhz5pckPXAn8H21O7sWqD51AniiKSV2Ja6wR/xzF02w7o7tCtAT0sT1h1CQdmLgIo
         hnnnYQZH3pfTujjdwXDk7KKyP6Rh8hQz15Dj8KWtazS55Rghe8Kk+mmE7ziYqr0Qu7V6
         1VWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q24si27564841pff.62.2019.07.17.23.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 23:25:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jul 2019 23:25:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,276,1559545200"; 
   d="scan'208";a="191506532"
Received: from unknown (HELO [10.239.13.7]) ([10.239.13.7])
  by fmsmga004.fm.intel.com with ESMTP; 17 Jul 2019 23:25:39 -0700
Message-ID: <5D301232.7080808@intel.com>
Date: Thu, 18 Jul 2019 14:31:14 +0800
From: Wei Wang <wei.w.wang@intel.com>
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Thunderbird/31.7.0
MIME-Version: 1.0
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
 kvm@vger.kernel.org, xdeguillard@vmware.com, namit@vmware.com, 
 akpm@linux-foundation.org, pagupta@redhat.com, riel@surriel.com, 
 dave.hansen@intel.com, david@redhat.com, konrad.wilk@oracle.com, 
 yang.zhang.wz@gmail.com, nitesh@redhat.com, lcapitulino@redhat.com, 
 aarcange@redhat.com, pbonzini@redhat.com, 
 alexander.h.duyck@linux.intel.com, dan.j.williams@intel.com
Subject: Re: [PATCH v1] mm/balloon_compaction: avoid duplicate page removal
References: <1563416610-11045-1-git-send-email-wei.w.wang@intel.com> <20190718001605-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718001605-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/18/2019 12:31 PM, Michael S. Tsirkin wrote:
> On Thu, Jul 18, 2019 at 10:23:30AM +0800, Wei Wang wrote:
>> Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
>>
>> A #GP is reported in the guest when requesting balloon inflation via
>> virtio-balloon. The reason is that the virtio-balloon driver has
>> removed the page from its internal page list (via balloon_page_pop),
>> but balloon_page_enqueue_one also calls "list_del"  to do the removal.
> I would add here "this is necessary when it's used from
> balloon_page_enqueue_list but not when it's called
> from balloon_page_enqueue".
>
>> So remove the list_del in balloon_page_enqueue_one, and have the callers
>> do the page removal from their own page lists.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Patch is good but comments need some work.
>
>> ---
>>   mm/balloon_compaction.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index 83a7b61..1a5ddc4 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -11,6 +11,7 @@
>>   #include <linux/export.h>
>>   #include <linux/balloon_compaction.h>
>>   
>> +/* Callers ensure that @page has been removed from its original list. */
> This comment does not make sense. E.g. balloon_page_enqueue
> does nothing to ensure this. And drivers are not supposed
> to care how the page lists are managed. Pls drop.
>
> Instead please add the following to balloon_page_enqueue:
>
>
> 	Note: drivers must not call balloon_page_list_enqueue on

Probably, you meant balloon_page_enqueue here.

The description for balloon_page_enqueue also seems incorrect:
"allocates a new page and inserts it into the balloon page list."
This function doesn't do any allocation itself.
Plan to reword it: inserts a new page into the balloon page list."

Best,
Wei

