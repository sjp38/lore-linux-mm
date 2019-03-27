Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D834FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 09:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FB0E2075D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 09:01:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FB0E2075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AE636B026B; Wed, 27 Mar 2019 05:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284786B026C; Wed, 27 Mar 2019 05:01:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19B096B026D; Wed, 27 Mar 2019 05:01:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC6096B026B
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:01:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so6355838eda.8
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:01:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qz7vWRDvBT6ms8RMeGmKQaJT8HTkwdif4BNMNeL14HI=;
        b=cpnANAaVVYiSxWyu2Ul6sRU4OprRklm/f1+tsMEah2isdhPTABv8uVQ8C1zLrkg0hw
         9QpiV99aOPBnFv8m8rZgB190lKqLS7oGYW+/Itx64QVcz4PiiSimD0UxHn9eFVxRy7k+
         DYFO3JSx1zwoJNpDjGNSdzSV6viswwZcvAwgCI0DWCRgAHRKwd5yQjMM5lOxTHaENzyQ
         GZMgJd+1gjTXTl5kMo48Br/7+Gxu6V3aQoGBprLQNVJHsBKIzWVXjn1HpcBcu86luZBd
         0LoVMNRK7WZKD8ekLBXXD4AYnCvsAgr1trZzMD50a8SJI1fufg01Ceoi9qwE2+nA7eQL
         FQNQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVpKQVK/wU3c1fPnbfpZ4xUx4KwqTh/gBuSLQKEQv6b35ma1K+r
	pYvcLo20ieHiaVA8NGPK/FsQu8PzheFQOvXncpcTcQivK4dU3cYee0BoN9VzsomG1DTcON5fzUf
	ikK0+ntTUVkAYO6Fr/u2Uj6wwzyqV8ihgxGoZpwpFAbak4oSI7ZEY1xxpgScbc9w=
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr22966579ede.98.1553677263324;
        Wed, 27 Mar 2019 02:01:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSQ+ynEjnFLJsBeK+wvDBuWZByDJADqylY1idGW447or9mfLUm1iKwjpP3NdnYTSCL9fJm
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr22966537ede.98.1553677262452;
        Wed, 27 Mar 2019 02:01:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553677262; cv=none;
        d=google.com; s=arc-20160816;
        b=QOu3FMjiYLXNuKcmHHvONiYC5b+8MdotNe3Qy3LMNZIVooR8nk/ap+FC5Qr+D2/vOf
         IWNDuiMTfrHHDcxWRrY6660R2CH+D1xdLkRJqnyy9A/htrhBi7YU9aHMelnm8lJt/THk
         VQGsJZDKjeut3L0fAhBxDzZOfmGPpd6EEQI5OuvK+pWbUfC/SYtjNK3X9T6YlyZowWVx
         p0h62mTw1ZK9s2Itqol5QcTgbyJYqzS3mzw2XmCLwbFpj7E1Dzu3LsMaHYZeprHMdqQP
         ShZnhHGet0hhCOz69fVULJx4anC34dkrnY0KszDupLscbn0tJmduTx9NHACLHR1ZaHBo
         ggkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qz7vWRDvBT6ms8RMeGmKQaJT8HTkwdif4BNMNeL14HI=;
        b=Si5FqWxGJA2cYrGxUSp8dQTteaQYwzrQ3tC6pUadkwpGI9cyFXl3pX7AMqMd0ZIduF
         5f5ZvHKFm1j319gK1i7tpMKms9b4cxM3vKC/FKzwAzHnoUmcR04s/Sp4+JrstmTM4FmI
         yYPXR6PNqadN9ABqHV/Zfyw935N05/YuZWRJOV6sVxdb8qklFQJYDAQSsNdih+LDAIlG
         AQESmF/px7ztD9hiC3faP5w6nb9GtDHZFEXYgTqmOJhMw39A0+b34nD1Arf2Ez2mjdBT
         /XuOmcKorXXxjbtAIwhSMivacI8UE9uvjddPaE28PgRJHYFY2hL3R6i26yjPjs64gbMC
         i83g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si840472edg.21.2019.03.27.02.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 02:01:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 898C5AC86;
	Wed, 27 Mar 2019 09:01:01 +0000 (UTC)
Date: Wed, 27 Mar 2019 10:01:00 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190327090100.GD11927@dhcp22.suse.cz>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 19:58:56, Yang Shi wrote:
> 
> 
> On 3/26/19 11:37 AM, Michal Hocko wrote:
> > On Tue 26-03-19 11:33:17, Yang Shi wrote:
> > > 
> > > On 3/26/19 6:58 AM, Michal Hocko wrote:
> > > > On Sat 23-03-19 12:44:25, Yang Shi wrote:
> > > > > With Dave Hansen's patches merged into Linus's tree
> > > > > 
> > > > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
> > > > > 
> > > > > PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
> > > > > effectively and efficiently is still a question.
> > > > > 
> > > > > There have been a couple of proposals posted on the mailing list [1] [2].
> > > > > 
> > > > > The patchset is aimed to try a different approach from this proposal [1]
> > > > > to use PMEM as NUMA nodes.
> > > > > 
> > > > > The approach is designed to follow the below principles:
> > > > > 
> > > > > 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
> > > > > 
> > > > > 2. DRAM first/by default. No surprise to existing applications and default
> > > > > running. PMEM will not be allocated unless its node is specified explicitly
> > > > > by NUMA policy. Some applications may be not very sensitive to memory latency,
> > > > > so they could be placed on PMEM nodes then have hot pages promote to DRAM
> > > > > gradually.
> > > > Why are you pushing yourself into the corner right at the beginning? If
> > > > the PMEM is exported as a regular NUMA node then the only difference
> > > > should be performance characteristics (module durability which shouldn't
> > > > play any role in this particular case, right?). Applications which are
> > > > already sensitive to memory access should better use proper binding already.
> > > > Some NUMA topologies might have quite a large interconnect penalties
> > > > already. So this doesn't sound like an argument to me, TBH.
> > > The major rationale behind this is we assume the most applications should be
> > > sensitive to memory access, particularly for meeting the SLA. The
> > > applications run on the machine may be agnostic to us, they may be sensitive
> > > or non-sensitive. But, assuming they are sensitive to memory access sounds
> > > safer from SLA point of view. Then the "cold" pages could be demoted to PMEM
> > > nodes by kernel's memory reclaim or other tools without impairing the SLA.
> > > 
> > > If the applications are not sensitive to memory access, they could be bound
> > > to PMEM or allowed to use PMEM (nice to have allocation on DRAM) explicitly,
> > > then the "hot" pages could be promoted to DRAM.
> > Again, how is this different from NUMA in general?
> 
> It is still NUMA, users still can see all the NUMA nodes.

No, Linux NUMA implementation makes all numa nodes available by default
and provides an API to opt-in for more fine tuning. What you are
suggesting goes against that semantic and I am asking why. How is pmem
NUMA node any different from any any other distant node in principle?
-- 
Michal Hocko
SUSE Labs

