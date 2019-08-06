Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 341C2C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:45:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4ECF20C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:45:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="dCNqxHY8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4ECF20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6863F6B0003; Tue,  6 Aug 2019 06:45:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6370F6B0005; Tue,  6 Aug 2019 06:45:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5255A6B0006; Tue,  6 Aug 2019 06:45:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 040C36B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:45:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so53597828edt.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:45:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mLxh1xnnQMfeNrHf0aYqKYeviGu5yN55vYMo0/wqLZk=;
        b=g1GzfnHM0fD0qEs5If7woBQffswTZKslLMxovU+tTnh8e6JwFqXx5E5gtlZzkpaVGy
         fLdtt0X9OyCZJFtYBhZSNIk6yZt3lzZ0x3oywfwmsBsO2cu9Te8Yd8m4j7zNB8+RB4VH
         eHYxclCDZnuj0tHXiu82RUJwW7i7GfWrSDRlyGMNyjTa2zYnZW5nnz4WcLkJLu8H8SlJ
         HfxUvmby+kOXHMHjTqFHk8LRJNymnxfYCsOrYMXhfJzclya3MY9VWAMQ1oOc4ATdIh8z
         iTYWEeICgM+sVWK5Dlj6lMv9H6l4kUlG/wHz4sS4wXiAfU+qkCNSWSsNpArwkKOlMY0u
         7GTA==
X-Gm-Message-State: APjAAAU8Vq9kZNGxxo1fiOQJYDsdeoHWAX3Dicbj4LuQASzOpOrs7+Kf
	SyBoDp8gQo92MtN7oi9P1YDOGu4VTOme1JlocExBDCc0EujKLYnRDqjcCFR+xE4XL4Ybk+NPnAM
	wFlj2z0EhUXOV+KE7upiaZ1v/3qphiSi8EysBhDsfij04WB/TQ21KP4X6tui3VXo38g==
X-Received: by 2002:a17:906:1fd4:: with SMTP id e20mr2494151ejt.242.1565088318578;
        Tue, 06 Aug 2019 03:45:18 -0700 (PDT)
X-Received: by 2002:a17:906:1fd4:: with SMTP id e20mr2494099ejt.242.1565088317792;
        Tue, 06 Aug 2019 03:45:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088317; cv=none;
        d=google.com; s=arc-20160816;
        b=N5xKl2s2XjR8rX7XRHvnBrxNxtKzRotQmhmyNKeh1JBYd2eY0KstkuK3u5TIuk5kr0
         yR1Wqz0ExIpI8VLwst7V4fUGxaIJLJOFn1yId+3F7iPvisvU4jfBbEQXSY//htrKMApp
         cHL4XEDfqTH9x6Tedjt+vSE1eZARUx7KOfx/SI19OaZh43UBjNOa1oOm3wMEaQ6Qlb2c
         IpDCCkMCO6iFjispNYFuUJ6cDDUg10tvKzrZ7Tnkgn3unPNHDm48/WN5Hdwm2gt7zjBY
         eciCWskMa8O+Hw20HwN0fH0EFsUci428mTG74skEN78afz2HTkcmtVjeV8Ze8xovpMIr
         +3JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mLxh1xnnQMfeNrHf0aYqKYeviGu5yN55vYMo0/wqLZk=;
        b=m0kMUaF8tHn6Y9uwssPtI827vqKbUm79ViZfp3J636QNw3ASlDcuU6GxiafeehyfGY
         9TADK6r6yp89KAPpYM0ZRpBw4qJmV2wv8gCTQys7r1ho/wmYJjgE/s56AZVGxAC6fEGW
         BxTsq6rVKXC8iHNwwmp2iZy9zlviZYuu6UgBQp/ajn6QFKzhnliYdbXABcRN6f9V/5H8
         jDJehhgMwM0/aVmKUXDjLqJZd8hv8NAWR0qQ/fXMp06Ursld7UtOJbzcvChPbqnqha30
         neuDajghzdmUjhuRrt5gHHQcGO1KUgAK25b/XSj8r9EWeqjUHjx6wI+RJdjjQyfivbL7
         W5hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dCNqxHY8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24sor16694980ejk.18.2019.08.06.03.45.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 03:45:17 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dCNqxHY8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mLxh1xnnQMfeNrHf0aYqKYeviGu5yN55vYMo0/wqLZk=;
        b=dCNqxHY8plIDmYXpsy08QCX+iLvxPKZniVm+ncSZ3Buz54doFAW+0MiXkxSfa6aZ8N
         jTXJVTUqheLEyn7aW+R/fuDvBVdUs6Xh1fwu7j26vjbyzEwKEDlhCUidQu4KmRqzZOVa
         oDhQ+hqdK6ua5BH0xjQgzzSY2YytIfxpQZbUbhHRfBt+5myVtlvcOTS0tg2Us6YrayDX
         spYFcJQpsTWAHLAWlWQ4c+a7j4DzTav2yKnrSBmM6urDLun3EPrbW9LTSp94TCS/Nqy6
         yUFovGgvKMukOtEtX/dZWO89MRVjVrn4dfNeI+KJg31PeTSFYAKqz3WMNOK0C1qeIyJD
         lgzQ==
X-Google-Smtp-Source: APXvYqz/KhBA+ZSNGOJbjZoeKD/ak+4bM/swWsBeb0rTxPioOaajmtlsxRIAU93xegZHr6XtYLs1kQ==
X-Received: by 2002:a17:906:340e:: with SMTP id c14mr2544571ejb.170.1565088317410;
        Tue, 06 Aug 2019 03:45:17 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id e43sm20620511ede.62.2019.08.06.03.45.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:45:16 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 3AED71003C7; Tue,  6 Aug 2019 13:45:16 +0300 (+03)
Date: Tue, 6 Aug 2019 13:45:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, arnd@arndb.de,
	kirill.shutemov@linux.intel.com, mhocko@suse.com,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] asm-generic: fix variable 'p4d' set but not used
Message-ID: <20190806104516.yvioe2t4w2vwvs64@box>
References: <1564774882-22926-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564774882-22926-1-git-send-email-cai@lca.pw>
User-Agent: NeoMutt/20180716
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

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

