Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F49BC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:24:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35AFC2083D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:24:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Pcr54m33"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35AFC2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0DF06B0006; Tue, 19 Mar 2019 15:24:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBDF56B0007; Tue, 19 Mar 2019 15:24:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAD596B0008; Tue, 19 Mar 2019 15:24:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8C66B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:24:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j10so23806755pfn.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:24:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=B4FuCFgWwDXwO2PMosZVJcIQ7FyaY1g0iFVVlUcEXgc=;
        b=RFMxggW1EVEY9JWtmhZejgwJ5SRsP/D2+CKZUdt/RNVQPyfASszqcP5T7CVotwChfb
         ORwtLd7bfkIRjRy9B1CM/4Bu/UCkfVWqgGZB/N+hSYBxDRgGlVltjhieQzqbcuHMTGkB
         MbgFsTP+j22yi014zQVgm228vSUu5Szh7VHUaY6GlYNajqLYfC9SyJMBXvIu30zfx0KG
         SmYt52dGGVEeZUuq9yxjAYtzVyYIVjtbsIiPJ30d4XRvk7rJvvP0QL6W39rdqhboefri
         U/+N+/fE0jYarKjO8z1WR0Bf/O/T62Sli0BjZnsmLq9/7U4W2MwiiW+2pKmXkZg1+4ix
         zzRg==
X-Gm-Message-State: APjAAAVIgi+evm6y/MT7NMuaClTJTF97q+h5TBtts2AbBHfhA5GIG/tT
	fC74/bSXd82myeDs/O3L0NFWdgRLcuhXuRbwDlWADta0j6ehL/i4oNNKM0cJLIB7ka+36tGdbGw
	5sfHZTj0IzbLIUhEEa2fkBTDqPOZFR0mYCCWIHN4PA4Uap5kjoGCv6Qub96XSYiV8CQ==
X-Received: by 2002:a65:5c49:: with SMTP id v9mr3522793pgr.150.1553023450197;
        Tue, 19 Mar 2019 12:24:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUtNfllcAAY2XDaTA79SBKSyp2XQ2aKU3NwGUd/NXmkZhJdXq4GXnqvwbV++r9gO0Lxz6l
X-Received: by 2002:a65:5c49:: with SMTP id v9mr3522732pgr.150.1553023449405;
        Tue, 19 Mar 2019 12:24:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553023449; cv=none;
        d=google.com; s=arc-20160816;
        b=bAD1Ghsi6W/kMDVEWFQLdgwGdWQDR1WynvTSBNvi6rskmGOWgt+eIXOpAR/PqAeg82
         Wap/l6iQU+T1WTsN2dTnq3bLEIXiHDKVtqT1KP8//M5YoUdqp8sisccEgRRrBuktBjRJ
         vsjcwI8wjzajA4xkxhg4r9QUqY3qvyp9PNCXfPQ8MUE+6y2YnEdgv3o83ExbJp/eH/nN
         BBo+8+ht0aUhZOLuv+BXs0nrPeVVKO0Obg5TdMxcmt2tXjdJARCwdEPnDG6dPSNQJpJS
         dV1B5r72l/vD3+scr/K/o0OsVbMRHmOrUdVwn3Trxys+o1C5kytJZLcF7g/vUUlxew+U
         lLwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=B4FuCFgWwDXwO2PMosZVJcIQ7FyaY1g0iFVVlUcEXgc=;
        b=LoPIrI7P/lBDZW3Hou0JC0fd+DPg/iB8APeTzOHl1wwq0uAiO9WuIkelZI8nftbW0L
         WVAblik9kulAELsMKMLVVC99qRGvHXhNCvJRokkfq89AsQ7oo0KPx8LNZ0HBqU8Wyzgy
         aHGbkvTGS6389ikNDQGvNLE5CDW+8wM02t0gZcSb5OWhY6Ck/9E/Na5zO9RetqF6A4IB
         2PMs6KMcFKazZUMUHBUnvlVJ8o1eZiveZlomb1RfnPVpOHDegxRdKAEv3XkUEd+Bc67K
         0kqAHUHxPZke1QcH7G0VFT/ayR0C/V+yWpT3hGFy+CPw1o5vHEw98KkzWP8obQKeYBtK
         +Mew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Pcr54m33;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id k30si10751736pgb.587.2019.03.19.12.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:24:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Pcr54m33;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9141d60000>; Tue, 19 Mar 2019 12:24:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 19 Mar 2019 12:24:07 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 19 Mar 2019 12:24:07 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 19 Mar
 2019 19:24:07 +0000
Subject: Re: [PATCH v4 0/1] mm: introduce put_user_page*(), placeholder
 versions
To: Christopher Lameter <cl@linux.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave
 Chinner <david@fromorbit.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@email.amazonses.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <dc2499a6-4475-bea3-605a-7778ffcf76fc@nvidia.com>
Date: Tue, 19 Mar 2019 12:24:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@email.amazonses.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553023446; bh=B4FuCFgWwDXwO2PMosZVJcIQ7FyaY1g0iFVVlUcEXgc=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Pcr54m33hAY5+G1DxNuTgqEP0O0rC1NZ1dS7TpgNqEtN58Do8NCaXyvPcCY9D7Ebt
	 giBwXsvb/USudSDVE57EBMZsDeMVF20GRfInVh3nFfGKs4cmMUDvD0MH3OAbUqkRiS
	 v1u1ksXJ7k+IVC/26xMvrmJOgsdOnTwTp6GV1gSjOVck6l3uugy88GR2eMgLhN2Yj6
	 lfSp55JiL54qGodDwJN9Pfm+qXEloGPiLxh1PkVCKlvxvanF1zXUiXWs/nmt30QgP1
	 IyyNtuER93PF2uPGSF3iKcraGVN8PyKsCwlcqIdHZO0Kk6ilXKt/Gb1qAbBuG0YLjL
	 0ESRUpd2tDtPQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/19 11:12 AM, Christopher Lameter wrote:
> On Fri, 8 Mar 2019, john.hubbard@gmail.com wrote:
> 
>> We seem to have pretty solid consensus on the concept and details of the
>> put_user_pages() approach. Or at least, if we don't, someone please speak
>> up now. Christopher Lameter, especially, since you had some concerns
>> recently.
> 
> My concerns do not affect this patchset which just marks the get/put for
> the pagecache. The problem was that the description was making claims that
> were a bit misleading and seemed to prescribe a solution.
> 
> So lets get this merged. Whatever the solution will be, we will need this
> markup.
> 

Sounds good. Do you care to promote that thought into a formal ACK for me? :)


thanks,
-- 
John Hubbard
NVIDIA

