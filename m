Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDA06B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:09:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g32so2807252wrd.8
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:09:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 190si1901826wmj.143.2017.08.15.15.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 15:09:50 -0700 (PDT)
Date: Tue, 15 Aug 2017 15:09:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap: choose swap device according to numa node
Message-Id: <20170815150947.9b7ccea78c5ea28ae88ba87f@linux-foundation.org>
In-Reply-To: <20170815054944.GF2369@aaronlu.sh.intel.com>
References: <20170814053130.GD2369@aaronlu.sh.intel.com>
	<20170814163337.92c9f07666645366af82aba2@linux-foundation.org>
	<20170815054944.GF2369@aaronlu.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

On Tue, 15 Aug 2017 13:49:45 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> On Mon, Aug 14, 2017 at 04:33:37PM -0700, Andrew Morton wrote:
> > On Mon, 14 Aug 2017 13:31:30 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
> > 
> > > --- /dev/null
> > > +++ b/Documentation/vm/swap_numa.txt
> > > @@ -0,0 +1,18 @@
> > > +If the system has more than one swap device and swap device has the node
> > > +information, we can make use of this information to decide which swap
> > > +device to use in get_swap_pages() to get better performance.
> > > +
> > > +The current code uses a priority based list, swap_avail_list, to decide
> > > +which swap device to use and if multiple swap devices share the same
> > > +priority, they are used round robin. This change here replaces the single
> > > +global swap_avail_list with a per-numa-node list, i.e. for each numa node,
> > > +it sees its own priority based list of available swap devices. Swap
> > > +device's priority can be promoted on its matching node's swap_avail_list.
> > > +
> > > +The current swap device's priority is set as: user can set a >=0 value,
> > > +or the system will pick one starting from -1 then downwards. The priority
> > > +value in the swap_avail_list is the negated value of the swap device's
> > > +due to plist being sorted from low to high. The new policy doesn't change
> > > +the semantics for priority >=0 cases, the previous starting from -1 then
> > > +downwards now becomes starting from -2 then downwards and -1 is reserved
> > > +as the promoted value.
> > 
> > Could we please add a little "user guide" here?  Tell people how to set
> > up their system to exploit this?  Sample /etc/fstab entries, perhaps?
> 
> That's a good idea.
> 
> How about this:
> 
> ...
>

Looks good.  Please send it along as a patch some time?

> 
> I'm not sure what to do...any hint?
> Adding a pr_err() perhaps?

pr_emerg(), probably.  Would it make sense to disable all swapon()s
after this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
