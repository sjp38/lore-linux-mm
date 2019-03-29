Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F482C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 22:23:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E259218A2
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 22:23:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="DqmrzG0c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E259218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC8F06B0007; Fri, 29 Mar 2019 18:23:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9E816B0008; Fri, 29 Mar 2019 18:23:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8F706B000A; Fri, 29 Mar 2019 18:23:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 944326B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 18:23:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d128so2567648pgc.8
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 15:23:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=U3+Cg2KmhdLf9sXflfQLb4WPspNVvCbzVKQ3Qb8V0J0=;
        b=KsZ+o7aDymZGMr/f2dQerR9k+4VIJLkvpUu4HyKFOad/pbNhixLluJH4SZ1Y8XKMC8
         HXqsXwu/VtV9gjY5BvzbGl4rCaGHI9xIwpMReYFoR3FXGQCwFl/OjNQ6sy49jhoQUbKw
         iDeHhX1KLYjIJ+hiZGf0qu+Y20p8unEtgR7uLZ4IANxtJO1XDJVgp44C3s+cpmhdWa5l
         lyMkdhT+zwihfdjYJKFLyLpFtsgPaA/JBfmliWIcka7f8sXazcgkAFtjm32ZZPvzUTAO
         27KQI0tQnrJmQDxUy1+MIl5EUvNCcDhaS3a+6KNL6uFoCn5/1dmhR3Q9TXbdx+Wc8ayV
         7BMA==
X-Gm-Message-State: APjAAAVDFHwuc8RViiP3zCSkcGUf/OohpGRJ5TJ1HL3/gLDplbqW4H0m
	3q/cAbVRFT6Y1L7mPC8gyCRWPLUbA0xMKbYrFeFB+iSvMpPhwZQiv770FcHixbqGRcmx0S9lJFG
	WdZVgR6XRMuEdzqXc6IpInO/gUR8YzldcHcpnLjBlhYoqYoM/OVFkibNnntkCKnrpDg==
X-Received: by 2002:a62:e50a:: with SMTP id n10mr26568418pff.55.1553898183291;
        Fri, 29 Mar 2019 15:23:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvd6itNYTKL4mU3A9cnBFnxYvVvX45Qc05jRS2+o3r2cOCNR6ZZutsN0YbGdJLSblY1+OI
X-Received: by 2002:a62:e50a:: with SMTP id n10mr26568373pff.55.1553898182615;
        Fri, 29 Mar 2019 15:23:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553898182; cv=none;
        d=google.com; s=arc-20160816;
        b=VROygC42hY9gfqyIXGa7ZE6v76uGMaaxoIMOK/ZThbKcqToeu+tnfYllLEKWaL/TcB
         HpI/y4DkJYoJ03+4Jws5exqfESKBpr4bs7tZRHgVxWOIRqBW7Y32LH0sfkvrWDYd+1aw
         r+CBZ88y/oQgs9x0ZHm+2EQlFoysiDwnxZB6pb1J05LMFF/DpG8oolCog1Us7i153Nvh
         fHmxozdAiXl2Sn38QsNJSnK+kzyKLGKjXOZA3fynm5iGVEhb36kD2n3rBa8Du+jFamti
         WuOpIGjBWRP5Jg5phTNGzJh7uvF2nlFTUGmv8pXwn7vo2Zi9wrS1bwpEVoDF+eOVTW5i
         qcYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=U3+Cg2KmhdLf9sXflfQLb4WPspNVvCbzVKQ3Qb8V0J0=;
        b=07kIWgmRMJSajUGAnhvN5y0gFDgzAVZCyhxrfGFPkMZb5NeI0wcA1XVcw+X/IE0gSU
         DiLwFaGGcg/CmS1bjILX2Tag3uKEuxZzSTW53clCYTUQdpep2X/ox3mCbkKfaM2sy892
         grHM999WkZIf5pZ+33CPOa1X9Hb7SSeWcXhztwHCJFsQiPtoVEHZ/VY4wLlCCVAPoBbs
         CLqC0seKC/LKKD8WQ8+Uw9XTjT5g3PCUKAVQmVhDfH00wgsJQRXtb4ak3TofDt3bnRka
         7B12w55ltJiWU1R8ihCkOZPF/PGyPP+MHL4dPgMaurL5NWAOkMirLB8cJ2uCKGOUYXbQ
         mACQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=DqmrzG0c;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j1si2778803pfe.189.2019.03.29.15.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 15:23:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=DqmrzG0c;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9e9abe0000>; Fri, 29 Mar 2019 15:22:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 29 Mar 2019 15:23:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 29 Mar 2019 15:23:02 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 22:23:01 +0000
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>, <akpm@linux-foundation.org>
CC: <mhocko@suse.com>, <david@redhat.com>, <dan.j.williams@intel.com>,
	<Jonathan.Cameron@huawei.com>, <anshuman.khandual@arm.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190328134320.13232-1-osalvador@suse.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <91cfdf41-ef43-1f18-36b8-806e246538a0@nvidia.com>
Date: Fri, 29 Mar 2019 15:23:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328134320.13232-1-osalvador@suse.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553898175; bh=U3+Cg2KmhdLf9sXflfQLb4WPspNVvCbzVKQ3Qb8V0J0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=DqmrzG0cHnR4jvd40Vi6xsFts3l7d2KYsnimjZYTvcLonF8Dwkal/DGxDorvxqV80
	 bOczMwanRQNhGhhQ3KWbVTMGF0Fyi/tSJmENmF9e/RoF/U955vc8itii5RSE42jrwX
	 qQn1mo67jXESqS4+hTPheb9+r3hz3dUlEOO4zDJakX3XIzx8L8++fY/6zqsW8gGmFJ
	 Xg19unTShmntzSLOt76pblb3NHjXzqjFimSsgAC+aM5i7tZew5VgZEod72QFL1C4rf
	 tbQicist8p0rL5/Pwus6B0YFRNr5oXgtPY5SvLGbhaPubf+cH6dSgsfnoUjUTEor2X
	 VS1HH/Ww56sgA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 6:43 AM, Oscar Salvador wrote:
> Hi,
> 
> since last two RFCs were almost unnoticed (thanks David for the feedback),
> I decided to re-work some parts to make it more simple and give it a more
> testing, and drop the RFC, to see if it gets more attention.
> I also added David's feedback, so now all users of add_memory/__add_memory/
> add_memory_resource can specify whether they want to use this feature or not.
> I also fixed some compilation issues when CONFIG_SPARSEMEM_VMEMMAP is not set.
> 

Hi Oscar, say, what tree and/or commit does this series apply to? I'm having some
trouble finding the right place. Sorry for the easy question, I did try quite
a few trees already...

thanks,
-- 
John Hubbard
NVIDIA

