Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EFBAC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:20:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 228FB206B6
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:20:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 228FB206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5D5A6B0006; Thu, 11 Apr 2019 07:20:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0CEA6B0007; Thu, 11 Apr 2019 07:20:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FE8F6B000E; Thu, 11 Apr 2019 07:20:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD3D6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:20:10 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n10so5244706qtk.9
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:20:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=gE8DBy8ZknvEWPhXOAMtY9tEqA7/smA66FHYreuujF4=;
        b=Pkmx6EjjV3Y57n35FZVQxS8AxAcYCFcpabKZUNOXFHdnq1dC+/J6yHIiXb81h1uUL7
         9FGKq7ISYnkzKlX6n6Ek7aw/mMqknRmE3PnoN7VA9GbzsN1ZtXX0dy+UlE1/FLLCg4jz
         stzJB6zefn2tdJugayZGFqM3hbf8azgJ7qMC92ib6+TbigBoKKZrkeaPNZmOusbIC5jC
         KDgG0KOGhIkqwWKPtNdzmqJGFpl6MN5Kc8YMaI0MS8N9qEQDdxZsfOlTQfUtguvcOv46
         2Xqhtx53P2rvixbK/lbDf3TC2rLPH9K88MUyTQPSOL/eyhjX958L+s/46nhl8QA31+6Z
         ER5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFaVsGQjKeU+k8uua14bZ63K5jLOIG/EPVKMMbVdMr8+aJs+Co
	4WPluFeLwgVjznM5TQa9EyWZ6Sh09F94vL5av5RNFqHn5yEiaviQDECOHWutU83T/UGRT5JDq/l
	Ax7qobhVn1ahSAwKBngahf0XqMgjLa4K5TSf/tNAoh/srdYoCmzhQilucfytm5LPxhg==
X-Received: by 2002:ac8:544c:: with SMTP id d12mr42242273qtq.199.1554981610242;
        Thu, 11 Apr 2019 04:20:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD+3oxaRzk1nCO1WrlhrdbWZFjbSSPxqjAIG6jEuM7Qc9jmerX8d+NGI9lqegfObU65YFJ
X-Received: by 2002:ac8:544c:: with SMTP id d12mr42242239qtq.199.1554981609721;
        Thu, 11 Apr 2019 04:20:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554981609; cv=none;
        d=google.com; s=arc-20160816;
        b=hDnBuidPrp6laBVmAeAEIldsdLjzfKZwVXLb4q6G6qhmPq4Nu6h3SvsvMxk29yzJk3
         zqTfOVkcYKWqIM5JeSl+Mmi8B6VaYKc5RHGoLHm9P53Iq5xJJG9iRDF9jl4BxM86DYQt
         j6nt5HwfM58+osNLOajTqppcpd/cLIFyIbo6kdSFgfG/5R3A2CHPDYd2Cjga9wrozcEI
         XDnIrfAS3KB7SyqfY02FiXSeL6PQKO+p6VjY8v3OfUsq4FM6PTZTv6MJJHspNr33JLV3
         AXLgzW+N5OsOX8f6e5h9yIm9rtA585M9H4PhE9rCvj1o6Vp+xyPYFAhyXOuBKQKgfYAD
         M6xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=gE8DBy8ZknvEWPhXOAMtY9tEqA7/smA66FHYreuujF4=;
        b=JK7nekFUVclV/Yzg53+ZX2D+Qd7PB1niw7BRdNnjdAIkHBPuRSb2V+SpJBGFaU9QRR
         R1q0Yfg/MYT2MQ9eucRRfLA6HwyT+++Df8Sj8yTu4A3uo1xL2SQvq1viFk+OAP1lRYm7
         spg8Fdfqt7/j1E4DzPtWnYjOe1DQpyXwTAofGGDEAzdYSpFU67Wmzyfifph22dqQY8Dp
         P+2/ip+ENIVgN0+TEEG00IwM0YWSvDODFzc3ExPKQ0dL5q8Z0rdfvGUW20qykis7TW7u
         Jzcph/sias6H3NSlXAz1S8G96PU2tjRA4SjKq//idfNPPHQ80faAppdIQWR2WXBcwxuJ
         mF1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q51si6473998qvc.222.2019.04.11.04.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:20:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D483330B4ACF;
	Thu, 11 Apr 2019 11:20:08 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C46E65D9C4;
	Thu, 11 Apr 2019 11:20:08 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 9E2143FAF4;
	Thu, 11 Apr 2019 11:20:08 +0000 (UTC)
Date: Thu, 11 Apr 2019 07:20:08 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>, 
	Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Message-ID: <1160472485.21015333.1554981608278.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190411110955.1430-1-david@redhat.com>
References: <20190411110955.1430-1-david@redhat.com>
Subject: Re: [PATCH v2] mm/memory_hotplug: Drop memory device reference
 after find_memory_block()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.67.116.15, 10.4.195.11]
Thread-Topic: mm/memory_hotplug: Drop memory device reference after find_memory_block()
Thread-Index: hOruerfZeTE3c3BjR0vSDEFOFEFtCw==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 11 Apr 2019 11:20:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> Right now we are using find_memory_block() to get the node id for the
> pfn range to online. We are missing to drop a reference to the memory
> block device. While the device still gets unregistered via
> device_unregister(), resulting in no user visible problem, the device is
> never released via device_release(), resulting in a memory leak. Fix
> that by properly using a put_device().
> 
> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Wei Yang <richard.weiyang@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/memory_hotplug.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 5eb4a4c7c21b..328878b6799d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long
> nr_pages, int online_typ
>  	 */
>  	mem = find_memory_block(__pfn_to_section(pfn));
>  	nid = mem->nid;
> +	put_device(&mem->dev);
>  
>  	/* associate pfn range with the zone */
>  	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
> --
> 2.20.1

Good catch it is.

Acked-by: Pankaj Gupta <pagupta@redhat.com>

> 
> 

