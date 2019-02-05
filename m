Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55982C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 21:53:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3439217F9
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 21:53:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="N59FiNSu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3439217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D0818E009F; Tue,  5 Feb 2019 16:53:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F958E009C; Tue,  5 Feb 2019 16:53:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 296228E009F; Tue,  5 Feb 2019 16:53:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF6CA8E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 16:53:53 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t3so2293836ybo.15
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 13:53:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Gc/ra3KjxqohEuxyjSuu/9457Ston9pava1kQCW1bEI=;
        b=EVtgJ7JV5YW/zIkuSmTTfxMcTvx3Mzz94ltu7tPFxuJ5az4QaXwAUnVcBExDJSn6rw
         0K5oSbtfSsHY2eDHrdxkCpLgaG2W9vonYkwD7OtunWJcpuwOIK1/Xx6KeY9wFGBppQLf
         EMnxwIKdZ5KRl3wiH2TE8fxddIhpItupHbp7GCGGJZBhyi/GI1i9g2idvbgjDtmQn0k0
         ascNVjzNVETnpGOSpXIaMbckaW0U6xrsUYPwxxWJ07W2Ks34p66Q/E3hMMvHbUn7oWbq
         mGiWnAizk6opxgalnfR5vm3ckT7jsGV1gSorc/Xmz9dEzhMcGIoNohf7JpfY7Ch47ooa
         kFNg==
X-Gm-Message-State: AHQUAubeJyVTOsY/MnSHtpDe7IVEeFL2rprW4zlyw+buZdQF++5BHobZ
	s118r8kD5DsCuz95cMUitkrn5W0usS4MdgoaOq0jXDuydaD+qI6E4MM5NAHDk4kWXnx1iehw5UX
	8zCHD2sL5CYIA4AXw0TAGzw5OPyzFco3zkeWQgBVm7//Ov5vTIe39pPd1E+omjl8Xdg==
X-Received: by 2002:a81:9ad8:: with SMTP id r207mr5891867ywg.72.1549403633625;
        Tue, 05 Feb 2019 13:53:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZWqZ8w0b2uQk94+2S55m9tDSZ0ZdFy6TEGYcaPDNSpEhy9CP9hrNQba6Qehh3o+faucOAO
X-Received: by 2002:a81:9ad8:: with SMTP id r207mr5891829ywg.72.1549403632798;
        Tue, 05 Feb 2019 13:53:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549403632; cv=none;
        d=google.com; s=arc-20160816;
        b=aoJI9pvNXauIslxUEUshuDOWOk8d0wYKo5FgrRx66n9AjzHgmKStWp6VDjuRrI5QsZ
         dO4xC6EcsuRlQPH+40mEmh8PthBuT9k+InlLfGb5dJvMxd57KWzYvE+6n4YQaehKVP1A
         zgALD8+iLd7gsSSdG6hEzxwd8Z/1k+aWY5q9JFrGKyFbKdRpYvIbfm8N/t1l73qaSGXs
         3tIcdCOr3rtBQuut9Crk47G2Vh9gUGgdRhIOojE6UVe5NFoJ1MfAtHBCXdfuu8bMnHyW
         i5YRlZ3fR6J4ug7g4h1CQ7khrxU21WnJKd9mE49xb3Fuvf9SgtGgoxQT20rxkIAPVdjs
         dNbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Gc/ra3KjxqohEuxyjSuu/9457Ston9pava1kQCW1bEI=;
        b=qsipj2AG6l52MTmMyjHMY6Vi3iLc7PovMCIoAyM9Mjw4zzknZ2XFr9Ty4UzkRUF7ph
         6rQqrYUGQKNcHH5DjDmkyClLrDcSSJ9nfsE10/G2amyW/KcONOzOWO2HE4X1gZwJr5ws
         XJlY/aKGjfFnZb5qTtVOsnu3WMJbhZqUZ4sfmnT6KS3L49rBnCokuy63dbpfgBzVMVTe
         qywROp/8mqN4V2ZKG1Ox6OhSNraRgrqPj1SSd/3j0FdtKwzXOyHpm5ZmeX4MCoR1qJzV
         sXw46jbzYjPFz1MQOaCf9nU09G365ODR5ETY8NKJJ7wtLZ5dQhF23afGEl4RzDP9YeyG
         uuOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N59FiNSu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id l145si2577920ywl.98.2019.02.05.13.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 13:53:52 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N59FiNSu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c5a05d00000>; Tue, 05 Feb 2019 13:53:20 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 05 Feb 2019 13:53:51 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 05 Feb 2019 13:53:51 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 5 Feb
 2019 21:53:51 +0000
Subject: Re: [PATCH 6/6] mm/gup: Documentation/vm/get_user_pages.rst,
 MAINTAINERS
To: Mike Rapoport <rppt@linux.ibm.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <20190204052135.25784-7-jhubbard@nvidia.com>
 <20190205164029.GA12942@rapoport-lnx>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <8655ea8a-4c43-c824-942b-bff06cf69a04@nvidia.com>
Date: Tue, 5 Feb 2019 13:53:50 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190205164029.GA12942@rapoport-lnx>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549403600; bh=Gc/ra3KjxqohEuxyjSuu/9457Ston9pava1kQCW1bEI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=N59FiNSusZgwWITszf58QJ5LATZGCLJ6mTy//vUGv9M0jLI0GYTt1KRQSJwz1plM6
	 VO3nP8n8vlMcYsEzeBcmkjYkXQl/1uvd+1JxYa8z1HKL06OwZ7F1HaJsPplJUVKlxH
	 fTFTItczRTD6PC3G2lNCD48OYMUs/O9fFk6HWF3Fc22lL07gVqnGjEkWeKpQiP/L13
	 vMhvReGxYxga2uyS4xs7qat5EKlBXoC9S+VF2+c3CigjzeZxEzy4lepbuHSrTq85sq
	 rOU535vEGOEB9qNUSQtojaxs+tQvG5niBOGoFgWmIaR0KdYalindJiojIKi1Ni4Qya
	 Nb6STwlNA/beQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/5/19 8:40 AM, Mike Rapoport wrote:
> Hi John,
>=20
> On Sun, Feb 03, 2019 at 09:21:35PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> 1. Added Documentation/vm/get_user_pages.rst
>>
>> 2. Added a GET_USER_PAGES entry in MAINTAINERS
>>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>> ---
>>  Documentation/vm/get_user_pages.rst | 197 ++++++++++++++++++++++++++++
>>  Documentation/vm/index.rst          |   1 +
>>  MAINTAINERS                         |  10 ++
>>  3 files changed, 208 insertions(+)
>>  create mode 100644 Documentation/vm/get_user_pages.rst
>>
>> diff --git a/Documentation/vm/get_user_pages.rst b/Documentation/vm/get_=
user_pages.rst
>> new file mode 100644
>> index 000000000000..8598f20afb09
>> --- /dev/null
>> +++ b/Documentation/vm/get_user_pages.rst
>=20
> It's great to see docs coming alone with the patches! :)
>=20
> Yet, I'm a bit confused. The documentation here mostly describes the
> existing problems that this patchset aims to solve, but the text here doe=
s
> not describe the proposed solution.
>=20

Yes, that's true. I'll take another pass at it with that in mind.

thanks,
--=20
John Hubbard
NVIDIA

