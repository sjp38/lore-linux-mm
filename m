Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CC3FC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:42:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 182FB2168B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:42:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="i5j6lJ3z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 182FB2168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 797236B0006; Thu, 23 May 2019 17:42:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 746356B0007; Thu, 23 May 2019 17:42:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 634B96B0266; Thu, 23 May 2019 17:42:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 445796B0006
	for <linux-mm@kvack.org>; Thu, 23 May 2019 17:42:57 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v15so6430556ybe.13
        for <linux-mm@kvack.org>; Thu, 23 May 2019 14:42:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fChv2jZysnH0YR2y5rlBhLoHF4XJSOv5yE7IjBMa6MI=;
        b=DFXSiWRG8pI1nuRWleJpqfLMfwtb3CscE60LiczT3fYh2M04z1D6tLDMK7XeAjrSHO
         uiB8me7XleJ6fHmJIe0vafi1BMngvOEo9pS98sn609C8f+2KrBt3EjoQskq5oiRinvd0
         J++9cYnMeyYxzOALTK1J8D9rllYe5tgZC+luBi5nApt2f0tbQAigEYzPHTe4ZsalXZkf
         UTjfhKuphEKdyuPIfTnpVxiErD4KxI0vcpiPNVJP+EEctTUg4lz4oRa96XaiYZJFhZl4
         BxdOCTWcwwWAydojHiRpZT9U9FdLsHSmdqz1P6D7bwS/6ta+qW1bl4z4X//ExbU23pfU
         3d1Q==
X-Gm-Message-State: APjAAAVOywB7Otq4LEmUJyazkH2uwHEkEf7ZlNqVEH4O6+vHi2tsqO5R
	+Zy/HaUSqml2rDKMDayCKZnlWkta+zuzDTChH5Ehm/wB+ieW7zc1dT3tacx/4mHM0rpoFwBTWH8
	+8Pl3oJRU21GSOHTvf3CKdCxHGAXxd3kny8Nt7wCNvVDh44sgOiyY84mBKB8XdEl9Xg==
X-Received: by 2002:a81:9855:: with SMTP id p82mr42734193ywg.498.1558647776963;
        Thu, 23 May 2019 14:42:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZRr6mqCX3AepZ55McdSfNpGtj+GAeENaTeR/9z7+ajIQNN6Q8bWEdwPwgBGXIgQnPqajt
X-Received: by 2002:a81:9855:: with SMTP id p82mr42734162ywg.498.1558647776133;
        Thu, 23 May 2019 14:42:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558647776; cv=none;
        d=google.com; s=arc-20160816;
        b=dqv5Rlk3XAD8RpIwt0G27LP8GSL9RBPS8K7b9Vo6uryr9NY3Is5zUvUkx0vcXw33EB
         xSWrx7usiLhWa6zNPhuZfA9mz+BluZ0YRs2AvZZTCF327sA8Fj6C9kG5x8ady2xsj1Cl
         Yr/X1gxyvohZh1yXbjXzSLX2ELGmE7/YWffqy2gQyMnPo+bg9S0acgUXS85bk8gJ8QDc
         61oMt+9WR6QSrqsoM7ZKW3PNwgFYbAVYCgvXEC7FEnOelD+3eYQM6Uz2EIpwis8QJuMz
         7WzMgnulqZgsbKzBwPLb+4ea00XtyDRwm+haTXFgsB/g2v+eRIDtH4JnG8m9XKKtdZHF
         sc3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=fChv2jZysnH0YR2y5rlBhLoHF4XJSOv5yE7IjBMa6MI=;
        b=NIgY1REZJa3w19eQs1pu9UUQYK/HEGb7HPqoqgpJXvSE9rfjwXjCjKvthXCs/2lQIU
         g59prOEQcP+CIRExB1jwHjHmKcJyjeQu3cuyRnI7lqxrSpg5UMav5tcN6xdiz8g1o3nA
         1dsZ508n9hKT4nHFwTP7nhBSyW+gO614N6YHPOtnrzgqwgg1uWR1b7GQGOQHszEAsQtM
         Uz4Dn/Nhsx9UKvlO00TDRjhVPOsTlv7jU1AGar47NdzsmzH5kmDlScW94my3E2xUPy+0
         Mqwbw93+GWIqmPxMCNOlttYpiOg1ojFl7etXNjfXqI2Xt1/8sAAQkF6Nd3vVhC9c9J5r
         MP7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=i5j6lJ3z;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 190si192643ywd.197.2019.05.23.14.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 14:42:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=i5j6lJ3z;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NLYrP6194020;
	Thu, 23 May 2019 21:42:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=fChv2jZysnH0YR2y5rlBhLoHF4XJSOv5yE7IjBMa6MI=;
 b=i5j6lJ3z4Hf6Mwe1uFCyW+Dx0BGc6CLgnMT05UhOAfwtXEFuubZ+5cv8bNXRQH8SGgIo
 3OyLnYWAZcw9X87yhv0YScSmwlfD77yg0wTvg1PD2uhxSUM5Gy8pVikHFeRo6px2TaaX
 1T5zqOZo/S3v8s0hewcbGZ3eIMfGRoZXC5u4QclbQcN+yRHCnMRvFytz7HBe/xVcQAjJ
 q7QGNHrFLf5im7IlibITLPPps1G2JhmeRisj45eynyh1gJCP32P+yM8kZMYnSTS9vT+Y
 qf/xCuv9cZn8I8m8yv46kQ4CowM5trlHuA6dN6lqyIZI05Jf3nu9oHXNSoc9l5912SdM mQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2smsk5n8d7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 21:42:41 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NLfaot156717;
	Thu, 23 May 2019 21:42:41 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2smsgtgmuy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 21:42:41 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4NLgaOB031829;
	Thu, 23 May 2019 21:42:37 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 23 May 2019 21:42:36 +0000
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
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <047e3b90-d73e-0ca8-869c-d03b7580e644@oracle.com>
Date: Thu, 23 May 2019 15:42:33 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523201105.oifkksus4rzcwqt4@mbp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9266 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905230138
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9266 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905230138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 2:11 PM, Catalin Marinas wrote:
> Hi Khalid,
>=20
> On Thu, May 23, 2019 at 11:51:40AM -0600, Khalid Aziz wrote:
>> On 5/21/19 6:04 PM, Kees Cook wrote:
>>> As an aside: I think Sparc ADI support in Linux actually side-stepped=

>>> this[1] (i.e. chose "solution 1"): "All addresses passed to kernel mu=
st
>>> be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI=

>>> for kernel code.") I think this was a mistake we should not repeat fo=
r
>>> arm64 (we do seem to be at least in agreement about this, I think).
>>>
>>> [1] https://lore.kernel.org/patchwork/patch/654481/
>>
>> That is a very early version of the sparc ADI patch. Support for tagge=
d
>> addresses in syscalls was added in later versions and is in the patch
>> that is in the kernel.
>=20
> I tried to figure out but I'm not familiar with the sparc port. How did=

> you solve the tagged address going into various syscall implementations=

> in the kernel (e.g. sys_write)? Is the tag removed on kernel entry or i=
t
> ends up deeper in the core code?

Tag is not removed from the user addresses. Kernel passes tagged
addresses to copy_from_user and copy_to_user. MMU checks the tag
embedded in the address when kernel accesses userspace addresses. This
maintains the ADI integrity even when userspace attempts to access any
userspace addresses through system calls.

On sparc, access_ok() is defined as:

#define access_ok(addr, size) __access_ok((unsigned long)(addr), size)
#define __access_ok(addr, size) (__user_ok((addr) & get_fs().seg, (size))=
)
#define __user_ok(addr, size) ({ (void)(size); (addr) < STACK_TOP; })

STACK_TOP for M7 processor (which is the first sparc processor to
support ADI) is 0xfff8000000000000UL. Tagged addresses pass the
access_ok() check fine. Any tag mismatches that happen during kernel
access to userspace addresses are handled by do_mcd_err().

--
Khalid

