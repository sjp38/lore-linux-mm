Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85C9FC04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FD320B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:20:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FD320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 984A76B0289; Tue, 28 May 2019 14:20:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933D96B028A; Tue, 28 May 2019 14:20:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FCCB6B028B; Tue, 28 May 2019 14:20:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 33B9B6B0289
	for <linux-mm@kvack.org>; Tue, 28 May 2019 14:20:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y12so34229507ede.19
        for <linux-mm@kvack.org>; Tue, 28 May 2019 11:20:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iPhoVZK+2VXkt3qLmBwlRgdAwOLllwqyHMSUVSOUr0o=;
        b=QrDSXQaa4Y8FFbxpaNzv5kR89FaQMtuHE6lrNiE6z53r5mE1yuNPeQEukk5OfYiyXz
         6HbsrnrKrHNOj2aERUJIvdwiJofCKduoIUaqt44oitKavsMGvCWtrw5xkQGPRBCDlC1+
         cgQTn1xrRH4i6Q98fBArjXstZABNbWj88OVy5auvHYf3CMFeXe6eIJz4zfjhK71Iz2Dh
         3khHukh7MOoQ06X3ut5WWzjx4iLzUBz+gwQ04YYnOaUUQGgaG33Ha52gH4gwUA1P7L8h
         K8R/UJxEr8MF9RBoAIN1A0ciOCR9cnNMpQ2N9Nf0mN0vSilqCOKoxWn6T6iBAfV94DcO
         L/OQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVZ1HoUCWdTMmRmf7AgyqX4U64hNvjtIHWthR5jJCj7WskSASpe
	/dihDPL8S6OjD2mk88OGVWL3m23xmdjGvvju0ifoQvv+hh4rdFdEGpMQkMfqlvLMA41bjE/zCjU
	r8BwfeDS1BElQMmq8BzU+eF7mM5w8pPvjPMGxy+cHvtl0IFMXV2OtXqhUJFLoDUs=
X-Received: by 2002:a50:e79c:: with SMTP id b28mr129410393edn.277.1559067614784;
        Tue, 28 May 2019 11:20:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5tchQgTMzM03b7LG5ULXIq8t4EfAyxqcaBvnzD9pgfOX52Fdqng6iIEz3KypWhv2sDlFa
X-Received: by 2002:a50:e79c:: with SMTP id b28mr129410312edn.277.1559067613869;
        Tue, 28 May 2019 11:20:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559067613; cv=none;
        d=google.com; s=arc-20160816;
        b=qFvX/iQM7qdsgI4Xjo0f8fmVAG1S5ZUHBWbxjj/VNe7JLqFNG/uf1me1YSh2QEUXZ4
         CFiNPZEIpeFpLClbTqOQ6NiqEry8DKMgescYCZns8S8PDDPwzJxxFo1LTIKm1fn5S1E9
         P335YtMmwu8WjnwTBXPRtMf/vmbUQKG/Fyxziwfca4Nvq0j+WBggPUlJFZU2lsdWxNIF
         8jf4E4I/m0e1jpDj4MoHGwxPoK2wJGv8l7phM/VUoguiSxPODnlZWu3yYnAVlUSxZeg0
         yPrWJxA5v3IenOdAinAxJ/wU2Kc70t3bW/pP6VjfhnjKuOU22s1s7St53ljKeMa8UnKs
         oo/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iPhoVZK+2VXkt3qLmBwlRgdAwOLllwqyHMSUVSOUr0o=;
        b=xo5xQCrNgnPXly2mYzSNEJAQIeVDfcn9XrlTyKWAMSvTeWpvjpCfpcgqznROBGtWMW
         kM9dMnekRP0Gpb0HkXbuZeVRMcVhg5YERqgnyMNdgLIrZLpd1TasS2CJfW04I7/DxDXW
         hr1RaIr0B3leWbaSRuYo2Tue+tIhlCcWH/SBx5M0OOi7ODNLwh277wqK8Khq2ulollET
         5dHkzgdL0fDkTxuSQT8YwKoaoJS0+dSW1bpgaNAO05bfQ9GrAXqPpWMzmuGLoakpcECB
         HqzPvA6mCTmQgs1YavK6TX52Mf4vvXJ6VFQ6x4C4CJnfA5E20uM07wY3fsfccF675ToF
         4nXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n23si9717779ejc.81.2019.05.28.11.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 11:20:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C0B88ACBA;
	Tue, 28 May 2019 18:20:12 +0000 (UTC)
Date: Tue, 28 May 2019 20:20:11 +0200
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
Message-ID: <20190528182011.GG1658@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
 <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw>
 <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw>
 <20190513153143.GK24036@dhcp22.suse.cz>
 <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
 <20190522111655.GA4374@dhcp22.suse.cz>
 <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for a late reply]

On Thu 23-05-19 11:58:45, Pingfan Liu wrote:
> On Wed, May 22, 2019 at 7:16 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 22-05-19 15:12:16, Pingfan Liu wrote:
[...]
> > > But in fact, we already have for_each_node_state(nid, N_MEMORY) to
> > > cover this purpose.
> >
> > I do not really think we want to spread N_MEMORY outside of the core MM.
> > It is quite confusing IMHO.
> > .
> But it has already like this. Just git grep N_MEMORY.

I might be wrong but I suspect a closer review would reveal that the use
will be inconsistent or dubious so following the existing users is not
the best approach.

> > > Furthermore, changing the definition of online may
> > > break something in the scheduler, e.g. in task_numa_migrate(), where
> > > it calls for_each_online_node.
> >
> > Could you be more specific please? Why should numa balancing consider
> > nodes without any memory?
> >
> As my understanding, the destination cpu can be on a memory less node.
> BTW, there are several functions in the scheduler facing the same
> scenario, task_numa_migrate() is an example.

Even if the destination node is memoryless then any migration would fail
because there is no memory. Anyway I still do not see how using online
node would break anything.

> > > By keeping the node owning cpu as online, Michal's patch can avoid
> > > such corner case and keep things easy. Furthermore, if needed, the
> > > other patch can use for_each_node_state(nid, N_MEMORY) to replace
> > > for_each_online_node is some space.
> >
> > Ideally no code outside of the core MM should care about what kind of
> > memory does the node really own. The external code should only care
> > whether the node is online and thus usable or offline and of no
> > interest.
>
> Yes, but maybe it will pay great effort on it.

Even if that is the case it would be preferable because the current
situation is just not sustainable wrt maintenance cost. It is just too
simple to break the existing logic as this particular report outlines.
-- 
Michal Hocko
SUSE Labs

