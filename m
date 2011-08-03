Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 340166B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 13:23:17 -0400 (EDT)
Date: Wed, 3 Aug 2011 10:23:13 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: questions about memory hotplug
Message-ID: <20110803172313.GD3466@labbmf-linux.qualcomm.com>
References: <20110729221230.GA3466@labbmf-linux.qualcomm.com>
 <20110730093055.GA10672@sli10-conroe.sh.intel.com>
 <20110801170850.GB3466@labbmf-linux.qualcomm.com>
 <1312247376.15392.454.camel@sli10-conroe>
 <1312358106.15392.466.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312358106.15392.466.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Larry Bassel <lbassel@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 03 Aug 11 15:55, Shaohua Li wrote:
> On Tue, 2011-08-02 at 09:09 +0800, Shaohua Li wrote:
> > On Tue, 2011-08-02 at 01:08 +0800, Larry Bassel wrote:
> > > 
> > > In use case #1 yes, maybe not in #2 (we can arrange it to be
> > > at the end of memory, but then might waste memory as it may
> > > not be aligned on a SPARSEMEM section boundary and so would
> > > need to be padded).
> > then maybe the new migrate type I suggested can help here for the
> > non-aligned memory. Anyway, let me do an experiment.
> so your problem is to offline memory in arbitrary address and size (eg,
> might not be at the end, and maybe smaller than a section)

Yes (and online it again). Also the decision to (attempt to)
on/offline must be done from userspace (as memory hotplug does already).

> 
> I had a hack. In my machine, I have DMA, DMA32, and NORMAL zone.
> At boot time, I mark 500M~600M ranges as MOVABLE_NOFB. the range is in
> DMA32 and not section size aligned.

A few questions:

* You still use SPARSEMEM though, correct?
* Would there be any problem using NORMAL memory as MOVABLE_NOFB?
* So you don't use ZONE_MOVABLE or kernelcore= or movablecore=
at all?
* Do you online/offline using the /sys/devices/system/memory files?
If so, does the kernel still attempt to on/offline the entire
section (as it does now) or only the MOVABLE_NOFB part?
If not, how do you on/offline memory?

> MOVABLE_NOFB is a new migrate type I
> added. That range memory is movable, but other type of allocation can't
> fallback into such ranges. so such range memory can only be used by
> userspace.

And the kernel will not reserve memory from it either (I had to put a
hack in an earlier version of what I'm doing to not allow reserving
from the movable zone because otherwise the existence of these
reserved pages would block logical hotremove), correct?

> I then run a memory stress test and do memory online/offline for the
> range at runtime, the offline always success.
> Does this meet your usage? If yes, I'll cook it up a little bit.

Yes, this looks very promising.
Do you see any reason this can't be backported to 2.6.38?

Thank you very much for your help here.

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
