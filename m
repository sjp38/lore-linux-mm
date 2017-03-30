Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB652806E6
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:57:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o70so11405540wrb.11
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:57:47 -0700 (PDT)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id s72si4748495wma.24.2017.03.30.09.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 09:57:45 -0700 (PDT)
Date: Fri, 31 Mar 2017 00:57:29 +0800
From: joeyli <jlee@suse.com>
Subject: Re: memory hotplug and force_remove
Message-ID: <20170330165729.GN28365@linux-l9pv.suse>
References: <20170320192938.GA11363@dhcp22.suse.cz>
 <2735706.OR0SQDpVy6@aspire.rjw.lan>
 <20170328075808.GB18241@dhcp22.suse.cz>
 <2203902.lsAnRkUs2Y@aspire.rjw.lan>
 <alpine.LSU.2.20.1703301046570.31814@cbobk.fhfr.pm>
 <20170330162031.GE4326@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330162031.GE4326@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jiri Kosina <jikos@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Thu, Mar 30, 2017 at 06:20:34PM +0200, Michal Hocko wrote:
> On Thu 30-03-17 10:47:52, Jiri Kosina wrote:
> > On Tue, 28 Mar 2017, Rafael J. Wysocki wrote:
> > 
> > > > > > we have been chasing the following BUG() triggering during the memory
> > > > > > hotremove (remove_memory):
> > > > > > 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> > > > > > 				check_memblock_offlined_cb);
> > > > > > 	if (ret)
> > > > > > 		BUG();
> > > > > > 
> > > > > > and it took a while to learn that the issue is caused by
> > > > > > /sys/firmware/acpi/hotplug/force_remove being enabled. I was really
> > > > > > surprised to see such an option because at least for the memory hotplug
> > > > > > it cannot work at all. Memory hotplug fails when the memory is still
> > > > > > in use. Even if we do not BUG() here enforcing the hotplug operation
> > > > > > will lead to problematic behavior later like crash or a silent memory
> > > > > > corruption if the memory gets onlined back and reused by somebody else.
> > > > > > 
> > > > > > I am wondering what was the motivation for introducing this behavior and
> > > > > > whether there is a way to disallow it for memory hotplug. Or maybe drop
> > > > > > it completely. What would break in such a case?
> > > > > 
> > > > > Honestly, I don't remember from the top of my head and I haven't looked at
> > > > > that code for several months.
> > > > > 
> > > > > I need some time to recall that.
> > > > 
> > > > Did you have any chance to look into this?
> > > 
> > > Well, yes.
> > > 
> > > It looks like that was added for some people who depended on the old behavior
> > > at that time.
> > > 
> > > I guess we can try to drop it and see what happpens. :-)
> > 
> > I'd agree with that; at the same time, udev rule should be submitted to 
> > systemd folks though. I don't think there is anything existing in this 
> > area yet (neither do distros ship their own udev rules for this AFAIK).
> 
> Another option would keepint the force_remove knob but make the code be
> error handling aware. In other words rather than ignoring offline error
> simply propagate it up the chain and do not consider the offline. Would
> that be acceptable?

Then the only difference between normal mode is that the force_remove mode
doesn't send out uevent for not-offline-yet container.

I vote to remove force_remove not just it ignored offline error and also
it's a acpi global knob that it affect all container devices in system.

Thanks a lot!
Joey Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
