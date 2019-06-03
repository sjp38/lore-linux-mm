Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 465BAC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:49:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF11223A48
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:49:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mgXqHJD2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF11223A48
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89E376B026C; Mon,  3 Jun 2019 17:49:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 875336B0271; Mon,  3 Jun 2019 17:49:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78C386B0272; Mon,  3 Jun 2019 17:49:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5E26B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:49:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n23so29381135edv.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:49:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jSb30N0jvHoftFPeqnRT0DDU5guICPUBTZ+cum9JlR4=;
        b=qK0odyPvLc0pdxzNH2Bsr2q/ua7tBpgQp7WphcFN9GEPXYuR3Ym2uUafgxb/FV5J0d
         EDk19GxikEWfQDk9r3u1ukx2npCYgfLCiljlzDmh0gSmUwaIA6NqtMS+sTUg21Vrdd6d
         m7DrBA7WjGzgARSpgcaok0XYIq2wZ6onLC8SEkU43axpMc9oefCaDjqGJIx/yjkV8viD
         j4hLcesBSoEXQK2vUDhcmo+THpNQlNQbr6E/m3MXn9kK2qK+lgm2t/3op/63Uo8+PxGb
         Zf9h5gvJ65mfhvA1wj+88bh2SvKl1nYv2vmjRW5BBWb9aS6wF91FnyHsvkq2p1p2Oq7T
         7gwg==
X-Gm-Message-State: APjAAAWZfYRIgauqG2t4nJ9LWgUiJ/7qMGnmzQ4rIIsS6P2YBaqvyFW3
	BIA7NOFcavmXnFQmFX3drnP3I0sK7mwoJtb1EAy5t4hFArLBQOU7rnKApx526PwxJl4zbv7+7bg
	lFTWCOsR44YFhylk2Me4iQ1ybZoTBfmCFsbOvPumA/mSM3g9pZFyMnj4hc5MYxva9Wg==
X-Received: by 2002:a17:906:1c4a:: with SMTP id l10mr26075584ejg.124.1559598574750;
        Mon, 03 Jun 2019 14:49:34 -0700 (PDT)
X-Received: by 2002:a17:906:1c4a:: with SMTP id l10mr26075524ejg.124.1559598573960;
        Mon, 03 Jun 2019 14:49:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559598573; cv=none;
        d=google.com; s=arc-20160816;
        b=0pGFaYv5D7CcmxAHr2hhRwaFnk8qOtwWQRwKQpf8VEj+V2Npf734B+HlFigQUAgG/i
         sGkNImlGN9KSsBA4PnLsuwIvK2nCW0VtcP8HPK8h4CuBRivmknG+uemFMuGtyleEoaeB
         H++JM7Kgiexs3Ll+Rnex6n5IpQqmUxcgYY1kQwybvJPGoapKCWRJ/EHzkSkKKARayKqD
         DwhoYBYQ2/hlK66DgMGvNjxgl5tA/CWw4yxOsXVQ5gDJuVIH0NGLODjpBhtCdcKef5RF
         2raPiD0f7d87cps6EH9wxmlGYpUkunyilKjOEbzN5mcjTesvfGSPUax6jT4p9hJGKod0
         drLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=jSb30N0jvHoftFPeqnRT0DDU5guICPUBTZ+cum9JlR4=;
        b=H4HFMar0jr6iRvdzCObCx1ueTZIQUlVf0kbMd9rzZWZ62lfoLnOgzSUfvEt7W7Ae0j
         CcVCcn/KIIumYYdLaACIaC7ulD9pvJ75dvNKaH0UT5CZda//ayyu0B80vjy38R0lqRyv
         hhYj3h4330lQTIo4yrbT1wzmcwwFlnP6no+kkj6iEEChb483r3pcoD4gWmm6lsQfRCJw
         3ne7LqsYRHla4CT1mrl+AaHOLJSz3K/bsp2ZstS6fQRfYAt7tgEDbTd8I388XC2EtRpf
         N+VUxqPn2ar56qJ2nn2KVc1I85jir0ztYXGBhwyLc4gyWyl/aMnMPBSW39HGzwde4Fgx
         oKgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mgXqHJD2;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor667164edd.18.2019.06.03.14.49.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:49:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mgXqHJD2;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jSb30N0jvHoftFPeqnRT0DDU5guICPUBTZ+cum9JlR4=;
        b=mgXqHJD2asQbJ2oQs51g/wKDUPSvM+cdNOzAPTyJufLHFAJ19jz11IiehaMBP9Q8ik
         U7cGojJDSlIkY3XlU1wbDp/ZvfgCPH2xtvqbe8RTcqyW4RgEYqKYfvzgUXPExUHfWphX
         l6AEhObQDHlSi21ygsz20Rc+h9b47N32S+aUh7dW5enm+vZUggpdxoXVUyuZMF5MtWwu
         HvQgRVJ2g/tV3CdwcqyDzfDmGbDOJgMVhPQtiAPMWcP+2I1nYtbVep68GhMqaZszwkMu
         ZoMyIv97BEMZtXBzKLTZmelReybdKtsgdltfFU51nMZzyYEnx+zhis0dtU/Ii/M4+PfR
         vrDg==
X-Google-Smtp-Source: APXvYqy1VbSFtSybN1lKgHKlPjNOgnekacgTTpaBFyeruT/9MIRoRmfvBRLBg5v3bxan4Gxq56A6XA==
X-Received: by 2002:aa7:c645:: with SMTP id z5mr31432297edr.43.1559598573674;
        Mon, 03 Jun 2019 14:49:33 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id d5sm1533710edr.8.2019.06.03.14.49.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:49:32 -0700 (PDT)
Date: Mon, 3 Jun 2019 21:49:32 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH v3 05/11] drivers/base/memory: Pass a block_id to
 init_memory_block()
Message-ID: <20190603214932.3xsvxwiiutcve4tz@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-6-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-6-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:46PM +0200, David Hildenbrand wrote:
>We'll rework hotplug_memory_register() shortly, so it no longer consumes
>pass a section.
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c | 15 +++++++--------
> 1 file changed, 7 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index f180427e48f4..f914fa6fe350 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -651,21 +651,18 @@ int register_memory(struct memory_block *memory)
> 	return ret;
> }
> 
>-static int init_memory_block(struct memory_block **memory,
>-			     struct mem_section *section, unsigned long state)
>+static int init_memory_block(struct memory_block **memory, int block_id,
>+			     unsigned long state)
> {
> 	struct memory_block *mem;
> 	unsigned long start_pfn;
>-	int scn_nr;
> 	int ret = 0;
> 
> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> 	if (!mem)
> 		return -ENOMEM;
> 
>-	scn_nr = __section_nr(section);
>-	mem->start_section_nr =
>-			base_memory_block_id(scn_nr) * sections_per_block;
>+	mem->start_section_nr = block_id * sections_per_block;
> 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
> 	mem->state = state;
> 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>@@ -694,7 +691,8 @@ static int add_memory_block(int base_section_nr)
> 
> 	if (section_count == 0)
> 		return 0;
>-	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
>+	ret = init_memory_block(&mem, base_memory_block_id(base_section_nr),
>+				MEM_ONLINE);

If my understanding is correct, section_nr could be removed too.

> 	if (ret)
> 		return ret;
> 	mem->section_count = section_count;
>@@ -707,6 +705,7 @@ static int add_memory_block(int base_section_nr)
>  */
> int hotplug_memory_register(int nid, struct mem_section *section)
> {
>+	int block_id = base_memory_block_id(__section_nr(section));
> 	int ret = 0;
> 	struct memory_block *mem;
> 
>@@ -717,7 +716,7 @@ int hotplug_memory_register(int nid, struct mem_section *section)
> 		mem->section_count++;
> 		put_device(&mem->dev);
> 	} else {
>-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
>+		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
> 		if (ret)
> 			goto out;
> 		mem->section_count++;
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

