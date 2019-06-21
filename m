Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84D3AC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:58:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43FA52084E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:58:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="qF/NDer4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43FA52084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5BA16B0007; Fri, 21 Jun 2019 08:58:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0BA78E0002; Fri, 21 Jun 2019 08:58:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B024B8E0001; Fri, 21 Jun 2019 08:58:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2D26B0007
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:58:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so9079899edm.21
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:58:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dVKGzXA5B6NB4OVvqTStklSLQa0EXu/N0vMf2aCAAmE=;
        b=Ueu7AiG/fjZsA4YFSUvb8IlVWMXNXEJKI1l3Wrp6Sgxz3t8xMdF+rYHfNNcn9d/W2m
         wNfpyVNN4VrxBViZaCRS/ltJ+e6K2KvT2foyOpbysqtFg06rQ/mZOYmPZkon2IApdP8K
         fIEAiyjh7gWiSCbtcXNcsrpF1vt3vO5mUp9x1yHKBxfougnRuDVbn1vNyxPJaRFEDQNo
         xoHUbXzEIVM4x9lhK4nxVc7NMvxNVKckrH6CYnT4FRX9GfZXoNwifUgkJ3kRlV0bKtiU
         hBOg2QtcT3/fRh2NyfM1dnDK4h9noBkQVGagcsGOyncVCsvhSHWi8/Piwaweh1SYzcP3
         ONvQ==
X-Gm-Message-State: APjAAAXJGQblXoTpKR40OXBhBCsMUSqGavT/iYHIVUsjCPBdr0DzMiUp
	PNScMVjWNulMeI9Hcrf6H0f+ce+S2jraCsF3xVCXCggDTwzT3lNplesZjyDCNnheIFJCiAGABAv
	9AxxMuv/J46qJMr7U9pcu8h3jlMVcDMnJeb8QIJAkgPkVhi5rn7Q8GNYczw4BJK3i2Q==
X-Received: by 2002:a50:c9c2:: with SMTP id c2mr107302483edi.183.1561121889947;
        Fri, 21 Jun 2019 05:58:09 -0700 (PDT)
X-Received: by 2002:a50:c9c2:: with SMTP id c2mr107302425edi.183.1561121889300;
        Fri, 21 Jun 2019 05:58:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561121889; cv=none;
        d=google.com; s=arc-20160816;
        b=mGK0mrQcd1llSTeXybk1P1n804tVIbPNrYrdk29ecfYgWoQw1xstrMZhbGIDzy7rXC
         Pse8X5RnhYRgvawwV3cA8F0QuOSTtETTDj7/HpmJJc/+2Z4CbZDbtPR5aU1mGvFVit5n
         3X0WCXC1rC+ZMHDflvPjHsMsh2kbz9samvUlP0PP4GB00KJdGh1rJ0nWxEjoiow10ORS
         7+NwfJRuCkgjR8Xs3w6ZsmTomwRcoNTZEl/wLhTDDASPfYMtAk9qhSNf8zW2XY3/xPel
         MCNCKFL9ZACsO+X5ib6POapjv2lpLNd2BRTncMplNfoSR0nj1wI2ClIEos+7M+wLadZw
         k7vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dVKGzXA5B6NB4OVvqTStklSLQa0EXu/N0vMf2aCAAmE=;
        b=M+Sh4mO81rF5XzcAuv2+WrKyQXbSb1K8MSSh9C6Sh0U6RwBSFH/+eHwSzHiSA/xvl9
         u6v+pBcXxQXmGW5SaCALEELeIMWdcdZ/Qbrp6u/KCJJq2Et3BSotAjjfQoDa2VuFj3SQ
         NgkBAMOeSkXatc29GEitSuYkKA840Wo6U8X4MYUismfuzRYqN9qtcM1So7l0+96IToa5
         RGWN3lZDORjr2vtdnD3IuIooQknvANtdRlbXwcsNWry9qthVrcYJDXMF1bxfbPT+qR1H
         fjxrjrUPeUGZj8DvDkw+AP+L4vuahxms3D0LcrQfg8KTS19IGPiA/Suft4T9YX8/kCLX
         ZvCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="qF/NDer4";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25sor2811426eda.21.2019.06.21.05.58.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 05:58:09 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="qF/NDer4";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dVKGzXA5B6NB4OVvqTStklSLQa0EXu/N0vMf2aCAAmE=;
        b=qF/NDer4aXW8iQ2KeBT1ZkfOz7wLcsRewEWWJy0lXEj7q1aiix6qQSNT3iz5f/40mE
         nsgT+5YWAcuDFlXYaVb2zcPm4tAJOBE/nOzlApMWC+qRjfma1FWHQX/i2nx+yft7wQub
         ZDhJy1fPIBLwql3rDG7kV8aVaTQ+wfmchwUFChNKyJBUZ0YUBoIT4aSetJUIX6z2t8AK
         t/Vc95wEcl7tRE/JnRd8i5wnFOEaeFQ2WYVfCazDmXCAoetSWwYCN/X40mmJ4kM0aX3j
         3JYm/TBNr8ps9GAyc4q6uGaUfGYX8JNi5ROwqDeJa/R1QLMiYUc24W2rGdk+3vNsuScJ
         tVNQ==
X-Google-Smtp-Source: APXvYqx8SzlMLp994dQ93/TAWJyY58mJLu8quPT//Tsira6JSsrNJNaIUZVbHF7B8xIZqJ9mwlxd7w==
X-Received: by 2002:a05:6402:14cf:: with SMTP id f15mr86319232edx.255.1561121889001;
        Fri, 21 Jun 2019 05:58:09 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id i3sm830042edk.9.2019.06.21.05.58.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:58:08 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 6B93510289C; Fri, 21 Jun 2019 15:58:10 +0300 (+03)
Date: Fri, 21 Jun 2019 15:58:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, chad.mynhier@oracle.com,
	mike.kravetz@oracle.com
Subject: Re: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190621125810.llsqslfo52nfh5g7@box>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190614182204.2673660-4-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614182204.2673660-4-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:22:04AM -0700, Song Liu wrote:
> This patch is (hopefully) the first step to enable THP for non-shmem
> filesystems.
> 
> This patch enables an application to put part of its text sections to THP
> via madvise, for example:
> 
>     madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
> 
> We tried to reuse the logic for THP on tmpfs. The following functions are
> renamed to reflect the new functionality:
> 
> 	collapse_shmem()	=>  collapse_file()
> 	khugepaged_scan_shmem()	=>  khugepaged_scan_file()
> 
> Currently, write is not supported for non-shmem THP. This is enforced by
> taking negative i_writecount. Therefore, if file has THP pages in the
> page cache, open() to write will fail. To update/modify the file, the
> user need to remove it first.
> 
> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
> feature.

Please document explicitly that the feature opens local DoS attack: any
user with read access to file can block write to the file by using
MADV_HUGEPAGE for a range of the file.

As is it only has to be used with trusted userspace.

We also might want to have mount option in addition to Kconfig option to
enable the feature on per-mount basis.

-- 
 Kirill A. Shutemov

