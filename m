Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A6FCC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:15:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DA71206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:15:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DA71206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD318E0005; Wed, 31 Jul 2019 10:15:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAE068E0001; Wed, 31 Jul 2019 10:15:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9CA88E0005; Wed, 31 Jul 2019 10:15:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74C928E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:15:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so42518226edt.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:15:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IbdijOvBahuK4NE8cFNp9Rx7G9sham5GMp6tNhW4N+Y=;
        b=JWLPOZhMnCNBCkrFebmvfYZG6iJSzt3S2tL4d0hn2OFbsSUMb2FxGHEBWnLnJB6TOg
         gKdnP9fylCcEaRUECCQQhopgW4kJLA8m7q7kHYbc7f78ovZKzJhUSN58dIbJZGWr+IG3
         af+l/LCLWmv1tdvH4H94N3Mm7/KvO/+xl9L9jLM50nlsRL2h+xY8xxWxOQ1in/rT8O6D
         li8dP6+4bjpXKtGI7ZrMa4wD6d5wEujgGsZ+xF5G6CIdyrKFjxXtxSw81r0N30RyUxcd
         aGAq9KtZCXZncIIdY2kjdPhr+E4Aoswuq98DtpUIL08PjSXCBYJT3ZxlqorXsKvVomMp
         yOFw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUQsOvaIeLnhf5x8LOzOI9pxctAwG+zggqKJenqBpB6zuP2+Pdb
	jvlJvb77Ungxdzzxz/JmSxDGcM83ES9pzWiBJGsvBVKSd+2FrXrOXA2XFZOfsdX1k2Z7hpxjkZb
	QOko/zyj2383XcY+Z/8py7+IN5A8eOJ3QwwaFOXp2bBx4jqH10bNKhtE/o2yKYfU=
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr107246029edq.251.1564582547061;
        Wed, 31 Jul 2019 07:15:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkwnfUx8wt+7E/2RMa4YyT2rG6aVx2KJF75VL5YolyuQftRyRXc7SFiJ3Vx8gpj2yjRX5R
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr107245968edq.251.1564582546464;
        Wed, 31 Jul 2019 07:15:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564582546; cv=none;
        d=google.com; s=arc-20160816;
        b=LP59lTiMx2Gs1D8iojzYZsYTYhweCDri8tIY3mc2NRyCax89rItD9NERGda0FkRg9H
         MOETVR71PrsCJsF+VtX3JIbnnE7AA0Kq4pzoVl0gh0GeuYX6Ifds8d752mfXNl002kEd
         y9u7XbpLsUb6AuNITdLcWFzVkG/5d6w9soEtuCBYDDLcS5xli7Wd69A1KVyHew1Yort5
         NHr7iFg98SDIQq/V4QmiVP2hzh9NS3tZyHghHKEF4FT5a6ohskrSKMmlhzqVu1sVqYmU
         gWK1uVSsw445vk1KfZXFLZx1yXc/ZME6Nl1icCQYL2gil10BXj7ItPjTRSXoLvs/ZpU9
         wuow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IbdijOvBahuK4NE8cFNp9Rx7G9sham5GMp6tNhW4N+Y=;
        b=nE5x2WEMA/uuQgSZuwtml39/X5b1M28/F2Imq0Z76ip71qQj6gcucf7REbcGqbG9ga
         XQxd8erDab/7wZWX00FJ8axYaD57JT21yOMwJeEzu4uOG7R5q7cxfSXyGhPMk+4mefse
         XHE7Byw487YWPdXQZLBeIRblFcu5uERooJIXEfziRSvMVopmNWSQ2LF/6EYqlOSyNDvZ
         whBIRV5c3s0UURIkEtIEeIisz/UoMI0mS+iaf5wLhptHKfMuhMVZ+MTHqmnraacbv06r
         pXaKZmuNoKBs5LWuRce5Lx0Sft8s14JhpTOt6JwHql8EOLs1XaBPPFTtacn7dlHBGoEi
         tIQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si21195059edc.355.2019.07.31.07.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:15:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1B30EADA2;
	Wed, 31 Jul 2019 14:15:46 +0000 (UTC)
Date: Wed, 31 Jul 2019 16:15:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
Message-ID: <20190731141545.GV9330@dhcp22.suse.cz>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
 <92a8ba85-b913-177c-66a2-d86074e54700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <92a8ba85-b913-177c-66a2-d86074e54700@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 16:04:10, David Hildenbrand wrote:
> On 31.07.19 15:42, David Hildenbrand wrote:
[...]
> > Powerpc userspace queries it:
> > https://groups.google.com/forum/#!msg/powerpc-utils-devel/dKjZCqpTxus/AwkstV2ABwAJ
> 
> FWIW, powerpc-utils also uses the "removable" property - which means
> we're also stuck with that unfortunately. :(

Yeah, I am aware of that and I strongly suspect this is actually in use
because it is terribly unreliable for any non-idle system. There is
simply no way to find out whether something is offlinable than to try
it.
-- 
Michal Hocko
SUSE Labs

