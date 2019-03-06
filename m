Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3EEFC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:42:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 708C52064A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:42:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 708C52064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 091858E0003; Wed,  6 Mar 2019 14:42:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0187E8E0002; Wed,  6 Mar 2019 14:42:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E23178E0003; Wed,  6 Mar 2019 14:42:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 896FE8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:42:26 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m25so6845733edd.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:42:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=7u9pA6yad3S410CPLHAom9h4nmwulfqwO7kiYNgvVbE=;
        b=EJU0BH3lwm1836mhxDJmTKYxCdRoLCz0M9pc6cSunfXUw6EXFxITghiJHbVivmhuZk
         FmV0bOKd2V2pYsiJDFQdrquJJReVj3Sq4OSW4Z4g114ifVANayDSE7f3ayks16bwLucQ
         H3Keo4sMF1KYTMdJ0G83h87InJ7ycazxmmAhzJ7E4KLbyrxdNvzPbRi8em+/UMi6hUKA
         hF2olhyPgzFnMKshbCEueU0VbZAzvDLIjp2JnenDhWWKnoXUd/ZJFdIuXTMNqnLi0Gk3
         jTDQxL/7wxMYI4uj0n1GCzw7/0skogoMqVXSYVu8MypzhyD32+vzkGug7pcjPSy9ubOu
         NVfQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUAiBVaUcvRrRyxPsO1gmsQKGcnv9R8h/u/pxYlMDhMDKcpZIar
	gglugAYntflwDaXxy0Syjj4SKHB1MtCqRbwuomMY8A5+BD3RDNc7ZFL0oibjAMx7AdCtyKAgMUD
	Q7ZbDsNvEaq/jfV76RM3tHqdYDk07Pw4dq/kC9Jfo57ynnWpAsSl40/Ygl4FRJc4=
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr24032611edp.237.1551901346138;
        Wed, 06 Mar 2019 11:42:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqx+3ddB8xt6nfm0otqq8tOCb0ua7FqTqZyrvJ9G59uPznng1y8lB9Qf/HaFflOXLnomuwjF
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr24032572edp.237.1551901345304;
        Wed, 06 Mar 2019 11:42:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551901345; cv=none;
        d=google.com; s=arc-20160816;
        b=TpVM5QY0lHGpZF0dVU0bgYGa4PCH3fBqj2JhUq3XJoeQQs2Wj4GoQgMncqWulZlsmb
         YaCzWbP/xu+AuLCQuvgytCruNJqJLrhS58paPMy0jU4EBvngNL8rKx/iPHLX4IAvD9E9
         cZNp27R42mwJaJnQ93xZKFxwHrDKd1UgpVJ+HsFI3jvQj0A5NMAdEjrlxk+TcpAD4H3+
         xTYK9JhgYseuXZkR58TN5SqlaKHze/H7YRzFNG4qlYsv/tsW26msOL4WlRZ3F1/+lnqL
         qdxuR8tv6ENo7YPf/+PDa9bYtPkGbTTj61Gx277hgEnDRGNGlZAsQ13Qd5fLpPt/LAOA
         qXbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=7u9pA6yad3S410CPLHAom9h4nmwulfqwO7kiYNgvVbE=;
        b=d6c/HDxtmOYx31Ii6TcgYc+1QdLUDBt54RHUuHNBR0B8W9Ts9XBgUwil/8QuG6AZuz
         OUhxs3/89Gk58m1szqnqE4wprGvCnghQzMXaYyfjEnG+0rJktHhTdMPRMqB/rsQMQm9g
         QDhozXWOnkmiuLPrpqBwEbIR7wykL8zbgvXjEO54p1ErjepT3eLC6PkFLSTr6cnATB/G
         957/sStMI+shSY0XEIaa+p4/mR3H2Dt1rdbEmSD2vxUcOJS0EQ94+A5bLanWf+al5MkE
         avWJOjqw3zJSadCRWIFRDZyqIm4f6dMw/2glNfBjOeKFCFsCpDakr5KkcNIvtG4uJiY+
         uARg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id z6si926641ejq.49.2019.03.06.11.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 11:42:25 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 7973DFF802;
	Wed,  6 Mar 2019 19:42:18 +0000 (UTC)
Subject: Re: [PATCH v5 3/4] mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA
 into CONTIG_ALLOC
To: Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190306190005.7036-1-alex@ghiti.fr>
 <20190306190005.7036-4-alex@ghiti.fr>
 <6a50153b-c68b-f96c-1840-df6b7dd2cc61@suse.cz>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <bf448a35-47e0-53f2-59d7-384c45514b9c@ghiti.fr>
Date: Wed, 6 Mar 2019 14:42:18 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <6a50153b-c68b-f96c-1840-df6b7dd2cc61@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 2:30 PM, Vlastimil Babka wrote:
> On 3/6/19 8:00 PM, Alexandre Ghiti wrote:
>> This condition allows to define alloc_contig_range, so simplify
>> it into a more accurate naming.
>>
>> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> (you could have sent this with my ack from v4 as there wasn't
> significant change, just the one I suggested :)

Thanks, that's good to know.

Alex

