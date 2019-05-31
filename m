Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11127C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 05:05:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAA4F263E6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 05:05:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAA4F263E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 040906B027C; Fri, 31 May 2019 01:05:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F33B26B027E; Fri, 31 May 2019 01:05:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFB786B0280; Fri, 31 May 2019 01:05:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 918616B027C
	for <linux-mm@kvack.org>; Fri, 31 May 2019 01:05:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so12121605edv.9
        for <linux-mm@kvack.org>; Thu, 30 May 2019 22:05:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=jL83xFdD/aHxispjhU2AiV5rEgrDKtxgwM3aVYvmG4Q=;
        b=UF9ZuvztLfmz0q4ITJgXMSJaZKMmKvX7RWmcZggNsFMs3PgaE2jOl5/5vra8kWAVhr
         IpbJe/hdlZuZAO2LALK9ZRT+9cnCGeXhIZ6L79syYDkxGkHhFvUqvUdAULA5BMKJSjk/
         u8XWbCoaQOch1HTXGd9ZM+cTkgt3wY70qMfV+xoGlnI/asCP25KPLEAnjP701iJIbUZH
         pVe7SL9zNq7A1FzwQEewky/xDhlrano11o4jNze+WWtgb45zt6wUx+ai7AAhXmpJZOy9
         aAhYVB5haiykwGCjqm6L72DJKcrdTdoNWez8mqtOz5o7bDrK4pH3lKV/aIMlcbQj/3hj
         /v1g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVRPbeEUwmCYxmr5p9jprCOXU/XpXJGKDhPi23ay7/kFUZTk1qH
	9fFP5CrY4K0AlpQfASfVFgcDbHHRG8NJ/XBa0FCohPmAvrbT7KFIsiy8hilMLGrXlRvMXZpva2S
	R+oCkNoUP7NSvdnasGZzo37IiRPv5CyXKVRhM6gyGSCP5gr3vfYmgQhURNi8hfDc=
X-Received: by 2002:aa7:c24d:: with SMTP id y13mr8895234edo.230.1559279115099;
        Thu, 30 May 2019 22:05:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdZfXYbJ8mgQ6pgN7XbbwstYGw2WkDC0f8UYnITxSDOwPZFiLRTiYheamIUJoy8gN66Vt1
X-Received: by 2002:aa7:c24d:: with SMTP id y13mr8895172edo.230.1559279114301;
        Thu, 30 May 2019 22:05:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559279114; cv=none;
        d=google.com; s=arc-20160816;
        b=gyGE7RVBdd4ruHjkMFobg740Q3bZ3TJiq+JNn5QTPQPu/AZfFdm+zoKtMU1L+cBPlZ
         W7kT+Wz1uMJTrDf/WvmNC2edvA/NQWWmOWzy5qYKWtz0pYc0N6eFC6BAWVrZfg/LRGRx
         az8hDTLmSYVgxNBn1nLvkEUCwNLht0PinrIxC6cY3aoXMue4mRTZj9d94KG058H0qjr6
         Nh+AfAO3OCT7edZHfyVaLsfVKh4QmzxIkh3uAPXjxrYXeQZfbuqOLDii7YaM1/zfdLDy
         F3xCmXmYtSasGJHYiwomdAzn0JVRr2QhBq56PH/PIutjuYkO2a3++q28jn6vaVAlFfk4
         88FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jL83xFdD/aHxispjhU2AiV5rEgrDKtxgwM3aVYvmG4Q=;
        b=qnS3uuGErOPHtf4PhA8d5RbbLphFUPT3X/zISSrFAHomhiJ6rElkLJVnDtKWZ6tPVu
         tiyduKf73+b4NGL8U7hgpnykI8TpqsPsrM7wA0RtbdAi+hhcoLgRi8N2mCK9Kd0dY2ZS
         05fBIFOBHd56Ys9odusPLnrJEp8ps8h18WTZRr7mSMFPqeusAaviWPbUefAa1wRBYRnx
         R/FyvDqxtmMS9+Z24KAxYLNJUYUw0fPAuL1e/kgchC5PHD82pPWzFqBE32irYXxdF3ne
         5bIfHhuzqW+hRjcPNf06lprwRCTlUt5pBk3uv272n5FAUZksO8jFLX3mbqIjSSUobrnP
         9hUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id q6si2932867edd.141.2019.05.30.22.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 22:05:14 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 6BA8020002;
	Fri, 31 May 2019 05:04:56 +0000 (UTC)
Subject: Re: [PATCH v4 00/14] Provide generic top-down mmap layout functions
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190526134746.9315-1-alex@ghiti.fr>
 <201905291313.1E6BD2DFB@keescook>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <d4e04178-e6f3-6d11-4ab8-9be7cf8ae87a@ghiti.fr>
Date: Fri, 31 May 2019 01:04:55 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <201905291313.1E6BD2DFB@keescook>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000734, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/29/19 4:16 PM, Kees Cook wrote:
> On Sun, May 26, 2019 at 09:47:32AM -0400, Alexandre Ghiti wrote:
>> This series introduces generic functions to make top-down mmap layout
>> easily accessible to architectures, in particular riscv which was
>> the initial goal of this series.
>> The generic implementation was taken from arm64 and used successively
>> by arm, mips and finally riscv.
> As I've mentioned before, I think this is really great. Making this
> common has long been on my TODO list. Thank you for the work! (I've sent
> separate review emails for individual patches where my ack wasn't
> already present...)


Thanks :)


>>    - There is no common API to determine if a process is 32b, so I came up with
>>      !IS_ENABLED(CONFIG_64BIT) || is_compat_task() in [PATCH v4 12/14].
> Do we need a common helper for this idiom? (Note that I don't think it's
> worth blocking the series for this.)


Each architecture has its own way of finding that out, it might be 
interesting if there are other
places in generic code to propose something in that sense.
I will search for such places if they exist and come back with something.

Thanks Kees for your time,

Alex


>
> -Kees
>

