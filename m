Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02DA5C742BC
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4D732080A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4D732080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F74C8E0146; Fri, 12 Jul 2019 08:50:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 480E08E00DB; Fri, 12 Jul 2019 08:50:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3212E8E0146; Fri, 12 Jul 2019 08:50:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0A9E8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:50:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so7738290edr.8
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GhyPz7FHI3zBhpf39YLkhlDZQvPucO9z0Kyalr33zPM=;
        b=hcIUIRwxOc3zbwlMzX/MfUMd8sY59vYpqoGQd658PsNQ5rU27IrspESwZ0X8aMXPVr
         l4CsVq/KcnkjVsS4yBrlCpFN09W7ta8TYjAYmXauVt/urf9P3K1BRNZ7CP17DYJMZePy
         4sdeeg4tGXYD7jnIxF9zm/4cOWwDaVHtY5/RrkVEV5KFrPZub84N8lJzmt8PiN085WCO
         Ya3xFbcGvqq+VrEZORE7kDdxoMqbY5SoX6SGyo4VTHc3kr0QcNCC6a9w565sAvn6ZkJf
         O534UzENHE/pTgpgNQZ9qtTJ4RdT5/WwmLyfIN+2sFR1G29uY6UCZwhlTgOX7U6qRGht
         o6Ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAWS663MVuwZkL3DwfxQgQXv5oQmf6/ag4jkE6xHX269ODn8dc84
	39TIGOplI8wyhb3VmctCgToKYMn12omzkW/cr/wXNe6qqpTGAzT41ahr2RzJ2JluBr7Mek0FwMe
	oBLzaIywy+1HJqVwCLYzN7GynG5w4ZRtzXdufIO0nsps2T6STInqG/+XYeepOAnpiCw==
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr8006360ejr.277.1562935852413;
        Fri, 12 Jul 2019 05:50:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbxZM3slt9EOeFfbZSfLFRTVG7mefN42Lltw2OUgB6Bn/ShRCkbzfnuqOnuchyvw0vwqtA
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr8006318ejr.277.1562935851601;
        Fri, 12 Jul 2019 05:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562935851; cv=none;
        d=google.com; s=arc-20160816;
        b=K/48f0ltsDl8D+j67hwaBlFyg5tEHjen58ROg1YFAf690gR8nrfAB+VOC9fo2MufoV
         4Px4LPeId0J+dTuZ5zsyny1loxE/D9Zpo+GK4m+AVkWRjgnLBJx1zI3NerL3/+Hmhi55
         qzWvsjcEAJhkutQ6B8n3+e524NLYZNa9lcaQ5pv01kCK39pkmDFAgSSUdsG1CbIXN5og
         mgNEusyb15Byl3fKWte5b6WhQg9x5UEPylPCOdF2fNlNlqpHghERP9TUzqyLI122c7rC
         zzCC4f++WPTWA+THEkwL7dKQXUkDhx5Pb9kctKzdoHFLpZTYunaIJbnSBDPfQfPfrHwJ
         CsTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GhyPz7FHI3zBhpf39YLkhlDZQvPucO9z0Kyalr33zPM=;
        b=Y5uMHYvCpxTbYWJy4dp//8K5GDVI865yTdSkq9jYIpYDtAdCsO41lyYHLZFjEo4nNN
         qg2pb8YT7J2kHb53/FBrExPdIxAmP7DAFuxAodAW/3COJuaz7R2GqCJCSeh6zXaje7tV
         wBWHuKD6/09JwfnfdTE4tvvR8eJqeesDnSQ4dWniPf2vb9zaLk8eeUScrq4vA1p4fFnX
         w8ltZ3eq5FDjrUKdGujIToKk8YT3+muyKHZ5VPbqtqJJhfzlNjUq3Dn7vQyrwoc47r5F
         nLj6BVP7LyFvS5IxTGlDavBVqTYOLBxp36FKk/enT9gQwD69vWrDIVu2STDbNNMh2Hz5
         ueyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si4635351ejz.322.2019.07.12.05.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80A04AC3F;
	Fri, 12 Jul 2019 12:50:50 +0000 (UTC)
Date: Fri, 12 Jul 2019 13:50:47 +0100
From: Mel Gorman <mgorman@suse.de>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: huang ying <huang.ying.caritas@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, jhladky@redhat.com,
	lvenanci@redhat.com, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
Message-ID: <20190712125047.GL13484@suse.de>
References: <20190624025604.30896-1-ying.huang@intel.com>
 <20190624140950.GF2947@suse.de>
 <CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
 <20190703091747.GA13484@suse.de>
 <87ef3663nd.fsf@yhuang-dev.intel.com>
 <20190712082710.GH13484@suse.de>
 <87d0ifwmu2.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87d0ifwmu2.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 06:48:05PM +0800, Huang, Ying wrote:
> > Ordinarily I would hope that the patch was motivated by observed
> > behaviour so you have a metric for goodness. However, for NUMA balancing
> > I would typically run basic workloads first -- dbench, tbench, netperf,
> > hackbench and pipetest. The objective would be to measure the degree
> > automatic NUMA balancing is interfering with a basic workload to see if
> > they patch reduces the number of minor faults incurred even though there
> > is no NUMA balancing to be worried about. This measures the general
> > overhead of a patch. If your reasoning is correct, you'd expect lower
> > overhead.
> >
> > For balancing itself, I usually look at Andrea's original autonuma
> > benchmark, NAS Parallel Benchmark (D class usually although C class for
> > much older or smaller machines) and spec JBB 2005 and 2015. Of the JBB
> > benchmarks, 2005 is usually more reasonable for evaluating NUMA balancing
> > than 2015 is (which can be unstable for a variety of reasons). In this
> > case, I would be looking at whether the overhead is reduced, whether the
> > ratio of local hits is the same or improved and the primary metric of
> > each (time to completion for Andrea's and NAS, throughput for JBB).
> >
> > Even if there is no change to locality and the primary metric but there
> > is less scanning and overhead overall, it would still be an improvement.
> 
> Thanks a lot for your detailed guidance.
> 

No problem.

> > If you have trouble doing such an evaluation, I'll queue tests if they
> > are based on a patch that addresses the specific point of concern (scan
> > period not updated) as it's still not obvious why flipping the logic of
> > whether shared or private is considered was necessary.
> 
> I can do the evaluation, but it will take quite some time for me to
> setup and run all these benchmarks.  So if these benchmarks have already
> been setup in your environment, so that your extra effort is minimal, it
> will be great if you can queue tests for the patch.  Feel free to reject
> me for any inconvenience.
> 

They're not setup as such, but my testing infrastructure is heavily
automated so it's easy to do and I think it's worth looking at. If you
update your patch to target just the scan period aspects, I'll queue it
up and get back to you. It usually takes a few days for the automation
to finish whatever it's doing and pick up a patch for evaluation.

-- 
Mel Gorman
SUSE Labs

