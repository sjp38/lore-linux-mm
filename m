Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0803C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:45:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F5BB27CF3
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:45:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F5BB27CF3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B3126B0266; Mon,  3 Jun 2019 03:45:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 263676B0269; Mon,  3 Jun 2019 03:45:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12C716B026C; Mon,  3 Jun 2019 03:45:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5E596B0266
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 03:45:21 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id j3so2910406wmh.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 00:45:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=s9ygAoGPsfD+6Rv/tp7HGbU8HGcWRgkFLCMEeAuzNzM=;
        b=uA+J5nmtBB4toGsZcPpVcS8OgcARgkCZwsJhmMPirfRt2EWw6RLa517poK51p6Jyhr
         AlU05fcu9lb5gdge5ZK1nI0XLavSH7Qs4vkDL3C7rnKA20fYxM1Tsdhn/6sHA5ms75mE
         l3pkUwYDUIpBED6cxSO3IsBIWjIVSkbwKmFoJX3EH4pIt7sLlxk+9yXKLc4Xr7jV1Hex
         hG5t1uK56gX74c3e+kbcCpytc/XVhG7BAfHIZeLxv6phCyi/nWCatOZBkrwE50vtVKcD
         2ZbyxnDdVhBBGceywhuqgl89ZxA6+Ju7qKZgS5MKshCFZqJBJctnuSHsrFhVPqX5jISS
         VgFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAULqlj1rbKP4q4HfM5bZMBsUR6F8Nyp7lOzCrxFnk2FmhdLenNR
	9u61mpexcxQLpFMLGjrOqs2ZNnorN2G6ECuCM6/lT8m1cSbpVDBiM9bS2rlldLhPmZQDzbPYaQu
	ToFXiZ8KaKsfaYoMylRBozVc1b4EuK/w4coZUkOxpVKsAD2ifrTHGnwRlCeQfrwUrng==
X-Received: by 2002:a1c:1947:: with SMTP id 68mr13207081wmz.171.1559547921265;
        Mon, 03 Jun 2019 00:45:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzktmK/iL5zJS7/DF1K0G30uVHKHTyFyETKcFoykp2dAvY1/zygk06XdNlU153hgD5hvm9d
X-Received: by 2002:a1c:1947:: with SMTP id 68mr13207045wmz.171.1559547920494;
        Mon, 03 Jun 2019 00:45:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559547920; cv=none;
        d=google.com; s=arc-20160816;
        b=MOU+LEN1TToF7gbKvpHCnq1KyyNyC7rET0D0EdXNlz5Z159aqc1LPzI/OGY200v7Pn
         HBqDg/ANRLX/lB2Av8i5mX5Sb16e++j9wSneQPId9eoF53/Zp4CIFDnbirqDsx9+at0D
         4lcRft0dcMhFjwou77QmI+NHNkipVYBerCtT3Z/P+OHI8/2ZVU+qr8tsjX5ZsrZQENLu
         nc7vWtk1fQr3h9862zv6UNKtVFjW+X7Nq3eetzV3vTCCevQOjFuXQMc/h/DnC88nUAYh
         Dzl3ZxnPXqklWtsyWoQQ7gc114R9qy3BHsY2S/BM4Bcr/JNY6YHvQKuf255JLywBZvcW
         FpkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=s9ygAoGPsfD+6Rv/tp7HGbU8HGcWRgkFLCMEeAuzNzM=;
        b=C0z7utHHQ14Hrq5qRXWV5mn4Q6dEfO9ULTcz7XLwFWe/a/W25fzbrkJCGiHePkv5c3
         TT8JhzZiQW6odxXtiT/8TeOTXtow94x/kek15WYCEwBgznYBsZ+iPwYJ778yE4nBDzfZ
         k+yoeL8vKOpiGWNMjIqngVL/5wCcw4iK70pCAH/LilFt4ydIVsf8Xhz8Q8Br/cjPl3Kw
         JrCioLAWFZl6TG3Vw3aHiIRX9qGwNp7eHsiTjdT7WU+PE7uEUU2qjejiyCmR35nSJ/ua
         EESH9APBSURS7OltETOmwQ9i2paWMpkrzp0NUHCzpAJLA+tmbFYpbpUKTMvfO2qNZ6yu
         OQkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j6si422531wro.318.2019.06.03.00.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 00:45:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 2E3F867358; Mon,  3 Jun 2019 09:44:56 +0200 (CEST)
Date: Mon, 3 Jun 2019 09:44:55 +0200
From: Christoph Hellwig <hch@lst.de>
To: Hillf Danton <hdanton@sina.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 10/16] sparc64: use the generic get_user_pages_fast code
Message-ID: <20190603074455.GC22920@lst.de>
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190601074959.14036-11-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 02, 2019 at 03:39:48PM +0800, Hillf Danton wrote:
> 
> Hi Christoph 
> 
> On Sat,  1 Jun 2019 09:49:53 +0200 Christoph Hellwig wrote:
> > 
> > diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> > index a93eca29e85a..2301ab5250e4 100644
> > --- a/arch/sparc/include/asm/pgtable_64.h
> > +++ b/arch/sparc/include/asm/pgtable_64.h
> > @@ -1098,6 +1098,24 @@ static inline unsigned long untagged_addr(unsigned long start)
> >  }
> >  #define untagged_addr untagged_addr
> >  
> > +static inline bool pte_access_permitted(pte_t pte, bool write)
> > +{
> > +	u64 prot;
> > +
> > +	if (tlb_type == hypervisor) {
> > +		prot = _PAGE_PRESENT_4V | _PAGE_P_4V;
> > +		if (prot)
> 
> Feel free to correct me if I misread or miss anything.
> It looks like a typo: s/prot/write/, as checking _PAGE_PRESENT_4V and
> _PAGE_P_4V makes prot always have _PAGE_WRITE_4V set, regardless of write.

True, the if prot should be if write.

