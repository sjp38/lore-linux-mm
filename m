Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8F77B6B0081
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 17:29:51 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id q200so2421995ykb.19
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 14:29:51 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id g35si11229213yhb.157.2014.09.15.14.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 14:29:50 -0700 (PDT)
Message-ID: <1410815951.28990.384.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 15 Sep 2014 15:19:11 -0600
In-Reply-To: <1410384895.28990.312.camel@misato.fc.hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	 <1410367910-6026-7-git-send-email-toshi.kani@hp.com>
	 <CALCETrVnHg0X=R23qyiPtxYs3knHaXq65L0Jw_1oY4=gX5kpXQ@mail.gmail.com>
	 <1410379933.28990.287.camel@misato.fc.hp.com>
	 <CALCETrUh20-2PX_KN2KWO085n=5XJpOnPysmCGbk7bufaD3Mhw@mail.gmail.com>
	 <1410384895.28990.312.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 15:34 -0600, Toshi Kani wrote:
> On Wed, 2014-09-10 at 13:29 -0700, Andy Lutomirski wrote:
> > On Wed, Sep 10, 2014 at 1:12 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > > On Wed, 2014-09-10 at 11:30 -0700, Andy Lutomirski wrote:
> > >> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > >> > +Drivers may map the entire NV-DIMM range with ioremap_cache and then change
> > >> > +a specific range to wt with set_memory_wt.
> > >>
> > >> That's mighty specific :)
> > >
> > > How about below?
> > >
> > > Drivers may use set_memory_wt to set WT type for cached reserve ranges.
> > 
> > Do they have to be cached?
> 
> Yes, set_memory_xyz only supports WB->type->WB transition.
> 
> > How about:
> > 
> > Drivers may call set_memory_wt on ioremapped ranges.  In this case,
> > there is no need to change the memory type back before calling
> > iounmap.
> > 
> > (Or only on cached ioremapped ranges if that is, in fact, the case.)
> 
> Sounds good.  Yes, I will use cashed ioremapped ranges.

Well, testing "no need to change the memory type back before calling
iounmap" turns out to be a good test case.  I realized that
set_memory_xyz only works properly for RAM.  There are two problems for
using this interface for ioremapped ranges.

1) set_memory_xyz calls reserve_memtype() with __pa(addr).  However,
__pa() translates the addr into a fake physical address when it is an
ioremapped address.

2) reserve_memtype() does not work for set_memory_xyz.  For RAM, the WB
state is managed untracked.  Hence, WB->new->WB is not considered as a
conflict.  For ioremapped ranges, WB is tracked in the same way as other
cache types.  Hence, WB->new is considered as a conflict.

In my previous testing, 2) was undetected since 1) led using a fake
physical address which was not tracked for WB.  This made ioremapped
ranges worked just like RAM. :-( 

Anyway, 1) can be fixed by using slow_virt_to_phys() instead of __pa().
set_memory_xyz is already slow, but this makes it even slower, though.

For 2), WB has to be continuously tracked in order to detect aliasing,
ex. ioremap_cache and ioremap to a same address.  So, I think
reserve_memtype() needs the following changes:
 - Add a new arg to see if an operation is to create a new mapping or to
change cache attribute.
 - Track overlapping maps so that cache type change to an overlapping
range can be detected and failed.

This level of changes requires a separate set of patches if we pursue to
support ioremapped ranges.  So, I am considering to take one of the two
options below.

A) Drop the patch for set_memory_wt.

B) Keep the patch for set_memory_wt, but document that it fails with
-EINVAL and its use is for RAM only.

Any suggestion?
Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
