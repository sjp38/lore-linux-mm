Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ACB0C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 21:17:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94D5420661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 21:17:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94D5420661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F190C8E0003; Wed,  6 Mar 2019 16:17:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC6A58E0002; Wed,  6 Mar 2019 16:17:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D416D8E0003; Wed,  6 Mar 2019 16:17:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD9D8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 16:17:36 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 27so13707185pgv.14
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 13:17:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=loVhwJRnpkgdnpbZ2Uea8dnQHINtHnxdKbkFjujEQsI=;
        b=ErJONuaGtmD2Cl07UokikFYG+v+C8OypuzQ8cTE4soKK/uE7djRADrak45I8xqFJth
         GIamkPSb674hD7zCxw8pP2ca/ip6+K/ZMHgM/Pd/IR6zkcj3bCzg6ldJiotyBSf+wQSq
         MH5wrpc3QLJZE/HPU2CKwbWHUgxxpVU3i/qChcVvVtpzEqiQj4FdsL5IjlJaytL18hZ9
         +wKBDcT3R3428ifPAU9t6zQJxvpYCVhlWFco4bNkV35M4q2APJXfzeieWkrZn5f5UavZ
         6cUNvt8ZueBPLeQSj+YQder2N/JUBM+++4b5qRhLOBak6Me+5q1ly0EjqC48X5BWqmtE
         odDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUrCQ6XSsIMfUWu1e0lsp8vsVsztPtJ4WWlaq4lZor1RFTk8Bpx
	n6komCNU/ccUQXnSvDZeYxOXRCB4f0LvON/69nvuoOFGRYE4VOrghcCkbYI5YblBrwCZ4BHf7nl
	iSLq1qbDEKxbnyo9AsHghhtO1eqbPWc3yNUgXD8xKZyUxdw6lUYvDO6Q7ykhhf+x7KQ==
X-Received: by 2002:a17:902:25ab:: with SMTP id y40mr8970931pla.62.1551907056212;
        Wed, 06 Mar 2019 13:17:36 -0800 (PST)
X-Google-Smtp-Source: APXvYqzkSXmgLHEiIDqk60oa0j5mCee+M19TT6L98ZIs0THcTbtMiUbafqI7i1f4tov2qLQIC8lf
X-Received: by 2002:a17:902:25ab:: with SMTP id y40mr8970847pla.62.1551907055186;
        Wed, 06 Mar 2019 13:17:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551907055; cv=none;
        d=google.com; s=arc-20160816;
        b=WYw5qSXTM1la9lwYEhmNzrK3iRtTZCEFSQVZ/+Yq3hBr55hiPWEJ2CYQvDpMpR0v0v
         L9Tdoz06BQcS+Pjm7GzMRg1N7/myiO7U3l9EnQ04i9zvP5eRMOBCdGgHiKHt2vpEIdpD
         KwVUni8f1zQuyQuSjmpspzCgxik3+mZnOQWyR1SITAPCuPaG61b7o1cZvXG4q6aZdEGM
         9+AYYxtD+22Qj0U6thccPJlmqjZFRDC4CagY3MCH8h5BJer5iclwmxNdTXoiqjq1QsCm
         HGQKNi+KcOVFUqj8X4FORjY1Bcp7JuUuUMVoVGiesOUlZHtZPLqgLSHvw3VKaY44NGgW
         0BAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=loVhwJRnpkgdnpbZ2Uea8dnQHINtHnxdKbkFjujEQsI=;
        b=dKbO3WGP6lwB7K+mH2DgEbma600xmM7ahUvbc9NETCQldiUAhcPGwDrqoHzlnbWAzE
         /WT7Gc+sKLMQ2C9nkFIZsca4o3k3wbOIQAIfWo1qiGJjNzJxqiVi4bi5xTDa7mrbhT6P
         e/VcC0P30THVqOke80UvHMRR14Wzy0xWLKnozQoiArNKK+8UBonaXJy5iwBMSfC+jjmY
         qopwaEW+DekA+0+nhImEvMNrOUx7JI3nfVhF+FKQ7+TFEUsO5eQTRd4pnzz/MCvo0tR+
         pJDuLVROzktLCyIJSl+K04RWIBKrdtGIFyKLXbZ9MepPfSZUZ08F+OLVQPF28PD414l4
         cLkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z9si1414028pfg.21.2019.03.06.13.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 13:17:35 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Mar 2019 13:17:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,449,1544515200"; 
   d="scan'208";a="304986830"
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga005.jf.intel.com with ESMTP; 06 Mar 2019 13:17:34 -0800
Subject: Re: [PATCH v5 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alex Ghiti <alex@ghiti.fr>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190306190005.7036-1-alex@ghiti.fr>
 <20190306190005.7036-5-alex@ghiti.fr>
 <7c81abe0-5f9d-32f9-1e9a-70ab06d48f8e@intel.com>
 <82a3f572-e9c1-0151-3d7d-a646f5e5302c@ghiti.fr>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <5058428f-f351-ce26-7348-3b2255e5425d@intel.com>
Date: Wed, 6 Mar 2019 13:17:38 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <82a3f572-e9c1-0151-3d7d-a646f5e5302c@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 12:08 PM, Alex Ghiti wrote:
>>>
>>> +    /*
>>> +     * Gigantic pages allocation depends on the capability for large
>>> page
>>> +     * range allocation. If the system cannot provide
>>> alloc_contig_range,
>>> +     * allow users to free gigantic pages.
>>> +     */
>>> +    if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
>>> +        spin_lock(&hugetlb_lock);
>>> +        if (count > persistent_huge_pages(h)) {
>>> +            spin_unlock(&hugetlb_lock);
>>> +            return -EINVAL;
>>> +        }
>>> +        goto decrease_pool;
>>> +    }
>> We talked about it during the last round and I don't seen any mention of
>> it here in comments or the changelog: Why is this a goto?  Why don't we
>> just let the code fall through to the "decrease_pool" label?  Why is
>> this new block needed at all?  Can't we just remove the old check and
>> let it be?
> 
> I'll get rid of the goto, I don't know how to justify it properly in a
> comment,
> maybe because it is not necessary.
> This is not a new block, this means exactly the same as before (remember
> gigantic_page_supported() actually meant CONTIG_ALLOC before this series),
> except that now we allow a user to free boottime allocated gigantic pages.
> And no we cannot just remove the check and let it be since it would modify
> the current behaviour, which is to return an error when trying to allocate
> gigantic pages whereas alloc_contig_range is not defined. I thought it was
> clearly commented above, I can try to make it more explicit.

OK, that makes sense.  Could you get some of this in the changelog,
please?  Otherwise this all looks good to me.

