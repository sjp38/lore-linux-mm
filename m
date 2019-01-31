Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2060C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 968BF20870
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:07:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="rCd82aqn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 968BF20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 008A38E0002; Thu, 31 Jan 2019 02:07:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF8448E0001; Thu, 31 Jan 2019 02:07:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D72018E0002; Thu, 31 Jan 2019 02:07:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFE88E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:07:34 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id 144so607782wme.5
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:07:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MXHl21tpazUCycYGJIF5K2H108fXMrwBKp0kMfVZOHU=;
        b=Jf+VK1X+2+PFif+Sh8WTy3ZtZkAqSzDsssqjBE4TtayhVXeGgjNT0cz0Zvw+na4cnK
         OcV5cXWENlqQWiOyJuXj2SK4fWnpb19h8A/1gAn/uPseU9Pi6t08WbKAZcV+s/vNZSLj
         0Pp5OY37pvBEr9JTF8hBn6OkD++GaceV4MJpIfVIGo2CN7dnlcSi5VV1SJKctgOC5gfy
         9EiU88FBqKACZaHX7eAzCeSzWmox/YC9bgK3gywd1IimMcG15Nbv/asVmPyXooRW7T+E
         UVpOtNxbR2C5NMA+9YJF8rmOtI3C6GNrkKswWUGlXV/TwVWbZWvj5BoH4lEVkJ/rzB+8
         Xtgw==
X-Gm-Message-State: AJcUukdivX4MLF0woBSRTR28nGeeibEf55S0v3DN2Wt7DyiV+o8ny5bC
	D8RnctCCuzjkx37kUDqk1On45vJ2QJH6QCdDfPKgmkuWpqAU2XQBiXBuboCaIKr1cB4qS8+DIRw
	p3YDynQ+d54tdpMzslDTIPRHKQmeSo/+BxcD+PnEAvWK6FAgjREAnzUHo9uX4XP2UGg==
X-Received: by 2002:a1c:8d53:: with SMTP id p80mr29602574wmd.68.1548918454036;
        Wed, 30 Jan 2019 23:07:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7E+cIJWyO4un0yOH869TYJ7wGp8nWoRuYdMrfoue3XIY2qr2QBi4IqKbMQ7xIGY7ZkDgaU
X-Received: by 2002:a1c:8d53:: with SMTP id p80mr29602501wmd.68.1548918452933;
        Wed, 30 Jan 2019 23:07:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548918452; cv=none;
        d=google.com; s=arc-20160816;
        b=h05Aeye+u5GHP2c3huQER1l84v+aig1UHQb5rt00iVyCrcqCLUOMgBK7xp5BMXKdE2
         Ypp6EbHViAqxpn5ixPYuBlWhnu8D5cNr6vSi9AWOzGwpajikFXGZ5W3U3qLFInEZ67CS
         Tt6ePnYwn5/TK/5BW2HDZWWx/SfKg7tWNrYVVxLWT2Ez5uq55c3l14U64wCl77vkHTWd
         IUGBf9gxVqBGpcu4OlyaOKxfw7X7B37cKPmV8XfCpjnd9IxztDh1zLStMjhxPk/8pKlJ
         D7jwOTVxZZ7L7kQNalNn5fpnjuG/fRhP2Fgi9n8IogvxzJlByajlc/r1ti9IxKF3Pyt2
         KHpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=MXHl21tpazUCycYGJIF5K2H108fXMrwBKp0kMfVZOHU=;
        b=aA5i88C+9xvbZ82UmlS5eRsQWqsEwZVZj+K/riSjKkFynVO0nRDa7yMyPYyvHs4+TR
         3i0Sgkz3rNCUe3KvZiMGVy5yleOPbC5zRl+KB3mn58n2RkPRN3fPcGvTIiWkdr+U2nr8
         GHBk9KGsRq8e79VZIabsorLyiHAmM50aTePbWMuF4GPC95bNRRihz3l74y0AYuIEQYwq
         v5iy2d9Er9VRKsXqt4Z8yMPTgXxHE+66vxFJKQDTYSJ7/jtfxB0uPlIavGu/kVm69BHq
         xJ1BEBN4ZlYxks3sD75l5wx2Q6AH/282k/bd5yAk0QthZ8A8oMaRMwvqA7sJXz6qyk2l
         A7WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rCd82aqn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id m65si3327315wmf.40.2019.01.30.23.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 23:07:32 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rCd82aqn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43qrsH3KnTz9v0Ql;
	Thu, 31 Jan 2019 08:07:31 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=rCd82aqn; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id DAzsBnhWoB9O; Thu, 31 Jan 2019 08:07:31 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43qrsH1tsMz9v0Qj;
	Thu, 31 Jan 2019 08:07:31 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1548918451; bh=MXHl21tpazUCycYGJIF5K2H108fXMrwBKp0kMfVZOHU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=rCd82aqnCmgVKey8lh2qo7e2czYPgKR5K0SsqXWaaG+aPdVhNoJAHK8cvl05jNaLQ
	 01Tbj78zc0z794OUHngjeqyEvlUQI7ONSfsFOcwtpy8Q//8zmi0Zwd5Q5S7O8IAO0Y
	 J0iKKRNhFMGd08UKWW9aHyiQ2pzFvIMvvFhWRBCY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 176168B78D;
	Thu, 31 Jan 2019 08:07:32 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 9D0PmJeNjYuQ; Thu, 31 Jan 2019 08:07:31 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 075218B74C;
	Thu, 31 Jan 2019 08:07:29 +0100 (CET)
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
 <8838f7ab-998b-6d78-02a8-a53f8a3619d9@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <d5e4ff5b-d33a-e641-8159-d4f83bc28d0b@c-s.fr>
Date: Thu, 31 Jan 2019 08:07:29 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <8838f7ab-998b-6d78-02a8-a53f8a3619d9@c-s.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 31/01/2019 à 07:44, Christophe Leroy a écrit :
> 
> 
> Le 31/01/2019 à 07:41, Mike Rapoport a écrit :
>> On Thu, Jan 31, 2019 at 07:07:46AM +0100, Christophe Leroy wrote:
>>>
>>>
>>> Le 21/01/2019 à 09:04, Mike Rapoport a écrit :
>>>> Add check for the return value of memblock_alloc*() functions and call
>>>> panic() in case of error.
>>>> The panic message repeats the one used by panicing memblock 
>>>> allocators with
>>>> adjustment of parameters to include only relevant ones.
>>>>
>>>> The replacement was mostly automated with semantic patches like the one
>>>> below with manual massaging of format strings.
>>>>
>>>> @@
>>>> expression ptr, size, align;
>>>> @@
>>>> ptr = memblock_alloc(size, align);
>>>> + if (!ptr)
>>>> +     panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
>>>> size, align);
>>>>
>>>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>>>> Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
>>>> Acked-by: Paul Burton <paul.burton@mips.com>         # MIPS
>>>> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
>>>> Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
>>>> ---
>>>
>>> [...]
>>>
>>>> diff --git a/mm/sparse.c b/mm/sparse.c
>>>> index 7ea5dc6..ad94242 100644
>>>> --- a/mm/sparse.c
>>>> +++ b/mm/sparse.c
>>>
>>> [...]
>>>
>>>> @@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned 
>>>> long size, int nid)
>>>>           memblock_alloc_try_nid_raw(size, PAGE_SIZE,
>>>>                           __pa(MAX_DMA_ADDRESS),
>>>>                           MEMBLOCK_ALLOC_ACCESSIBLE, nid);
>>>> +    if (!sparsemap_buf)
>>>> +        panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d 
>>>> from=%lx\n",
>>>> +              __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
>>>> +
>>>
>>> memblock_alloc_try_nid_raw() does not panic (help explicitly says: 
>>> Does not
>>> zero allocated memory, does not panic if request cannot be satisfied.).
>>
>> "Does not panic" does not mean it always succeeds.
> 
> I agree, but at least here you are changing the behaviour by making it 
> panic explicitly. Are we sure there are not cases where the system could 
> just continue functionning ? Maybe a WARN_ON() would be enough there ?

Looking more in details, it looks like everything is done to live with 
sparsemap_buf NULL, all functions using it check it so having it NULL 
shouldn't imply a panic I believe, see code below.

static void *sparsemap_buf __meminitdata;
static void *sparsemap_buf_end __meminitdata;

static void __init sparse_buffer_init(unsigned long size, int nid)
{
	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
	sparsemap_buf =
		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
						__pa(MAX_DMA_ADDRESS),
						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
	sparsemap_buf_end = sparsemap_buf + size;
}

static void __init sparse_buffer_fini(void)
{
	unsigned long size = sparsemap_buf_end - sparsemap_buf;

	if (sparsemap_buf && size > 0)
		memblock_free_early(__pa(sparsemap_buf), size);
	sparsemap_buf = NULL;
}

void * __meminit sparse_buffer_alloc(unsigned long size)
{
	void *ptr = NULL;

	if (sparsemap_buf) {
		ptr = PTR_ALIGN(sparsemap_buf, size);
		if (ptr + size > sparsemap_buf_end)
			ptr = NULL;
		else
			sparsemap_buf = ptr + size;
	}
	return ptr;
}


Christophe

