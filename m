Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70B04C4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:51:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36B13222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:51:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36B13222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7A2C8E0002; Wed, 13 Feb 2019 10:51:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C50A28E0001; Wed, 13 Feb 2019 10:51:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B40938E0002; Wed, 13 Feb 2019 10:51:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 731478E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:51:13 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so2148046pfi.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:51:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=fgQsZ6VxUSCnuA6WERI+ivrgHoQKon5VtEFEmujHWUI=;
        b=QguzKWXPrtQsXBcjEEplwhDAa3KDWa61rNJ3oH9bNTtV3ePK9ztw7b5o7G58ktWYIi
         BtyXmaxIt1IzSyhevMkIbIvKrqJYN8JyRmDuK5FV4mokbzLUJiOa7ZQKJeukEqyuS8ds
         Gr2uM/6O3VNWkxpyukgtN1k5OJarJPH20QKs0Xe4IEXaFlEJT/5XMG+p/KKFP3dNJmJy
         SyxjCEWk1oreTttpUKlBhFy5Zu+wB26KR+7GmjFOmAH09JI2TJ5bYBRR11uuC9D+BgDe
         8M6D2mMdnlfuSKAiqBR9HH6RFlEqwVHoU7mmtliPgHY39elYkmJyMsD4AwC5Uc4FHUTo
         3bbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaSGV7g7+4tnEfOVWRJPhLIa6siraRfIUqw9uU8GsHAQNh4PD63
	Wna4/BhiksmmDV82J1rHyEgjRC704bOGFYPKhx9gOjGZ2iMRmkYv+wvfs3kLmLsHCfRWqSSxfQD
	DB9gDTwy0yYwQhYsKIriiuKKSYef7Xtjyjz8NaQyPshUz8rWsyOo7aGu9R4+fksb5FA==
X-Received: by 2002:a63:160d:: with SMTP id w13mr1025615pgl.85.1550073073165;
        Wed, 13 Feb 2019 07:51:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYWUaED0SzmSbeWpZTulZGfOM9o29+zDJMIN45/oRcNp4Q1n7oMDmHkcZ5MxjOJfsVgOMGO
X-Received: by 2002:a63:160d:: with SMTP id w13mr1025582pgl.85.1550073072541;
        Wed, 13 Feb 2019 07:51:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550073072; cv=none;
        d=google.com; s=arc-20160816;
        b=qEMnPZaZT4vT3rkHEEkJm2jKI5T80ApX3f03togne0vUcPeyr0IqjCEBeyb6TjP1mt
         S96AQ7wNQ6QI9UoWlaRss7vaKv1j9dB0Lq7ksnE8K5Mfw4WjrZWHGPty9g+i8nxAHi05
         8V3FtC7mYWp4oUy3zTqy7kt1OMk32rIpG2YbjDzRmJZdW9Li4SA+3gvXR5cxRW0fvX4f
         4GVKeMW9MzQQunwdSejyrUik6VRPbBCx7OFydsHLqD1aczUqrD1TWYpT9wgM8Ppf2kYx
         0tqYaeMoIceI41ZkBxgiF6Ke3NliyU7gQalCU4QC7Xesx1p4ekQDx/dWRfieZ/3DOgaC
         rOVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=fgQsZ6VxUSCnuA6WERI+ivrgHoQKon5VtEFEmujHWUI=;
        b=bBtlZSwwaFhBQhfXE7Gt3/s9KTgTtZsYDxPQgRaEqHRsjW5JrRCkn1WsJ2iVlQaxYc
         hLn3mC/J7JnP5VCrtluKevbMefbvp/NC3ugWTJS/OLYjuWkznPbzU3lHEuz5fVpf53xs
         NcBqOb0SbVdZ7q2jUoh9l2b6MK2DnO6FSeqDGicwcWeZDDUdwMvv/SPA5Kdo9GB7F7y0
         0qJeQRWawCCqZlCzkQQXcw7S8POajMpdjlqzyrCun8zyDQeVKEWH92BaUQOcSakIiJFe
         oB3xHkgByiFRoxsrxffmNHKCKBKZX8jicrA4mEqob5ltMWA5ehtvlo4t0iu9M4e6yax6
         snLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id n20si6904026pgb.195.2019.02.13.07.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 07:51:12 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 07:51:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="143945163"
Received: from pmmonter-mobl.amr.corp.intel.com (HELO [10.254.87.236]) ([10.254.87.236])
  by fmsmga004.fm.intel.com with ESMTP; 13 Feb 2019 07:51:11 -0800
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
To: Dan Williams <dan.j.williams@intel.com>,
 Dave Chinner <david@fromorbit.com>
Cc: lsf-pc@lists.linux-foundation.org,
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
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <a9b9af61-d4cb-46c2-8e98-256565dcf389@intel.com>
Date: Wed, 13 Feb 2019 07:51:12 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4g4vF84Ufrdv8ocwfW3hrvUJ_GaF65AbZyXzaZJQVMjEw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 7:31 PM, Dan Williams wrote:
> Thanks, yes, fscrypt needs a closer look. As far I can see at a quick
> glance fscrypt has the same physical block inputs for the encryption
> algorithm as MKTME so it seems it could be crafted as a drop in
> accelerator for fscrypt for pmem block devices.

One bummer is that we have the platform tweak offsets to worry about.
As far as I know, those are opaque to software and practically prevent
us from replicating the MKTME hardware's encryption/decryption in software.

Unless we can get around that, I think it rules out being a drop-in
replacement for any software-driven encryption.

