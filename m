Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 60A0A9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 02:07:48 -0400 (EDT)
Received: by eye13 with SMTP id 13so191498eye.14
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 23:07:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110928180909.GA7007@labbmf-linux.qualcomm.com>
References: <20110928180909.GA7007@labbmf-linux.qualcomm.com>
Date: Thu, 29 Sep 2011 11:37:46 +0530
Message-ID: <CAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
Subject: Re: RFC -- new zone type
From: Sameer Pramod Niphadkar <spniphadkar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: linux-mm@kvack.org, vgandhi@codeaurora.org, Xen-devel@lists.xensource.com

On Wed, Sep 28, 2011 at 11:39 PM, Larry Bassel <lbassel@codeaurora.org> wro=
te:
> We need to create a large (~100M) contiguous physical memory region
> which will only be needed occasionally. As this region will
> use up 10-20% of all of the available memory, we do not want
> to pre-reserve it at boot time. Instead, we want to create
> this memory region "on the fly" when asked to by userspace,
> and do it as quickly as possible, and return it to
> system use when not needed.
>
> AFAIK, this sort of operation is currently done using memory
> compaction (as CMA does for instance).
> Alternatively, this memory region (if it is in a fixed place)
> could be created using "logical memory hotremove" and returned
> to the system using "logical memory hotplug". In either case,
> the contiguous physical memory would be created via migrating
> pages from the "movable zone".
>
> The problem with this approach is that the copying of up to 25000
> pages may take considerable time (as well as finding destinations
> for all of the pages if free memory is scarce -- this may
> even fail, causing the memory region not to be created).
>
> It was suggested to me that a new zone type which would be similar
> to the "movable zone" but is only allowed to contain pages
> that can be discarded (such as text) could solve this problem,
> so that there is no copying or finding destination pages needed (thus
> considerably reducing latency).
>
Is this approach similar to Copy-on-Write being used in most page
sharing entitlements ? If yes, then it almost depends on the # of
writes made on the pages.

> The downside I see is that there may not be anywhere near
> 25000 such discardable pages, so most of this zone would go unused, and
> the memory would be "wasted" as in the case where it is pre-reserved.
> Also, this is not currently supported, so new code would
> have to be designed and implemented.
>
> I would appreciate people's comments about:
>
> 1. Does this type of zone make any sense? It
> would have to co-exist with the current movable zone type.
 Ideally can't there be a reserved zone created from which all the
remaining on-the fly zones are shared based on CoW ?

> 2. How hard would it be to implement this? The new zone type would
> need to be supported and "discardable" pages steered into this zone.
>
Most VMs do support ballooning,  CoW and other forms of sharing and
can provide as basis for any memory management projects.

> 3. Are there better ways of allocating a large memory region
> with minimal latency that I haven't mentioned here?
>
Hmm...there are mechanisms as pointed by yourself but they all depend
on the policy of consolidation, priority and security of operations.
> Thanks.
>
> Larry Bassel
>
> --
> Sent by an employee of the Qualcomm Innovation Center, Inc.
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum=
.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
