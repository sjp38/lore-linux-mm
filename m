Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 028506B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 04:30:21 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l95so14790634wrc.12
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 01:30:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q81si2417764wmb.96.2017.03.31.01.30.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 01:30:19 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:30:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory hotplug and force_remove
Message-ID: <20170331083017.GK27098@dhcp22.suse.cz>
References: <20170320192938.GA11363@dhcp22.suse.cz>
 <2735706.OR0SQDpVy6@aspire.rjw.lan>
 <20170328075808.GB18241@dhcp22.suse.cz>
 <2203902.lsAnRkUs2Y@aspire.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2203902.lsAnRkUs2Y@aspire.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Kani Toshimitsu <toshi.kani@hpe.com>, Jiri Kosina <jkosina@suse.cz>, joeyli <jlee@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

[Fixed up email address of Toshimitsu - the email thread starts
http://lkml.kernel.org/r/20170320192938.GA11363@dhcp22.suse.cz]

On Tue 28-03-17 17:22:58, Rafael J. Wysocki wrote:
> On Tuesday, March 28, 2017 09:58:08 AM Michal Hocko wrote:
> > On Mon 20-03-17 22:24:42, Rafael J. Wysocki wrote:
> > > On Monday, March 20, 2017 03:29:39 PM Michal Hocko wrote:
> > > > Hi Rafael,
> > > 
> > > Hi,
> > > 
> > > > we have been chasing the following BUG() triggering during the memory
> > > > hotremove (remove_memory):
> > > > 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> > > > 				check_memblock_offlined_cb);
> > > > 	if (ret)
> > > > 		BUG();
> > > > 
> > > > and it took a while to learn that the issue is caused by
> > > > /sys/firmware/acpi/hotplug/force_remove being enabled. I was really
> > > > surprised to see such an option because at least for the memory hotplug
> > > > it cannot work at all. Memory hotplug fails when the memory is still
> > > > in use. Even if we do not BUG() here enforcing the hotplug operation
> > > > will lead to problematic behavior later like crash or a silent memory
> > > > corruption if the memory gets onlined back and reused by somebody else.
> > > > 
> > > > I am wondering what was the motivation for introducing this behavior and
> > > > whether there is a way to disallow it for memory hotplug. Or maybe drop
> > > > it completely. What would break in such a case?
> > > 
> > > Honestly, I don't remember from the top of my head and I haven't looked at
> > > that code for several months.
> > > 
> > > I need some time to recall that.
> > 
> > Did you have any chance to look into this?
> 
> Well, yes.
> 
> It looks like that was added for some people who depended on the old behavior
> at that time.
> 
> I guess we can try to drop it and see what happpens. :-)

OK, so what do you think about the following? It is based on the current
linux-next and I have only compile tested it.
---
