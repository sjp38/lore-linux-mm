Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97AC0C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:31:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CA962085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:31:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CA962085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFD586B0003; Tue, 25 Jun 2019 03:31:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D86608E0003; Tue, 25 Jun 2019 03:31:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4E258E0002; Tue, 25 Jun 2019 03:31:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0BA6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:31:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so11341132pfn.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:31:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:subject
         :in-reply-to:cc:from:to:message-id:mime-version
         :content-transfer-encoding;
        bh=LSFnG1VLPAxdrZu/1aoqM762Ph1wbr10WuLO1iu5MTU=;
        b=lIGQFsd6w+6FtHbnjmv+r+42Dtjj0dZ522lGh//SN3/OBnz7cJ2GVJgAlPWya3h5m8
         BrL1FahmF0h62HGeLJh2PNk9V8lYEoQwNgvgxRwvNI39Wrd0GmMp5JQyqX5BgGZvNKEh
         jWXWAmu+GDNhHS4l0Qv9eYci/8Ve81SG2Zd5Tlcj7d3eln8L1NJsKv6+W8AKSJZcvcuP
         dSRb6w3bu0HMc+vBdRDLXhTeuUWUGAPJ/ajgtuEMOBh8QSCJsm1ObuD80Aqn71IXXJL+
         QCd74XjRE6NtejjkLr8ngbtLfIkdfyQt7OxyWRrq1dWOqN7/6ZY4sMCAEO4DCjQYw0wt
         yjkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@dabbelt.com
X-Gm-Message-State: APjAAAWVZG5poXHiLs6bcancWSAvmLaYCJlLHJHLlPsN7hpUf0phTEOB
	uC9q8Bdlez6OZy489Zc5/Dz1Da1jGurhvrOJgCkIcvoItqGCPoSUayk0IqJiZYUjM2BTV21Oipb
	+2ODgP2z6LFyQN0m9mX8zXJ3gA3yux4mkWrXRYvo6+1l2th4fmMfMETwCP/vy4kg0MQ==
X-Received: by 2002:a17:90a:62c7:: with SMTP id k7mr2220943pjs.135.1561447887234;
        Tue, 25 Jun 2019 00:31:27 -0700 (PDT)
X-Received: by 2002:a17:90a:62c7:: with SMTP id k7mr2220879pjs.135.1561447886481;
        Tue, 25 Jun 2019 00:31:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561447886; cv=none;
        d=google.com; s=arc-20160816;
        b=G9Z6+PjmS1tgy4utzpSo7yV2UK0PD0jbSddtvSWYotzRoRkz/O5/bFEloGkClts7pb
         q2B/h29x4LvO88GYpEAsuehE8xVXG4nwVM+j+rqwE75f0ITZeQSp+uUCEcwqivgnN3KQ
         cyDhWpQhqz3u3rCpXyLiki0SBUC//JPlo5V9+wodVmIAdiwSmXMT94Hh0JovFwHhGXqz
         8RVVP95qIZoC74ulKD5lNd4z1O4b855CGQK6ooKapenv7ZlZn2tLW8OWdG8lmILoC/yj
         GqEes9xEvBVUmfbnO3sNmYRZzmkEtvZDUq+d4g8aqesXnU43UlyZPLMocLUmbfYEcL2n
         bcGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:to:from:cc
         :in-reply-to:subject:date;
        bh=LSFnG1VLPAxdrZu/1aoqM762Ph1wbr10WuLO1iu5MTU=;
        b=vwSASPFl9d1HpXOo9gJI3kXg0LvjhJE+JrDX3JZiw35X9wcOY8W0tkcfBciEiFq70E
         EGnIQ8gJyHv4K8CdrD7xuueb4gT5/zSO4rbjTsDut2xcElXnz4yGDN5FFUqgA+jdczNR
         JvlWMzvg0BjulRHfrW8R/Qg9VEIT9+Q8VVvr2o5KrxqThR2l/K11EN6qw2jfuUV+70GD
         CQUfU3egncd2DNwtcZkwwu3OGII3V8bQWD90Q07EjL54H6l+hBtY/hOhUbcNWcYQ+W2O
         ewdkcrZYL9xZiBfYQD0FY97PMkC2FZWcOXiEOPJrUfTvyVdZltoRs9EmWQo4oF5ZW4V/
         mHKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@dabbelt.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor4456708plb.21.2019.06.25.00.31.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 00:31:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@dabbelt.com
X-Google-Smtp-Source: APXvYqxA3AiKfUdGgybrZGEd+QlSDx5f6SSD+C9TEX69lBm8COreE3lS5uJ/emXNgMIJT2bbhTf5JQ==
X-Received: by 2002:a17:902:8f81:: with SMTP id z1mr85183321plo.290.1561447885879;
        Tue, 25 Jun 2019 00:31:25 -0700 (PDT)
Received: from localhost (220-132-236-182.HINET-IP.hinet.net. [220.132.236.182])
        by smtp.gmail.com with ESMTPSA id 12sm13241505pfi.60.2019.06.25.00.31.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 00:31:25 -0700 (PDT)
Date: Tue, 25 Jun 2019 00:31:25 -0700 (PDT)
X-Google-Original-Date: Tue, 25 Jun 2019 00:30:40 PDT (-0700)
Subject:     Re: RISC-V nommu support v2
In-Reply-To: <d4fd824d-03ff-e8ab-b19f-9e5ef5c22449@arm.com>
CC: Christoph Hellwig <hch@lst.de>, Paul Walmsley <paul.walmsley@sifive.com>,
  Damien Le Moal <Damien.LeMoal@wdc.com>, linux-riscv@lists.infradead.org, linux-mm@kvack.org,
  linux-kernel@vger.kernel.org
From: Palmer Dabbelt <palmer@sifive.com>
To: vladimir.murzin@arm.com
Message-ID: <mhng-6f11ed95-e3f3-41dc-93c5-1576928b373b@palmer-si-x1e>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jun 2019 06:08:50 PDT (-0700), vladimir.murzin@arm.com wrote:
> On 6/24/19 12:54 PM, Christoph Hellwig wrote:
>> On Mon, Jun 24, 2019 at 12:47:07PM +0100, Vladimir Murzin wrote:
>>> Since you are using binfmt_flat which is kind of 32-bit only I was expecting to see
>>> CONFIG_COMPAT (or something similar to that, like ILP32) enabled, yet I could not
>>> find it.
>>
>> There is no such thing in RISC-V.  I don't know of any 64-bit RISC-V
>> cpu that can actually run 32-bit RISC-V code, although in theory that
>> is possible.  There also is nothing like the x86 x32 or mips n32 mode
>> available either for now.
>>
>> But it turns out that with a few fixes to binfmt_flat it can run 64-bit
>> binaries just fine.  I sent that series out a while ago, and IIRC you
>> actually commented on it.
>>
>
> True, yet my observation was that elf2flt utility assumes that address
> space cannot exceed 32-bit (for header and absolute relocations). So,
> from my limited point of view straightforward way to guarantee that would
> be to build incoming elf in 32-bit mode (it is why I mentioned COMPAT/ILP32).
>
> Also one of your patches expressed somewhat related idea
>
> "binfmt_flat isn't the right binary format for huge executables to
> start with"
>
> Since you said there is no support for compat/ilp32, probably I'm missing some
> toolchain magic?
>
> Cheers
> Vladimir
To:          Christoph Hellwig <hch@lst.de>
CC:          vladimir.murzin@arm.com
CC:          Christoph Hellwig <hch@lst.de>
CC:          Paul Walmsley <paul.walmsley@sifive.com>
CC:          Damien Le Moal <Damien.LeMoal@wdc.com>
CC:          linux-riscv@lists.infradead.org
CC:          linux-mm@kvack.org
CC:          linux-kernel@vger.kernel.org
Subject:     Re: RISC-V nommu support v2
In-Reply-To: <20190624131633.GB10746@lst.de>

On Mon, 24 Jun 2019 06:16:33 PDT (-0700), Christoph Hellwig wrote:
> On Mon, Jun 24, 2019 at 02:08:50PM +0100, Vladimir Murzin wrote:
>> True, yet my observation was that elf2flt utility assumes that address
>> space cannot exceed 32-bit (for header and absolute relocations). So,
>> from my limited point of view straightforward way to guarantee that would
>> be to build incoming elf in 32-bit mode (it is why I mentioned COMPAT/ILP32).
>>
>> Also one of your patches expressed somewhat related idea
>>
>> "binfmt_flat isn't the right binary format for huge executables to
>> start with"
>>
>> Since you said there is no support for compat/ilp32, probably I'm missing some
>> toolchain magic?
>
> There is no magic except for the tiny elf2flt patch, which for
> now is just in the buildroot repo pointed to in the cover letter
> (and which I plan to upstream once the kernel support has landed
> in Linus' tree).  We only support 32-bit code and data address spaces,
> but we otherwise use the normal RISC-V ABI, that is 64-bit longs and
> pointers.

The medlow code model on RISC-V essentially enforces this -- technically it
enforces a 32-bit region centered around address 0, but it's not that hard to
stay away from negative addresses.  That said, as long as elf2flt gives you an
error it should be fine because all medlow is going to do is give you a
different looking error message.

