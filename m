Received: by ey-out-1920.google.com with SMTP id 21so533724eyc.44
        for <linux-mm@kvack.org>; Fri, 24 Oct 2008 20:17:41 -0700 (PDT)
Date: Sat, 25 Oct 2008 07:20:58 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
Message-ID: <20081025032058.GA5010@x200.localdomain>
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org> <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx> <20081024220750.GA22973@x200.localdomain> <Pine.LNX.4.64.0810241829140.25302@quilx.com> <20081025002406.GA20024@x200.localdomain> <20081025025408.GA27684@x200.localdomain> <1224903645.3248.106.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224903645.3248.106.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org, avi@qumranet.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 10:00:45PM -0500, Matt Mackall wrote:
> On Sat, 2008-10-25 at 06:54 +0400, Alexey Dobriyan wrote:
> > On Sat, Oct 25, 2008 at 04:24:06AM +0400, Alexey Dobriyan wrote:
> > > On Fri, Oct 24, 2008 at 06:29:47PM -0500, Christoph Lameter wrote:
> > > > On Sat, 25 Oct 2008, Alexey Dobriyan wrote:
> > > >
> > > >> Fault occured at slab_destroy in KVM guest kernel.
> > > >
> > > > Please switch on all SLAB debug options and rerun.
> > > 
> > > They're already on!
> > > 
> > > New knowledge: turning off just DEBUG_PAGEALLOC makes oops dissapear,
> > > other debugging options don't matter.
> > 
> > Here is typical scenario:
> > cache -- filp or dentry, ->buffer_size = 4096, objp = c643d000, dbg_redzone1 = c643df78.
> > 
> > Unable to handle ... at c643df7c. which is not next page.
> 
> Huh. That sounds more like an actual use-after-free. Possible that the
> object is getting freed twice?
> 
> There's a call to kernel_map_pages(..., 0) on line 2905 of slab.c.
> Commenting it out will nullify the debugging effect of DEBUG_PAGEALLOC
> without changing the layout decisions and other behavior. If that kernel
> works, that probably means your oops is a genuine use-after-free.

Commenting this code helps very much, looking further...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
