Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 046836B03A0
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 13:11:08 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n80so14834653qke.8
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 10:11:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t21si5370916qta.36.2017.04.07.10.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 10:11:06 -0700 (PDT)
Date: Fri, 7 Apr 2017 13:10:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
Message-ID: <20170407171055.GA16527@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-2-jglisse@redhat.com>
 <20170407121349.GB16392@dhcp22.suse.cz>
 <20170407143246.GA15098@redhat.com>
 <20170407144504.GG16413@dhcp22.suse.cz>
 <20170407145740.GA15335@redhat.com>
 <20170407151105.GH16413@dhcp22.suse.cz>
 <20170407160959.GA15945@redhat.com>
 <20170407163737.GI16413@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170407163737.GI16413@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Fri, Apr 07, 2017 at 06:37:37PM +0200, Michal Hocko wrote:
> On Fri 07-04-17 12:10:00, Jerome Glisse wrote:
> > On Fri, Apr 07, 2017 at 05:11:05PM +0200, Michal Hocko wrote:
> > > On Fri 07-04-17 10:57:43, Jerome Glisse wrote:
> > > > On Fri, Apr 07, 2017 at 04:45:04PM +0200, Michal Hocko wrote:
> > > > > On Fri 07-04-17 10:32:49, Jerome Glisse wrote:
> > > > > > On Fri, Apr 07, 2017 at 02:13:49PM +0200, Michal Hocko wrote:
> > > > > > > On Wed 05-04-17 16:40:11, Jerome Glisse wrote:
> > > > > > > > When hotpluging memory we want more information on the type of memory.
> > > > > > > > This is to extend ZONE_DEVICE to support new type of memory other than
> > > > > > > > the persistent memory. Existing user of ZONE_DEVICE (persistent memory)
> > > > > > > > will be left un-modified.
> > > > > > > 
> > > > > > > My current hotplug rework [1] is touching this path as well. It is not
> > > > > > > really clear from the chage why you are changing this and what are the
> > > > > > > further expectations of MEMORY_DEVICE_PERSISTENT. Infact I have replaced
> > > > > > > for_device with want__memblock [2]. I plan to repost shortly but I would
> > > > > > > like to understand your modifications more to reduce potential conflicts
> > > > > > > in the code. Why do you need to distinguish different types of memory
> > > > > > > anyway.
> > > > > > > 
> > > > > > > [1] http://lkml.kernel.org/r/20170330115454.32154-1-mhocko@kernel.org
> > > > > > > [2] the current patchset is in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > > > > > >     branch attempts/rewrite-mem_hotplug-WIP
> > > > > > 
> > > > > > This is needed for UNADDRESSABLE memory type introduced in patch 3 and
> > > > > > the arch specific bits are in patch 4. Basicly for UNADDRESSABLE memory
> > > > > > i do not want the arch code to create a linear mapping for the range
> > > > > > being hotpluged. Adding memory_type in this patch allow to distinguish
> > > > > > between different type of ZONE_DEVICE.
> > > > > 
> > > > > Why don't you use __add_pages directly then?
> > > > 
> > > > That's a possibility, i wanted to keep the arch code in the loop in case
> > > > some arch wanted to do something specific. But it is unlikely to ever be
> > > > use outside x86 and i don't think we will want to do anything more than
> > > > skipping linear mapping.
> > > 
> > > Hmm, I am looking closer and x86 stil updates max_pfn. Is this needed
> > > or you are guaranteed to not cross the max_pfn?
> > 
> > No guaranteed so yes i somewhat care about max_pfn, i do not care about
> > any of its existing user last time i check but it might matter for some
> > new user.
> 
> OK, then we can add add_pages() which would do __add_pages by default
> (#ifndef ARCH_HAS_ADD_PAGES) and x86 would override it do also call
> update_end_of_memory_vars. This sounds easier to me than updating all
> the archs and add something that most of them do not really care about.
> 
> But I will not insist. If you think that your approach is better I will
> not object.

Something like attached patch ?

> 
> Btw. is your series reviewed and ready to be applied to the mm tree? I
> planed to post mine on Monday so I would like to know how do we
> coordinate. I rebase on topo of yours or vice versa.

Well v18 core patches were review by Mel, i did include all of his comment
in v19 (i don't think i did miss any). I think Dan still want to look at
patch 1 and 3 for ZONE_DEVICE.

But i always welcome more review. I know Anshuman replied to this patch
to improve a comments. Balbir had issue on powerpc because iomem_resource.end
isn't clamped to MAX_PHYSMEM_BITS But that is all review i got so far on v19.

I don't mind rebasing on top of your patchset. What ever is easier for
Andrew i guess.

Cheers,
Jerome

--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-mm-memory_hotplug-add-add_pages-hotplug-without-line.patch"
Content-Transfer-Encoding: 8bit


--envbJBWh7q8WU6mo--
