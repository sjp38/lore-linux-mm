Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3AD4C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:41:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D3DB2190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:41:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D3DB2190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F26488E0003; Wed, 13 Feb 2019 08:41:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5358E0001; Wed, 13 Feb 2019 08:41:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC5778E0003; Wed, 13 Feb 2019 08:41:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8581A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:41:19 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so1041721edi.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:41:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TZFOjxEzkb+xWsfZuwTAAn8tiDRXhJcT8XUbp/GzZDQ=;
        b=P+SVNkRZTxetopgaRnd6OJTHeFtepg7Wncy9glGjmGilPjyMHhkRxS8w79KcgnHYej
         1tvsBKHkQGWa1U5SLEkUoH6A8CefU8WWviT1uWrct74PdwPJNo2i6IDE7WcHsBIksiez
         kxJO9sz+0PHDsMNp+nEe+7D0oJdvgsfhEqA8YYlXQEd9LkfHDdCcGh97D3h2/RGNplVD
         BJ91FjBtJGjf+3Qqigwct2Vnzs2j0io2f5wFnCfiGyIs7g8rxCRB4emUCAqqtOqWM7b0
         VhS4t4lyEVjveJ7kbxBoms5287/Vmgvp3OztCJELwyec79K+sPgfg+hPvMxew18WqWdE
         2gug==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZDdjibGJfx46DJCR1aaxQGTxyU5hWX3iZpOSvBj7SPCD52jimz
	uU+sOlmeZSEI2Z/qawmpMAFTZa4hK96q4VGWGhPX/CnGkUi2jDvczzakU9ivUBCRMiYRAanONbt
	jZ9CGUUSYuw9DvQWGHfZpNycrdF3s5tLrXqkhKPZ+Jptykjn7ssftAmYeWPXY3i0=
X-Received: by 2002:a17:906:33c1:: with SMTP id w1-v6mr408657eja.49.1550065279097;
        Wed, 13 Feb 2019 05:41:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbbvKpSXRycBffRO0453OLRrSnoF5iNsQ9Yr69Gdrc89g6bOKdbWRpDmWlZHOxtDSx9udmQ
X-Received: by 2002:a17:906:33c1:: with SMTP id w1-v6mr408619eja.49.1550065278222;
        Wed, 13 Feb 2019 05:41:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550065278; cv=none;
        d=google.com; s=arc-20160816;
        b=hcBGXboRVr8gsUcW33kcQRx6DGnTT7Cjp3OqDhSElh2yTJoNYqQCwDUTiARYJ5NGTG
         DF/xvnYW/NxHWBqH1FicuWS2XHq5H2Z7eG144AG1nwJ1hGWuo6wudJLkrXs6WrwDqGQQ
         75WZArGgqmml2pSAlHtwvVKRv9FW3MqjDvnT+fuk+rS7RzzmlBuHgs51PZqDXEbAVd8k
         IVAn0X5rA+f3lTXBiYhirktjUyD4i/5wJzAkKlqVyRbQCo4w1spDGJUWgFmsy1DbbJr0
         7+lgdIVUYR9kxOeT1TUe8vjb7Td/ivqNSkkD9FRio8OIlksvXRUAIMYA5BwCqNL/Y863
         eouA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TZFOjxEzkb+xWsfZuwTAAn8tiDRXhJcT8XUbp/GzZDQ=;
        b=c/vp2c55PTQq4sEBn8yll9SwG1WebpvpKCfKX3nwbVvwpOOGSVu4oBwpki4+bbD/Sm
         sNoIAUiDiWQ1is6eyyXUE41DTD9q4wwPtjEoxKzVXslqcSy5Pic/rAv6J4vdZTa4+snA
         ut9UQBvYbJrSDT7Kf47HBHKLKJ9H8GvKKoF7lLMnipc8Xi7hb25hVBKqn/YsJIhDqH7X
         ug/W8Bxm48HW5pIgeGCf/uG7uB8e69VqxLuiFEGRpr0EFfCWWF4RO5gUyLYw8XId2V5f
         H+tvj8WPWahkDABNBXyilIh2Wi5NmgA1qk54cXjxxrkX7o1FtDkMCGDqe5oo6VL8XmTj
         k/Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x15si5854276eds.146.2019.02.13.05.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:41:18 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AA8E0AEBC;
	Wed, 13 Feb 2019 13:41:17 +0000 (UTC)
Date: Wed, 13 Feb 2019 14:41:15 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-ID: <20190213134115.GO4525@dhcp22.suse.cz>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
 <20190213103231.GN32494@hirez.programming.kicks-ass.net>
 <20190213115014.GC4525@dhcp22.suse.cz>
 <20190213131131.GS32494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213131131.GS32494@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 14:11:31, Peter Zijlstra wrote:
> On Wed, Feb 13, 2019 at 12:50:14PM +0100, Michal Hocko wrote:
> > On Wed 13-02-19 11:32:31, Peter Zijlstra wrote:
> > > On Wed, Feb 13, 2019 at 10:43:15AM +0100, Michal Hocko wrote:
> > > > @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
> > > >  
> > > >  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
> > > >  	build_thisnode_zonelists(pgdat);
> > > > +
> > > > +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> > > > +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> > > > +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> > > > +	pr_cont("\n");
> > > >  }
> > > 
> > > Have you ran this by the SGI and other stupid large machine vendors?
> > 
> > I do not have such a large machine handy. The biggest I have has
> > handfull (say dozen) of NUMA nodes.
> > 
> > > Traditionally they tend to want to remove such things instead of adding
> > > them.
> > 
> > I do not insist on this patch but I find it handy. If there is an
> > opposition I will not miss it much.
> 
> Well, I don't have machines like that either and don't mind the patch.
> Just raising the issue; I've had the big iron boys complain about
> similar things (typically printing something for every CPU, which gets
> out of hand much faster than zones, but still).

Maybe we can try to push this through and revert if somebody complains
about an excessive output.

-- 
Michal Hocko
SUSE Labs

