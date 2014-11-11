Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B6347900018
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:36:48 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id r20so2987058wiv.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:36:48 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id hv3si24831391wib.48.2014.11.11.13.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 13:36:47 -0800 (PST)
Date: Tue, 11 Nov 2014 22:36:39 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
In-Reply-To: <54627512.7060806@intel.com>
Message-ID: <alpine.DEB.2.11.1411112233180.3935@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <545BED0B.8000001@intel.com> <alpine.DEB.2.11.1411111213450.3935@nanos>
 <54627512.7060806@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Tue, 11 Nov 2014, Dave Hansen wrote:
> On 11/11/2014 10:27 AM, Thomas Gleixner wrote:
> > On Thu, 6 Nov 2014, Dave Hansen wrote:
> >> Instead of all of these games with dropping and reacquiring mmap_sem and
> >> adding other locks, or deferring the work, why don't we just do a
> >> get_user_pages()?  Something along the lines of:
> >>
> >> while (1) {
> >> 	ret = cmpxchg(addr)
> >> 	if (!ret)
> >> 		break;
> >> 	if (ret == -EFAULT)
> >> 		get_user_pages(addr);
> >> }
> >>
> >> Does anybody see a problem with that?
> > 
> > You want to do that under mmap_sem write held, right? Not a problem per
> > se, except that you block normal faults for a possibly long time when
> > the page(s) need to be swapped in.
> 
> Yeah, it might hold mmap_sem for write while doing this in the unmap
> path.  But, that's only if the bounds directory entry has been swapped
> out.  There's only 1 pointer of bounds directory entries there for every
> 1MB of data, so it _should_ be relatively rare.  It would mean that
> nobody's been accessing a 512MB swath of data controlled by the same
> page of the bounds directory.
> 
> If it gets to be an issue, we can always add some code to fault it in
> before mmap_sem is acquired.

I don't think it's a real issue.
 
> FWIW, I believe we have a fairly long road ahead of us to optimize MPX
> in practice.  I have a list of things I want to go investigate, but I
> have not looked in to it in detail at all.

:)
 
> > But yes, this might solve most of the issues at hand. Did not think
> > about GUP at all :(
> 
> Whew.  Fixing it was getting nasty and complicated. :)

Indeed. Though I think that distangling specific parts of MPX from
mmap_sem is still a worthwhile exercise. So not all of the complex
ideas we came up with during the discussion are lost in the pointless
complexity universe :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
