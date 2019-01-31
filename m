Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CB0BC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:44:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECBB320881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:44:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="JMZ+vLjQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECBB320881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F1168E0002; Thu, 31 Jan 2019 01:44:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A1048E0001; Thu, 31 Jan 2019 01:44:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7907B8E0002; Thu, 31 Jan 2019 01:44:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20F808E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:44:19 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y7so679095wrr.12
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:44:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cOJiyexC4RhzV3nLmw1xVDcK744oiB5d7rgry5+gXoM=;
        b=IxIs84ykqFRBXEmDUhgNt3L5LuqO48qqxEfN7+g/0VqkHAlKdiJ+KM4r6U8racS8O6
         X5od3MOwwF1fznw1j5mfmzz68EodqFMJpkgP366yfgcSLA2qT2R0VjEFE5p7/E1HmvJJ
         nR0rxUS2kMxJcoOqM4Y1mLH/DIAiltIjKAagGFu3tLRSec5k6B8eXWntP/RySWtWBLO/
         0eLvZVzS42/3mkwNoIY8nB3yI6wafMeC/mvrqwIR1Hu0++RRgxWmX6KyJVvKGmECeLBc
         9TMdxdMv6yMMG3v+ETLGJeVmqoDml77XNnDK0SSZdenmanU1ZOH7WgDtSYEQ4kPs9Qy+
         AS8w==
X-Gm-Message-State: AJcUukc7rIQKc6FWu5FdhIbzalgqVij2rMyeiFLNk5zPVjYWkuDS9LeY
	XCDJbpL9Ql2pKi+aqbcIuBTL0C+lsZND/m9Z2LMn03Sp6xpEc9VIqOURxvWtTFhTpMoalyiWO5i
	ct7ui7dPPAyd5HtwQhxnjyVPqfVD5mpQQ1w6H7TgH0PzsXhZMwn4Qf4Hv9H4jG4u78Q==
X-Received: by 2002:adf:ae41:: with SMTP id u1mr31686464wrd.20.1548917058641;
        Wed, 30 Jan 2019 22:44:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7iSJw2iFSF3cULJGvko/D6nIzpeJHCRtmM3sJXwZaJNqY328dBOtxXE4vASilLiFkIQWu6
X-Received: by 2002:adf:ae41:: with SMTP id u1mr31686426wrd.20.1548917057774;
        Wed, 30 Jan 2019 22:44:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548917057; cv=none;
        d=google.com; s=arc-20160816;
        b=GgZLlMH0xvQG7EnLyzDBAIGd+fUYbrqrIjuBQ0+YoOGH8FjIthg/lhzEW2jmuEsaaL
         QwCMzrgDq/cVf9+2OzQiWY3Y3mdF/lDJ1OtLbfZEu2zxD2ZRSAuyn8T2V6SxAAD+sZ85
         iYf5nKPqrMcrlXue5GYPxMwLKd+F+Xj+c8jxCFqr6lABflpQ6Rbr+uO+l78AWzBy8rW8
         uAI9equIDEDdpwYo2V+CClAdx6KV9qbsy8fcCZR2ptdDQOgokFAeTOkWqjbOnB8dsva1
         28f/ToCLV2bQjuFQd2pP4Em5KXDIfqMPrn4GVdZcyskVtIYeoGEdgnEoeNYQ8BLs6Lly
         4JGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=cOJiyexC4RhzV3nLmw1xVDcK744oiB5d7rgry5+gXoM=;
        b=ptTrNJURRW8zVvDb5a20izVtWyrZsg0KYHoYuZhvvrP3yZ69OWukRWjFrXub/cmJey
         Mdv5kcOiDPsVPch/fnu+VMK0OdXQSt6bU6qwJ4m+pwXubHJqa/mghsCf7apEPvCNHTx/
         /7sVLC09J5zefHqpyp4PmE/Gfef5CLpA/iSBn1BjL1jxEC/SGtPBdC5frO4+HdASocZ0
         zX9N5xxR2iDBcmWwSeinEeZtaIfpeJQJUnNdbQ+MShsaQc9COntAmwFyMYb2UtdX6ihP
         B/D9DDj0/LaGzCv5SQwNuZcqYVdxDYK94HaByuM1Mual/i1OSCx4Dm0nMZnHcCT1xB8i
         JkRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=JMZ+vLjQ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id i12si2610255wrw.413.2019.01.30.22.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 22:44:17 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=JMZ+vLjQ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43qrLS1Crsz9v0QW;
	Thu, 31 Jan 2019 07:44:16 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=JMZ+vLjQ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id GE1BryDiLvL6; Thu, 31 Jan 2019 07:44:16 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43qrLR6vTNz9v0QV;
	Thu, 31 Jan 2019 07:44:15 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1548917056; bh=cOJiyexC4RhzV3nLmw1xVDcK744oiB5d7rgry5+gXoM=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=JMZ+vLjQ76kryo0d4/3v/CDV0aIlsMdhbsiuclC0eKE0XnqOavCGYfranMcArXvgZ
	 dV45OC8eZ/80eWqgb+hc9/o9z1Khd3UH2cqOEZvxMsXqASyrcPNuh48OKAIU0LEGhU
	 t5oaxwZcm23sWI0poHri1Vgox0AoX9rAx2aliPUM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BA4FF8B78E;
	Thu, 31 Jan 2019 07:44:16 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id ETfFXp9TLqKY; Thu, 31 Jan 2019 07:44:16 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8915D8B74C;
	Thu, 31 Jan 2019 07:44:14 +0100 (CET)
Subject: Re: [PATCH v2 19/21] treewide: add checks for the return value of
 memblock_alloc*()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Rich Felker <dalias@libc.org>,
 linux-ia64@vger.kernel.org, devicetree@vger.kernel.org,
 Catalin Marinas <catalin.marinas@arm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org,
 linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>,
 Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org,
 linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>,
 Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com,
 Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>,
 Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>,
 linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp,
 Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org,
 linux-alpha@vger.kernel.org, linux-um@lists.infradead.org,
 linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>,
 Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org,
 Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>,
 linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>,
 Tony Luck <tony.luck@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org,
 linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>,
 Vineet Gupta <vgupta@synopsys.com>, Andrew Morton
 <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org,
 Stephen Rothwell <sfr@canb.auug.org.au>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
 <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
 <20190131064139.GB28876@rapoport-lnx>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <8838f7ab-998b-6d78-02a8-a53f8a3619d9@c-s.fr>
Date: Thu, 31 Jan 2019 07:44:14 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131064139.GB28876@rapoport-lnx>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 31/01/2019 à 07:41, Mike Rapoport a écrit :
> On Thu, Jan 31, 2019 at 07:07:46AM +0100, Christophe Leroy wrote:
>>
>>
>> Le 21/01/2019 à 09:04, Mike Rapoport a écrit :
>>> Add check for the return value of memblock_alloc*() functions and call
>>> panic() in case of error.
>>> The panic message repeats the one used by panicing memblock allocators with
>>> adjustment of parameters to include only relevant ones.
>>>
>>> The replacement was mostly automated with semantic patches like the one
>>> below with manual massaging of format strings.
>>>
>>> @@
>>> expression ptr, size, align;
>>> @@
>>> ptr = memblock_alloc(size, align);
>>> + if (!ptr)
>>> + 	panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
>>> size, align);
>>>
>>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>>> Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
>>> Acked-by: Paul Burton <paul.burton@mips.com>	     # MIPS
>>> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
>>> Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
>>> ---
>>
>> [...]
>>
>>> diff --git a/mm/sparse.c b/mm/sparse.c
>>> index 7ea5dc6..ad94242 100644
>>> --- a/mm/sparse.c
>>> +++ b/mm/sparse.c
>>
>> [...]
>>
>>> @@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
>>>   		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
>>>   						__pa(MAX_DMA_ADDRESS),
>>>   						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
>>> +	if (!sparsemap_buf)
>>> +		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
>>> +		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
>>> +
>>
>> memblock_alloc_try_nid_raw() does not panic (help explicitly says: Does not
>> zero allocated memory, does not panic if request cannot be satisfied.).
> 
> "Does not panic" does not mean it always succeeds.

I agree, but at least here you are changing the behaviour by making it 
panic explicitly. Are we sure there are not cases where the system could 
just continue functionning ? Maybe a WARN_ON() would be enough there ?

Christophe

>   
>> Stephen Rothwell reports a boot failure due to this change.
> 
> Please see my reply on that thread.
> 
>> Christophe
>>
>>>   	sparsemap_buf_end = sparsemap_buf + size;
>>>   }
>>>
>>
> 

