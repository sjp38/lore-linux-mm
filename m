Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6C57A6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 04:59:08 -0500 (EST)
Received: by wivz2 with SMTP id z2so9917257wiv.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 01:59:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ks3si6014812wjb.97.2015.03.04.01.59.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 01:59:06 -0800 (PST)
Date: Wed, 4 Mar 2015 10:59:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol: Let mem_cgroup_move_account() have
 effect only if MMU enabled
Message-ID: <20150304095904.GA14748@dhcp22.suse.cz>
References: <54F4E739.6040805@qq.com>
 <20150303134524.GE2409@dhcp22.suse.cz>
 <54F61300.1070409@sohu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F61300.1070409@sohu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <dsg_gchen_5257@sohu.com>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Chen Gang <762976180@qq.com>, Balbir Singh <bsingharora@gmail.com>

[CCing Balbir]

On Wed 04-03-15 04:01:04, Chen Gang wrote:
> On 3/3/15 21:45, Michal Hocko wrote:
> > On Tue 03-03-15 06:42:01, Chen Gang wrote:
> >> When !MMU, it will report warning. The related warning with allmodconfig
> >> under c6x:
> > 
> > Does it even make any sense to enable CONFIG_MEMCG when !CONFIG_MMU?
> > Is anybody using this configuration and is it actually usable? My
> > knowledge about CONFIG_MMU is close to zero so I might be missing
> > something but I do not see a point into fixing compile warnings when
> > the whole subsystem is not usable in the first place.
> > 
> 
> For me, only according to the current code, the original author assumes
> CONFIG_MEMCG can still have effect when !CONFIG_MMU: "or, he/she needn't
> use CONFIG_MMU switch macro in memcontrol.c".

Well this was before my time. 024914477e15 (memcg: move charges of
anonymous swap) added them because of lack of page tables (as per
documentation). This is a good reason but a bigger question is whether
we want to add small little changes to make compiler happy or face the
reality and realize that MEMCG without MMU is so restricted (I am even
not sure whether it is usable at all) and reflect that in the
dependency. Balbir had actually mentioned this in early submissions:
https://lkml.org/lkml/2008/3/16/59. I haven't seen anybody objecting to
this so I guess it went in without a good reason. So instead I suggest
the following change instead.
---
