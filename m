Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 586F5C31E49
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 01:41:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14EA720861
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 01:41:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ElB77Qbj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14EA720861
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A273B8E0004; Sun, 16 Jun 2019 21:41:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D7828E0001; Sun, 16 Jun 2019 21:41:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C6E58E0004; Sun, 16 Jun 2019 21:41:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA4C8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:41:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k8so7922605qtb.12
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 18:41:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=yDNJnnWMnvyj74KJjqDNrTKP8BhcNS3oCZ7kmmIyfm4=;
        b=C3eJCG3MG9uBVGiiIu/kXR0NQJqteNdlgH4KT7cszsCTN4tLpDCdNzbZGAL0KFVbbQ
         PYAc9H63PZbbb7KCvjlYwlNhQEhIvoKgWh8xXrowVq0rr8GSlAC/+fC4CIHaH5dCx+Ps
         o3tRoPB9OjcypLiUvv6TGBYbJiK77F7dKdz59oH3hd9bvX1L/ikZmWXr5popkEILsKga
         MzwdADGiM/pGWwNDh3/l1PEgOjjWTZFS3WPdOdE0IX45INTiUWVBxtxBrtlk3OixfTxO
         1/YGWDftijgHRUNADLoXcAEi3DBq62INm2Ve2ETTGdrahvo2I9/pxghFh6MD5yipuAGS
         e7JQ==
X-Gm-Message-State: APjAAAU1NQxijxHNxh0FClZ37jSUe7N5HPtO5SjhwpTRJhnwjB3DA9J3
	YQh5D3+r1UvNsKnz2NmLNmXf/5idNOZCyc4he9fwHV622i9pRmOyqQaPx+J2rIocUn7XTlhucLv
	9eHXSNRl3mxo9ljx+gnVpWmGPDt0lNCYC2Jn4nLAhwhXla1kw5bFyPq8UfUlbqIMd/g==
X-Received: by 2002:a37:b0c3:: with SMTP id z186mr19217180qke.178.1560735672122;
        Sun, 16 Jun 2019 18:41:12 -0700 (PDT)
X-Received: by 2002:a37:b0c3:: with SMTP id z186mr19217160qke.178.1560735671553;
        Sun, 16 Jun 2019 18:41:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560735671; cv=none;
        d=google.com; s=arc-20160816;
        b=S0J/q+QxZ975ilpSyLz2hK9Cz3D12sPV8Xh9olGTc4g3YdSKd0ZHhS82Y2qyF1tCfB
         iHZu6SffY8jZfyrX6QziqwNpZsIlovqDzbp6WmZf7Jlgvq7aZGbliQOD66IjWVrKoUAI
         Np764WxWUmdsEtu36hlBEs9axaXmOrDmLoDteyCs4S322BwnQkFszhDggTd04dMHFo55
         p/D1NEMakNQ0icjID8wP5y6aOt+blsr+x8cAo1wpLrwUh3HRaY9QGWUiOLRHmvytAZyI
         GgVAg5/RhZ6XjpO0IhTiLVhQGaRNUh+OAY74+tN/dzA9/oAbMeIOzJMCqgMEogTlLPI3
         HXZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=yDNJnnWMnvyj74KJjqDNrTKP8BhcNS3oCZ7kmmIyfm4=;
        b=pZNhOgW1WBTEdxrfsDK+Ejhh45Cmz0n90C6/L6X4pXKK0kFKb0luACFhDd/eRjauuy
         a2Wi2T/GcdlxnQMdaNk+ZEHszCB0IV9svksq/eP2y4OKV7FZ9klWdMs7NRMMko65olFy
         sPhY0/4VcaER84OAGftAuSoCrtXKLmlQ/3ypB+e8urL5UEFVcyMvTOu1wDF706aQ4DhH
         rhQ4PDc7hFh7/EgKAzhG2k0ZkqulO3Ret9ZaAfBi5WHlckXYT/k8VKc5ugHlgxNjxTbn
         KPfV08f0DJ+0WfVXRL042syVe0Rxaad69SNQSYBHP8SqWP48KVGynpQHGLGMC8bECadJ
         Glsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ElB77Qbj;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor6302563qks.52.2019.06.16.18.41.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 18:41:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ElB77Qbj;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=yDNJnnWMnvyj74KJjqDNrTKP8BhcNS3oCZ7kmmIyfm4=;
        b=ElB77QbjwicalLDAC/XLHtEXw3/UU+ToIyPskfkAUH1tIu/U9suKHVBjE+Gra7qlu4
         SfROdnCJnmHBNN1JY8yyqKoevbAf71SEXwBAiHw3MoEKCkCFmzyQIstM4lJPVL9bE8sW
         ol+INiBZwwHD7Vssk4wOLmuefAvt1+xQjPKj2pJEK/KBp0tmoraLJv3cwMQBU5ozFYrL
         xqBlsK9d2XGk7Z//uN9nMV29HByV5hsqpWrEhHX5TfIdxdq9Kf7bd/MVMdbDKuKazbM0
         w5ctKa0w7flVcDSgU+A3S9ntfWhtBXdpMaClcKumhtGa6lxEnKfQttxesKMVHWox44ln
         1VJA==
X-Google-Smtp-Source: APXvYqz+ah+V71vGndXB9PVxkYf68i4b83LtgwwezyYhS64hdWj/C2Et4tvVQq+ACar89DMNZAxCaw==
X-Received: by 2002:a37:4887:: with SMTP id v129mr6511552qka.17.1560735671205;
        Sun, 16 Jun 2019 18:41:11 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id l6sm5718357qkf.83.2019.06.16.18.41.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 18:41:10 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
From: Qian Cai <cai@lca.pw>
In-Reply-To: <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
Date: Sun, 16 Jun 2019 21:41:09 -0400
Cc: Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <EC704BC3-62FF-4DCE-8127-40279ED50D65@lca.pw>
References: <1560461641.5154.19.camel@lca.pw>
 <20190614102017.GC10659@fuggles.cambridge.arm.com>
 <1560514539.5154.20.camel@lca.pw>
 <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 16, 2019, at 9:32 PM, Anshuman Khandual =
<anshuman.khandual@arm.com> wrote:
>=20
> Hello Qian,
>=20
> On 06/14/2019 05:45 PM, Qian Cai wrote:
>> On Fri, 2019-06-14 at 11:20 +0100, Will Deacon wrote:
>>> Hi Qian,
>>>=20
>>> On Thu, Jun 13, 2019 at 05:34:01PM -0400, Qian Cai wrote:
>>>> LTP hugemmap05 test case [1] could not exit itself properly and =
then degrade
>>>> the
>>>> system performance on arm64 with linux-next (next-20190613). The =
bisection
>>>> so
>>>> far indicates,
>>>>=20
>>>> BAD:  30bafbc357f1 Merge remote-tracking branch =
'arm64/for-next/core'
>>>> GOOD: 0c3d124a3043 Merge remote-tracking branch =
'arm64-fixes/for-next/fixes'
>>>=20
>>> Did you finish the bisection in the end? Also, what config are you =
using
>>> (you usually have something fairly esoteric ;)?
>>=20
>> No, it is still running.
>>=20
>> https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
>>=20
>=20
> Were you able to bisect the problem till a particular commit ?

Not yet, it turned out the test case needs to run a few times (usually =
within 5) to reproduce, so the previous bisection was totally wrong =
where it assume the bad commit will fail every time. Once reproduced, =
the test case becomes unkillable stuck in the D state.

I am still in the middle of running a new round of bisection. The =
current progress is,

35c99ffa20ed GOOD (survived 20 times)
def0fdae813d BAD=

