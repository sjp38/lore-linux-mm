Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7CD5C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74D652086D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:36:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74D652086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E60688E0016; Thu, 27 Jun 2019 10:36:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E11A08E0002; Thu, 27 Jun 2019 10:36:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD9EC8E0016; Thu, 27 Jun 2019 10:36:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 973C38E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:36:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so1671311pfo.22
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:36:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FM5julINmYTjziCqyb1ir1kNuTsTXKZ31ZtTIJjDJMQ=;
        b=b9H2t7M9q+VuKQmQh9ZVxJFXVIV3SBTI7I3rj92OKgHRStNvtS3H2VEYKYNiLHkIxc
         oPbiuAxR+rZe1fmpqmB8zgiryiXQmut9ScL0mdtqAybwXVVcpqJp9HN8yLP11Eiv6abj
         1c/yyeIz0Pp/5cxd8OA2MPGsrojT4Cr8f+lomW1rbru/lqzWccQcJJOvXBwHLW7CpRns
         XQ83YY9fBHTGgBT71Rdg7SmPr0hJCZqlQoGhXIa5vQ0BGJK3cj+PI8rTVM3L/SrjTQpk
         gv7BR8w7s/5r9+ZzwrsVMl9oRvUokERHkOnt1f28VkH32wJwMS6o+sWfZ1s99cr5cy5N
         FYvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVBwQpCpI+YJmXJLNuSvQDHwi/FqjNX2l5A0htY2AKDxgLHEGXy
	D0wH0yl2xkiOMVqTZwtinKlR+cretjitBC4AUmmn1N0RXmrTvUkuRsRnww4KjRT3P8gVFPhEEXN
	XsOJaHUNMfvp9HflQO0mPDlvaUB7xAw5gjwURdrOhey28UcohHe4Zl0Nnx/XplhJ26w==
X-Received: by 2002:a17:902:1101:: with SMTP id d1mr5131475pla.212.1561646213210;
        Thu, 27 Jun 2019 07:36:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeTbjp0pko10V6j2oOmUhs6yvGiTZO/BogrhhI4GvXOufwN+w5oIlwi2BCwxMPzXmCw/Ps
X-Received: by 2002:a17:902:1101:: with SMTP id d1mr5131416pla.212.1561646212518;
        Thu, 27 Jun 2019 07:36:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561646212; cv=none;
        d=google.com; s=arc-20160816;
        b=QkEQh1YDKzrecJaspWGYJGnJnhQpj0EoxnagabOzS+fjEJFQ20iNPwkrJEh/4iOV7C
         zCrEhwjv0tuuruVR4TmPFfVYvmC7t9uTWyJSiOVvPB5FBWWJo+xqpvwLY5ofYw0/7D6q
         BTiE4LSkwMFSpF3KMQYu+FokjgtwkcWeJ6ou5j+t4bbU9Vu295O3is/vfwvHkPFAt5JF
         RNj6BLobuINGtv4x2nxer4NyL5UA3u8yeMsJK/yukDTPbahCLvdcda5+Ygh2yBrvR/sI
         wifdA2CETCev3ck7mmK+yqfEt3O3aG3jKmsebJRKSJjiP2O0+HoVJado0H2vsqAf+2jI
         GTTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=FM5julINmYTjziCqyb1ir1kNuTsTXKZ31ZtTIJjDJMQ=;
        b=Zzr8FVCcFiyuht1s/G6PEncZz6xgJwqI1RRdSAKHSlZMroJUNn9n29cAM7BSoAYnv4
         Vxl50k546wrqS4Acrjj7fjYeg0J+/pY8dh8KgtNJte5zcmEcOqRughF7qrW+H7gdfFrB
         pPj+CtdXI743dNETLy0c2sV7CJCGJSjNLuZIUFhHyyNgHeaRW2Hi8z1cdZC5cUQs8h14
         tYoRx9uJztY460tTrsRw4a9HNcwxZO3d8Czp8rubMJE0ecyFCXIUkoh1beOVsD+hWYrR
         PO0Npwb3NppjTmt0d/r0jvxfa/ORgCqrdWqD6ovFAIeBnRT76bRn1z4mdZ6gdofTb/ZO
         BIeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id q4si2857935pfh.12.2019.06.27.07.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 07:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Jun 2019 07:36:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,424,1557212400"; 
   d="scan'208";a="170441783"
Received: from jrschiff-mobl.amr.corp.intel.com (HELO [10.251.13.147]) ([10.251.13.147])
  by FMSMGA003.fm.intel.com with ESMTP; 27 Jun 2019 07:36:51 -0700
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>,
 Joel Fernandes <joel@joelfernandes.org>,
 Suren Baghdasaryan <surenb@google.com>, Daniel Colascione
 <dancol@google.com>, Shakeel Butt <shakeelb@google.com>,
 Sonny Rao <sonnyrao@google.com>, oleksandr@redhat.com, hdanton@sina.com,
 lizeb@google.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
 <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
 <20190627140203.GB5303@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <d9341eb3-08eb-3c2b-9786-00b8a4f59953@intel.com>
Date: Thu, 27 Jun 2019 07:36:50 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190627140203.GB5303@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 7:02 AM, Michal Hocko wrote:
>> Is the LRU behavior part of the interface or the implementation?
>>
>> I ask because we've got something in between tossing something down the
>> LRU and swapping it: page migration.  Specifically, on a system with
>> slower memory media (like persistent memory) we just migrate a page
>> instead of discarding it at reclaim:
> But we already do have interfaces for migrating the memory
> (move_pages(2)). Why should this interface duplicate that interface?
> I believe the only purpose of these two new madvise modes is to provide
> a non-destructive MADV_{DONTNEED,FREE} alteternatives. In other words,
> pageout vs. age interface.

The existing interface's problem for this case is that it has to know
exact locations where the memory is and where it should go.  For
instance, if you have two sockets, you very likely want to demote DRAM
to the persistent memory DIMM sitting next to it and not go
cross-socket.  To do _that_, you need to know where the existing
allocation lies so you can find the appropriate destination node.

That's not a problem for existing NUMA-enlightened apps, but it is for
everything else.

For MADV_COLD, if we defined it like this, I think we could use it for
both purposes (demotion and LRU movement):

	Pages in the specified regions will be treated as less-recently-
	accessed compared to pages in the system with similar access
	frequencies.  In contrast to MADV_DONTNEED, the contents of the
	region are preserved.

It would be nice not to talk about reclaim at all since we're not
promising reclaim per se.

