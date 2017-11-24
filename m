Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 460DA6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:43:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j16so22221719pgn.14
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:43:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r26si20255859pfi.232.2017.11.24.07.43.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 07:43:23 -0800 (PST)
Date: Fri, 24 Nov 2017 16:43:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
Message-ID: <20171124154317.copbe3u6y2q4mura@dhcp22.suse.cz>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
 <CAJZ5v0i7vOxwhgA1LWYDqxCKkHaYikCf_HZZQCbgApLpoyV2JA@mail.gmail.com>
 <20171124144917.GB1966@samekh>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124144917.GB1966@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, Mark Rutland <mark.rutland@arm.com>, scott.branden@broadcom.com, Will Deacon <will.deacon@arm.com>, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Rafael Wysocki <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Fri 24-11-17 14:49:17, Andrea Reale wrote:
> Hi Rafael,
> 
> On Fri 24 Nov 2017, 15:39, Rafael J. Wysocki wrote:
> > On Fri, Nov 24, 2017 at 11:22 AM, Andrea Reale <ar@linux.vnet.ibm.com> wrote:
> > > Resending the patch adding linux-acpi in CC, as suggested by Rafael.
> > > Everyone else: apologies for the noise.
> > >
> > > Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > > introduced an assumption whereas when control
> > > reaches remove_memory the corresponding memory has been already
> > > offlined. In that case, the acpi_memhotplug was making sure that
> > > the assumption held.
> > > This assumption, however, is not necessarily true if offlining
> > > and removal are not done by the same "controller" (for example,
> > > when first offlining via sysfs).
> > >
> > > Removing this assumption for the generic remove_memory code
> > > and moving it in the specific acpi_memhotplug code. This is
> > > a dependency for the software-aided arm64 offlining and removal
> > > process.
> > >
> > > Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> > > Signed-off-by: Maciej Bielski <m.bielski@linux.vnet.ibm.com>
> > > ---
> > >  drivers/acpi/acpi_memhotplug.c |  2 +-
> > >  include/linux/memory_hotplug.h |  9 ++++++---
> > >  mm/memory_hotplug.c            | 13 +++++++++----
> > >  3 files changed, 16 insertions(+), 8 deletions(-)
> > >
> > > diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> > > index 6b0d3ef..b0126a0 100644
> > > --- a/drivers/acpi/acpi_memhotplug.c
> > > +++ b/drivers/acpi/acpi_memhotplug.c
> > > @@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
> > >                         nid = memory_add_physaddr_to_nid(info->start_addr);
> > >
> > >                 acpi_unbind_memory_blocks(info);
> > > -               remove_memory(nid, info->start_addr, info->length);
> > > +               BUG_ON(remove_memory(nid, info->start_addr, info->length));
> > 
> > Why does this have to be BUG_ON()?  Is it really necessary to kill the
> > system here?
> 
> Actually, I hoped you would help me understand that: that BUG() call was introduced
> by yourself in Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> in memory_hoptlug.c:remove_memory()). 
> 
> Just reading at that commit my understanding was that you were assuming
> that acpi_memory_remove_memory() have already done the job of offlining
> the target memory, so there would be a bug if that wasn't the case.
> 
> In my case, that assumption did not hold and I found that it might not
> hold for other platforms that do not use ACPI. In fact, the purpose of
> this patch is to move this assumption out of the generic hotplug code
> and move it to ACPI code where it originated. 

remove_memory failure is basically impossible to handle AFAIR. The
original code to BUG in remove_memory is ugly as hell and we do not want
to spread that out of that function. Instead we really want to get rid
of it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
