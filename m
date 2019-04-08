Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63F97C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 12:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 011B621473
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 12:54:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 011B621473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9044C6B0005; Mon,  8 Apr 2019 08:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B11C6B0006; Mon,  8 Apr 2019 08:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A11D6B0007; Mon,  8 Apr 2019 08:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 296DF6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 08:54:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e55so6914836edd.6
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 05:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=06peTqdcNInZ+oWxyV+sSkHnBCLYisC/RHJzONNwdUE=;
        b=HXBHZ82OnoCcW50zBkgBASfZOOUv2Csejme/QlQueJLztfLWN3FdMPSAKJVbopxsuy
         36TJ1H+gHC/ta4dGI4SWPYfjFEyiACR49tknN3rQzKpExdIOfBF1Cek7jpCtI9DwRov3
         0jWUzK0enY2Ia98zU4153zCh5L9cs+E1TZL8rrJOu5uNYjBkPwv4+E/FJu3TadSaN/QL
         UARfzJHG+/XVtuz21OXashcfJspCf5XA2XGqtiNWp2d93tOOpEWaPei1tq3G5QmY8Ujo
         HKgkWpvVlQ2Ur/24Z2mHIkpnw8dbp+dx5gGSYYo6kZLj/iRzq5rnDQMZ9kguinrOHulC
         Hyug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.190 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXe1knpNTEvOwCsIKsObQ92XXn2zevupr8M2mOH9Y9v+Y93UVeo
	0NozjXai6epzItMhxLmz0TR8GR5a7J3z12mi8in6K1E5gmsKi++f61vTDfCWduTjUiAXL8zHJbC
	XFeRNsdH2NIkwZMVZF6lQdtKC6rJKls180vJKkk6cBq8dCH8GVmYOYGZSP7api/AFEw==
X-Received: by 2002:a50:fa06:: with SMTP id b6mr13663870edq.76.1554728091602;
        Mon, 08 Apr 2019 05:54:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4e2uCZ54R9pwwzum8j0BBvG0gAXOSbVBvgWB7AGlOcu+OoNuZhUQ0DKYOxBDu1+7ZuNp/
X-Received: by 2002:a50:fa06:: with SMTP id b6mr13663812edq.76.1554728090521;
        Mon, 08 Apr 2019 05:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554728090; cv=none;
        d=google.com; s=arc-20160816;
        b=CUc3srBaqMFMAz3VDn88lCS7DahkTHUmSY5edGNTKxe4ujI1fc8kZxqlfnOerTchIY
         T2xogiQfjJ3QRHOuIof04xSuo3+pbs3T7qcSEkJ7k/UfptWDxnoUM+AKg4ke5cgzl8CM
         pLhItEeJIOnCcUqLQ2vITWCnl+eHJBeGktqq+2eBd21covOZz5kU0ThJybwchPaVe0cc
         xoR/73b6FlPkokheSIbEWosKhL9HpvVO73zyQ6vwJzGsWxr45sDwv/tHYd8Oz7okS771
         EuMUWo1fdpKNPl9beOZrobC8AfIK2tKNAgSSNAlLnQQYE+pxM2hR0I0hPE8TYIq9OrIJ
         9fMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=06peTqdcNInZ+oWxyV+sSkHnBCLYisC/RHJzONNwdUE=;
        b=jGWxByIDdcNe62fSiFyXSqnerAKrYEpo9giUx4g/7+yfVFspCQysGlw93POQPEUMa9
         OyLo8ribEjlzqXClnYEZzIVWehLoe+bEGSZEEv/ziYWSVEPGcl3ndsEK9grTwLEdKZYJ
         I2/9IH/scK3CoGNKYPoF18l3oAi9vTDylSItdxQu7ScESrNnJ1YQ4zB0TmACuvmWPmEs
         4ensdWuF9YtIk4mcuUIy9T5RHu1xaQQifWgB3uaC+MxGpLh/KgsIWcTLUWKKrFsjprub
         1xLIJt/Gt5kUIwwjcFm5rcLA7OlZjpis5DnhnJEeqB2ooegjrMHR3ufVH+fvbOHiUaI5
         nwUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.190 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp22.blacknight.com (outbound-smtp22.blacknight.com. [81.17.249.190])
        by mx.google.com with ESMTPS id d23si976217edp.178.2019.04.08.05.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 05:54:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.190 as permitted sender) client-ip=81.17.249.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.190 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp22.blacknight.com (Postfix) with ESMTPS id 182DC10C016
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 13:54:50 +0100 (IST)
Received: (qmail 18696 invoked from network); 8 Apr 2019 12:54:50 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 8 Apr 2019 12:54:49 -0000
Date: Mon, 8 Apr 2019 13:54:48 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>,
	"James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
Message-ID: <20190408125448.GB18914@techsingularity.net>
References: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
 <20190408095224.GA18914@techsingularity.net>
 <alpine.LRH.2.02.1904080639570.4674@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1904080639570.4674@file01.intranet.prod.int.rdu2.redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 07:10:11AM -0400, Mikulas Patocka wrote:
> > First, if pa-risc is !NUMA then why are separate local ranges
> > represented as separate nodes? Is it because of DISCONTIGMEM or something
> > else? DISCONTIGMEM is before my time so I'm not familiar with it and
> 
> I'm not an expert in this area, I don't know.
> 

Ok.

> > I consider it "essentially dead" but the arch init code seems to setup
> > pgdats for each physical contiguous range so it's a possibility. The most
> > likely explanation is pa-risc does not have hardware with addressing
> > limitations smaller than the CPUs physical address limits and it's
> > possible to have more ranges than available zones but clarification would
> > be nice.  By rights, SPARSEMEM would be supported on pa-risc but that
> > would be a time-consuming and somewhat futile exercise.  Regardless of the
> > explanation, as pa-risc does not appear to support transparent hugepages,
> > an option is to special case watermark_boost_factor to be 0 on DISCONTIGMEM
> > as that commit was primarily about THP with secondary concerns around
> > SLUB. This is probably the most straight-forward solution but it'd need
> > a comment obviously. I do not know what the distro configurations for
> > pa-risc set as I'm not a user of gentoo or debian.
> 
> I use Debian Sid, but I compile my own kernel. I uploaded the kernel 
> .config here: 
> http://people.redhat.com/~mpatocka/testcases/parisc-config.txt
> 

DISCONTIGMEM is set so based on the arch init code. Glancing at the
history, it seems my assumption was accurate. Discontig used NUMA
structures for non-NUMA machines to allow code to be reused and simplify
matters.

I'll put together a patch that disables this feature on DISCONTIG as it
is surprising in the DISCONTIGMEM.

> > Second, if you set the sysctl vm.watermark_boost_factor=0, does the
> > problem go away? If so, an option would be to set this sysctl to 0 by
> > default on distros that support pa-risc. Would that be suitable?
> 
> I have tried it and the problem almost goes away. With 
> vm.watermark_boost_factor=0, if I read 2GiB data from the disk, the buffer 
> cache will contain about 1.8GiB. So, there's still some superfluous page 
> reclaim, but it is smaller.
> 

Ok, for NUMA, I would generally expect some small amounts of reclaim on
a per-node basis from kswapd waking up as the node fills. I know in your
case there is no NUMA but from a memory consumption/reclaim point of
view, it doesn't matter. There are multiple active node structures so
it's treated as such.

In the short-term, I suggest you update /etc/sysctl.conf to workaround
the issue.

> BTW. I'm interested - on real NUMA machines - is reclaiming the file cache 
> really a better option than allocating the file cache from non-local node?
> 

The patch is not related to file cache concerns, it's for long-term
viability of high-order allocations, particularly THP but also SLUB which
uses high-order allocations by default.

> 
> > Finally, I'm sure this has been asked before buy why is pa-risc alive?
> > It appears a new CPU has not been manufactured since 2005. Even Alpha
> > I can understand being semi-alive since it's an interesting case for
> > weakly-ordered memory models. pa-risc appears to be supported and active
> > for debian at least so someone cares. It's not the only feature like this
> > that is bizarrely alive but it is curious -- 32 bit NUMA support on x86,
> > I'm looking at you, your machines are all dead since the early 2000's
> > AFAIK and anyone else using NUMA on 32-bit x86 needs their head examined.
> 
> I use it to test programs for portability to risc.
> 
> If one could choose between buying an expensive power system or a cheap 
> pa-risc system, pa-risc may be a better choice. The last pa-risc model has 
> four cores at 1.1GHz, so it is not completely unuseable.

Well if it was me and I was checking portability to risc, I'd probably
get hold of a raspberry pi but we all have different ways of looking at
things.

-- 
Mel Gorman
SUSE Labs

