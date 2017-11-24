Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9E8A6B0038
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 13:17:45 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o60so14319151wrc.14
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:17:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si1759445edj.185.2017.11.24.10.17.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 10:17:44 -0800 (PST)
Date: Fri, 24 Nov 2017 19:17:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
Message-ID: <20171124164042.3crcoz2lwgwv725l@dhcp22.suse.cz>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
 <CAJZ5v0i7vOxwhgA1LWYDqxCKkHaYikCf_HZZQCbgApLpoyV2JA@mail.gmail.com>
 <20171124144917.GB1966@samekh>
 <20171124154317.copbe3u6y2q4mura@dhcp22.suse.cz>
 <20171124155458.GC1966@samekh>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124155458.GC1966@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, Mark Rutland <mark.rutland@arm.com>, scott.branden@broadcom.com, Will Deacon <will.deacon@arm.com>, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Rafael Wysocki <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Fri 24-11-17 15:54:59, Andrea Reale wrote:
> On Fri 24 Nov 2017, 16:43, Michal Hocko wrote:
> > On Fri 24-11-17 14:49:17, Andrea Reale wrote:
> > > Hi Rafael,
> > > 
> > > On Fri 24 Nov 2017, 15:39, Rafael J. Wysocki wrote:
> > > > On Fri, Nov 24, 2017 at 11:22 AM, Andrea Reale <ar@linux.vnet.ibm.com> wrote:
> > > > > Resending the patch adding linux-acpi in CC, as suggested by Rafael.
> > > > > Everyone else: apologies for the noise.
> > > > >
> > > > > Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > > > > introduced an assumption whereas when control
> > > > > reaches remove_memory the corresponding memory has been already
> > > > > offlined. In that case, the acpi_memhotplug was making sure that
> > > > > the assumption held.
> > > > > This assumption, however, is not necessarily true if offlining
> > > > > and removal are not done by the same "controller" (for example,
> > > > > when first offlining via sysfs).
> > > > >
> > > > > Removing this assumption for the generic remove_memory code
> > > > > and moving it in the specific acpi_memhotplug code. This is
> > > > > a dependency for the software-aided arm64 offlining and removal
> > > > > process.
> > > > >
> > > > > Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> > > > > Signed-off-by: Maciej Bielski <m.bielski@linux.vnet.ibm.com>
> > > > > ---
> > > > >  drivers/acpi/acpi_memhotplug.c |  2 +-
> > > > >  include/linux/memory_hotplug.h |  9 ++++++---
> > > > >  mm/memory_hotplug.c            | 13 +++++++++----
> > > > >  3 files changed, 16 insertions(+), 8 deletions(-)
> > > > >
> > > > > diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> > > > > index 6b0d3ef..b0126a0 100644
> > > > > --- a/drivers/acpi/acpi_memhotplug.c
> > > > > +++ b/drivers/acpi/acpi_memhotplug.c
> > > > > @@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
> > > > >                         nid = memory_add_physaddr_to_nid(info->start_addr);
> > > > >
> > > > >                 acpi_unbind_memory_blocks(info);
> > > > > -               remove_memory(nid, info->start_addr, info->length);
> > > > > +               BUG_ON(remove_memory(nid, info->start_addr, info->length));
> > > > 
> > > > Why does this have to be BUG_ON()?  Is it really necessary to kill the
> > > > system here?
> > > 
> > > Actually, I hoped you would help me understand that: that BUG() call was introduced
> > > by yourself in Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > > in memory_hoptlug.c:remove_memory()). 
> > > 
> > > Just reading at that commit my understanding was that you were assuming
> > > that acpi_memory_remove_memory() have already done the job of offlining
> > > the target memory, so there would be a bug if that wasn't the case.
> > > 
> > > In my case, that assumption did not hold and I found that it might not
> > > hold for other platforms that do not use ACPI. In fact, the purpose of
> > > this patch is to move this assumption out of the generic hotplug code
> > > and move it to ACPI code where it originated. 
> > 
> > remove_memory failure is basically impossible to handle AFAIR. The
> > original code to BUG in remove_memory is ugly as hell and we do not want
> > to spread that out of that function. Instead we really want to get rid
> > of it.
> 
> Today, BUG() is called even in the simple case where remove fails
> because the section we are removing is not offline.

You cannot hotremove memory which is still online. This is what caller
should enforce. This is too late to handle the failure. At least for
ACPI.

> I cannot see any need to
> BUG() in such a case: an error code seems more than sufficient to me.

I do not rememeber details but AFAIR ACPI is in a deferred (kworker)
context here and cannot simply communicate error code down the road.
I agree that we should be able to simply return an error but what is the
actual error condition that might happen here?

> This is why this patch removes the BUG() call when the "offline" check
> fails from the generic code. 

As I've said we should simply get rid of BUG rather than move it around.

> It moves it back to the ACPI call, where the assumption
> originated. Honestlly, I cannot tell if it makes sense to BUG() there:
> I have nothing against removing it from ACPI hotplug too, but
> I don't know enough to feel free to change the acpi semantics myself, so I
> moved it there to keep the original behavior unchanged for x86 code.

Heh, yeah that is an easier path for sure. I would prefer sorting this
out ;) Not that I would enforce that, though. My concern is that the
previous hotplug development followed this "I do not understand exactly
so I will simply put my on top of existing code" mantra and it ended up
in a huge mess.

> In this arm64 hot-remove port, offline and remove are done in two separate
> steps, and is conceivable that an user tries erroneusly to remove some
> section that he forgot to offline first: in that case, with the patch,
> remove will just report an erro without BUGing.

As I've said it is the caller to enforce that.

> Is my reasoning flawed?

I wouldn't say flawed but this is a low-level call that should already
happen in a reasonable context.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
