Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB87AC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:29:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A64121872
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:29:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A64121872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 234308E0002; Wed, 13 Feb 2019 15:29:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E4398E0001; Wed, 13 Feb 2019 15:29:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D3018E0002; Wed, 13 Feb 2019 15:29:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBA298E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:29:21 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b4so2517493plb.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:29:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ep3RlBRQ6132DZIOqsrmX3DttXPYHqqQR4ptpKFN7as=;
        b=GXiciACOuCQW3cUTKbTismpA6P8dH0WubaP+NFokLrNNPuAeDZ3PstNx5PlYE+UMCq
         bqiVPa4l3cuPsUTf+nkCc8PnUd2ftk3cUcQRa68IGPRNwJapVWgVkfKKvREZ1AO9ZgV4
         U1tb8VBy6Gxq2fKvNOkae+KNPzzEllqfxvNxJL14Nr7Vs36mv8XXi2SixOAFy0lYFq7l
         7MJlnHkOs/TJr41E07/s9moLjTQdDLN70fePrGwJ7rHShietrAhgSAyTlauH0VCIwBWs
         4RcgU4Lz9SidK1sl6wo4yE578fRqZyaRulFh0RPBuMO/8tveTsD7YqvfKyGiB1vSK0T+
         Tk/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubQEGKZRKKTo7QvBK+u7D7yU9NK7oprvgSxLmWzw6zVKqrj/YAD
	q6/cMG/ywhWbaCwsFSb0upk3z6UBy22yuSOO3gdM0EwaoixKI12HDAq06S8BZKfJpL6qARu+ch3
	4f5KSiPGVByrlfGeIUTXbUFLoL9uQQMi1lV1/Y1dw+TcrVyGN1jc09E0/somrVo+O4w==
X-Received: by 2002:a62:59d0:: with SMTP id k77mr2238547pfj.211.1550089761422;
        Wed, 13 Feb 2019 12:29:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbP47GyoqKD2P58YReoX98DpSoEFd1zD+tjTA/g6xtwv2DIqGECSljfCapkAk+0LHiqzT36
X-Received: by 2002:a62:59d0:: with SMTP id k77mr2238486pfj.211.1550089760564;
        Wed, 13 Feb 2019 12:29:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550089760; cv=none;
        d=google.com; s=arc-20160816;
        b=EvGUDr2VYb21M9fbv+vfTCpQgsY0nACAG4daUekkOSR/wDjhAdF5gSfF/7mFXkimFl
         4eSweSbQGYfM61hxhJzVZOFfBYS0sDCTczHLJaAk8k9d3fHw81xa5he0493GxSDpUYlt
         eWw5CIIf1wuxUzh8VNf59YYDLgRuId5Mcg396XpVupRxQhDu5+mGqIJJCbOqpHAd7Dbg
         tx26Hg/gDF6jqK4C2N3ATwvceBog1lXkRZvOPKHvaMj7/frQe9nvMDAxbnaotX/Rk3HC
         v7TCxvvwuc/WL/zfSS/XmcQSRy+YOiuRn0bO2PIUqx5T4iGP0XASqAdTU0KKwe837f97
         lYRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ep3RlBRQ6132DZIOqsrmX3DttXPYHqqQR4ptpKFN7as=;
        b=VIVkANej19KUBYKMrVI/GGLDcf4VbMGKWYuf7/sz9N/R49Vt/Hac60nhN1o2maEEO4
         qt08/11In5G+kdq4L0PEM5Tb6TR6Iaj0nS9Jb3fFPg+Ro+5qUAeIf/I1o4W9TB8ZWXnl
         kVPGPgdWG9GGls9zUO6rcdllKIO6aXTZur8uA9wmb3Ch6gMhXRVwr1NemqmkKgkQlazS
         RaJLL3UzOFu+Qg77iYF6iHMzxinjW1x5CMXUyp/FVrikZhS9hT/KJMhnn6Zx088Cj9Dd
         KtnNWT7IorucYBIVhrrBAnkXUNlTEqLWoUmxgJNqbqXy0Sf6nZKTMpTZPhFBiLbDDyUI
         PZ8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o89si240256pfk.223.2019.02.13.12.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 12:29:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 12:29:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="143214320"
Received: from ssripath-mobl.amr.corp.intel.com (HELO [10.254.80.112]) ([10.254.80.112])
  by fmsmga002.fm.intel.com with ESMTP; 13 Feb 2019 12:29:19 -0800
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
 lsf-pc@lists.linux-foundation.org,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM
 <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>,
 "Schofield, Alison" <alison.schofield@intel.com>,
 "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>,
 Christoph Hellwig <hch@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
 Jaegeuk Kim <jaegeuk@kernel.org>
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
 <20190212235114.GM20493@dastard>
 <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
 <20190213021318.GN20493@dastard>
 <CAPcyv4g4vF84Ufrdv8ocwfW3hrvUJ_GaF65AbZyXzaZJQVMjEw@mail.gmail.com>
 <a9b9af61-d4cb-46c2-8e98-256565dcf389@intel.com>
 <20190213202147.GP20493@dastard>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <cbbb8876-116c-5e02-d9a3-355b65a53e15@intel.com>
Date: Wed, 13 Feb 2019 12:29:21 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213202147.GP20493@dastard>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 12:21 PM, Dave Chinner wrote:
> On Wed, Feb 13, 2019 at 07:51:12AM -0800, Dave Hansen wrote:
>> On 2/12/19 7:31 PM, Dan Williams wrote:
>>> Thanks, yes, fscrypt needs a closer look. As far I can see at a quick
>>> glance fscrypt has the same physical block inputs for the encryption
>>> algorithm as MKTME so it seems it could be crafted as a drop in
>>> accelerator for fscrypt for pmem block devices.
>>
>> One bummer is that we have the platform tweak offsets to worry about.
> 
> What's a "platform tweak offset"?

AES-XTS uses a "tweak key" that is typically generated from the physical
address of the data being encrypted.  This mitigates block-relocation
attacks.

However, in a real server, the physical address of an NVDIMM might
change due to a bunch of things, like a PCI card or memory getting added
or removed.  The platform tweak offsets allow the physical address that
actually goes into generating the tweak key to be adjusted.  This can
keep the tweak key for a physical block constant even if the block moves
around in the address space.

>> As far as I know, those are opaque to software and practically prevent
>> us from replicating the MKTME hardware's encryption/decryption in software.
> 
> We're not trying to replicate the encryption in software, just use
> the existing software to manage the keys that get fed to the
> hardware so it can do the encrypt/decrypt operations as the data
> passes through it.

OK, managing the keys alone sounds sane.  I really need to do some
fscrypt homework to see how it manages keys.

