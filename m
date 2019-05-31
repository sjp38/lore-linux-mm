Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 217ECC28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 09:03:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D631226657
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 09:03:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D631226657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AAA26B0276; Fri, 31 May 2019 05:03:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5340D6B0278; Fri, 31 May 2019 05:03:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D4BA6B027A; Fri, 31 May 2019 05:03:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3C926B0276
	for <linux-mm@kvack.org>; Fri, 31 May 2019 05:03:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so1399815edo.5
        for <linux-mm@kvack.org>; Fri, 31 May 2019 02:03:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CouyX2VEbNMbBW9+tYcTLAxIFPuGVDSSe9hR4Eem9P8=;
        b=qtXUu3lW2nzKZ9/i5Upv2lxMpY7/3e8rTVqwkKmFIDCuGX1E/lrJKY+LiHHWR5RCkU
         zK/wP0HfLpcTN8Vb2w7YGsAWvKLWS26PAvXYLNQxDWsUAZWgl6zeQGJ3697giEPYSMgQ
         ZYTQEjCFYLvAn2pRybxznPvnks996+ttodUtZEr9yVL8ws1orPKF+hoejwI8WSmwVv7J
         yhFGF8XYZaNm6UuX63MDnQ2R4T0Di+b1umaoU3V/rhzay/eVH126dUg6HkNTxS2wR6ZU
         oPtk9WTAQOZF9rblv+b0QA8gdRAgYHv156klr3R1dtViWJM9NIv3GlpxqApPO/3Vx04m
         oHFg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVos8komQLD1xN4xnxBBJbJfN67YypqmvL6hoZbGgZrychk0rwg
	iNxDnUyaQbyvnph2lha3QqK7m9lz7FkeCqQ3NjnQfwinmXhdipMVATZcopTzKC4QaiqLl6EtE6i
	spcnIZ+hlCr2ZuWbpy5OVfu5dLCezzmgmhxDF7tSiKR4F+SdfABXgEfCIqtciRpA=
X-Received: by 2002:a50:ee01:: with SMTP id g1mr9814983eds.263.1559293390392;
        Fri, 31 May 2019 02:03:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0YPl/WeFh6dCNqLTxZuBZl1BOHmA+zqtPWh7lDwnCAKBijD0FqlkZlyX2rLq9aZlENQLy
X-Received: by 2002:a50:ee01:: with SMTP id g1mr9814892eds.263.1559293389463;
        Fri, 31 May 2019 02:03:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559293389; cv=none;
        d=google.com; s=arc-20160816;
        b=MqNazcrUAvqK2ltuPAzNFnJjuXN4ldlS60i8rIQvXHfTlOWXAQ3pK8GMBkqrn7dTMg
         rT48S/hhhBi+ub7H7WgFYB4Q1n9WNDrfjCF9sZg3m2CLObGe19vU+m810bk5U4uTML2r
         hEu7INu+KhlTX8eE3EEPMdqjyNWkNYqKjgGGAgJWMTb189IuVZuM1KHiKHeIVs6eg0Oy
         /70sGJCwJmdKND/Pau6oG+xVAprG4FnytV/1oQRYxsiG3fPijfNwWEBQ5MlEGZpFEy8g
         aNmnUZAoc60FAoomQF9Xw4+EYGUxJecZP+s10gwQ190+MV27Hl/jKNkwbB/W4F7MaxnZ
         49Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CouyX2VEbNMbBW9+tYcTLAxIFPuGVDSSe9hR4Eem9P8=;
        b=q/tysCo+NhYbnSdDbIcIXbbiiyH/WVkhxUjB29SrJXg+Vq9qNWwV/VoCPPTLMWl3X0
         WWKV0MJOpEjYoVoSCCSGy2RWqRCvWCI5aLip4rPXPNnx9APMsEduLlC0RJS9T/Zidp9T
         4w4r0iACs+qCPdnUnusw0Wc7vitsF1m5hHf9R0n2VUJvtXWaOCUvrSBHyvDdQp4lew8Z
         tTv1es2auWP27GSOkYYBGQ0ISuJNnGZVUEjrtcgOSWBfAHUXcqpF7IFsiugw3R3xed4j
         Po+t4ykmm0iWzlXWjSLUxZGyYE74MJ+Xf4rjx17x5hfgvo7Trkbegw4+aGvQcs05Yvps
         AEXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w28si3955067eda.127.2019.05.31.02.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 02:03:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 53E5DAF61;
	Fri, 31 May 2019 09:03:08 +0000 (UTC)
Date: Fri, 31 May 2019 11:03:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	Barret Rhoden <brho@google.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>,
	Oscar Salvador <osalvador@suse.de>,
	Andy Lutomirski <luto@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190531090307.GL6896@dhcp22.suse.cz>
References: <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw>
 <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw>
 <20190513153143.GK24036@dhcp22.suse.cz>
 <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
 <20190522111655.GA4374@dhcp22.suse.cz>
 <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
 <20190528182011.GG1658@dhcp22.suse.cz>
 <CAFgQCTtD5OYuDwRx1uE7R9N+qYf5k_e=OxajpPWZWb70+QgBvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtD5OYuDwRx1uE7R9N+qYf5k_e=OxajpPWZWb70+QgBvg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 20:55:32, Pingfan Liu wrote:
> On Wed, May 29, 2019 at 2:20 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > [Sorry for a late reply]
> >
> > On Thu 23-05-19 11:58:45, Pingfan Liu wrote:
> > > On Wed, May 22, 2019 at 7:16 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Wed 22-05-19 15:12:16, Pingfan Liu wrote:
> > [...]
> > > > > But in fact, we already have for_each_node_state(nid, N_MEMORY) to
> > > > > cover this purpose.
> > > >
> > > > I do not really think we want to spread N_MEMORY outside of the core MM.
> > > > It is quite confusing IMHO.
> > > > .
> > > But it has already like this. Just git grep N_MEMORY.
> >
> > I might be wrong but I suspect a closer review would reveal that the use
> > will be inconsistent or dubious so following the existing users is not
> > the best approach.
> >
> > > > > Furthermore, changing the definition of online may
> > > > > break something in the scheduler, e.g. in task_numa_migrate(), where
> > > > > it calls for_each_online_node.
> > > >
> > > > Could you be more specific please? Why should numa balancing consider
> > > > nodes without any memory?
> > > >
> > > As my understanding, the destination cpu can be on a memory less node.
> > > BTW, there are several functions in the scheduler facing the same
> > > scenario, task_numa_migrate() is an example.
> >
> > Even if the destination node is memoryless then any migration would fail
> > because there is no memory. Anyway I still do not see how using online
> > node would break anything.
> >
> Suppose we have nodes A, B,C, where C is memory less but has little
> distance to B, comparing with the one from A to B. Then if a task is
> running on A, but prefer to run on B due to memory footprint.
> task_numa_migrate() allows us to migrate the task to node C. Changing
> for_each_online_node will break this.

That would require the task to have preferred node to be C no? Or do I
missunderstand the task migration logic?
-- 
Michal Hocko
SUSE Labs

