Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7CA7C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:28:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA4F02054F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:28:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA4F02054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1328E0008; Tue, 18 Jun 2019 12:28:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52BD18E0001; Tue, 18 Jun 2019 12:28:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41B2C8E0008; Tue, 18 Jun 2019 12:28:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB5468E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:28:08 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id n26so1660274lfl.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:28:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jU7PIwhw4fc5R5yu8eYhYLUBF3pk1ulWXKj0FSCGJqE=;
        b=ZriuiJtnP+9T0J7+f2VMt+WrZ5bpT/+N864ociAyDGkKsa1s0zF9vvBSb731WJdLVe
         4eiOc2qXcmTDXcJaxd10zCW1HsqBDcZwJMNdvqamwz58UzMLxSZ0qHL5E1rdLTlMDa0V
         cpHUM7MboxXP8mdBsNYf/oAiyKawELIJXvOG8nIiTyDcrRGw771wNA6446gOY2T5BGJo
         GEijpT8uQzYcljUe9AWrasr3Yh3n+JHBPf8F7yUbU7lVGLmIYFGPJDfvQWM4lGE3RNMq
         I6Hz2oLuuKZODhraS8/H/pzB0G9hBTkOfTl52dIs/T8fFSNJrV/X0oztYtQA/tPO3h0k
         QE/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVvpP4pdBFZZGvxHpfal+oHT6HszCRAGf+hV8CQFdiajq7yP2tS
	1C49+eVi6xqRwsQ0aARzC7wbcQufnGy+CvaagBXPQ/DPAv9yCMb8QoMCiWm01wJ82ydwT6tM7Z1
	MWTNYGrOgRNLIcrm8toXyqXNn24R26rHhmSLPhFdDOvQ7wmDSawMlekJuqaiejb5+5A==
X-Received: by 2002:a2e:9758:: with SMTP id f24mr11707220ljj.58.1560875288165;
        Tue, 18 Jun 2019 09:28:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxhecy2riKjmfmfi9jCDM4+KAAFAik6rHTApzWxFeKZytRNmHixqRcljrxIjuPuOogrPmU
X-Received: by 2002:a2e:9758:: with SMTP id f24mr11707180ljj.58.1560875287416;
        Tue, 18 Jun 2019 09:28:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560875287; cv=none;
        d=google.com; s=arc-20160816;
        b=C5/tV8auLF1isJII7Boe830GsrF9IllhFp8ApGHif0+I0h55kvnkF4e25WQsZhGKTr
         4dq3oNaDC93LtGGSAR2J/n9ZODa8G9GSqX27ar5ZnY3pbuo4gZI4Cb+knBcxmiaExXqs
         3Gtp367XsgtoKJG2ZFPyo8T3VNL6ogG+nIf3XhTO+bb+/BxLZmpSqlmHxRqobv9BJ3D1
         U2RhD6M81d1DTLzYPJI4RxHNh2ejoRFmEQb2QiLoAB7gz/1QeJJN8N6DeTruY2wDVV8E
         yjnLWqM8XHrRU2vdysRw4N6nys+QU1Rd1C+sPvCCsATQJc1u1NNTA2LLn80MgTwMOrnW
         ezJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jU7PIwhw4fc5R5yu8eYhYLUBF3pk1ulWXKj0FSCGJqE=;
        b=WUurc/4dRJc59EBoOY3VQ4oyyBS1Td37l8BOLShCkNr4WnvLHUNz5aar6cWLzTiBBr
         KJRRajYi+FtXAhRFSJ4Yy/z3iqNghQ7m29K90sE/t4qZdkQYerC03w4U6zlWL1Ta8xQT
         Xr4W6v6vUu1EmQrx7ZOOx+20fl9lzjJDtzKogNbR+RxZGoXQIfN+G75pP+v2a/oZQ9Da
         brGOntd1NV28xpV+fLR9I/LTshvzW+Bg3zg3vYKV8Ml4SKmBmoEDf/4+ehhvM3ODwNPB
         3UNgPzVNHWPFRIrGg8V3AjepKWLS326YDZRyyid7f142uRixpOkiOZcY8/9jlynUTAE+
         EbWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id k14si13978717lja.95.2019.06.18.09.28.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:28:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hdGxk-0002qE-CF; Tue, 18 Jun 2019 19:28:00 +0300
Subject: Re: [PATCH] [v2] page flags: prioritize kasan bits over last-cpuid
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>,
 Andrey Konovalov <andreyknvl@google.com>, Will Deacon <will.deacon@arm.com>,
 Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <20190618095347.3850490-1-arnd@arndb.de>
 <5ac26e68-8b75-1b06-eecd-950987550451@virtuozzo.com>
 <CAK8P3a1CAKecyinhzG9Mc7UzZ9U15o6nacbcfSvb4EBSaWvCTw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e782e546-dac7-8479-d5a0-fdacfb3359b8@virtuozzo.com>
Date: Tue, 18 Jun 2019 19:28:10 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAK8P3a1CAKecyinhzG9Mc7UzZ9U15o6nacbcfSvb4EBSaWvCTw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/18/19 6:30 PM, Arnd Bergmann wrote:
> On Tue, Jun 18, 2019 at 4:30 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> On 6/18/19 12:53 PM, Arnd Bergmann wrote:
>>> ARM64 randdconfig builds regularly run into a build error, especially
>>> when NUMA_BALANCING and SPARSEMEM are enabled but not SPARSEMEM_VMEMMAP:
>>>
>>>  #error "KASAN: not enough bits in page flags for tag"
>>>
>>> The last-cpuid bits are already contitional on the available space,
>>> so the result of the calculation is a bit random on whether they
>>> were already left out or not.
>>>
>>> Adding the kasan tag bits before last-cpuid makes it much more likely
>>> to end up with a successful build here, and should be reliable for
>>> randconfig at least, as long as that does not randomize NR_CPUS
>>> or NODES_SHIFT but uses the defaults.
>>>
>>> In order for the modified check to not trigger in the x86 vdso32 code
>>> where all constants are wrong (building with -m32), enclose all the
>>> definitions with an #ifdef.
>>>
>>
>> Why not keep "#error "KASAN: not enough bits in page flags for tag"" under "#ifdef CONFIG_KASAN_SW_TAGS" ?
> 
> I think I had meant the #error to leave out the mention of KASAN, as there
> might be other reasons for using up all the bits, but then I did not change
> it in the end.
> 
> Should I remove the "KASAN" word or add the #ifdef when resending?

It seems like changing the error message is a better choice.
Don't forget to remove "for tag" as well.

