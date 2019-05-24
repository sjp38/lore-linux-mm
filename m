Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 915AEC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:26:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4401520863
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:26:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ymf3dbVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4401520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCC986B000A; Fri, 24 May 2019 10:26:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7D096B000C; Fri, 24 May 2019 10:26:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C45676B000D; Fri, 24 May 2019 10:26:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4C136B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:26:05 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id v15so8295878ybe.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 07:26:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OJhMCvW2kp8bOu0Aj9xHYqe11sQBRT1hGdecAvzomjs=;
        b=T7FxwcJ5Gq/S+C9QuvELagOVxrisReLaGJh072fk1wfapTW07oOqf2j1Ulq2J/89uT
         0bxvmmbn5GUnZmI9ZfNFaRN6vfSHegI0KDhHqwjODyMhnUlOqGtiNk0pCTurAYsDWTDh
         Wx1ELBs0GnPKS+tDrcPZXCXEuBKfJ/O+Jqj/LAUKjzJV8AgewWVB5nbFIr6zG/qdO7IS
         S8a1EHSOIzJjgWcstGcGi5Eq1ZFoinf38OsZ0kF1M8eqlW5CTMS9guoAbAipkVSx4Sup
         W0VticBycTXdQpob95cdKpock8uSobKU37MCyIL3G2wsDN9grYqNZdbK4AMdqmso2jNN
         5DnQ==
X-Gm-Message-State: APjAAAWX9OY83+CkLnhuAWGS5IFRSEZCSp64JzvRvdGVZGWj/PPkn8fV
	XrZerMmoSO01RNG/p6/Hr8JjI3cR1u2DcbNb3uheigg5Jww0DVCGjn9S84Anin8ClByM+ltDKUZ
	YC4jeDJvClekHp2SWf83wCXrPZmZxpToivAIKdz+d2h1Kzdz7kXkKjIK5SwLc6YOHIg==
X-Received: by 2002:a81:5806:: with SMTP id m6mr46250102ywb.102.1558707965239;
        Fri, 24 May 2019 07:26:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzyYCL/aMl3Xg9FmXTQmOG93wO0GDBb9pDsX5n2iWGgGznDaGRm797yno3I8g9AbuDVQuu
X-Received: by 2002:a81:5806:: with SMTP id m6mr46250036ywb.102.1558707964069;
        Fri, 24 May 2019 07:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558707964; cv=none;
        d=google.com; s=arc-20160816;
        b=I0fPx0JRMxwVZUUYwqekW2UHHbwShdt+SXC5oGPiNwT3kMmEOUpf0laDVSN47cuRks
         brGzLhENUgFIpqecn+tEWq5WEIFbd1aJHeKEHdFSt/UDLP5utXgPNcBBmH4nvbebkhee
         H6T6IMxnXt8YKnub074BCVj8OAMvAfpiP9uIPFNrSt6/Ks5p0mcWiL8//xehNUKtZ1vq
         hIBulyTbfEzvHxUnAbWkz6sIeeRH0dl6B6nnPWNuULLbseugxxSQ+K5DPJJYGTBa7B+L
         /9zIpVipsQ8Ybxhq9cBuM5fA8+MezATN5BU4fzj6vjmiJk7qq+gF3JCJ5Fgvctaoo9Vp
         unzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=OJhMCvW2kp8bOu0Aj9xHYqe11sQBRT1hGdecAvzomjs=;
        b=weLs32OkvAu6Z1iXr2tiCIscyhEh6/Yi5Bp+ExUPYlw0khDK9LEKuaUai77Fyh6fiY
         yZDhbZ9ZYbEqdS1W+SPMgKSltmNaljBLXYgV6rwB19tDI2pmbU71wiUU2/kq9DKTw4EX
         JPoCmZoylWsEtGw7kKdH1Z+LqMId+PeSx49nSmRrRDnX7iLOSGCMr9l++DL+NvN4Fqm6
         mAEINMV9djPpf/4x8w0Lf+Oi66PmkdlcukyJkC86+//yfbJyO7v7aV2LsTNzLYLaFKYH
         iyTKsnP17RaptP7b/yUdeRgQuH/m7BTUbiAftd4Ikyhp7tm6XKQYzaPgD7uC2iIBZ8kj
         LOPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ymf3dbVV;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j185si958771ywf.80.2019.05.24.07.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 07:26:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ymf3dbVV;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4OE8bjv170883;
	Fri, 24 May 2019 14:25:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=OJhMCvW2kp8bOu0Aj9xHYqe11sQBRT1hGdecAvzomjs=;
 b=Ymf3dbVVSk/usGv/LWyN8I3YdUizbsu/NiEI/I45nxcgQtjyJP24xaCjavUVvrMsM2O6
 yEP3RCJrHDJF5nnRuz4iw9XN7owpeQqjW6DAcNsFAO79ZSNGKG1WbLKp1rBvO3sJA5Dr
 +fBrLpy1lQu6d91Ea6iJuVHlzyPxZBxwhYSSJ8nFZjA8cuYTCNKl6zTycOpBAIsWwpl+
 g1GFUsvpVXx8ufMZ3zfNa2womboo5KLhh4oJCIIc9jToeIVyIP/Opv9xH3hpRByfsilL
 vIwIH66z4yFn+YxGOtQgVRvyfsmkvl77RxspM3YzOuGKjPJ5b3GlOA6tg3BSpgx4LR4x mw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2smsk5sewf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 24 May 2019 14:25:48 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4OEPft9008165;
	Fri, 24 May 2019 14:25:48 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2smsgtwpfx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 24 May 2019 14:25:47 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4OEPkT8002811;
	Fri, 24 May 2019 14:25:46 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 24 May 2019 14:25:45 +0000
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kees Cook <keescook@chromium.org>, Evgenii Stepanov <eugenis@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling
 <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Elliott Hughes <enh@google.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
 <20190524101139.36yre4af22bkvatx@mbp>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
Date: Fri, 24 May 2019 08:25:42 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190524101139.36yre4af22bkvatx@mbp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9266 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905240096
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9266 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905240096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/24/19 4:11 AM, Catalin Marinas wrote:
> On Thu, May 23, 2019 at 03:49:05PM -0600, Khalid Aziz wrote:
>> On 5/23/19 2:11 PM, Catalin Marinas wrote:
>>> On Thu, May 23, 2019 at 11:51:40AM -0600, Khalid Aziz wrote:
>>>> On 5/21/19 6:04 PM, Kees Cook wrote:
>>>>> As an aside: I think Sparc ADI support in Linux actually side-stepp=
ed
>>>>> this[1] (i.e. chose "solution 1"): "All addresses passed to kernel =
must
>>>>> be non-ADI tagged addresses." (And sadly, "Kernel does not enable A=
DI
>>>>> for kernel code.") I think this was a mistake we should not repeat =
for
>>>>> arm64 (we do seem to be at least in agreement about this, I think).=

>>>>>
>>>>> [1] https://lore.kernel.org/patchwork/patch/654481/
>>>>
>>>> That is a very early version of the sparc ADI patch. Support for tag=
ged
>>>> addresses in syscalls was added in later versions and is in the patc=
h
>>>> that is in the kernel.
>>>
>>> I tried to figure out but I'm not familiar with the sparc port. How d=
id
>>> you solve the tagged address going into various syscall implementatio=
ns
>>> in the kernel (e.g. sys_write)? Is the tag removed on kernel entry or=
 it
>>> ends up deeper in the core code?
>>
>> Another spot I should point out in ADI patch - Tags are not stored in
>> VMAs and IOMMU does not support ADI tags on M7. ADI tags are stripped
>> before userspace addresses are passed to IOMMU in the following snippe=
t
>> from the patch:
>>
>> diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
>> index 5335ba3c850e..357b6047653a 100644
>> --- a/arch/sparc/mm/gup.c
>> +++ b/arch/sparc/mm/gup.c
>> @@ -201,6 +202,24 @@ int __get_user_pages_fast(unsigned long start, in=
t
>> nr_pages
>> , int write,
>>         pgd_t *pgdp;
>>         int nr =3D 0;
>>
>> +#ifdef CONFIG_SPARC64
>> +       if (adi_capable()) {
>> +               long addr =3D start;
>> +
>> +               /* If userspace has passed a versioned address, kernel=

>> +                * will not find it in the VMAs since it does not stor=
e
>> +                * the version tags in the list of VMAs. Storing versi=
on
>> +                * tags in list of VMAs is impractical since they can =
be
>> +                * changed any time from userspace without dropping in=
to
>> +                * kernel. Any address search in VMAs will be done wit=
h
>> +                * non-versioned addresses. Ensure the ADI version bit=
s
>> +                * are dropped here by sign extending the last bit bef=
ore
>> +                * ADI bits. IOMMU does not implement version tags.
>> +                */
>> +               addr =3D (addr << (long)adi_nbits()) >> (long)adi_nbit=
s();
>> +               start =3D addr;
>> +       }
>> +#endif
>>         start &=3D PAGE_MASK;
>>         addr =3D start;
>>         len =3D (unsigned long) nr_pages << PAGE_SHIFT;
>=20
> Thanks Khalid. I missed that sparc does not enable HAVE_GENERIC_GUP, so=

> you fix this case here. If we add the generic untagged_addr() macro in
> the generic code, I think sparc can start making use of it rather than
> open-coding the shifts.

Hi Catalin,

Yes, that will be good. Right now addresses are untagged in sparc code
in only two spots but that will expand as we expand use of tags.
Scalabale solution is definitely better.

>=20
> There are a few other other places where tags can leak and the core cod=
e
> would get confused (for example, madvise()). I presume your user space
> doesn't exercise them. On arm64 we plan to just allow the C library to
> tag any new memory allocation, so those core code paths would need to b=
e
> covered.
>=20
> And similarly, devices, IOMMU, any DMA would ignore tags.
>=20

Right. You are doing lot more with tags than sparc code intended to do.
I had looked into implementing just malloc(), mmap() and possibly
shmat() in library that automatically tags pointers. Expanding tags to
any pointers in C library will require covering lot more paths in kernel.=


--
Khalid


