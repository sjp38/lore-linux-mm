Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76384C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F1112075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:28:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="QIBBpSa/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F1112075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06836B0003; Thu, 28 Mar 2019 19:28:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB5476B0007; Thu, 28 Mar 2019 19:28:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A69A6B0008; Thu, 28 Mar 2019 19:28:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60ABC6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:28:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so351311plq.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:28:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=aerzQFuHUaWHNBU0Ye3GXuNAqGnCivYkdN0hPFwBFaQ=;
        b=VXnDMTypIrce/M2I+wbE5Q7mMqvs7i10qp0DQNwMU3cx+yoXlHg55eD/YSC4yAvLSE
         20ya4YktvBWlLDC4Eyz0eo48GFOvnnfeyFmThIJvWcjrd74nDEFYERsBif9O7BncMXfG
         Q4h8VN2ZP3tiKIG+RHO0BWy41nDwiLgGk6FIt6Rd1yg15FnumdE5XjyviQTOQbGc2JrC
         zS3uZMfkElQCLb0RJqOCaRT1+qdJP3ssFnDlncKsESTJtC/iBWAvh2UZCwrA0kNROepk
         a0H36dnMbGTqmPgbs9nmOslwobdl9CCqL4R1E7djoshbW4xwDlEpeKrDJxrAKY0OwvFG
         JijQ==
X-Gm-Message-State: APjAAAWw/czXQ+0yq6EYfOTNzdxAFfGELKlA47AVSP5Vytjock9ZHHGZ
	IoAATmqDyL80MO3JzR7TLhs9qaGLQGODz7LVJRYbpacd0yLnyj6bBcA26SE85pKqDk2viVRE0si
	82fppUhCr/5QDpV4Lc5fG+pWkzw89rld1ZrJCbCXP6M9x1jImStUWjUJhuV7F55egzA==
X-Received: by 2002:a63:88c3:: with SMTP id l186mr43087249pgd.148.1553815729964;
        Thu, 28 Mar 2019 16:28:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjvNvDrSNtqIOtXQjghAueUFIavberMAsk+/v7UYXl0YC9vGM12OOtdI/EUxSPjOPfTpWc
X-Received: by 2002:a63:88c3:: with SMTP id l186mr43087210pgd.148.1553815729174;
        Thu, 28 Mar 2019 16:28:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553815729; cv=none;
        d=google.com; s=arc-20160816;
        b=Rv7hqCO4Ey/znVcBy5nBcwL3Grx7XdcM+MKsTys5OUMHgESbbVdhzAlJKS2XwPP6C6
         cWX/xElaesEQ9PVJ55M53nkjRHHR9mUtTCMS6vQwEu1Bvi/gXONME9x8Rjba4Zc1daqW
         +QcS+PNdVO2XHSKJ01A4NLrIULDyGSM//2Nsv1THboz+XcTzdUNP7pb+1GUnzumNlprl
         tV4pwQqWjcOEy+LY0B3anoiFdyPgzs31x2NdNUAgwI4QgwzjBhbrpvk81PWSv9K6XqxN
         uJryEf7JCdnQEhE4bRi5GaATSDCcBOOD/A63iK5G+WnNDnh/XsEoglmBfebk0pBUVvU3
         jqpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=aerzQFuHUaWHNBU0Ye3GXuNAqGnCivYkdN0hPFwBFaQ=;
        b=Fb9NiHsgyiNKQj9aphC146ZkRtkhbnfCPCRpDC7mip/u0YaBy/xpVeh+78vtkuQwtt
         3RdSSU9GrXm3onJLNVXTpnRYki4a0sOOzZoagT0hUZRgiG3HiJlYUAHmVV2QfikRdnA3
         6qQLwGjXiZKeqDmf7YBJrkBqEzc0IOWRHftSgKYjH5vxL+aJjH/UV+cPjsSyQNvQS04V
         woNAf3mIFZn1xTCDETexIkYTIKBMT/Ibbs5HTsUMBJ9PL6mo5UTm1wjbGOn0PSu1J9ZN
         OcyKBX2xU1H+HGjbryLRIUjbltqjwdZuEkER7d6mbBeoRIFW3QeNMWs7OZ7LZTLtCLeu
         Od0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="QIBBpSa/";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j25si405737pgb.531.2019.03.28.16.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:28:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="QIBBpSa/";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d58aa0000>; Thu, 28 Mar 2019 16:28:42 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 16:28:48 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 16:28:48 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 23:28:48 +0000
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
Date: Thu, 28 Mar 2019 16:28:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328232125.GJ13560@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553815722; bh=aerzQFuHUaWHNBU0Ye3GXuNAqGnCivYkdN0hPFwBFaQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=QIBBpSa/0/+y1QUBtjk0WMrKjg0++8/QnMIUZMUo6mQIDaJ6smESM5I5ch/C4bcKH
	 4qBcxVfdS8voLks1eLkyS8TcNyeFqhXmOP1FgKahwVVm8larMAMA6RH02wWOfyVq9J
	 lb9wsrBLo3l3112rq4ho3BpwR4pUvb4Jf1cywmBJUUwnTvqU/bwEJVygR/6U2sUTaW
	 M0hlATT/xTlyMZCNWPLSbJFE94GlabPa4Deblhci3btR4/nXfUHfwwTFbsjxLmEMQr
	 B2dtneO+A6FhGaLbya++9CWXoFGtV+63pZc7WbHQwl1qD2Rcu3HEduPOexvheT0mPI
	 4NORuQZ4Ogu0g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 4:21 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
>> On 3/28/19 3:31 PM, Jerome Glisse wrote:
>>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
>>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
>>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
[...]
>> Hi Jerome,
>>
>> I think you're talking about flags, but I'm talking about the mask. The=
=20
>> above link doesn't appear to use the pfn_flags_mask, and the default_fla=
gs=20
>> that it uses are still in the same lower 3 bits:
>>
>> +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] =3D {
>> +	ODP_READ_BIT,	/* HMM_PFN_VALID */
>> +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
>> +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
>> +};
>>
>> So I still don't see why we need the flexibility of a full 0xFFFFFFFFFFF=
FFFFF
>> mask, that is *also* runtime changeable.=20
>=20
> So the pfn array is using a device driver specific format and we have
> no idea nor do we need to know where the valid, write, ... bit are in
> that format. Those bits can be in the top 60 bits like 63, 62, 61, ...
> we do not care. They are device with bit at the top and for those you
> need a mask that allows you to mask out those bits or not depending on
> what the user want to do.
>=20
> The mask here is against an _unknown_ (from HMM POV) format. So we can
> not presume where the bits will be and thus we can not presume what a
> proper mask is.
>=20
> So that's why a full unsigned long mask is use here.
>=20
> Maybe an example will help let say the device flag are:
>     VALID (1 << 63)
>     WRITE (1 << 62)
>=20
> Now let say that device wants to fault with at least read a range
> it does set:
>     range->default_flags =3D (1 << 63)
>     range->pfn_flags_mask =3D 0;
>=20
> This will fill fault all page in the range with at least read
> permission.
>=20
> Now let say it wants to do the same except for one page in the range
> for which its want to have write. Now driver set:
>     range->default_flags =3D (1 << 63);
>     range->pfn_flags_mask =3D (1 << 62);
>     range->pfns[index_of_write] =3D (1 << 62);
>=20
> With this HMM will fault in all page with at least read (ie valid)
> and for the address: range->start + index_of_write << PAGE_SHIFT it
> will fault with write permission ie if the CPU pte does not have
> write permission set then handle_mm_fault() will be call asking for
> write permission.
>=20
>=20
> Note that in the above HMM will populate the pfns array with write
> permission for any entry that have write permission within the CPU
> pte ie the default_flags and pfn_flags_mask is only the minimun
> requirement but HMM always returns all the flag that are set in the
> CPU pte.
>=20
>=20
> Now let say you are an "old" driver like nouveau upstream, then it
> means that you are setting each individual entry within range->pfns
> with the exact flags you want for each address hence here what you
> want is:
>     range->default_flags =3D 0;
>     range->pfn_flags_mask =3D -1UL;
>=20
> So that what we do is (for each entry):
>     (range->pfns[index] & range->pfn_flags_mask) | range->default_flags
> and we end up with the flags that were set by the driver for each of
> the individual range->pfns entries.
>=20
>=20
> Does this help ?
>=20

Yes, the key point for me was that this is an entirely device driver specif=
ic
format. OK. But then we have HMM setting it. So a comment to the effect tha=
t
this is device-specific might be nice, but I'll leave that up to you whethe=
r
it is useful.

Either way, you can add:

	Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

