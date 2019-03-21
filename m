Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D799C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:36:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36F7D218B0
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:36:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F7D218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCB756B0003; Thu, 21 Mar 2019 04:36:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C794A6B0006; Thu, 21 Mar 2019 04:36:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67B66B0007; Thu, 21 Mar 2019 04:36:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB1C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 04:36:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5so1905722edl.22
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:36:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w0aciZn0l6zC216FbEhedH3z4RBjywV1AEoZgQDUUdo=;
        b=Gf/mMdoBWhrEGmNjkpO+9vosFK0vajuzLt6YBSq/ZcfaUlZv0cgcllPHFtLzzb35Xd
         YIA0PN9R2uXMAk9N/P/DxBq1ZG6OnfOClAP4RutbdM2sUW0cmpmvwbyRXsW0IzpGlP+G
         xFmgXuG+aCqzL//RgneZXrtgLdqFkLKv0TjGgpS/sWnTzowQWvZ9/cKmGmkJg4e1Dn4N
         gXz8ZXT1xPZP3tWc/4dP3lC3KoeIBlL9Vgk4F1UX9c3UDfs4IE5NjHKFJS52y0SoRNJc
         rhl3tKSIlDzm9gQl4U+Xutpd5CTpDJOZxtPCowPvPKtqhrtChlPW4ArDBwlFyn0ypowG
         e75A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWGEm673cK7898EHPKFxfuBC7wTeH7VjtIqQOXU9CBBBIgvoFE9
	9ShBMXyMsQMZStPvEgToYuy+0AkxqoPDazmUARf3cFQXufzMsYQPO0qC4v4+Lsi5SUeuxEQl8r2
	kwZgfIuyIR000XRVy+APrnWeaOO40Xoi5m1LdNfrSZlL0usGPl9PdXS3Gbnx5ty0=
X-Received: by 2002:aa7:c69a:: with SMTP id n26mr1603033edq.113.1553157402892;
        Thu, 21 Mar 2019 01:36:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZe+aJqSaqZ/CP9vP3LolgLPZuvUDosm7nrB+DgrMVyBloQ0C6FArCqEETEJvqUn4NdzwL
X-Received: by 2002:aa7:c69a:: with SMTP id n26mr1603002edq.113.1553157402051;
        Thu, 21 Mar 2019 01:36:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553157402; cv=none;
        d=google.com; s=arc-20160816;
        b=wQWWBOJfwwYaproT0128dSD/Ji1pnjU8WssKjzxgNZotR0m5v6HD8hzeWclyk6cahb
         5knjhTfITlTY5s1hHdNVCNseYCQW6VIVHzuIow97+MrHsFQ+6iZmUtnx7sGa3KyWH+xk
         9EiVLD6pwbtPmaUKee4kyR7q0xIMIMj/pz4buegWLVGI8wNQg1tK2HBjQEquSXkvP3bv
         YzQiWsuP4J7apNwR/it/cmcqEiuZfWOof1gTYtb5xeO8Gch/AIyll55PEEs17BjuqJbC
         VVqPei40/mm8C8efA8mP5ROm8p27J6gLoFpsyJut1KIhmJPgHL3v9M1L/RruiUNZFBfR
         UEVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w0aciZn0l6zC216FbEhedH3z4RBjywV1AEoZgQDUUdo=;
        b=Cpg80LdZfPBySzIrwFADWhp+7Zf1+byXItwBRacoSkQmClsj5pIMfUxCB6Cri7Oeic
         8NWV98g8n6n03AqJTVrokdRCQta8uEYbze04czSemE/m93Kzjh7MGRcVyqz1JZSnHIQr
         6YpYjNmPImXWmnhMR2BLfmQkf/+MhZR1sH4qUoPBI1LsPo+okf/fgHrHdzwSTv3/z9uF
         E/xDER3cTkr3F6VtCKwsI5/ll/6ph/rLEu5/L+DUT1lMmcEMHNhHBtgA5MdFri/o24Z1
         g3QFHKp5Egs9dWFLM0jF7nXEgK1hDfTibyIHm7BT++iVnD8Eg3dV7NAXNO2l1oBj0fKr
         Qh2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 58si1888373eds.7.2019.03.21.01.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 01:36:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 460A5AC8A;
	Thu, 21 Mar 2019 08:36:41 +0000 (UTC)
Date: Thu, 21 Mar 2019 09:36:39 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
	osalvador@suse.de, hannes@cmpxchg.org, akpm@linux-foundation.org,
	richard.weiyang@gmail.com, rientjes@google.com,
	zi.yan@cs.rutgers.edu
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
Message-ID: <20190321083639.GJ8696@dhcp22.suse.cz>
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 13:38:20, Anshuman Khandual wrote:
> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
> entries between memory block and node. It first checks pfn validity with
> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
> 
> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
> which scans all mapped memblock regions with memblock_is_map_memory(). This
> creates a problem in memory hot remove path which has already removed given
> memory range from memory block with memblock_[remove|free] before arriving
> at unregister_mem_sect_under_nodes().

Could you be more specific on what is the actual problem please? It
would be also helpful to mention when is the memblock[remove|free]
called actually.

> During runtime memory hot remove get_nid_for_pfn() needs to validate that
> given pfn has a struct page mapping so that it can fetch required nid. This
> can be achieved just by looking into it's section mapping information. This
> adds a new helper pfn_section_valid() for this purpose. Its same as generic
> pfn_valid().

I have to say I do not like this. Having pfn_section_valid != pfn_valid_within
is just confusing as hell. pfn_valid_within should return true whenever
a struct page exists and it is sensible (same like pfn_valid). So it
seems that this is something to be solved on that arch specific side of
pfn_valid.
-- 
Michal Hocko
SUSE Labs

