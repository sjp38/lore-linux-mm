Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16651C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:09:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D108A217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:09:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D108A217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C0E78E0005; Tue, 26 Feb 2019 07:09:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 970F18E0001; Tue, 26 Feb 2019 07:09:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83B4D8E0005; Tue, 26 Feb 2019 07:09:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 270E48E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:09:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u12so5361632edo.5
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:09:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BxvEPDTvmGkEMa3athK9AvgcXNWTtbm9k+8p3UZj79I=;
        b=rD+i3oASAoFmKf52Sq4HgaUIJXcWebaKbEq0ng3djycV5ijQBBcGciFp8M96izDq3H
         YVpJaEgICU6hN3eJ9AsBVjfqWu2QfXRMmhWiRClBqv82k8hQBrozCPDiTdc4zptaHgnW
         2dCe0y2xX7eedVjUPQwvUOMqKbyMcZY70bCFQASAUiBh86wNMjnu3JbbRo4mUc2H70Ug
         /RkR1N6xfu9KWEySPXsg0TIlJkXyuh/gjC1gYirKqR63o19lexSCOHhRH71VHSFLXTxY
         TF/j8Il9pQ6ecC0QGjTpg7EECniSd1qrYCuoe05xDlVmx6BO+yiu1YD3PqD7/igUhF4H
         75sA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubjOgAT8pWLEnvC1hQ7wZp38xejhDX4E0KdjlyOO8yIrScp6/yS
	+zo8Hvz4qLzDZxv2ZVY47+VSJ+QApLoASE+uwfO/0IylYSZ0zXDDnGI/0CwAG+dV8WEf73lBKuZ
	VyEa3WFq/7rJ6CQG9PNKtsxH2ZHvs0EWGho9QqML2h1Ah1zPuzgFSs5JtVoEC8I8=
X-Received: by 2002:a17:906:2dda:: with SMTP id h26mr16494666eji.26.1551182962707;
        Tue, 26 Feb 2019 04:09:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZgRsjxKvLY5J9lZS67NF2NltVjzszVDWCz4/oKmxlM+hl5WARp0f7mR3NrD6qrSxG/sQXs
X-Received: by 2002:a17:906:2dda:: with SMTP id h26mr16494612eji.26.1551182961841;
        Tue, 26 Feb 2019 04:09:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551182961; cv=none;
        d=google.com; s=arc-20160816;
        b=vloa0gsNJTNUOsc0t1y5kFA2heTHn7i2yH2k82vSSodFljCs4hCJmqskZXRsxqt2Bi
         80+SucQqaUGoAwIpclRewftnib0eFHSGsDRPo0seTEt7umh0AvqJ5lEjBPk2NJrjOkre
         49iq7RAEZ4QdM7uai9Ur4QUyoE8R3mJQSj2iwIoa0TFwnkRqUXgKez5Ff+wUlPRWDqE3
         43pSKCQI+14g42uozTmID7E45v0mf9oJIs1XvEar0HXaK1RryvivmnB6xjT64k6S8kx5
         ycw29XFY7EE8zcAQ5GgLQgg22X+XLV1lmABH1UAjJK+WJTIeQdw2mHQxIeWvHt6x9iiA
         vLkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BxvEPDTvmGkEMa3athK9AvgcXNWTtbm9k+8p3UZj79I=;
        b=khcB0/28HDRqRhQ6KDxhPZ/rXUfCJkMoccql6OgjP8R2R9w5HireJZqiy25JT6rg2L
         FhoxMRYJX/WMaNNfnkWZudx/VrvswW7jpaOCFiN0XUjbs9JI+KrXu3Yk+9pvuevZ6D8W
         Cya4PSEMiPBdrY4VPNOJAzOrwbAgrKYbhqreomssZLNY961qfftUseSOiTVwoA1GllZd
         S7MnBob+KITUmGDKJ9whpylUFlc13ehAZTlWgDPs2MkKlDxkUSJZ/9+QQDw2mLJ/sBML
         +1VB1xSlnXpq9Fk5xynd5Geq/S+F16S078Y1b6W4Vb2Wf2jtnupMPgsrUlsdJBdKl/WH
         w/Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x37si2229785edm.407.2019.02.26.04.09.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:09:21 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2C35BB611;
	Tue, 26 Feb 2019 12:09:21 +0000 (UTC)
Date: Tue, 26 Feb 2019 13:09:19 +0100
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
	Daniel Vacek <neelx@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/6] make memblock allocator utilize the node's fallback
 info
Message-ID: <20190226120919.GY10588@dhcp22.suse.cz>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <20190225160358.GW10588@dhcp22.suse.cz>
 <CAFgQCTuD9MMdXRjyu1w5s3QSupWWtdcCOR6LhdSEP=1xGONWjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTuD9MMdXRjyu1w5s3QSupWWtdcCOR6LhdSEP=1xGONWjQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 13:47:37, Pingfan Liu wrote:
> On Tue, Feb 26, 2019 at 12:04 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Sun 24-02-19 20:34:03, Pingfan Liu wrote:
> > > There are NUMA machines with memory-less node. At present page allocator builds the
> > > full fallback info by build_zonelists(). But memblock allocator does not utilize
> > > this info. And for memory-less node, memblock allocator just falls back "node 0",
> > > without utilizing the nearest node. Unfortunately, the percpu section is allocated
> > > by memblock, which is accessed frequently after bootup.
> > >
> > > This series aims to improve the performance of per cpu section on memory-less node
> > > by feeding node's fallback info to memblock allocator on x86, like we do for page
> > > allocator. On other archs, it requires independent effort to setup node to cpumask
> > > map ahead.
> >
> > Do you have any numbers to tell us how much does this improve the
> > situation?
> 
> Not yet. At present just based on the fact that we prefer to allocate
> per cpu area on local node.

Yes, we _usually_ do. But the additional complexity should be worth it.
And if we find out that the final improvement is not all that great and
considering that memory-less setups are crippled anyway then it might
turn out we just do not care all that much.
-- 
Michal Hocko
SUSE Labs

