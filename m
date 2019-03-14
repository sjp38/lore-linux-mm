Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0C19C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 997822186A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jpTdb9Oc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 997822186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 346946B0003; Thu, 14 Mar 2019 16:37:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31E536B0005; Thu, 14 Mar 2019 16:37:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 234766B0006; Thu, 14 Mar 2019 16:37:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D79D16B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:37:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c15so7540365pfn.11
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=DgWsHZ14WtEAfPFOWW1z2Gf+RMCUzw4CBvC7Or4dKYg=;
        b=D5zWmDANr0vaYohAOOp03P9sMtWKL+xpjv7AdB662Sj93scjc2Xpdoz/y44BWEUqZi
         Qo7Ahr/wWlIXfgv6dP4ve4s27w/PkSAnggTUiuLQoPF6fYSP3MzNP4pW7o2v6pPz0OTA
         I0xpINdgtFT2Yh2tTiXueVV4ksxA4og4fD2EbphyCGhmwK7eKoV/P8u+ERIJR4qlLYTF
         1AgxuttKkC48m3GZJ2GYogpMGCQchDbsFmZO7GRSvaiHaaZJ/3+C/1vg8Yb9co9QtFQN
         WzTF383/zx6yQTGAPmi7h+25kcHbSsplRCA+Qv/Iz5up5zNMn0Rz93K40ee4J7y5qjqr
         Stlg==
X-Gm-Message-State: APjAAAVy+Di1+hd03nTQvRwlhh9vO7T9+B8pUlYcZ9UY/R8vA/9w2N1a
	6rt5/Sxc4I2ZA/CeLTMJ9/75o8T4gAD5d4u1B9H+zBhM3WXU1LSjfBVXnMsctbRzQdeC6l1GRCm
	eVGWwksBKW990jzEv7xU06gUW+AwdR2/3QgAhgehYSluswD446Gm75gLgKQg5eHCAjw==
X-Received: by 2002:aa7:86c6:: with SMTP id h6mr196423pfo.236.1552595828544;
        Thu, 14 Mar 2019 13:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/Y8PLJTisp7gBIkAUs8rNd0X0m7ecYimvALgKeJBjdyF2Q1UDQukq7wAgEjZJ8aO+orEJ
X-Received: by 2002:aa7:86c6:: with SMTP id h6mr196343pfo.236.1552595827415;
        Thu, 14 Mar 2019 13:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552595827; cv=none;
        d=google.com; s=arc-20160816;
        b=f8Hcz2O/acMlWsA5rZh1JXgvZhKt8tyr92e5QjFeSNhka1ulj5dHyZ7wsVvj/nY7eh
         X6bIXBKS28NhFWLzpfeFs2i6zUOvpBw+vE2rQiSNdAdpEbxge72Ls1Qiv0rAbM1U22GR
         3/MESc00WxlptviHmwaqH/R2pN075oYu92ttcz3Y4qYbfoX9wzJrmu+Zi8KzKog72JZy
         H5AK6tIcHqAkQx6uJuB+a4HFsdCaJk4raHoY7gv6ROCrjAmFiz8vKascHbyBZaDhPK75
         /OK9YMA10B8VJiNUCep23NSuqngld5UE2cIMVLXt62xsILdV5eX+QbpOBmsn9CYSZpyd
         Sy0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=DgWsHZ14WtEAfPFOWW1z2Gf+RMCUzw4CBvC7Or4dKYg=;
        b=ATVzW/SOH70ZFrqsLnFvpgDJod9HXZLOcPqwa/Bb/cixLJUPhyAQHHB7yJT3+Jsgb7
         22pnXOx/5WSLc5ewlJm87I0ZMFUyjpQr0AkQoP+VBXDU/v8zdRTiYAu2AI545IOOE2jl
         LFLF/GJLAMh4EmKYvJKyp95ykC623CxxtFuny/VivZH4IVln+odh8hpoKsLq/4lm03Za
         BMmck5Nh4fsIcKNKuvcFRtXz0GvYDmNTOl4Cca46Vzx3pWxyYPN+SYAn5tPbImtfgHuF
         sHXhlW26d943+a0yid+/W1OeFc/GISUAD7f/TYu1uoaCSziJVul4A3vrqYJu3jM5maWS
         GPiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jpTdb9Oc;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id r82si37492pfa.140.2019.03.14.13.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 13:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jpTdb9Oc;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c8abb740000>; Thu, 14 Mar 2019 13:37:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 14 Mar 2019 13:37:06 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 14 Mar 2019 13:37:06 -0700
Received: from ngvpn01-165-234.dyn.scz.us.nvidia.com (10.124.1.5) by
 HQMAIL101.nvidia.com (172.20.187.10) with Microsoft SMTP Server (TLS) id
 15.0.1473.3; Thu, 14 Mar 2019 20:37:06 +0000
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
To: William Kucharski <william.kucharski@oracle.com>, Jan Kara <jack@suse.cz>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Christopher Lameter <cl@linux.com>, Jerome
 Glisse <jglisse@redhat.com>, <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave
 Chinner <david@fromorbit.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Ira Weiny
	<ira.weiny@intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko
	<mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
 <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
 <20190314090345.GB16658@quack2.suse.cz> <20190314125718.GO20037@ziepe.ca>
 <20190314133038.GJ16658@quack2.suse.cz>
 <3AF66C8F-F4BC-4413-A01C-3C90A3C27B28@oracle.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <b3090734-7250-8ee6-8c15-661ad8177c11@nvidia.com>
Date: Thu, 14 Mar 2019 13:37:05 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <3AF66C8F-F4BC-4413-A01C-3C90A3C27B28@oracle.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552595828; bh=DgWsHZ14WtEAfPFOWW1z2Gf+RMCUzw4CBvC7Or4dKYg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=jpTdb9OciKuyWNtxC/d1OlI3Sd/Cq6Uwi8BEbaAuli5lMpDCFIslwzEtCyWQ5s9pP
	 yag3egLlxKb8JoNaDiA5B3fNolLhyACXMoRdr/CfWKdrXNxpa1KELCWTkXhllRS3o9
	 Lt9cApp1NapXxvVHOb6o60T2AYiZinJGfejLmjcPv3B6e36Z5tlCoo7ZbWLmC+NUHP
	 7PEcdjTc7yLcVPTB6YbHvX1zefygfGRi2pRuVIqA5zS5SAugjNEAnWO/Tdr3cprYNO
	 SPIs3ifMB1H8GsXj+PnE3iEybhHN0PyHvCO/gOJBJgw3mRMbFwMwfyPs1FOj56faEv
	 OFY3y4rNhAhLw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/14/19 1:25 PM, William Kucharski wrote:
> 
> 
>> On Mar 14, 2019, at 7:30 AM, Jan Kara <jack@suse.cz> wrote:
>>
>> Well I have some crash reports couple years old and they are not from QA
>> departments. So I'm pretty confident there are real users that use this in
>> production... and just reboot their machine in case it crashes.
> 
> Do you know what the use case in those crashes actually was?
> 
> I'm curious to know they were actually cases of say DMA from a video
> capture card or if the uses posited to date are simply theoretical.


It's not merely theoretical. In addition to Jan's bug reports, I've
personally investigated a bug that involved an GPU (acting basically as
an AI accelerator in this case) that was doing DMA to memory that turned
out to be file backed.

The backtrace for that is in the commit description.

As others have mentioned, this works well enough to lure people into
using it, but then fails when you load down a powerful system (and put
it under memory pressure).

I think that as systems get larger, and more highly threaded, we might
see more such failures--maybe even in the Direct IO case someday,
although so far that race window is so small that that one truly is
still theoretical (or, we just haven't been in communication with
anyone who hit it).

thanks,
-- 
John Hubbard
NVIDIA

> 
> It's always good to know who might be doing this and why if for no other
> reason than as something to keep in mind when designing future interfaces.
> 

