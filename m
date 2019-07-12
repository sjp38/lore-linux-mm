Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D86F1C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BB182146E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:09:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LQjMfmek"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BB182146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 104648E016B; Fri, 12 Jul 2019 19:09:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B3838E0003; Fri, 12 Jul 2019 19:09:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBDFD8E016B; Fri, 12 Jul 2019 19:09:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA9B8E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 19:09:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so9116197edb.1
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 16:09:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Mp2L3+PxgXR8+xXdOZiEFJ7C433LcerfS54GdFQeN60=;
        b=tb7rNtNc0Qsl47Mnfm5X5+XSSHoewSkcTOxtCcAS2iMb1D/h2ku6A37nhsWTbFh4rw
         nTOHSmTygiM3FoYy1YyyUebIN2IwwK+L07QMufSEZckYp6dq48Gq2BUmb0WaCc5TbF6G
         EByBt9wvZL4XUZJUm26URVmAU//rNFlqBGcp6Pzqn3+vPyFGLEvazWtBIhRBOY8Yd9ys
         +R4QYK/Gf1FovvTY1Rv5Qz4org7+agYWeSXaUlKT2LjEoFX6o95dL5G1XjPockt7HHZq
         Ew2FpmZyQD0HR4m+BW9p1uFI4vAGnfxLcvV/gYyZ9JuPJbzd5WayzhVm7ykut2bLXFAG
         xx3A==
X-Gm-Message-State: APjAAAVQA2IDC90HdEoYQn67r18smfqqOnx7zDrfw1RT8ZMa6L7D51Uc
	4bcwGK3sW1QnqBjazjIQ1zG8Xky3mBGEmP0siyWnO1ql6XF1RMzvgKl92smpz2dt7g9WK0pl0Jb
	vrSUwCJyJlyUaqck3CyYam2C3F3xp9EVc0GXg8NH9vQWhwvYXGKDIN9euNEXkIMxYtg==
X-Received: by 2002:a17:906:6c16:: with SMTP id j22mr10466406ejr.307.1562972956115;
        Fri, 12 Jul 2019 16:09:16 -0700 (PDT)
X-Received: by 2002:a17:906:6c16:: with SMTP id j22mr10466368ejr.307.1562972955268;
        Fri, 12 Jul 2019 16:09:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562972955; cv=none;
        d=google.com; s=arc-20160816;
        b=FePBKF5cd9o/5Rxv2vud6Szu9UpsaWuNWp3+AZvL6CgMoTJJn12Givs6aMaShlNl9W
         Us3+SoOx4SCJHsheRhPp6gWxwcmiMPB0EMkQttLhkroIb0L1f6ud+iMlWGkEhS48ohE0
         H4FfCxwSGckfNt0l2K62xPDTjYmNaz1tSJwwy5C31ZVY3e8FnZx+TItyePhip3SxZnN7
         fFEFhpOHuQoE546tM2Nwn85aXHLttk4Qct8WCF+dyW0qkm4q2AdsKAtlvkSj9bJAzX/N
         YlafYikeQO1roGxH8SGAjBUZ6KAv87WDbqlilspTfaJ4jSC1pgLA4Udiy1FkwtjWhvdj
         tTBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=Mp2L3+PxgXR8+xXdOZiEFJ7C433LcerfS54GdFQeN60=;
        b=hV3ccamRgczPFc+KUrQPjGQtVHhcsvWv1IQIJw/OsivK0PUK6U7GMZpD7IPtyvVIuO
         H+y02h+k8usZcXzHLxkAsP3iRr+VRBIxM3zCram5F8zBI/NobYZks+mi1uPzYsRyiFaQ
         r7oNHELgkkF9ROMKVj/ZNoJp/Zp0lh4HxHpmD7rA7AwmLjl/16+xkwqjAm7z6X7ygObT
         O8rsUmTnraZuNslymZ8KQ6ISiwly4+7e7BwUlbonTqN0iqLld3toWTsnrEra5iIHivsf
         8pYBiIiWEnV3+ktc4y3nm1c/2mpnnkyeNifgguvazr12bPYui1klAr4nFzx0ahlF50gZ
         luvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LQjMfmek;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l33sor8705411edd.23.2019.07.12.16.09.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 16:09:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LQjMfmek;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Mp2L3+PxgXR8+xXdOZiEFJ7C433LcerfS54GdFQeN60=;
        b=LQjMfmekW6FIyum3X8Tu6KAwYJZpsP1W7C4wzzkjJaINWv0Cdlzp1a0TT/rq9nnGz7
         2x13o5w8cfwIdeVMkYonffNcDvmOI4oAQpv18KCELSgXrBu6zLzzh6HJ3I/p1GAyABIz
         +I9BcL3zfHm1V6yjnHRCGnytetrWxHup3dmQ/gcct/WJCE3DA56QZXR/Pebbl5yByrjL
         f0sSONp5AVLhtR4CYedkha4dVx2Orb+S2YVbJ5tTJmgiJ0bfLKgxQm8GUi2nEng8rtYr
         xgy/lFiJXPmwb0uN3Mgil2A1RBB3gyoEbdwZpu3fZ95dwkph4943Ei19/VO2U9NzbwYr
         bxdg==
X-Google-Smtp-Source: APXvYqzB7ir9/0LKvQ53vpsIdcgNNk/iqKUX0f46wSvbBPOxh+fd4lNokvB/gAWUwBgaIA8FAx6kjg==
X-Received: by 2002:a05:6402:14c4:: with SMTP id f4mr11724254edx.170.1562972954833;
        Fri, 12 Jul 2019 16:09:14 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id c16sm2958237edc.58.2019.07.12.16.09.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jul 2019 16:09:13 -0700 (PDT)
Date: Fri, 12 Jul 2019 23:09:13 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: KarimAllah Ahmed <karahmed@amazon.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH] mm: sparse: Skip no-map regions in memblocks_present
Message-ID: <20190712230913.l35zpdiqcqa4o32f@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1562921491-23899-1-git-send-email-karahmed@amazon.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562921491-23899-1-git-send-email-karahmed@amazon.de>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 10:51:31AM +0200, KarimAllah Ahmed wrote:
>Do not mark regions that are marked with nomap to be present, otherwise
>these memblock cause unnecessarily allocation of metadata.
>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Mike Rapoport <rppt@linux.ibm.com>
>Cc: Baoquan He <bhe@redhat.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Logan Gunthorpe <logang@deltatee.com>
>Cc: linux-mm@kvack.org
>Cc: linux-kernel@vger.kernel.org
>Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
>---
> mm/sparse.c | 4 ++++
> 1 file changed, 4 insertions(+)
>
>diff --git a/mm/sparse.c b/mm/sparse.c
>index fd13166..33810b6 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -256,6 +256,10 @@ void __init memblocks_present(void)
> 	struct memblock_region *reg;
> 
> 	for_each_memblock(memory, reg) {
>+
>+		if (memblock_is_nomap(reg))
>+			continue;
>+
> 		memory_present(memblock_get_region_node(reg),
> 			       memblock_region_memory_base_pfn(reg),
> 			       memblock_region_memory_end_pfn(reg));


The logic looks good, while I am not sure this would take effect. Since the
metadata is SECTION size aligned while memblock is not.

If I am correct, on arm64, we mark nomap memblock in map_mem()

    memblock_mark_nomap(kernel_start, kernel_end - kernel_start);

And kernel text area is less than 40M, if I am right. This means
memblocks_present would still mark the section present. 

Would you mind showing how much memory range it is marked nomap?

>-- 
>2.7.4

-- 
Wei Yang
Help you, Help me

