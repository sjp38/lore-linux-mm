Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4100CC31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05E4F217F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:49:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Ikr1Z0Qm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05E4F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 898456B0006; Tue,  6 Aug 2019 21:49:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 848EC6B0007; Tue,  6 Aug 2019 21:49:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 737636B0008; Tue,  6 Aug 2019 21:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F27A6B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:49:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so57157979pfb.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:49:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Dn5BKjZ7JEBRqWgfa18GnM7OhUXy8yDZwMN3JIIxlGw=;
        b=CVE1uaVp2XmJyB0/yOQQBdQlqEmpYPYV4xUP3X4+d6wDpT0eoWVlXgrVlb5WMgiMg3
         EFSPs1QjAZha3JNya86RUBwd4w8xWPjRMWc9BKq+OXUqxv8N74RXrJZGFRttpjHuQyc9
         KTtMlXW0cwBVRVRdvhxzvRHvdWgF3VhKB1LwxB6x8HVIKp9+Y3GwBh5F7I0C8u5UGGla
         rfssJttuJEmZpT0l5Fs5+BdrKyEOSEqre2T/a7vL3tKNq2OQd69FTQmvb4bBInlO4sEi
         My+6JfX4NCqdKRYsFiyfjO8aNZe5YgNSWlSaYDaSNrD8vjnB/larTes+HHGk4vFeEPZL
         QgoQ==
X-Gm-Message-State: APjAAAULNON5oudPj4RsgWto2rpwzjuDgRVSF6vT4TA56ggntZqb/I4X
	1bMeTUqXaNikItdK+miK7EhD2qPc/F96VFEYDvN7z+NEWw3NGHVmFztb7r5BRRqhBV4zkyUe2rZ
	qYjE9rIQdBqThgme5gDi8kHzkkfe7P48APU+ZxwviAb41pNmmCs6Id2C0M4uJZ0jO4g==
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr5956213plq.218.1565142597877;
        Tue, 06 Aug 2019 18:49:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3zyowbV4DAqp6VJTuV+NVC1j3nDv81OnDspDKQDvUKhXDRBdzdvTTMYcqKaUptFfLb5Yw
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr5956180plq.218.1565142597107;
        Tue, 06 Aug 2019 18:49:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565142597; cv=none;
        d=google.com; s=arc-20160816;
        b=PP9QuhMZopF9Gd8snAXuvhPm3WWbTL++SHyADUs+s3wF/BGKKn16pdZ3xX7zQqCp35
         411iqmMGohB30cK4DceCWW8HRHUL4U29OxWITqjE2ZUI7+G+NsJAEwzTZBNB6NeS2tjK
         0AuZKl9NJxYmrphyfLNACBrzn/J+eq7nVjPgS+eS8ZAqMkXP1f8jktCdZhVkIyvcEFTd
         eL/2EW5X04JZ9M4OltnzPMlzPphkwcM9VaAkijVVFbvtycgfBuNFIZfKdlfYVJZvyH2h
         4+JHh33DZjNDrpnuxFgs61gTbWgAc6TeUzMjZ4K5yvPF62bPinUZ085+knjmq8ZglK8u
         /YiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Dn5BKjZ7JEBRqWgfa18GnM7OhUXy8yDZwMN3JIIxlGw=;
        b=p/cdf4jzehG+SyykZKIHoSB9ZVHn2UydbxGnWwgiwx6iy21reFSW6G9Rne/7PIaA9L
         1QwDy32vybIpsI4q9N/Icsw++1Q105IVhNfvCl/S8c+dsacnbOHjlRAv3FuYAjmJJj+H
         nhKjTLiC+IZpN+EREBGtVgGqUnWBdS9sD7oOSBfcFYtooQwrYsunSyEXyJDpxVtlMH/y
         DsmyLsZ/McOhtNAVhJ7CEfMNY9wp4RAXuu4l0PP41y8MdL8Kgbnzx4HOQDWbDUKDe2qn
         DrhaHkltBWS3UMnjk4UYdMZTz0ZsYu2pS9urltRGpKcsTQkQcTsmDnYsEUDWjxvX/yRz
         oYSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Ikr1Z0Qm;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n13si47411126pff.46.2019.08.06.18.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 18:49:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Ikr1Z0Qm;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4a2e4e0000>; Tue, 06 Aug 2019 18:50:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 06 Aug 2019 18:49:56 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 06 Aug 2019 18:49:56 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 7 Aug
 2019 01:49:55 +0000
Subject: Re: [PATCH v3 00/39] put_user_pages(): miscellaneous call sites
To: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-rpi-kernel@lists.infradead.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rds-devel@oss.oracle.com>, <sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <912eb2bd-4102-05c1-5571-c261617ad30b@nvidia.com>
Date: Tue, 6 Aug 2019 18:49:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565142606; bh=Dn5BKjZ7JEBRqWgfa18GnM7OhUXy8yDZwMN3JIIxlGw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Ikr1Z0QmiSe2izYZJH1uqOSC6icnToC0RNMEpxuB23chpfLBCzP3w/AieqLXvDTl5
	 WiAJO8Q4P7LqaICg9w9tXQj3/iPr6N76Dc9IbqJMajQoyinrqFfwgCWwW9UnKbczaL
	 GaLoALYFsFwWv8Sy+VSzQYK1xKYCINe6tMld2WSk4jzjh2UDaUm/4PS/zoETIOvAHY
	 Cv7DiogcZErrjHQstqfLwjbbIS2N4ESoffKtD4ugOTExuz4uGt5TgMT8y01S0TheeO
	 6qVWyeW6YYVimOARtYB9SW21zJJlrmRpt7UH+8pXV98uEPUBYTW77sxtUkB504xqpb
	 D9OLrQ7tTourQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 6:32 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> ...
> 
> John Hubbard (38):
>   mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
...
>  54 files changed, 191 insertions(+), 323 deletions(-)
> 
ahem, yes, apparently this is what happens if I add a few patches while editing
the cover letter... :) 

The subject line should read "00/41", and the list of files affected here is
therefore under-reported in this cover letter. However, the patch series itself is 
intact and ready for submission.

thanks,
-- 
John Hubbard
NVIDIA

