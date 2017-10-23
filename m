Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D79D26B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:48:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so12374115pgo.20
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 11:48:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u8si5233279pgo.594.2017.10.23.11.48.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 11:48:54 -0700 (PDT)
Date: Mon, 23 Oct 2017 11:48:52 -0700
From: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023184852.GB12198@linux.intel.com>
Reply-To: sharath.k.bhat@linux.intel.com
References: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
 <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
 <20171023160314.GA11853@linux.intel.com>
 <20171023161554.zltjcls34kr4234m@dhcp22.suse.cz>
 <20171023171435.GA12025@linux.intel.com>
 <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, Oct 23, 2017 at 07:49:05PM +0200, Michal Hocko wrote:
> On Mon 23-10-17 10:35:44, Sharath Kumar Bhat wrote:
> > On Mon, Oct 23, 2017 at 07:20:08PM +0200, Michal Hocko wrote:
> > > On Mon 23-10-17 10:14:35, Sharath Kumar Bhat wrote:
> > > [...]
> > > > This lets admin to configure the kernel to have movable memory > size of
> > > > hotpluggable memories and at the same time hotpluggable nodes have only
> > > > movable memory.
> > > 
> > > Put aside that I believe that having too much of movable memory is
> > > dangerous and people are not very prepared for that fact, what is the
> > > specific usecase. Allowing users something is nice but as I've said the
> > > interface is ugly already and putting more on top is not very desirable.
> > > 
> > > > This is useful because it lets user to have more movable
> > > > memory in the system that can be offlined/onlined. When the same hardware
> > > > is shared between two OS's then this helps to dynamically provision the
> > > > physical memory between them by offlining/onlining as and when the
> > > > application/user need changes.
> > > 
> > > just use hotplugable memory for that purpose. The latest memory hotplug
> > > code allows you to online memory into a kernel or movable zone as per
> > > admin policy without the previously hardcoded zone ordering. So I really
> > > fail to see why to mock with the command line parameter at all.
> > 
> > Yes, but it won't let us offline the memory blocks if they are already
> > in use by kernel allocations. This is more likely over a long period of
> > uptime. The command-line ensures that the memory blocks are movable all
> > the time as reserved by the admin from the boot.
> 
> I am really confused about your usecase then. Why do you want to make
> non-hotplugable memory to be movable then?

Lets say,

The required total memory in the system which can be dynamically
offlined/onlined, T = M + N

M = movable memory in non-hotpluggable memory (say DDR in the example)
N = movable memory in hotpluggable memory (say MCDRAM in the example)

a. We need the entire hotpluggable memory (N) to be movable. Say this is
   16GB (MCDRAM) in KNL.

b. Additionally we need guranteed movable memory M, so that > 16GB (in this
   case) can be dynamically provisioned between two OS's

There is 'movable_node' command-line to accomplish a. But the problem is
that this makes all other non hotpluggable nodes as zone normal and
over a period of time there is no gurantee that we could get 'M' movable
memory to dynamically provision.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
