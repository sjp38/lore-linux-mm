Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C061C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 06:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 034142145D
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 06:16:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="a7kE9Glh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 034142145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CBFF6B0003; Tue, 16 Jul 2019 02:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67C726B0005; Tue, 16 Jul 2019 02:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56ABA6B0006; Tue, 16 Jul 2019 02:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36B016B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 02:16:03 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id b22so16135892yba.4
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 23:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=8MZblR3/48+uz1YHKzCNtQlnLBqU554eXVq9V58XHgE=;
        b=dvNlynmDRAxAgPg3Zm3yRO+4Vqf3W46ENmyY08vVwQXPUh9EtivskgonLixzcfmHRs
         gJ3KFnd6BdUgTCdkCijhZnor0HSzmCvAoSS70ZhNbBo31VXipX3aYbn/TMrmRBfdRiue
         EW5gONoxqSk2TyGwesSN6FW7EFOgyTKhCiRaFs4qTTfXEFK9piwfp+CBauVQLhSleDSS
         H+yr5Spxw9aj+wG1+Hfg6J8Gosqp5iIwE9JSF7gSV87d8PyPkDz8kpSxafSl5lbzFnRd
         vxxRRvJKJwVJR9MNC2alLndBW6GAahqBEUAtOc2zeLZDCn1RB0FvB9oH3ojT+/HIqG+3
         4UBw==
X-Gm-Message-State: APjAAAVsX/KBEJOoLoqt0T8PXrzKzZQr6rdLHuMp477Pncfwxre15Veq
	7nvdfAJkBZagWDzSbUkCOD7rMNvoeZZ4X0He9tLsFpfH4E2Py1uvw1hKB/Zd60DuWUU1KgFK70x
	D2vblFuOmL1ls45yD7qbS86sTZDf0K2IwjeFxgZgesJiCcVamlPkeeIyLLED9GyeB9Q==
X-Received: by 2002:a25:a093:: with SMTP id y19mr17529617ybh.363.1563257762965;
        Mon, 15 Jul 2019 23:16:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHKMhFU/8edewvNytiCL0VIbTH2RmJcsfxqQY1mf11pdqLhV3Jm5+TdJj39g8WkB9NFI8j
X-Received: by 2002:a25:a093:: with SMTP id y19mr17529586ybh.363.1563257762153;
        Mon, 15 Jul 2019 23:16:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563257762; cv=none;
        d=google.com; s=arc-20160816;
        b=N9lh0r7WFnVoRKUBYvO8SOLYJiD0rcoBzwZ5rfGpRH/zW+Rso0D6U1ohXQ7tXsElR1
         1HJ3ZsbAxoSjiz7UNbyZLDdxofStPQHQikwG/xXZlr5i+7Roh+boyqGroY4V5Im7JWSR
         wgBLv+pVXvEnWIQN88/I/Uy8gVncTM4HtM28vAa9Ch0DWnrE6a20IvL5QSfSHv6XNaEJ
         N91QXUod39SCcJJB7A5t8QwcnIrH51qCSNt9pFqMn11sWdu8Yyjo/v7lAmd3NwyM5Jnk
         3z564gNOCgENtkEUC2DWGIC667dCHzWLOqF/I8kaD7UBmTHz03UVpOWroCSTFbclBCiK
         T1pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=8MZblR3/48+uz1YHKzCNtQlnLBqU554eXVq9V58XHgE=;
        b=w+UjW+v8fl993aDkrVYM8Myhg9Z+F5mRfnhnPE4Jq2zNPJ9sYjbZAOCEjjCWDEnk1K
         e3lsw/avwxwzt/Hu27SYc8Y2ssIfglZTcLxcsKePdTnhOwx/usfQ0awSEhj/MF7D3t3E
         SUYyMrFxeluC86ljqaXEz6ac6S1LYlbTOqcfln0KG3q0yiXVm6pBrFsLSql0YTimTHFz
         zN5PvcpuVH/s/pR9y5imMLzkZ+BnxufKQ8aXm1xDu+W++i/q44jTL9agboX71Qn861fm
         lZ3nrI7k3ragh6n3zUAB3NcPozotUz2FI/BGBkslObVV/ApJJ3DjtRpcWMDBjXdh1lJo
         iekQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=a7kE9Glh;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id z9si7835866ybp.189.2019.07.15.23.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 23:16:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=a7kE9Glh;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2d6b9f0000>; Mon, 15 Jul 2019 23:16:01 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 15 Jul 2019 23:16:01 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 15 Jul 2019 23:16:01 -0700
Received: from [10.2.169.122] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 16 Jul
 2019 06:15:58 +0000
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
To: Ralph Campbell <rcampbell@nvidia.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>,
	Jason Gunthorpe <jgg@mellanox.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
 <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
 <05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
 <20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
 <0ee5166a-26cd-a504-b9db-cffd082ecd38@nvidia.com>
 <8dd86951-f8b0-75c2-d738-5080343e5dc5@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <6a52c2a0-8d27-2ce4-e797-7cae653df21a@nvidia.com>
Date: Mon, 15 Jul 2019 23:14:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <8dd86951-f8b0-75c2-d738-5080343e5dc5@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563257761; bh=8MZblR3/48+uz1YHKzCNtQlnLBqU554eXVq9V58XHgE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=a7kE9Glh+Srd5gt7zNr5hvcBKcP8f8HM7VTd3Zm2N7JHOi4SRpFRhOLKiPpJ7Pj0F
	 toRcVRYjMUGFw9B95uoF649yqD4D5ikilFcK/UIXrBFww3EtAWNYryNjylY7ksmXEX
	 GmPz/AhcOD+e+ExtkQ9f9tLA5a5hGqYWRiZlYDDLs8yQ4f0XlsSkENRC6V2NtOg7PG
	 flcxZ6nOnKzU8ibTfc3dS0VKJp9r8mBMGpqIcUo2XChgFsi+9Jdnl6His+t235Zu1E
	 fxzOi8uUXsKWCewjujYNSTEdC4lbeIR6e2fmjNLnbJiwWHQvhUg291OgCkDkVnDe0k
	 hFwTV9DVXBqjQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/15/19 5:38 PM, Ralph Campbell wrote:
> On 7/15/19 4:34 PM, John Hubbard wrote:
>> On 7/15/19 3:00 PM, Andrew Morton wrote:
>>> On Tue, 9 Jul 2019 18:24:57 -0700 Ralph Campbell <rcampbell@nvidia.com>=
 wrote:
>>>
>>> =C2=A0 mm/rmap.c |=C2=A0=C2=A0=C2=A0 1 +
>>> =C2=A0 1 file changed, 1 insertion(+)
>>>
>>> --- a/mm/rmap.c~mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one
>>> +++ a/mm/rmap.c
>>> @@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 * No need to invalidate here it will synchronize on
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 * against the special swap migration pte.
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 */
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sub=
page =3D page;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 goto discard;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>
>> Hi Ralph and everyone,
>>
>> While the above prevents a crash, I'm concerned that it is still not
>> an accurate fix. This fix leads to repeatedly removing the rmap, against=
 the
>> same struct page, which is odd, and also doesn't directly address the
>> root cause, which I understand to be: this routine can't handle migratin=
g
>> the zero page properly--over and back, anyway. (We should also mention m=
ore
>> about how this is triggered, in the commit description.)
>>
>> I'll take a closer look at possible fixes (I have to step out for a bit)=
 soon,
>> but any more experienced help is also appreciated here.
>>
>> thanks,
>=20
> I'm not surprised at the confusion. It took me quite awhile to understand=
 how=20
> migrate_vma() works with ZONE_DEVICE private memory.
> The big point to be aware of is that when migrating a page to
> device private memory, the source page's page->mapping pointer
> is copied to the ZONE_DEVICE struct page and the page_mapcount()
> is increased. So, the kernel sees the page as being "mapped"
> but the page table entry as being is_swap_pte() so the CPU will fault
> if it tries to access the mapped address.

Thanks for humoring me here...

The part about the source page's page->mapping pointer being *copied*
to the ZONE_DEVICE struct page is particularly interesting, and belongs
maybe even in a comment (if not already there). Definitely at least in
the commit description, for now.

> So yes, the source anon page is unmapped, DMA'ed to the device,
> and then mapped again. Then on a CPU fault, the zone device page
> is unmapped, DMA'ed to system memory, and mapped again.
> The rmap_walk() is used to clear the temporary migration pte so
> that is another important detail of how migrate_vma() works.
> At the moment, only single anon private pages can migrate to
> device private memory so there are no subpages and setting it to "page"
> should be correct for now. I'm looking at supporting migration of
> transparent huge pages but that is a work in progress.

Well here, I worry, because subpage !=3D tail page, right? subpage is a
strange variable name, and here it is used to record the page that
corresponds to *each* mapping that is found during the reverse page
mapping walk.

And that makes me suspect that if there were more than one of these
found (which is unlikely, given the light testing that we have available
so far, I realize), then there could possibly be a problem with the fix,
yes?

> Let me know how much of all that you think should be in the change log.
> Getting an Acked-by from Jerome would be nice too.
>=20
> I see Christoph Hellwig got confused by this too [1].

Yeah, him and me both. :)

> I have a patch to clear page->mapping when freeing ZONE_DEVICE private
> struct pages which I'll send out soon.
> I'll probably also add some comments to struct page to include the
> above info and maybe remove the _zd_pad_1 field.
>=20
> [1] 740d6310ed4cd5c78e63 ("mm: don't clear ->mapping in hmm_devmem_free")
>=20

That's  b7a523109fb5c9d2d6dd3ffc1fa38a4f48c6f842 in linux.git, now.

thanks,
--=20
John Hubbard
NVIDIA

