Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C633C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08D29222A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:49:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CCK4abFG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08D29222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 826B68E00E6; Mon, 11 Feb 2019 08:49:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 800278E00C3; Mon, 11 Feb 2019 08:49:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C6A48E00E6; Mon, 11 Feb 2019 08:49:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 120DC8E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:49:14 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z16so1665175wrt.5
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 05:49:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DVtdq8fU5yzV1rrZ0aSuQ/EzU0RuehB06aN26pxAuHw=;
        b=hPZe53jDA0H2nDdPuEz/Tm7YRHPDYS6/fa8kt9OjP3bVM9fUHJYwUWLcRcGvJ3s7vt
         xUZOdPw/Uhq/vSj8Rzp8nXFP8u65XCf8Gh/KiMEBz6gUupu4rmwy3nBRVXzCr6ly3wOq
         Mkyu7YfEtXXut7T4zNlbkrNQk6ONOKVaUCBSajS61KKk9AmkKxNRjE9j494zusopPfta
         zKGsipgM2GpE275jVKWOYAek50OhDhjgc2e7CjhTdu1ZpG24cRX4Ftzzvpy+eqxZXQX1
         R0mhLT632VEP1KV+yUteDlxOqeYhLMnjRZ9nQYqn0BpEKZfUrExUUXjJka7WZrPRQvOp
         cm5A==
X-Gm-Message-State: AHQUAuZ/3GTCwRhc1rI+rB+DmkdnimU3HoLXSv6nX6/InreVnN66PeE5
	0HQCtDDvkIvTQmUf0nggF8+o1ToXDICP1Zxln0+UsxS2Kc0daRG5Gsp8gqqvGqjyeR9kO17DM+R
	y7PYIXqvxSyCAWky0U6G+TUtpgeBmSyJdPJNPcTEpGml8ERgwKbBhtiC2xpdo7mAANPFrCs3Et8
	pAkGg5xFZm6IaHL4j84YaNRCbBBUnxcPXx6FbqBvqjw2oZdt8DWf/66opdNglmI1371s7j1dADD
	UcbPbi/L0HV3+Tq75KU5FuXeCk7lV/Ieuj0VMJnXTv/4P8oQdQJStOOgxCLyA5eBlCnD0CXZn4N
	nA5PGHxqSZnVIh7/PGQQACGa+RmnrjWmJabe+2IIBoHDX+aT+o6q2iRdHiEVfmyA8pFe2xtS3g=
	=
X-Received: by 2002:adf:dfc4:: with SMTP id q4mr6410106wrn.276.1549892953553;
        Mon, 11 Feb 2019 05:49:13 -0800 (PST)
X-Received: by 2002:adf:dfc4:: with SMTP id q4mr6410055wrn.276.1549892952736;
        Mon, 11 Feb 2019 05:49:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549892952; cv=none;
        d=google.com; s=arc-20160816;
        b=yvV8woNM0WaI8QOhCHtpHMx3u68MbGRdj0PF7UCoila0nr8IPcysXE7ew68n9i7k0Y
         c8xnsCjqZksBolZlxe/wYNppwwIZWBBlJQ5KzaUesQ1e5wJOfhonURGdC3ldTId6j4fs
         kZG11XlWMJ1bTVYClIaYb4nybFvkHTFOAuK7Hl/BMOXGkhPocQ7jJoXApmqcc334DqwA
         bHmEKT5IKbPmD/tFwcHY4FSHPtJQn1dH3oIwolKti2OLnE/QwABGm+Zjf0yEEIVNUTMM
         m+nQaN1Wi6ENkKMdN1ZFMBTI+AK8i8uUZsqCy7YayCfc1E8bV+kJpoJwSseB+Er9B2Am
         zvNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=DVtdq8fU5yzV1rrZ0aSuQ/EzU0RuehB06aN26pxAuHw=;
        b=obYsCHk8vmnoGR/bETaBw4UaKe0DivE+HsCVURAL0erGxCKuixnNKXTSHUZA1CA7k/
         wtazpy2LxPCZVX0HNqE7zvBVMnZ1gNyOFyamcwEbyKWiQQuKQFRp9vizjHRFQOmSFSad
         HkI2j5087lib8/dk13t3NFctio6/RUoENlFrwNHLdHqsxKOnyJcq0wq6NzCdGqm6zJBC
         CjtwNYpuEWdgvFvYD4LihtooYUJSRrFwKq5n4ScJbkQWF87f9LcCqKxlTRaHZKVZwDd5
         kc5CT+u41Z46eSXXrFNR5KcXDmrmywV9y9a4j+AsnzehQ6ylpUZwHsPwP3vYHKdpsukT
         Prqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CCK4abFG;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor6381720wmt.1.2019.02.11.05.49.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 05:49:12 -0800 (PST)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CCK4abFG;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DVtdq8fU5yzV1rrZ0aSuQ/EzU0RuehB06aN26pxAuHw=;
        b=CCK4abFGXcAfhVXmnffelYC/DDGe1Z8EpvNin5P2hc8Xjf3/+ybQ8YCd/ZRN0kZuGj
         BtJlskKem5DzyYfhdYZHmjftoWVZgmMfalk4/ALI3ebW/mobd9JROaujzQjZum/b7y+K
         4aO9OawsNAE+/uV+eQpzZbhiratfAlXETcydv2Cjd9OF7KBxn61f/7JXIq5wVHbnKJ/a
         6jNF0S8ah01tkg6wGRZ630re0KbURzsbTKQqnDZbsbfuRjt9pnWjAIqZ8AnUWLTseo+H
         Gzreb6TV39Aw3LUHelip++YXvjHQF4A2T1KXhQVutCk1MVeORaw1FV7orcBxhYLTQjHn
         enmQ==
X-Google-Smtp-Source: AHgI3IbnoKtqDyMN51wGAheblyAvac9xJv/j79dudDo+aSVyCoGxbXaU22La1kGx2XXQbkCFrKZ1+Q==
X-Received: by 2002:a1c:790c:: with SMTP id l12mr9002787wme.11.1549892952343;
        Mon, 11 Feb 2019 05:49:12 -0800 (PST)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id n9sm7499714wrx.80.2019.02.11.05.49.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 05:49:11 -0800 (PST)
Date: Mon, 11 Feb 2019 14:49:09 +0100
From: Ingo Molnar <mingo@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
	Pingfan Liu <kernelfans@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-ID: <20190211134909.GA107845@gmail.com>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
 <3a7a3cf2-b7d9-719e-85b0-352be49a6d0f@intel.com>
 <20190125105008.GJ3560@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190125105008.GJ3560@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 24-01-19 11:10:50, Dave Hansen wrote:
> > On 1/24/19 6:17 AM, Michal Hocko wrote:
> > > and nr_cpus set to 4. The underlying reason is tha the device is bound
> > > to node 2 which doesn't have any memory and init_cpu_to_node only
> > > initializes memory-less nodes for possible cpus which nr_cpus restrics.
> > > This in turn means that proper zonelists are not allocated and the page
> > > allocator blows up.
> > 
> > This looks OK to me.
> > 
> > Could we add a few DEBUG_VM checks that *look* for these invalid
> > zonelists?  Or, would our existing list debugging have caught this?
> 
> Currently we simply blow up because those zonelists are NULL. I do not
> think we have a way to check whether an existing zonelist is actually 
> _correct_ other thatn check it for NULL. But what would we do in the
> later case?
> 
> > Basically, is this bug also a sign that we need better debugging around
> > this?
> 
> My earlier patch had a debugging printk to display the zonelists and
> that might be worthwhile I guess. Basically something like this
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2e097f336126..c30d59f803fb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5259,6 +5259,11 @@ static void build_zonelists(pg_data_t *pgdat)
>  
>  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
>  	build_thisnode_zonelists(pgdat);
> +
> +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> +	pr_cont("\n");
>  }

Looks like this patch fell through the cracks - any update on this?

Thanks,

	Ingo

