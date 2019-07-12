Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA13C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:02:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F12042084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:02:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12042084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75B668E011C; Fri, 12 Jul 2019 03:02:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E3EC8E00DB; Fri, 12 Jul 2019 03:02:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5851E8E011C; Fri, 12 Jul 2019 03:02:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE7A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:02:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b21so6936021edt.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:02:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Vw/w8GJBF4FiF6A8d5MLdb2qQO8FnoQGLh9JrE5jyzQ=;
        b=r9yrflaNwWxytVMqhoefC6oUhpYTJMXmUv3IEfqJyHGzNjl2lvmTRQeURyxiQrUYIP
         slZvpqWizFc7jQ8H31M5betsyVi/WvI4XPQrHGxm50A/TAc/7wb8C/FoOj6oZgwrMeDe
         T1ipv1X2w6ilu8lwJQnE8aIKNoWSVqXPssnxEq8Yi8uMJ26n8qHpmq+1My1IoeVH8oFy
         6sQ2B4tF6hKmpsoUcUwgQpsfPb+SdQOsvd95olise9AlAZqyG1aQXIuEGV8/++FYzz8k
         N4bJmtiHCVjnmGd8mMue6BNOG1BEXqC6Vbk+mPZEGHJjF7rdYGBJ6OzJtJZwKwMhSeYE
         y4yw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVhwj0aKgwDNPYy8TNFSMqkcoqEo5j5I33Ti7v3mxfUGLkwAhhy
	Ohk8x9dvfaxZC+t16WetbRUgDS0I+D14dkJD3ax1CRwd+0dymGLB/O9FIoHvjPeuRlBjeQ+XGRs
	tkx1i6T7eLsWkzeDI/RyThS1NipsG4FJhzI3DAqWL5vaGY82frN59IM2lfBG121g=
X-Received: by 2002:aa7:c559:: with SMTP id s25mr7508729edr.117.1562914971587;
        Fri, 12 Jul 2019 00:02:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFihtutVBdEMKlyxRznHO5P9dFssfzFxjL9+cgnZKZAUsejj9gVjaNa/2KCnYtocsyqzpn
X-Received: by 2002:aa7:c559:: with SMTP id s25mr7508679edr.117.1562914970915;
        Fri, 12 Jul 2019 00:02:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562914970; cv=none;
        d=google.com; s=arc-20160816;
        b=cdqIk/xH4mw50tytSUWNRvsr/0F6pZsyb+hQeG3Y4Jlj3A59TqfGvoA/pfP/hvCYXd
         bF7zIAuFuIQdjojvwk0NY5WdcB8+GWf/oAP0Ftsza62qJw8E0EPL5Qoz3fJFajIRMPJW
         COweWbHtgC/iFYj1d21JKZUkQOjk6Xi1y6dkNq76luHWqpvethemXnbsekALSGQTHPIv
         qARkLp9XGUoua/b1Bdr5VucqJ6qjCmhn5NleCnyRuNmDLiupGchBmDL+ooCKYO9T2V/o
         RjFjGNAzX24d/i3u0yYpRO8daC+XxX3LZrFjbn9oD18bePp8TcY9ST9E6hvXBraCkmLg
         rgmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Vw/w8GJBF4FiF6A8d5MLdb2qQO8FnoQGLh9JrE5jyzQ=;
        b=gb1oMyw4bJlQbiBJnVeBcy7JchlSIoqBc8csPqV0SEaQime88cfPFsfqnPU6iiZuge
         Y5rDW4vma3G7vftXZ4jilJBF571q5PB4znb0jBLCBQGSrP47crksTFQHWbiB2QfoTxw+
         aqDBS1FZg9K/XHikBxs5YW6BTG3VdXIYNUaTX7uXVOxFDP7DwZqQJ3Mi78UpSsYtBtUl
         6xTb1LcwvKAzx9G9XbYiS+D56IDDM3fWZhSlHg7uMMjJ/Coe+BJmG3F5MojCfc1mmAHl
         +bdQ1nwnlWHHPkmp+lvVx6pMiIKf/a+iv33pBMenXGlz5wUDJPA3yiOXYymdcV5Dqnp9
         OTnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23si4668613edd.89.2019.07.12.00.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 00:02:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21758AFF9;
	Fri, 12 Jul 2019 07:02:50 +0000 (UTC)
Date: Fri, 12 Jul 2019 09:02:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"David S . Miller" <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Open Source Submission <patches@amperecomputing.com>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190712070247.GM29483@dhcp22.suse.cz>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-07-19 23:25:44, Hoan Tran OS wrote:
> In NUMA layout which nodes have memory ranges that span across other nodes,
> the mm driver can detect the memory node id incorrectly.
> 
> For example, with layout below
> Node 0 address: 0000 xxxx 0000 xxxx
> Node 1 address: xxxx 1111 xxxx 1111
> 
> Note:
>  - Memory from low to high
>  - 0/1: Node id
>  - x: Invalid memory of a node
> 
> When mm probes the memory map, without CONFIG_NODES_SPAN_OTHER_NODES
> config, mm only checks the memory validity but not the node id.
> Because of that, Node 1 also detects the memory from node 0 as below
> when it scans from the start address to the end address of node 1.
> 
> Node 0 address: 0000 xxxx xxxx xxxx
> Node 1 address: xxxx 1111 1111 1111
> 
> This layout could occur on any architecture. This patch enables
> CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA to fix this issue.

Yes it can occur on any arch but most sane platforms simply do not
overlap physical ranges. So I do not really see any reason to
unconditionally enable the config for everybody. What is an advantage?

-- 
Michal Hocko
SUSE Labs

