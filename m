Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF706C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:04:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A217620842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:04:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A217620842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A21A8E000F; Mon, 25 Feb 2019 11:04:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 327D48E000D; Mon, 25 Feb 2019 11:04:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C9F08E000F; Mon, 25 Feb 2019 11:04:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B48AC8E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:04:02 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so265491edd.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:04:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PNfhIfgwn33iwuw0DDDVaGD8aew2O6QdLi3sHg5XfjY=;
        b=eU1RZks+M6CDdG9o+1w+S+QlLadWqweUgGZtywVTT+9ATD9vnXbI1ypCUsJToXw9M4
         dpeIXGMtgETVdoS87V/5jjJOOQK0ejcwr1CUy2kSgtamdFNY9NZDNhoakVW5EVSrf1xn
         +dfqoZ18/UlNH9g8mtXnJfy6BSJkjDPsF1AfsSAIqNyrus3wLTFn7N1vhYczLxQ0Uuwe
         GDUb1i4/o7O0t3HtxKrq4sBgjFjx4N8Cz5rqz/DcVUjOVL1dGhEZglk9ZVMavu+41Q0L
         wpEHpK/9m8/lGymYXMIYv1BHj6Ca05gYT2w7ec7knu/AvcX9Sc86L5jY091oaDZJTn5Y
         jvfw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ71wk2MGnHPRD72GAVJGVbAOl2uHmQDg7zZN/YiC8MJM3QEUdH
	Uhk/aZmoORJ5XpsSHzGkXF8VtDAjtVtm61rsaq8GJdPkyQoA+ovuj7UWloFvMlTtXOlwz9Xh3i3
	LCYiErvQRCXPBwoMHVe36i/6OD0tivTD9TekLq2usypoz6aOAE/g3gF/aVBqhm+Q=
X-Received: by 2002:a50:b786:: with SMTP id h6mr15156496ede.85.1551110642300;
        Mon, 25 Feb 2019 08:04:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbrQNwNB+dUETq2JTLE72K1TdNIAOY2it4IIFomYoxZL4x4aHWmCNtj0hvjD6D9ekx6/82T
X-Received: by 2002:a50:b786:: with SMTP id h6mr15156442ede.85.1551110641446;
        Mon, 25 Feb 2019 08:04:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551110641; cv=none;
        d=google.com; s=arc-20160816;
        b=LREZzTCNwHzrP9K/PTGHsAtpO6wvI96dPG8N8MLROjggWDOUQEOZog0M/l6y9/QzvZ
         /TJvU2iQM6606OE1HoMTMToIvHaF4Y8iK8/m1//D4Moz8ab6fw19yLECgGah2m5nEmY2
         mqMmGpXmi3+LLxiVlyf51niTmWpN4G1cUxkH8fOyRKQg00WDv/BA9I8V1mV1dEfo2/O2
         UGPx1TPv8vxj7a68Hcl6XGjR4Os0Ngk0GusxVmwuJEhEjhL9B68XN4gxKQLM2NQz6BEV
         lbOLI+G+Lbeg/qz/co3WWoMbfeLhvzcrZVaG99mbpAg+ylR1DML6fJMvKaJEviXUXbaj
         K9ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PNfhIfgwn33iwuw0DDDVaGD8aew2O6QdLi3sHg5XfjY=;
        b=dZ4/I7PA7OXpnS1KJmpHl8ht/3txlQjCfJdzGOWZzj/OMrNYnlbJugvY44+/JaTFmZ
         sNF1XkRSM+CsEebllhB2UsyO2BJfkXqNyeHiPmazSDYm0tZRte13YFbbCdCNIKBNvs1U
         /V4kl3FzDPPCD7k95VI8YpDL1NTXlX5c87S1Rx3GIzjYQ2lTAhUvkrt+RzGdOcopcSXj
         ECse7oipPAm8aMMyPBoGjCKemR7r7gtwS7dhcbIs2auMMK0M/d3qDHSZbnRp4foiORnZ
         03wKMPswc9S2EpNGYhZmQ5s7OEPSCD8nStXWbulVZ5SWFqlmOxEtp4tGnz9WpXP6kLQ4
         klSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v32si1463482edc.184.2019.02.25.08.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 08:04:01 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 99F59AFCB;
	Mon, 25 Feb 2019 16:04:00 +0000 (UTC)
Date: Mon, 25 Feb 2019 17:03:58 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: x86@kernel.org, linux-mm@kvack.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/6] make memblock allocator utilize the node's fallback
 info
Message-ID: <20190225160358.GW10588@dhcp22.suse.cz>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 24-02-19 20:34:03, Pingfan Liu wrote:
> There are NUMA machines with memory-less node. At present page allocator builds the
> full fallback info by build_zonelists(). But memblock allocator does not utilize
> this info. And for memory-less node, memblock allocator just falls back "node 0",
> without utilizing the nearest node. Unfortunately, the percpu section is allocated 
> by memblock, which is accessed frequently after bootup.
> 
> This series aims to improve the performance of per cpu section on memory-less node
> by feeding node's fallback info to memblock allocator on x86, like we do for page
> allocator. On other archs, it requires independent effort to setup node to cpumask
> map ahead.

Do you have any numbers to tell us how much does this improve the
situation?
-- 
Michal Hocko
SUSE Labs

