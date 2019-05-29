Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C31D3C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 14:49:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ACF523AC5
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 14:49:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vAYGK9KO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ACF523AC5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06D0F6B000E; Wed, 29 May 2019 10:49:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 044316B0010; Wed, 29 May 2019 10:49:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E74876B0266; Wed, 29 May 2019 10:49:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0B066B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 10:49:42 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d22so1717167plr.0
        for <linux-mm@kvack.org>; Wed, 29 May 2019 07:49:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=bdiE7HWyHmzeDdhgcpTkxNwVwsKMW5J4u0bwenhkW2I=;
        b=crRULKiB6sKsKBppzbkepjEEpW3Jo37IcY6HhnjTzEAdPPrYV63bDEwDfheHGvyYzf
         G3Izl5zRbIKlc8FYw6eJ9jRDSUPQMsUVUMwZYX73UQHGLiXDGi3Ye+ZVxjqgzGROHOvU
         hfqI3AbVKH0gg7n0gGrFrgi49js1Mq56fSInQh5NInwRbv8s19GvObXEoSBSPsuP7Iym
         ml8VUXd2Z2uVDsWgZcUtS3XTz69TW5C7f1wFAlONNOrB98BOXkvDLQQpIyw7QNIyPgM4
         69+i8sCBhdf0cjumy7H6Tf3eOcL6r0SXJKVTklnU9uw4UAKQQvZGfOFqRhIueOuwHopQ
         B1Yw==
X-Gm-Message-State: APjAAAWeCzdHH3gW3qAhJc0gOpJqlerjqv3HUgWibnEf1bS2qNs71m8L
	Z2AEw4UT9Ez+XJPqueD/KP8m1BeGdGL3tB6mGvc/JHgJQlJmG6XrAkITP17p9/e1EGX83jkAyhY
	OE/Axh2N3R0esAOx2nynl4ZhF9objw7XOg/yl4382xTQ6ARUMukbsbwjjcw4EjcoATA==
X-Received: by 2002:a63:8f09:: with SMTP id n9mr109991644pgd.249.1559141382299;
        Wed, 29 May 2019 07:49:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpqpc5irxG8V6lCAj9E+vvQM3zGhy05r1DjHs3ZDrMpL7bxvzppDhiMf1T9BKRsNQKXB+r
X-Received: by 2002:a63:8f09:: with SMTP id n9mr109991556pgd.249.1559141381282;
        Wed, 29 May 2019 07:49:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559141381; cv=none;
        d=google.com; s=arc-20160816;
        b=PPYnCSuRxlvIPSMLXu6rMDHWUqZ9cw4yAyTBx6DIn+XxWhlwmY+yBrVA2sAnEhFdyD
         25EG+QqYBQtGF5UbzdbBGA5RgT965zIFEsmoG65xZ/phyEoZVe+jww5rNK0I3Fq4+eTF
         xJjZVyCQEuxcKJPc0qqaWMlwQWUAZpUI/UoF4ZLOQG2PNW4J1P3CkJMSos4SB/0jHurY
         vTnosmE6FhhAYaU0R1p0sYeHRefED62ZxwE3+ooTFwej4RbHmfZKuDqJQGerFNZqMauk
         DuFVWgtnKsTbDW619qAQMUqEsv9eul23Qg/MEEM355W4OqOstGap63F018LDSQnWnQxw
         8NGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=bdiE7HWyHmzeDdhgcpTkxNwVwsKMW5J4u0bwenhkW2I=;
        b=vWYebHwDC8xpy5UP1s+sYn4HOuBiLcCE++lE0Z6otVIFypiDzaywgBQD4fz4qb1iHc
         XOv5xvip8HOHtgh2925645GeOJbRKZQX1du8mbxdU8dLslNxX9Ruy9cQE3BjdU7R0xtv
         e2rFXufYBd7LbkIFZPZL78XcXF+AL12U2W49JDMmiGzTesgqSwPFp78LgyRqFSfbGQhn
         L7MkHqHQmh4RF+vxMTwVYOf5Afj7DEgcivpcQCaa51Do06VpKyr0rej1vS8eRM2famc/
         i5oH8JuAcIXgo38uMySMHzFOwRuxAGxxJwnCjIwoE9x411LoksO/mDv9LFCNLtbNwBMc
         TDOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vAYGK9KO;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t25si25988333pgk.442.2019.05.29.07.49.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 07:49:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vAYGK9KO;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TEmj59055774;
	Wed, 29 May 2019 14:49:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=message-id : subject
 : from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=corp-2018-07-02;
 bh=bdiE7HWyHmzeDdhgcpTkxNwVwsKMW5J4u0bwenhkW2I=;
 b=vAYGK9KOQKh1ci+61dIXEhKr/6PuEl3w9nerHoG2o6KZcTmroHCycrPlXsSVYoCc1D9e
 u53Af15v96j6SPmPoJ+syGA6mCGI1yCiY2PcW+gMzZiVseWDKwRqdfQ/vA5LKK20Ou6S
 qqH1kgPXhEpgNiGNUtFLQ9cNrcGvNjpxe3Gfdd5qauvpSfl3hiaspyOm5mJhBkWRqvwm
 IYx2v4CAD32zNH3jZdsRIlmsjtuapA8CQI+GAGIf1qsl+aD1+DqMFhyfxIFAGNXJW+cz
 9a5PK1sw72WXYdjOuDHWee7Q0Jai2TlWbMJfUWHm89DxiTdsjrZTZi400nmT0P2EZndw JQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2spu7djgus-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 14:49:23 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TEnL0O140618;
	Wed, 29 May 2019 14:49:22 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2ss1fngsh2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 14:49:22 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4TEnF2L021623;
	Wed, 29 May 2019 14:49:16 GMT
Received: from concerto-wl.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 29 May 2019 07:49:15 -0700
Message-ID: <3ade20696cc772772f5362fea02ede81c4a0fad3.camel@oracle.com>
Subject: Re: [PATCH v15 01/17] uaccess: add untagged_addr definition for
 other arches
From: Khalid Aziz <khalid.aziz@oracle.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
        Vincenzo Frascino
 <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Mark
 Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kees Cook
 <keescook@chromium.org>,
        Yishai Hadas <yishaih@mellanox.com>,
        Felix
 Kuehling <Felix.Kuehling@amd.com>,
        Alexander Deucher
 <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander
 <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan
 <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy
 <robin.murphy@arm.com>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Date: Wed, 29 May 2019 08:49:09 -0600
In-Reply-To: <67ae3bd92e590d42af22ef2de0ad37b730a13837.1557160186.git.andreyknvl@google.com>
References: <cover.1557160186.git.andreyknvl@google.com>
	 <67ae3bd92e590d42af22ef2de0ad37b730a13837.1557160186.git.andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5-0ubuntu0.18.04.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905290098
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905290098
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-05-06 at 18:30 +0200, Andrey Konovalov wrote:
> To allow arm64 syscalls to accept tagged pointers from userspace, we
> must
> untag them when they are passed to the kernel. Since untagging is
> done in
> generic parts of the kernel, the untagged_addr macro needs to be
> defined
> for all architectures.
> 
> Define it as a noop for architectures other than arm64.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  include/linux/mm.h | 4 ++++
>  1 file changed, 4 insertions(+)

As discussed in the other thread Chris started, there is a generic need
to untag addresses in kernel and this patch gets us ready for that.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6b10c21630f5..44041df804a6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #include <asm/pgtable.h>
>  #include <asm/processor.h>
>  
> +#ifndef untagged_addr
> +#define untagged_addr(addr) (addr)
> +#endif
> +
>  #ifndef __pa_symbol
>  #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
>  #endif

