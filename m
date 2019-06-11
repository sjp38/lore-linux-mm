Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF33AC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:23:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 797CE206E0
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:23:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5BNbvdzr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 797CE206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18ABE6B0008; Tue, 11 Jun 2019 15:23:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 162266B000D; Tue, 11 Jun 2019 15:23:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0501C6B000E; Tue, 11 Jun 2019 15:23:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C17746B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:23:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l4so10278294pff.5
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:23:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YlU5LEmt/4+KLQdtIjWgwQDa+/rDMT79BcosgR9T0To=;
        b=AgilAou/KOB8EugafO95sjLtmr3Zw3xeLJnc1nZ6CEBFY+wXWwepJixKAZTpDIHLWv
         I9Ubx5v3r7fXKsPz/EGysICjV3oS9/CSjOJV6b90VYVBYcrJlCskK6GHiUhw8nKmmUVh
         AnSGlixqnUursq7T8McJN3LIYei9tj/aXv2mw/LQsg+LApzE3oN0aCyz3c0TKwVlAqde
         3pnwcK/KhL1W0BCsiV0/yWrcXDgxs5urnK9N+hf7pjjgnEt9XkIay/FxgBGHnSc3kRXG
         7AHGttmTWmPqKI/mOIB4JfCONMOROcsvdTj+0kBBOMNsfcQlqoxwvTbwVW5DqFbXnAi0
         IpEQ==
X-Gm-Message-State: APjAAAUywDKZIcbD7mJGAL7Scw+OBM97t3yync76d9ZTg1Vbqi0wPPgp
	QlEwPIX9WIuFOIEbXTXoZ+PW81YbMpq9QX8TmtKFy19fSOaJbQM+CgkNYiqlLtow41m85CjneKX
	Q4vk97+AK5mKHCYKmIKb+hh+ZGiCjwYrmKwZOwzLX2yypms8FGBmhkO4ZJ6VjgDp+6w==
X-Received: by 2002:a63:1c4:: with SMTP id 187mr21974062pgb.317.1560281017317;
        Tue, 11 Jun 2019 12:23:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5ZrYnJaVSBV98/Pfw4aNTnIjiOXCtunRlpVkWSDVLFzTCC8RvWsmF0RtEAmzKf9Mawm8r
X-Received: by 2002:a63:1c4:: with SMTP id 187mr21974009pgb.317.1560281016521;
        Tue, 11 Jun 2019 12:23:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560281016; cv=none;
        d=google.com; s=arc-20160816;
        b=RRi2TfDSazecBwSTn4DcUo2kBbWmeTtjUPRByUD5RZvGJqMopLe588kTJCOorArgvG
         ycVbMFGeYuTjXoxT8nQwLphzLs0BlvIZq/o5VYyS5+s5QYyUaWv5h5xW7QQ9y6vonyTj
         t2O7Y+5mO8YXvAJ0b497iRBGlniXJElMjT0uuRoPYVVT48kryI6iahuKsXLeExNvjbnH
         XIFbP+0mzJuMzGrZXNTHiZHWJIREAqYDH2yX6QbNSDshA8umcn/gO1gQgR37BJusIeJs
         BGConGxdWxMaDYG+4MOxBSvRWp9VFalo6wwu0kj2DPLEvZz9WZTw8BztZA5Hxh4+3gXd
         SEiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=YlU5LEmt/4+KLQdtIjWgwQDa+/rDMT79BcosgR9T0To=;
        b=O3DkKa30MeT/S6ebr8oPEcRDEXEG+WikGF+8LY+Vlbh+DmQkmjLdeLpNEWwcfdXH8z
         pcMMRWQeLwCrCi+NlV1KEEcM8wQ/e7WY3nDQCCmNQq3oB0zY9hHj479RFUKLvm3yvVe4
         GEJOh12ijnN6FicTPt/UAHN+HxSSTRCBS3wJ9QMRjagrxhhScs6gOHcCcstov7SoWZzy
         zRoZgt07V/9o197bcPlDcP8w56o9ttxoAP8QvUDb1xOS1D1VV5eZT8tOpIzG1lFaW44i
         QD84ZyXA7wMGM4qBaw3M/1muyH0VGLzb3+PZg1szJmC1JZfM6zFFGcOajpg1FD85IFNw
         9FOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5BNbvdzr;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o184si12863339pgo.94.2019.06.11.12.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:23:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5BNbvdzr;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJNQmO155550;
	Tue, 11 Jun 2019 19:23:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=YlU5LEmt/4+KLQdtIjWgwQDa+/rDMT79BcosgR9T0To=;
 b=5BNbvdzrXPeQ9vFQYPqzXQGruWABl1v+APKNrwBasCFpe9tEeK2eFTZs76VwqFI1oK/m
 sp7W09J4V/7JoipFOq2yN7QiKvwwtlI8r/hzLYqBVAxo7xCT2XbKMlNRrWH3tN3OfX9Z
 g4UWs60mfpGNy/bK7G6wFXN9FPRIWDQJgdT8LtSLPX9jpVWvulzpQmqG/aDy8wRc0f3/
 6lF9bJXnzzexrGyCo8ydpR2Cbee48THi3gczkbb1D0Q2HRnY9WA//G/MPd8noPnAahml
 QnNVVxRgnfAy2wXwy5/e2ZH1HzQiR2uaqNAUxIkGgaV2sECaKDynp/pPOu6wp47YN3fj kA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2t02heqdjx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:23:26 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJN264176542;
	Tue, 11 Jun 2019 19:23:22 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2t1jphmcas-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:23:22 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5BJNKLx027118;
	Tue, 11 Jun 2019 19:23:20 GMT
Received: from [10.154.187.61] (/10.154.187.61)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 12:23:20 -0700
Subject: Re: [PATCH 08/16] sparc64: define untagged_addr()
To: Christoph Hellwig <hch@lst.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
        linux-kernel@vger.kernel.org
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-9-hch@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <13f72660-8f7b-a437-e449-6b4267de9c0c@oracle.com>
Date: Tue, 11 Jun 2019 13:23:17 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190611144102.8848-9-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110124
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 8:40 AM, Christoph Hellwig wrote:
> Add a helper to untag a user pointer.  This is needed for ADI support
> in get_user_pages_fast.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/sparc/include/asm/pgtable_64.h | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)

Looks good to me.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

>=20
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/a=
sm/pgtable_64.h
> index f0dcf991d27f..1904782dcd39 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -1076,6 +1076,28 @@ static inline int io_remap_pfn_range(struct vm_a=
rea_struct *vma,
>  }
>  #define io_remap_pfn_range io_remap_pfn_range=20
> =20
> +static inline unsigned long untagged_addr(unsigned long start)
> +{
> +	if (adi_capable()) {
> +		long addr =3D start;
> +
> +		/* If userspace has passed a versioned address, kernel
> +		 * will not find it in the VMAs since it does not store
> +		 * the version tags in the list of VMAs. Storing version
> +		 * tags in list of VMAs is impractical since they can be
> +		 * changed any time from userspace without dropping into
> +		 * kernel. Any address search in VMAs will be done with
> +		 * non-versioned addresses. Ensure the ADI version bits
> +		 * are dropped here by sign extending the last bit before
> +		 * ADI bits. IOMMU does not implement version tags.
> +		 */
> +		return (addr << (long)adi_nbits()) >> (long)adi_nbits();
> +	}
> +
> +	return start;
> +}
> +#define untagged_addr untagged_addr
> +
>  #include <asm/tlbflush.h>
>  #include <asm-generic/pgtable.h>
> =20
>=20


