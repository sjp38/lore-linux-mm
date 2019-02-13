Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB58CC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:11:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77F95218D3
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:11:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iKXNBPgJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77F95218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 135698E0002; Wed, 13 Feb 2019 08:11:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BD6E8E0001; Wed, 13 Feb 2019 08:11:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9F9F8E0002; Wed, 13 Feb 2019 08:11:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A64E58E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:11:39 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e68so1693589plb.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:11:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aYXYOSh02VrgFOoAtWZsG3dC6gl0mwh0qQIVsd6b6/U=;
        b=Avw3lGQvkT3ahJe9b7AR3Q8iBiQGtPpgjSScDcvr4UKCdnDHo+urvWtuubi5OFIyU4
         6W4xWdG2BgWtamepUpC749WB2nZrvMadZDJSIHY34D6eCOMtYIoGYvXbvXiW4G7+7FGS
         u4/qqlBd9nbQFpCCfkvEVB4Mvjqel+XnW9JJ0JbzvptF56wUQ1nioCAUY3Z8SQdSEDED
         ZHj0R67xc9FgJ5Dqf6Gynvmsj3ApSUoEYsxCaiKRVGyGwErHvamHq3PvYsdGhnov9Js4
         rna+1BWclGHt+y5RxzpbSvz/GU3Dfa2Ayhw4rnipQNOCPlMLJoq+38JJpkIqJuOs1ynX
         CoKg==
X-Gm-Message-State: AHQUAuYh2mTaMfBSJHQBC+xvmrAUn4ND0s5lFh4Tlmz2D2feCAjW5VfQ
	gMWyqxbCOmcDOXx9ZNBsEBDb3/Pg32vuIbSxO6GziVChYFBaYqSibH16fTnzkMN/TCd/fArCGOJ
	2MW+arR3KIfK9zszVf2JxeMzdxFjvAeif+52JqZAJidluRnERZBYiUH832tVpultSsA==
X-Received: by 2002:a63:da42:: with SMTP id l2mr379831pgj.403.1550063499305;
        Wed, 13 Feb 2019 05:11:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZxY0WnIREttn6okuS2g4ns6tqT9FpWqJX3J/xsFH0QkTOH2MhBkTd0u1I7Ut6CHNRKvOti
X-Received: by 2002:a63:da42:: with SMTP id l2mr379783pgj.403.1550063498713;
        Wed, 13 Feb 2019 05:11:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550063498; cv=none;
        d=google.com; s=arc-20160816;
        b=BiS48/PnRhM661tuGYdtMPMpy7IbKsRYF2NWqG3KILFoWXIbvdPgGCEBZ9yTxRJCGQ
         4bFoA3ncWCv0TAIMeVMBScK9m9DIAUTGD9evsrQum9mfl1zLjA3+sJLKCRqB4/oMlGQT
         SUVtQ6HoTjDnUjN6IjzOmLoERuSgjSJ5GrpRhhXCB3C9eOzc+VN+cw6P7Qlf3XXlGOZt
         ZTsPZJyQx5JObkYc5+jBSmPCfxIBzmiAmFySTJkQ1cGjldYVJFnVH/kpFF2iCTzOTDGZ
         +f+cDdmyBEoewAtOIMOOlcmQJfnRi/Sj/MJP49wt4SCekwNPBpPQPkCipNwKlenl24lu
         Ba0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aYXYOSh02VrgFOoAtWZsG3dC6gl0mwh0qQIVsd6b6/U=;
        b=SAAwCjbjrCqttspqNciI+IddgSUlgdwVADsQgnbm+RrwiK3yeqHU3vooGo25S4xfhA
         bW+vd8Dp8jUkBzKq0ySB+Sb2m6m7nd4vAcQkn5KBbkObPkWdywQE1O/nbi3GvDdwFKsG
         Se4jK07BlpyGTY+HPaqZPmL54Cts2qoF8eMrm3GkhFgYCmXLyKu6JfxWyXiupRtrGjVn
         3zkqioH8sWotlqu6HNYFESaYmNfkwKCkJ4b5/P0C6OeuWYDHKCUndfftEsSqhevoPgcw
         jsINoxrm1FVVTv7RM6LI+N1+TGbkUZTS0Egtk5Rqj5XTTmwZiXQRE/ZpBiORGiTOCC91
         fT5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iKXNBPgJ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f193si128176pgc.31.2019.02.13.05.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 05:11:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iKXNBPgJ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aYXYOSh02VrgFOoAtWZsG3dC6gl0mwh0qQIVsd6b6/U=; b=iKXNBPgJ/QWjwdq9K/ZA6v+x9
	5Y3A54QPC72zkNBsg4SgL6/FXbuEbgxUjjZMyeOumCtxt6+KjXuW94vOx+tdr0Gap/U+fRhOEtRcR
	5umJ2pljfWs+9TCLUZoW5tO+8wKmpCeVreqbVS3UrJJH3d/tjN89mOiAU7uvZW8wTYr9WHgQy5zDm
	NlQvX8XP71crgRCjSTVZ4xgb5A10DKgP/Ige657/16+t5l5sZqa8VLkfWNIoXpYC0j+4VHiWaunun
	GY4ABcJ6XUZPFXm+zW79mgTBCCmQ4rmjPQQIYcDIBl+KJxJVmcd+eCoRvIark50+94JSFMGLSPZJa
	N6Oe6fM9w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtuK4-0003qU-Na; Wed, 13 Feb 2019 13:11:32 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 3668222BBEBE5; Wed, 13 Feb 2019 14:11:31 +0100 (CET)
Date: Wed, 13 Feb 2019 14:11:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-ID: <20190213131131.GS32494@hirez.programming.kicks-ass.net>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
 <20190213103231.GN32494@hirez.programming.kicks-ass.net>
 <20190213115014.GC4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213115014.GC4525@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 12:50:14PM +0100, Michal Hocko wrote:
> On Wed 13-02-19 11:32:31, Peter Zijlstra wrote:
> > On Wed, Feb 13, 2019 at 10:43:15AM +0100, Michal Hocko wrote:
> > > @@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
> > >  
> > >  	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
> > >  	build_thisnode_zonelists(pgdat);
> > > +
> > > +	pr_info("node[%d] zonelist: ", pgdat->node_id);
> > > +	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
> > > +		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
> > > +	pr_cont("\n");
> > >  }
> > 
> > Have you ran this by the SGI and other stupid large machine vendors?
> 
> I do not have such a large machine handy. The biggest I have has
> handfull (say dozen) of NUMA nodes.
> 
> > Traditionally they tend to want to remove such things instead of adding
> > them.
> 
> I do not insist on this patch but I find it handy. If there is an
> opposition I will not miss it much.

Well, I don't have machines like that either and don't mind the patch.
Just raising the issue; I've had the big iron boys complain about
similar things (typically printing something for every CPU, which gets
out of hand much faster than zones, but still).

