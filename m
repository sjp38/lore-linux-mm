Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41048C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 12:16:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F252721734
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 12:16:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="dcvMx2nn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F252721734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D0008E017B; Mon, 25 Feb 2019 07:16:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7566F8E0005; Mon, 25 Feb 2019 07:16:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F74E8E017B; Mon, 25 Feb 2019 07:16:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3F38E0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:16:08 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id u8so3466100pfm.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 04:16:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QoHK3PgkDfCguINsmSF+2MuDz+h6HTxyVRXfDqtpRZg=;
        b=CoNo5It6tKIsI4iaOjb3Z3C5XxeunA2gjMiyOiAPsTrucRtSeBLCP4iEKboiZZjnES
         VNudT+TAhSw7aiD6n4kQNf8u6roO9aB7+BxF67Ym2w4G8kIX5elOX2xw8hq6lC0/9oyc
         fBTY7dG6F/XbtWMsZLEFvbVl/PB2mZKWnsOSLaDWKNGJexheVbMICzcIOORWdVYHn/QN
         rfe4FEZiJuB7U14vnghkacrUVsSPY+ThgwJy3v19gjMyUhxE8sOEGi+4c/z4oygG0yy3
         zwlsVdvm1D40hCEV5+SpLRlKnsdEvzqQGMGywVimH2qVAnhwz00wAY8B6ii5R5g/0Z5f
         goKg==
X-Gm-Message-State: AHQUAuaMfmSIu9KLqooTtcQJAJu2iev5EU4yR+egEfm+I+V7p+e05uVD
	I/9V6ohAgpifxoT/03te+IE3HfLZwtvDkiTehV3lqPFscr3BPV2+UNGzqaXcyY+W7p7reW+EurX
	YyM0rOdZnrDXtOD+nfld1MlePK6AUw+nA1oKtFxxOyG33avd5FgdhPjCn+oCfek3x3GY2DZdM6q
	zxecLOBgEDbwXei8XVuERlkg30t4INnrwcmBnPZF9hhsu0UfqUDczZk6G2B5koLtSCib3jiCZHm
	IviA3Yl3eV3yin4NXH8+8WRYmfCoSbLcfBvZuW5rE23DDpBeU2+aVf65M7zVosej++KpgdprISG
	RQwap37rqgJSis317eq+fNMBxGEzQP7QCchvQ9ExszL3veijGm8Geh9uiWvs1zqGv4re+BKIZHg
	Y
X-Received: by 2002:a62:e40d:: with SMTP id r13mr5465307pfh.11.1551096967550;
        Mon, 25 Feb 2019 04:16:07 -0800 (PST)
X-Received: by 2002:a62:e40d:: with SMTP id r13mr5465240pfh.11.1551096966496;
        Mon, 25 Feb 2019 04:16:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551096966; cv=none;
        d=google.com; s=arc-20160816;
        b=qEvRBK2PyfG3PyeCsZHwnlpMwsIn/Y/CZw0lypkyZp8jufeDeJ7/IkJIKHvU2SdF1J
         Ui9sD5iZpkZZCL+9mQ1dThiRYGKh/dlVpGSWODMTgLLPjz1teZng7sFX9AhLg6SG6Pm5
         tCT7CO1zF0kHBR0S1PLadF0kEK12Wri4ZfsNpwIpqoCwtf1FPlU3KjNswJjcSFqEj7M9
         sRxIj9gcOHpeOXp19+TP9B5uZeuDvYOetIGnULNRo5zRb2sWvSsSJ57ceD4POItyOiQO
         y0JnWv5itMu2SDrCUtte5rECmqUTRn3IIMHXRh8xaLLf0JwwKNdSh3guKv2KkYXjsnqv
         MfKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QoHK3PgkDfCguINsmSF+2MuDz+h6HTxyVRXfDqtpRZg=;
        b=Wjt0qU75jMOJJ9hNSrPdUMYRPvhhY7zSknpneIhYZT4XrOqJTAgof9L3VW+droJnP0
         JJ2QjkvGDKJYLFdpN87y1KkgcXbZRg+cKlmfnnTkLlhEeCPjSnjvLLDFOhL2nuzWivJz
         15E35JiVGcjKWJA0RIBcqe6XDv+lSxzGYnMs25fmi5crTILQKW1dbpCjyk8NCMBEZTFU
         Jb3AyarHuyDQFrjxr7j1BLEo8f7HVEDkjyEkjv6NkKm5IadPFFJWvFqPGB/Tra15XZG8
         iDLGXwv4qlyo/b+taKOAPLLZBcUYrji5sDMHjwCU2bRW38DJc7i7Bv9jc0IaJ5z3lG69
         swgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dcvMx2nn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i35sor6922525plg.40.2019.02.25.04.16.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 04:16:06 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dcvMx2nn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QoHK3PgkDfCguINsmSF+2MuDz+h6HTxyVRXfDqtpRZg=;
        b=dcvMx2nnQUb9KYZws9peECQMeHPpL5aFu9AtR8QIYHJRPARWGWWLtCeJWg2lkjFExc
         +Yu9GZq2U/OUigzY7nhXv/N12yv7ZDnTQVXvXdoRpfC5IPwdNBlCKHAT9hHWBgQltGbm
         6J1mi3qweufoa7wFeQ6aJOEODl611JN3aFUwBbMNoegswcIM9ZKNAYWbC7SHM/oxs+xJ
         sML5p6lFAMh6zDGafz4iDkkp5h/bYb0pcfDQSeTWEdasAm58VHoNgKjj4DktD1XZRzSP
         Y6k1fNzfrebGzArL8N+Awr5NHTiUcSeCD8YvhAa3LYe8LjSBouDhGiD3BUQWP4/VKnON
         cIVA==
X-Google-Smtp-Source: AHgI3Iae/hpdKws0On9nrGt+ofyS6R3GDjkkiVtcw6MZEHcEu3RLsH4W58bju8+OLMI5bulx6+MHGA==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr20151663plk.126.1551096965898;
        Mon, 25 Feb 2019 04:16:05 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.41])
        by smtp.gmail.com with ESMTPSA id h64sm16611921pfc.142.2019.02.25.04.16.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 04:16:04 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 97A8B301717; Mon, 25 Feb 2019 15:16:01 +0300 (+03)
Date: Mon, 25 Feb 2019 15:16:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	hughd@google.com, joel@joelfernandes.org, jglisse@redhat.com,
	yang.shi@linux.alibaba.com, mgorman@techsingularity.net
Subject: Re: [RFC PATCH] mm,mremap: Bail out earlier in mremap_to under map
 pressure
Message-ID: <20190225121601.k4g7cabebeemthae@kshutemo-mobl1>
References: <20190221085406.10852-1-osalvador@suse.de>
 <20190222130125.apa2ysnahgfuj2vx@kshutemo-mobl1>
 <cfc53e5a-a403-a732-69d2-1f96b8416f6d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cfc53e5a-a403-a732-69d2-1f96b8416f6d@suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 12:46:46PM +0100, Vlastimil Babka wrote:
> On 2/22/19 2:01 PM, Kirill A. Shutemov wrote:
> > On Thu, Feb 21, 2019 at 09:54:06AM +0100, Oscar Salvador wrote:
> >> When using mremap() syscall in addition to MREMAP_FIXED flag,
> >> mremap() calls mremap_to() which does the following:
> >>
> >> 1) unmaps the destination region where we are going to move the map
> >> 2) If the new region is going to be smaller, we unmap the last part
> >>    of the old region
> >>
> >> Then, we will eventually call move_vma() to do the actual move.
> >>
> >> move_vma() checks whether we are at least 4 maps below max_map_count
> >> before going further, otherwise it bails out with -ENOMEM.
> >> The problem is that we might have already unmapped the vma's in steps
> >> 1) and 2), so it is not possible for userspace to figure out the state
> >> of the vma's after it gets -ENOMEM, and it gets tricky for userspace
> >> to clean up properly on error path.
> >>
> >> While it is true that we can return -ENOMEM for more reasons
> >> (e.g: see may_expand_vm() or move_page_tables()), I think that we can
> >> avoid this scenario in concret if we check early in mremap_to() if the
> >> operation has high chances to succeed map-wise.
> >>
> >> Should not be that the case, we can bail out before we even try to unmap
> >> anything, so we make sure the vma's are left untouched in case we are likely
> >> to be short of maps.
> >>
> >> The thumb-rule now is to rely on the worst-scenario case we can have.
> >> That is when both vma's (old region and new region) are going to be split
> >> in 3, so we get two more maps to the ones we already hold (one per each).
> >> If current map count + 2 maps still leads us to 4 maps below the threshold,
> >> we are going to pass the check in move_vma().
> >>
> >> Of course, this is not free, as it might generate false positives when it is
> >> true that we are tight map-wise, but the unmap operation can release several
> >> vma's leading us to a good state.
> >>
> >> Because of that I am sending this as a RFC.
> >> Another approach was also investigated [1], but it may be too much hassle
> >> for what it brings.
> > 
> > I believe we don't need the check in move_vma() with this patch. Or do we?
> 
> move_vma() can be also called directly from SYSCALL_DEFINE5(mremap) for
> the non-MMAP_FIXED case. So unless there's further refactoring, the
> check is still needed.

Okay, makes sense.

> >>
> >> [1] https://lore.kernel.org/lkml/20190219155320.tkfkwvqk53tfdojt@d104.suse.de/
> >>
> >> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

