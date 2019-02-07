Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9631AC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 13:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41AEA21902
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 13:27:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="U7zyFCgl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41AEA21902
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D358D8E002B; Thu,  7 Feb 2019 08:27:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE53A8E0002; Thu,  7 Feb 2019 08:27:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFA698E002B; Thu,  7 Feb 2019 08:27:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97CB38E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 08:27:50 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q3so10107905qtq.15
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 05:27:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gVGRQAP8fycR5glSl7rC3QviX2H8rDZ6sJcRguQ7SeA=;
        b=jo9DyssTKfo8hG1LJyG343sZp4++HOp0Xneemyd0d8cf9ys4sOTaL9RDvRgch2cVAd
         Pi7ivi6IgOgWh2i7wHkUUMxPsOQCHDfRxet/3Ja9GooxxDi0avYoeOJN5RkBjW9tQdA+
         9RZ2nHMVfvJVR0PsVA0hTzYT52+LVM2YUTzJwwQeKKf/ca0GlpoYwIrJQNe089EtDRG0
         wI6GoNgGUFAPrkdz1TBBj1uNu07j1mRa/aCrEb60OKcfN1mjh9UyM72w9HhPX8KSyntb
         lYrMYheEI2GXE5ioeQh8loAwCy5n4i+fEk4scsP0w+guyBdkm37xciv8QuSzQZxTMCSK
         uUgw==
X-Gm-Message-State: AHQUAuaXOMluFZGN7B2/isoAKyf5rxQF8PctULBi9746dkwRSwyjt8fR
	hE/GL+VVeuXaknXKQ2pa1hRNMAKaux2fz5p38apiva8xpYveZ4UmihU9JBEjYrXzNQaKa2QmGCR
	uZZj2NyLGTB3uzgKv4RMHovp3thRqtWrAjLDWDUqFx3vgvpsdy/RO0JaV/8wff7erxcyRWYhxnP
	Ze3iMaxQDXGc9MsG+oDy0y08TVhd8IHLzBhtzIF0oA+VHtingH+F/AhLkyeg+iWhPcdyfiSArc0
	b1wvzHCEJVMjmKHqvOqjrpGkYU4GYc9ELAjI2GVIO8e1S10SVglPsH9W7QXt1Y7D3vJCAQ+fr1W
	OzJTs6Gkm5/9cc/BqIZ9UPyJMDZoepRk7zTAV+SgK1J/6EaDxLSJP4/Je1bwQjt3GnjftLLYu8b
	Y
X-Received: by 2002:ac8:2a06:: with SMTP id k6mr11974249qtk.245.1549546070331;
        Thu, 07 Feb 2019 05:27:50 -0800 (PST)
X-Received: by 2002:ac8:2a06:: with SMTP id k6mr11974211qtk.245.1549546069748;
        Thu, 07 Feb 2019 05:27:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549546069; cv=none;
        d=google.com; s=arc-20160816;
        b=FJERRfkv0RgWx5NxA/QP5FiOsBpfOo0MlD5y6OpzPsldgMeZUuzxXUBPkPHyxe3Jcm
         Xx/gBYLaSRE4xsOLGDKMkWiWR5DbgD8BuifsEY7tLsES63UZ0Kw32fiSgoh0X0cAdTFn
         Sged2+0u5V7+317CLnfpdUq1nDyYpe9UFlLt27JMR1RKXdrDS0Bc1vacit/nVrDkhr+k
         owiYMhRkq5E+RR98u7wTE4bzIhl/3rCIUA9K0C7GItaI1FF7OILQRgCJo9Dzj3Gu2FIe
         vYLD8Ej+9wLBDej156eCj8zntx2U9gQ33L5Xd5JSLabwHjZwnG0TS8D7rfavbncA+syd
         lRDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=gVGRQAP8fycR5glSl7rC3QviX2H8rDZ6sJcRguQ7SeA=;
        b=j4cDumsU3cg9+A230rGrtuWIcgF5upSbXHPuCziPfN3n2lxzl+tOeG/q9Q8oK9IVt4
         +GdVbPMDoq2qdJsNx4S7H3rKG0ayN8e6XodmEEifWOjwBRYS3LmVyXlq6WmY/QJ3pu0M
         D1KnQb1kzy3isBkMvjF7a5MblJ/mo0SoX1lyUbWE/M3xQtTleDC8esySSe8SLSobZiSd
         60xHOlc3EnBGDmmO44v6I8aNrSKgcbr82HfyBPJsZib8P/iUdzN90AUms9zxk8CkycI+
         eIb7oiyFhfw7YN14t99GDRqs6BgmM3kbmJin7ZTdAsXLhAOpY1c1cMfMHvF9NAu+VjUC
         41+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=U7zyFCgl;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u56sor32403447qvc.58.2019.02.07.05.27.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 05:27:49 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=U7zyFCgl;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=gVGRQAP8fycR5glSl7rC3QviX2H8rDZ6sJcRguQ7SeA=;
        b=U7zyFCgl8UsthAyJ6GJETaK6VjYO9R6hnAUbwum19EDn+UZ6JBvdfgXFYEo39DSMMt
         OCWrfeJgTO1AtlMsrjMplzGLIycHt/f9PV12yfmSy7kbh/IIpis694rqvKerN4Hc6BBb
         Ffb7P6FqZL+Ycy3JOclu/bQ6UT8dxNqnzynsNXZap9tJjZ+TXChEHDbYSjYQ3f+Y3sZ3
         J32i3W7pJedqxpJ/l2xGER3sO8xqAbdEoA9wOubbD/kJMsl98xHlip3vaYQbPztt90DS
         t71nhmXcqJViXU6tlKBzZbCZZQUqFSykuuuPATpq7SnH1zHPrhTE5YlzZKBo59p+wz36
         2ORw==
X-Google-Smtp-Source: AHgI3IZR2HVv+LZzBwlj0ZZiVIyTcwCHtDmzwE7pmqMazDqxl7fzx8CrNp0p9bykmTGq3BJqrR0cxg==
X-Received: by 2002:a0c:eaca:: with SMTP id y10mr11754387qvp.176.1549546069278;
        Thu, 07 Feb 2019 05:27:49 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d67sm8223865qkf.76.2019.02.07.05.27.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 05:27:48 -0800 (PST)
Subject: Re: CONFIG_KASAN_SW_TAGS=y NULL pointer dereference at
 freelist_dereference()
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux-MM <linux-mm@kvack.org>
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
 <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
Date: Thu, 7 Feb 2019 08:27:47 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000110, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/7/19 7:58 AM, Andrey Konovalov wrote:
> On Thu, Feb 7, 2019 at 5:04 AM Qian Cai <cai@lca.pw> wrote:
>>
>> The kernel was compiled by clang-7.0.1 on a ThunderX2 server, and it fails to
>> boot. CONFIG_KASAN_GENERIC=y works fine.
> 
> Hi Qian,
> 
> Could you share the kernel commit id and .config that you use?

v5.0-rc5

https://git.sr.ht/~cai/linux-debug/tree/master/config

# cat /proc/cmdline
page_poison=on crashkernel=768M earlycon page_owner=on numa_balancing=enable
slub_debug=-

