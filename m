Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6066B0390
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 11:11:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id t30so10835602wrc.15
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 08:11:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10si8185116wrd.125.2017.04.07.08.11.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 08:11:09 -0700 (PDT)
Date: Fri, 7 Apr 2017 17:11:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
Message-ID: <20170407151105.GH16413@dhcp22.suse.cz>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-2-jglisse@redhat.com>
 <20170407121349.GB16392@dhcp22.suse.cz>
 <20170407143246.GA15098@redhat.com>
 <20170407144504.GG16413@dhcp22.suse.cz>
 <20170407145740.GA15335@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170407145740.GA15335@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Fri 07-04-17 10:57:43, Jerome Glisse wrote:
> On Fri, Apr 07, 2017 at 04:45:04PM +0200, Michal Hocko wrote:
> > On Fri 07-04-17 10:32:49, Jerome Glisse wrote:
> > > On Fri, Apr 07, 2017 at 02:13:49PM +0200, Michal Hocko wrote:
> > > > On Wed 05-04-17 16:40:11, Jerome Glisse wrote:
> > > > > When hotpluging memory we want more information on the type of memory.
> > > > > This is to extend ZONE_DEVICE to support new type of memory other than
> > > > > the persistent memory. Existing user of ZONE_DEVICE (persistent memory)
> > > > > will be left un-modified.
> > > > 
> > > > My current hotplug rework [1] is touching this path as well. It is not
> > > > really clear from the chage why you are changing this and what are the
> > > > further expectations of MEMORY_DEVICE_PERSISTENT. Infact I have replaced
> > > > for_device with want__memblock [2]. I plan to repost shortly but I would
> > > > like to understand your modifications more to reduce potential conflicts
> > > > in the code. Why do you need to distinguish different types of memory
> > > > anyway.
> > > > 
> > > > [1] http://lkml.kernel.org/r/20170330115454.32154-1-mhocko@kernel.org
> > > > [2] the current patchset is in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > > >     branch attempts/rewrite-mem_hotplug-WIP
> > > 
> > > This is needed for UNADDRESSABLE memory type introduced in patch 3 and
> > > the arch specific bits are in patch 4. Basicly for UNADDRESSABLE memory
> > > i do not want the arch code to create a linear mapping for the range
> > > being hotpluged. Adding memory_type in this patch allow to distinguish
> > > between different type of ZONE_DEVICE.
> > 
> > Why don't you use __add_pages directly then?
> 
> That's a possibility, i wanted to keep the arch code in the loop in case
> some arch wanted to do something specific. But it is unlikely to ever be
> use outside x86 and i don't think we will want to do anything more than
> skipping linear mapping.

Hmm, I am looking closer and x86 stil updates max_pfn. Is this needed
or you are guaranteed to not cross the max_pfn?
 
> Note that however for CDM when doing it with ZONE_DEVICE (i am gonna
> post an RFC for that) maybe the powerpc folks will want to know the
> memory type ie what kind of ZONE_DEVICE this is. I don't think they need
> it but i am not sure if there is anything specific needed for their
> next gen power 9 in respect of device memory.

Well, I really want to get rid of anything zone specific down the
arch_add_memory. So whatever they want to do with zone they will have to
do it after arch_add_memory.

> Andrew if Michal think it is better to not use arch_add_memory directly
> for my case than i can respin HMM patchset. Let me know.

Well, I can drop
https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git/commit/?h=attempts/rewrite-mem_hotplug-WIP&id=bb1657d823a85bca045712467f517980650652ca
and arch_add_memory can have memory type argument as you suggest. I am
just trying to understand what are the expectations here. If you only care
about x86 then it sounds a bit too much to tweak all arches.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
