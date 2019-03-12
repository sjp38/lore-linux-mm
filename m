Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27107C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:57:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D48CA2054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:57:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D48CA2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B5888E0003; Tue, 12 Mar 2019 11:57:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 665BF8E0002; Tue, 12 Mar 2019 11:57:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 554FF8E0003; Tue, 12 Mar 2019 11:57:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F36D48E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:57:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f15so728214edt.7
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:57:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sbTPQW+Smhr4Qb72E0E5GmSfYaYo6gPSfRNZBvsArls=;
        b=mcj5P8SAbwWwHjWuZcIPMnKcLGGK5x0FTOP/VNsAKIELRUZV4up/3kD5xRNXjILF5e
         JmiJib+mIrd8qJZ8YuLPOl0ZWmYG4R0w6YXOACI3wdecSKizflTmfj3VdFduc/yw8yde
         thyObFvV8rOrN9rteRDG0w9icqRJsJRu75FkwJ9wkAYDtWMSFRY0AQ/7rcyxg7JHV7W8
         U5Q9XAI6psO2Uw6N7uhldvsdlK1N5YfjS45iOHJHKSKiHbgFy6w81YJ240fMvmgJLfEI
         gh3lIcRtxCtJgXxbJSFpMVYxC2bYQjZRekL2Icmc1A2LbCwmaeOLm13RJLtoVvUgFJqZ
         Anqw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVa4RbpPWdVtzndJPT3JXn8MtqVWdb+V8S3iTX0Yd4Z6AGoixC6
	eEzDm+TsnCC2QE/BGvuVWgcOtxTAvOd+nVUDOgKUT7/ZH7rvFsPao6floSYvXy14bwEkpfeU29r
	JEKaacDSoHbG2gKJEa8rB9Y43YKCkHuyd7xtZxqb7DYEDB+VffRa7HMwOVTN8T2w=
X-Received: by 2002:a17:906:2285:: with SMTP id p5mr3030055eja.220.1552406252579;
        Tue, 12 Mar 2019 08:57:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7ur8VilmeC0iwXLa61huKsICgxP/ED9z3S9m0jQ+pRanNeezQ6rpctOiVlYtpK8LkYNPH
X-Received: by 2002:a17:906:2285:: with SMTP id p5mr3029997eja.220.1552406251596;
        Tue, 12 Mar 2019 08:57:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552406251; cv=none;
        d=google.com; s=arc-20160816;
        b=IBGtL3IuvgGta1osIFZq7SAoSWUPp24z3mX2S7XPkRett4o+Gj1qzI7oBv8TOPhb+e
         sWHMJfIYZ2lCAZZ8f+NMqDrNOTUs+QGKqlvCWzHrUqKCrJ6BTz2CA/wRFVnOjoslJ2wv
         q/47vMFYdx58KVxk3Cf7uihbQHwklBlurPClyKvp4stfscpu7ESv5uwJbY7EY5LkhoAW
         QwKvLGT1lJ/yjg7OWWxR3NEd+J5lW0oOQqLuZxg2Q5jZC02ObJXnT7Bah3zaN+LWX2dT
         3qzc1QaKE+K0youeLgS0VLHvrlAfBFXPD2iPSxKh0Blt84TYULKRSkYPwhbgvSU8b1ZN
         oq/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sbTPQW+Smhr4Qb72E0E5GmSfYaYo6gPSfRNZBvsArls=;
        b=Eb3qOw8xKBr6OJ2GKVI/dcbAVpwF3c61G+KVkL+FStoo/Ar947XcibQf+lo97YKPyG
         PkXNkxarbOWO/pBBfaBtDN2Cx9Jr/D0p4LbJaQ6870vZeN6N9Q6Oy6chONDxaq/XEjCa
         s7Cax1IQcgAFGgVO54GUahoRL6xuCOBLZe60dYGAwSCCPfQ96yqhPrz4To02SAcatoiH
         1GyY/HZypi5sw7nz8MErEsB5OvZIdjhP4K1p9zp6Mcvaq/TKZZIzCTLGF6XrZ3Z6P8RS
         KrLAwX/7lBtG7rmCn4wNpUJrvG6mL5g2R1KedfEwHvb6wvb+UAUSOk1X89gDiXNNjaoI
         hfHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si1238950ejd.16.2019.03.12.08.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:57:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2DB6EAC5F;
	Tue, 12 Mar 2019 15:57:31 +0000 (UTC)
Date: Tue, 12 Mar 2019 16:57:30 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RESEND PATCH] mm/hotplug: don't reset pagetype flags for offline
Message-ID: <20190312155730.GZ5721@dhcp22.suse.cz>
References: <20190310200102.88014-1-cai@lca.pw>
 <20190312153458.qvmrblg3pnokgx4d@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312153458.qvmrblg3pnokgx4d@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 16:35:06, Oscar Salvador wrote:
[...]
> One thing I noticed when looking at start_isolate_page_range and 
> undo_isolate_page_range functions, is that start_isolate_page_range increments
> the number of isolated pageblocks, while undo_isolate_page_range does the counter
> part.
> Since undo_isolate_page_range is really never called during offlining,
> we leave zone->nr_isolate_pageblock with a stale value.
> 
> I __think__  this does not matter much.
> We only get to check whether a zone got isolated pageblocks in
> has_isolate_pageblock(), and this is called from:
> 
> free_one_page
> free_pcppages_bulk
> __free_one_page

It forces those into slow(er) path. So it makes a difference.

> With a quick glance, the only difference in has_isolate_pageblock() returning
> true or false, seems to be that those functions perform some extra checks in
> case the zone reports to have isolated pageblocks.
> 
> I wonder if we should set nr_isolate_pageblock back to its original value
> before start_isolate_page_range.

Yes. And that would be a fixup to my 2ce13640b3f4.

-- 
Michal Hocko
SUSE Labs

