Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E45DAC73C5A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 20:37:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BA8321670
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 20:37:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="J+oSXowC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BA8321670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2FEB8E005C; Tue,  9 Jul 2019 16:37:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE07A8E0032; Tue,  9 Jul 2019 16:37:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD04F8E005C; Tue,  9 Jul 2019 16:37:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4B758E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 16:37:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so13367759pgg.15
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 13:37:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sLiP4UA1DyazAQmoXMthEbO6RhFdgT0unr+HzqnFKaU=;
        b=Xh29BF0WJGNslLaceszKKV6emgVtGxBaA5KOlpTHaqQnDoxrEfBVqAoDeHCFYUqLVP
         dviNBASSHk6OcgCTBqoDn7joBdQjWAFL5Whgbeydx+fDENRFuka9EuTMxuPhnXHECmGy
         Xt0xgUYaLSpg8gUoZhXcpZWnGUxB739ns9wwPv+u3E3cp5yoED8jF1EEAFU+4Pnup9TV
         +IiSrpLRizi36kBN9qh4Twam8s7QLjPoIs6DQ/B3+ldsRBfxTgUxuAKqQpBRsITFjGyX
         RmHJXdWZKQIJJYlyz/6DNqKZwK5dd3IhYcaPAkBnLxcXfBbAnx5LMf/wcsvlXBRoWuh6
         4UgQ==
X-Gm-Message-State: APjAAAXUCGTn4f1MU55v2prNfirOoM4OPj2ObX6DCto7U8yy1nEsjqw7
	SMOatCZ7z/3dEf0fFAfkga0b+jjBSdGWebZlFdC7LLk+cvoXwMt+me5H6vKrKrlt1klDEmoakL/
	nML2zg8bnFyXQ9vl72CXAK55x5VKk9mghyStoFx4NSMYjA/FbDvzCsRhprO4Lr/DJ7w==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr33443104plp.95.1562704659114;
        Tue, 09 Jul 2019 13:37:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeRtCXm5KwGlcJa2X1Tva6uUL5ilYRsJHMvKNnfwRGVyxautHTHs0wB3xUWbFPG1o2mV5r
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr33443068plp.95.1562704658325;
        Tue, 09 Jul 2019 13:37:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562704658; cv=none;
        d=google.com; s=arc-20160816;
        b=LP718v9WT55PEZS4zxnuLYc5tqgdq5fMYk94PQFu/+vd1T7lMLFQciPIrpJIdBPi2I
         ZZsgQdPZdGQoClMrXTXOul14LqLJo6VD8RPwt1j2f9xMvaDDtZny0KLh5b7UHQqpPnvm
         XqNhC8bSeqlSdIdVrwnBNakSTZyr3D0pNhbA2fxBzjEVKmLG3BWdrzPDJ+qaTkxr8oCA
         6/TaiuXxOj6/7nYaLl/OupGbF155Q0wjPKM6vdhEadHXp/gDAGr2k5nLOpXEquRZerIy
         yAxpOKtKurW/xS7ljZfAjmXHEBabRmqV3mKbemthyVnpzmvk98rYSJRoQTx9DrC7xYlY
         mgbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sLiP4UA1DyazAQmoXMthEbO6RhFdgT0unr+HzqnFKaU=;
        b=qDVVmXMHiRuh3SSse2p/JA0qJiXQFomjaySH2v0D4Bh6/mnoJWWb9po9hnpk9KfKbF
         ThL+3CdFcLuDLdhrHRuG74rdGAo9GfKatGxBBCltXn4IfZIQRHUNkYEEWRZ7zgQSSOmS
         cpoLZLiPX421WIX0RXCEpmA/yi63nGRXyKUkrqa7MbGbsLKjV5Mad28hEidp0XQHlIqV
         BWly1yeGiEgnaHs2a5RoXJxUGgpY1WVAl52/rmKuFAhCX/amCtP/3NMEUwGndokBGmBx
         1FGQKgAqQMG2YXkYr580b097EwcF2n2lurt6Z9IU9T2CSQo4VVphOg7yEGjj+tZSYpvS
         s4Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=J+oSXowC;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c11si22970221pgk.383.2019.07.09.13.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 13:37:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=J+oSXowC;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4C6CA20861;
	Tue,  9 Jul 2019 20:37:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562704657;
	bh=/9LTzKi2u4iUq755wikCwdwulj3n2J071wkeNeptzIE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=J+oSXowCJu1Ojf7ZugvCFOUS/kT5hfSiz48WLrqAbUGjEHMko79VqV+tiTfBPcwzL
	 vSSbj06XgQKQbh2t6Z60kkhgAuMmF6IP0GT18Z+jf4x7Zg0QxDmuIr3q5wuCx65KbV
	 vfgDL/QRQJKySDVn6SeD2m7kXE4QAqa1KdtZNkMA=
Date: Tue, 9 Jul 2019 13:37:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mark Brown <broonie@kernel.org>
Cc: Lecopzer Chen <lecopzer.chen@mediatek.com>, Mark-PK Tsai
 <Mark-PK.Tsai@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>,
 Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Mike
 Rapoport <rppt@linux.ibm.com>, kernel-build-reports@lists.linaro.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-next@vger.kernel.org
Subject: Re: next/master build: 230 builds: 3 failed, 227 passed, 391
 warnings (next-20190709)
Message-Id: <20190709133736.31f22a5e4aae49fec83faa99@linux-foundation.org>
In-Reply-To: <20190709151333.GD14859@sirena.co.uk>
References: <5d24a6be.1c69fb81.c03b6.0fc7@mx.google.com>
	<20190709151333.GD14859@sirena.co.uk>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jul 2019 16:13:33 +0100 Mark Brown <broonie@kernel.org> wrote:

> On Tue, Jul 09, 2019 at 07:37:50AM -0700, kernelci.org bot wrote:
> 
> Today's -next fails to build tinyconfig on arm64 and x86_64:
> 
> > arm64:
> >     tinyconfig: (clang-8) FAIL
> >     tinyconfig: (gcc-8) FAIL
> > 
> > x86_64:
> >     tinyconfig: (gcc-8) FAIL
> 
> due to:
> 
> > tinyconfig (arm64, gcc-8) — FAIL, 0 errors, 0 warnings, 0 section mismatches
> > 
> > Section mismatches:
> >     WARNING: vmlinux.o(.meminit.text+0x430): Section mismatch in reference from the function sparse_buffer_alloc() to the function .init.text:sparse_buffer_free()
> >     FATAL: modpost: Section mismatches detected.
> 
> (same error for all of them, the warning appears non-fatally in
> other configs).  This is caused by f13d13caa6ef2 (mm/sparse.c:
> fix memory leak of sparsemap_buf in aliged memory) which adds a
> reference from the __meminit annotated sparse_buffer_alloc() to
> the newly added __init annotated sparse_buffer_free().

Thanks.  Arnd just fixed this:

From: Arnd Bergmann <arnd@arndb.de>
Subject: mm/sparse.c: mark sparse_buffer_free as __meminit

Calling an __init function from a __meminit function is not allowed:

WARNING: vmlinux.o(.meminit.text+0x30ff): Section mismatch in reference from the function sparse_buffer_alloc() to the function .init.text:sparse_buffer_free()
The function __meminit sparse_buffer_alloc() references
a function __init sparse_buffer_free().
If sparse_buffer_free is only used by sparse_buffer_alloc then
annotate sparse_buffer_free with a matching annotation.

Downgrade the annotation to __meminit for both, as they may be
used in the hotplug case.

Link: http://lkml.kernel.org/r/20190709185528.3251709-1-arnd@arndb.de
Fixes: mmotm ("mm/sparse.c: fix memory leak of sparsemap_buf in aliged memory")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Lecopzer Chen <lecopzer.chen@mediatek.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/sparse.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/sparse.c~mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory-fix
+++ a/mm/sparse.c
@@ -428,7 +428,7 @@ struct page __init *sparse_mem_map_popul
 static void *sparsemap_buf __meminitdata;
 static void *sparsemap_buf_end __meminitdata;
 
-static inline void __init sparse_buffer_free(unsigned long size)
+static inline void __meminit sparse_buffer_free(unsigned long size)
 {
 	WARN_ON(!sparsemap_buf || size == 0);
 	memblock_free_early(__pa(sparsemap_buf), size);
_

