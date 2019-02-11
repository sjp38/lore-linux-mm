Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ECC4C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 14:52:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CB5920855
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 14:52:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CB5920855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3E48E00ED; Mon, 11 Feb 2019 09:52:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2BD8E00EB; Mon, 11 Feb 2019 09:52:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 892DE8E00ED; Mon, 11 Feb 2019 09:52:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 310DB8E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:52:21 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m11so9793889edq.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 06:52:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eA0gRDTw/ANiPAcGnshtdFV3kfcuc01b7QJclj1/2nQ=;
        b=M6gER5e//dHfrYSyQAE/5xyno+proEZyen8ibZfMz6fNnBweJ6kTUgqxQIMgkHRbMJ
         gtqDeorpEUETb9nNV0emFOah/0J31zT+qLb8hyobX2DTa3Cn8FMHU4syIlwGfXgaEnot
         mmtqUY6b0pE+qBWcJODy7GZljPIGGCrJBem6Tnm3OgaRD7jHaNY5VqCScVhZbm+eULdF
         /OhgijheMuB0fF4sZ/M3Vg7q8jSTK1iBSKnbPnkX+pUkcROczFOa5zhPzIlzKIzG1Srd
         cJrjltAp7s1A/be/LdrxMuCANh+6jH4A5iXgNzz3Br7yLXuCqfubxOKL2b8eEuAJSzGw
         wrhg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubk6lfclchpDGrRo5QU3Mw7dCvhepDwMhEpQagSipkwboUJxstQ
	6vYUHlDtZ4Dbv/hfrUMuJmPhE1gOMKb1Ww448RbqjUr3eelZDx3kjNLFZK1Bymk++KrpRyAZdvt
	319AowtciYulbl/4yl0JlBqVUI7pFs3hc6v3pEF457Oj5bmeFCNdGtqYjiv4bDa8=
X-Received: by 2002:a17:906:5387:: with SMTP id g7mr26456458ejo.189.1549896740567;
        Mon, 11 Feb 2019 06:52:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaR1Qalyl4C1b9BQzzupnqpbyCkfIc2KhnSa2hbboecSPHUGw9VAk9zwrSdIGyOgRFL+d8V
X-Received: by 2002:a17:906:5387:: with SMTP id g7mr26456394ejo.189.1549896739568;
        Mon, 11 Feb 2019 06:52:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549896739; cv=none;
        d=google.com; s=arc-20160816;
        b=app8j3W4GjCLM5FTlbV6Wwy0S9M2+eyPeY7QFeimBAhL50p5E5HnXSfSWk2H4QVZUb
         /DR0M1O875qAPWs6kH/GqCD1JMahJRGv51oRMhBCEBzpe0lmoU7yYH9q0CxTHO+SgCLN
         8XljiASAyHYqOr/GQXH448wlpVAAWcAu/GNYsQEpa0EJG5unbnMv8EEZzuu1k1S+pBht
         BpNOIdz2yxOVarnBGZ57jW/Cw04+pO3mWz718c4yRlqD0RHJLFCFuZsmzxSmNZRHkOit
         S72cGpfGpfSWeoRCbPHuV0ZLEecQhWiYLlPXQawy/WsGZf1Kg4pw/RyDvyJbFQ/2lJLg
         Jqdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eA0gRDTw/ANiPAcGnshtdFV3kfcuc01b7QJclj1/2nQ=;
        b=RlXmn8D/H9aikVU3yDnohEDHgwcwgWdC2H9eW7hYmXNv6JxpOaRRmmGDWGtETDDhI9
         3D2uriG8UQe9dcVZKHnK8Wi1GnHnY4loTH78RGX2z0BNaK3iWDJOBeluxuHTRSKuEEsW
         hEhMtJ4CAMod6xwa28Rs/0xScLZLUXxmKO6YiSeJ25NEFMwdojfXlJ/iu+UOe6R0auCg
         bPU4USPe9gj8qz7dNemQ+RPmWaXSrTrHEJTxmU0IskHAFylwI1RLhOaUOSV6x3n4ximS
         Kj9Eoj0otkaW1c4q/BOw/6D4/dijqNvecXjHanzr7+rcSKZ+8AT99Q/geb2W/FQoNvcC
         JAog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a13si2305734eje.309.2019.02.11.06.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 06:52:19 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DBADFAE67;
	Mon, 11 Feb 2019 14:52:18 +0000 (UTC)
Date: Mon, 11 Feb 2019 15:52:17 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
	Pingfan Liu <kernelfans@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-ID: <20190211145217.GE15609@dhcp22.suse.cz>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
 <3a7a3cf2-b7d9-719e-85b0-352be49a6d0f@intel.com>
 <20190125105008.GJ3560@dhcp22.suse.cz>
 <20190211134909.GA107845@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211134909.GA107845@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 14:49:09, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 24-01-19 11:10:50, Dave Hansen wrote:
> > > On 1/24/19 6:17 AM, Michal Hocko wrote:
> > > > and nr_cpus set to 4. The underlying reason is tha the device is bound
> > > > to node 2 which doesn't have any memory and init_cpu_to_node only
> > > > initializes memory-less nodes for possible cpus which nr_cpus restrics.
> > > > This in turn means that proper zonelists are not allocated and the page
> > > > allocator blows up.
> > > 
> > > This looks OK to me.
> > > 
> > > Could we add a few DEBUG_VM checks that *look* for these invalid
> > > zonelists?  Or, would our existing list debugging have caught this?
> > 
> > Currently we simply blow up because those zonelists are NULL. I do not
> > think we have a way to check whether an existing zonelist is actually 
> > _correct_ other thatn check it for NULL. But what would we do in the
> > later case?
> > 
> > > Basically, is this bug also a sign that we need better debugging around
> > > this?
> > 
> > My earlier patch had a debugging printk to display the zonelists and
> > that might be worthwhile I guess. Basically something like this
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2e097f336126..c30d59f803fb 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5259,6 +5259,11 @@ static void build_zonelists(pg_data_t *pgdat)
> >  
> >  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
> >  	build_thisnode_zonelists(pgdat);
> > +
> > +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> > +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> > +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> > +	pr_cont("\n");
> >  }
> 
> Looks like this patch fell through the cracks - any update on this?

I was waiting for some feedback. As there were no complains about the
above debugging output I will make it a separate patch and post both
patches later this week. I just have to go through my backlog pile after
vacation.
-- 
Michal Hocko
SUSE Labs

