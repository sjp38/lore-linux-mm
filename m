Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4A96C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CAEB2082F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:55:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CAEB2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 361348E0004; Tue, 12 Feb 2019 11:55:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310BC8E0001; Tue, 12 Feb 2019 11:55:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 227178E0004; Tue, 12 Feb 2019 11:55:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D695B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:55:58 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w17so2584033plp.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:55:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :openpgp:autocrypt:subject:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=zVhAkBVxlFHJcNCQGtDm/Ael3djOHm1/1MXyzEZrsJE=;
        b=c6LmCNJADAKhKVWwHUdTJjKxmapUjYRgE5ZW5zKK4ixK40HlmheNxFvIVTFOSn9ydk
         Tpzrk6rp+f38GLxhBINUNDD+lBxDDWL+sgLTIxMCV+wMIGxrWZI3MT6uRwjlJ/EFl/eN
         RwWhMbSgY7fLH6q5DjxbMck/C158GE2W8/okprqhIRKZR9hN/tPFpqwq0PMY8W/4V+/K
         EfemQk861DpN45OxfnkrnGQnRXtH9dk6+MWtmcf72UbaO+CGdoovGCM9xDa7YZYnb2q5
         eSBher6K0/ZxwMvGHJQe7bU9fsmz3HwmuqJyO80nmOQd8Mir06962nXg9oIgguK6IRp4
         41xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubC8oj97KX/FcuOKaFTfSd27mgTQp/9uYp/bCh9wt4Ecnk/S1ZO
	BwHTsTEXGJPyk321TTjWGiYDvz+lZcVUAtHn8jtH3JLtjl6s1a005LlG/OJrJzL94kH0yuO5smz
	d8rbV7+tzzM5Y8Vb8H6o2frsQRJdIkv2BqwQ0NGEdZ1Sov7q9T2tHY9TEXpbglBHdtQ==
X-Received: by 2002:a65:438b:: with SMTP id m11mr2196108pgp.65.1549990558517;
        Tue, 12 Feb 2019 08:55:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia29GpciyLhzjqLw14dUlKZE7K+cKhZJx+6+y4BdeQI69wmQ1p7onAhQadfSw+86R94Y9b+
X-Received: by 2002:a65:438b:: with SMTP id m11mr2196067pgp.65.1549990557767;
        Tue, 12 Feb 2019 08:55:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990557; cv=none;
        d=google.com; s=arc-20160816;
        b=REBTbIseDGvmB9/TcLbniEFCBOqAThREMkpvbn9BBsQIyB+Rh3WYxECjhD1j89Jfmm
         nm4bOtLRwOj+IqVof6Y7T/9uuQSsJeOFeM0zAH3Q8jSZweGxGa/k+9EvgKzCA9bGeluc
         FKC4P91YTJivuzl6bY2xXB5BU+7r/b5vt8IfLcENLqHspe0F62kNrs1rxynOKAjqfiUR
         KvICGh9FFz2fLZ+i665/RbhD2Q5pRjeEZEAXTtnCVQ7ufNR5FiCTT8U6BMf+Z7L7WXWz
         Re4nn+hrRqskOt9JQpc4Mtj/tVY6Bjcp2MyFUaMCCBeNQYQxo+HHLmTm8bFZ6zB2mJnI
         7b7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:autocrypt:openpgp:from:cc:to;
        bh=zVhAkBVxlFHJcNCQGtDm/Ael3djOHm1/1MXyzEZrsJE=;
        b=lYbu4BupJ3cyfHvANWU54gch1OvEUcRp+Lx2y+3S2jIQ6sX3iS4u7S1xDH4ypuPfhB
         8OxsQsAy86yEMtDAxnAbUm4gePaN0elPqceR3zsYwxlOA+WsxywNBmWRVeVRiuNrRq6e
         kk23NH9U41F/mCEHFivPPAMUpWmmdk4ES4X90n78RXoOQ86LaKYMjxPNOExCnymEtg3W
         wh1Rj91w7vkr+o/S85yKP7wkGHfed2UfTS6o18DYkyeTlbPJRumtgQyaBGYFOmi9jwmI
         Dpn+vG5sUaKa1Q/XRKZU8psG7igPLm4VXwgmfPTzMKH/XZWY1ILOaNuG3uYXGvdSNqXr
         lHPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z4si6022283pgv.534.2019.02.12.08.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:55:57 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 08:55:57 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,362,1544515200"; 
   d="scan'208";a="133714213"
Received: from sikkaiax-mobl1.amr.corp.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 12 Feb 2019 08:55:56 -0800
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>, "Williams, Dan J" <dan.j.williams@intel.com>,
 "Shutemov, Kirill" <kirill.shutemov@intel.com>,
 "Schofield, Alison" <alison.schofield@intel.com>,
 Dave Chinner <david@fromorbit.com>, "Darrick J. Wong"
 <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>,
 Christoph Hellwig <hch@infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Subject: [LSF/MM TOPIC] Memory Encryption on top of filesystems
Message-ID: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
Date: Tue, 12 Feb 2019 08:55:57 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Multi-Key Total Memory Encryption (MKTME) [1] is feature of a memory
controller that allows memory to be selectively encrypted with
user-controlled key, in hardware, at a very low runtime cost.  However,
it is implemented using AES-XTS which encrypts each block with a key
that is generated based on the physical address of the data being
encrypted.  This has nice security properties, making some replay and
substitution attacks harder, but it means that encrypted data can not be
naively relocated.

Combined with persistent memory, MKTME allows data to be unlocked at the
device (DIMM or namespace) level, but left encrypted until it actually
needs to be used.  However, if encrypted data were placed on a
filesystem, it might be in its encrypted state for long periods of time
and could not be moved by the filesystem during that time.

The “easy” solution to this is to just require that the encryption key
be present and programmed into the memory controller before data is
moved.  However, this means that filesystems would need to know when a
given block has been encrypted and can not be moved.

We would like to discuss an early proposal for the tooling, APIs and
on-disk changes necessary to implement this feature and ensure we have
not overlooked the interactions with complementary features like
existing software-driven encryption (eCryptfs and fscrypt).

1. https://patchwork.kernel.org/cover/10592621/

