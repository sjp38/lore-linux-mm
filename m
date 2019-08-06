Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C28B0C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A8120C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="XTjnnHi8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A8120C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 253E76B0003; Tue,  6 Aug 2019 10:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DD106B0006; Tue,  6 Aug 2019 10:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004746B0007; Tue,  6 Aug 2019 10:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D49B86B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:39:06 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 41so73245443qtm.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R5CPIS4mmyxALTwu292eKFtIXYTqe3SCg3BcaBK423k=;
        b=srJP18V+UmnNSzEHnHCOwUMIgRjgQ4yBjO7pkbM3ix2xWlw42SNz1Mcn2/mnivDcre
         eZUdctip885sSAgfIWZV+NhSyXqNGJBmR3B95J0avDjBa4ueG7yA3M2MUG4sbj7Qo2Dn
         W0Sx7AVTqEJMHU5C4RDsbwLgSj7tUGM3tJbN/Wx9ZkdeJDetWhfOVfajpyxXfiU23Qp8
         QY5sCJrHiN+qnAQOExuiy9ETgVKcQG85CnPbSSDJJmjHkHpTrZqcUvPEOauIromtacB/
         MrQ2XF2X8R6+4dd9RGh0fL01J+A008+KmOQghKnzmfjGvtBAwOK6HCgKlOYTFqBlQF6B
         24pQ==
X-Gm-Message-State: APjAAAXW1E+eMTJGCKAPvTytpbnYVmOZANIAlch91Oll7tSaEBj7uN+v
	Hb1LDQCDflZBfyEzZ6CmypyzVuEcNJPcxsMzeVxIJhC+lJiym7E8Eg+yilDchsLKiTDT8beU1/O
	kVHowC+BZdwTL74RAfkVIrSVE1W1A6+WOEDFz8qKATC0C7YHDudiSqdBwKIJ0wbv5Kw==
X-Received: by 2002:a0c:ed31:: with SMTP id u17mr3319260qvq.107.1565102346646;
        Tue, 06 Aug 2019 07:39:06 -0700 (PDT)
X-Received: by 2002:a0c:ed31:: with SMTP id u17mr3319204qvq.107.1565102345922;
        Tue, 06 Aug 2019 07:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565102345; cv=none;
        d=google.com; s=arc-20160816;
        b=qwYAF9aPKUTJG7/KOhurJaLOd9rUBtzny96TOHo6lzqjYEZCX8sRLjvAgAvs1SR952
         syek3FLR2I5SIfFxybsEU+eYblBsb1diQfGhj2jKLeJUgIComksBaG7QQ3hkdUDUdG5o
         EdmMXteDRSzZ8NMHnz6goS1z2iCba401TiRZHv/UkSFoZSv3Euh6yxnXKTypFTdWRwOb
         l8cJIzgsYh/7miQIpw9xbi03CpsIv6yijeJDSkMQzZcRmZXsGWYo3xfHvhxVAII3dMuP
         FK0YoY4NURPoU1TKo+CUwAK6DstEcVA170hb5/f1jkZZToLRL1s47KQIkyedHXunLsQ5
         xTWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R5CPIS4mmyxALTwu292eKFtIXYTqe3SCg3BcaBK423k=;
        b=UhzyzC8oz6QcOylG2uI46m2s7wiLQ7D9Pep2fe+Ea/ndxGzUclg/BS5sokANAVZRCk
         ls+Q0B3l+0xxT3iV+DBZicZoBxa8fa4A4yPcW2w/COhdx708nb/tzYnHj3E5KJEdsCvJ
         lEiwBxQt/GTEv5l9Z08GB8Drt2/aMFYfP3kVQ2401cc3CI3LsxIdrAaYMKA7vS6IhY8d
         e/1EnqDUsTbp4WwEVjf3QQYpFnPYEbKxdzVQO9g5g6jgK7tkwGpibOdoD0NMhy4+2RR3
         qa+2PwHAjc7PL3Y4IlBAwnuWw2x/MPB6r8f12fWcLj4ahy3uOeorsgu9v9mMjyIRPC7v
         eBag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=XTjnnHi8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor74523224qve.42.2019.08.06.07.39.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 07:39:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=XTjnnHi8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=R5CPIS4mmyxALTwu292eKFtIXYTqe3SCg3BcaBK423k=;
        b=XTjnnHi8z+SYvy9zIZcrSsQ/4Y2tZDIGwuTiAd3On/3Qyk2jJKpY9TJZwKkhDIEj3+
         MGHtt3rEv401lGpVq5xL0CKheYAiDCONwdtltzljbu1GSNGjaTUSRBGuj6fMXfPd7xx9
         AvWLguAEFAriYfUuE/os0GFuvFNJgqJH9P1XG2mJ+YwX0AZhkzMufVj8RERsoxhYeF6L
         xRIbWAbvwo4On/nNeR5bWsE7X6QGURzO6ky4zV3wi1UlvTjZErwMLSfQ7U9cov+5JWeV
         kG6leE1orrap1pWD6YdXGVpsb3smabaJfOBSV25ApiXrIfZ6NUpp239eLF46tRKUjS0M
         cRZg==
X-Google-Smtp-Source: APXvYqxb9K01d3+TG7ks63JaVg+hAktf2Hz+U/53HsIRu0RYyLZKlOzhu0DzA2UWt4gOEDGxB6xX5A==
X-Received: by 2002:a0c:e001:: with SMTP id j1mr3394954qvk.110.1565102345637;
        Tue, 06 Aug 2019 07:39:05 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id d71sm500507qkg.70.2019.08.06.07.39.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 07:39:05 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv0cC-0005jc-Oe; Tue, 06 Aug 2019 11:39:04 -0300
Date: Tue, 6 Aug 2019 11:39:04 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, arnd@arndb.de,
	kirill.shutemov@linux.intel.com, mhocko@suse.com,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] asm-generic: fix variable 'p4d' set but not used
Message-ID: <20190806143904.GE11627@ziepe.ca>
References: <1564774882-22926-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564774882-22926-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 03:41:22PM -0400, Qian Cai wrote:
> GCC throws a warning on an arm64 system since the commit 9849a5697d3d
> ("arch, mm: convert all architectures to use 5level-fixup.h"),
> 
> mm/kasan/init.c: In function 'kasan_free_p4d':
> mm/kasan/init.c:344:9: warning: variable 'p4d' set but not used
> [-Wunused-but-set-variable]
>   p4d_t *p4d;
>          ^~~
> 
> because p4d_none() in "5level-fixup.h" is compiled away while it is a
> static inline function in "pgtable-nopud.h". However, if converted
> p4d_none() to a static inline there, powerpc would be unhappy as it
> reads those in assembler language in
> "arch/powerpc/include/asm/book3s/64/pgtable.h",
> 
> ./include/asm-generic/5level-fixup.h: Assembler messages:
> ./include/asm-generic/5level-fixup.h:20: Error: unrecognized opcode:
> `static'
> ./include/asm-generic/5level-fixup.h:21: Error: junk at end of line,
> first unrecognized character is `{'
> ./include/asm-generic/5level-fixup.h:22: Error: unrecognized opcode:
> `return'
> ./include/asm-generic/5level-fixup.h:23: Error: junk at end of line,
> first unrecognized character is `}'
> ./include/asm-generic/5level-fixup.h:25: Error: unrecognized opcode:
> `static'
> ./include/asm-generic/5level-fixup.h:26: Error: junk at end of line,
> first unrecognized character is `{'
> ./include/asm-generic/5level-fixup.h:27: Error: unrecognized opcode:
> `return'
> ./include/asm-generic/5level-fixup.h:28: Error: junk at end of line,
> first unrecognized character is `}'
> ./include/asm-generic/5level-fixup.h:30: Error: unrecognized opcode:
> `static'
> ./include/asm-generic/5level-fixup.h:31: Error: junk at end of line,
> first unrecognized character is `{'
> ./include/asm-generic/5level-fixup.h:32: Error: unrecognized opcode:
> `return'
> ./include/asm-generic/5level-fixup.h:33: Error: junk at end of line,
> first unrecognized character is `}'
> make[2]: *** [scripts/Makefile.build:375:
> arch/powerpc/kvm/book3s_hv_rmhandlers.o] Error 1
> 
> Fix it by reference the variable in the macro instead.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
>  include/asm-generic/5level-fixup.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
> index bb6cb347018c..2c3e14c924b6 100644
> +++ b/include/asm-generic/5level-fixup.h
> @@ -19,7 +19,7 @@
>  
>  #define p4d_alloc(mm, pgd, address)	(pgd)
>  #define p4d_offset(pgd, start)		(pgd)
> -#define p4d_none(p4d)			0
> +#define p4d_none(p4d)			((void)p4d, 0)

Yuk, how about a static inline instead?

Jason

