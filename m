Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEDBC6B025E
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:55:10 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id r58so16779143qtc.7
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:55:10 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s16si1022204qki.321.2017.11.24.07.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 07:55:09 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAOFnfBc141193
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:55:08 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eemxnc2xb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:55:08 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Fri, 24 Nov 2017 15:55:05 -0000
Date: Fri, 24 Nov 2017 15:54:59 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
 <CAJZ5v0i7vOxwhgA1LWYDqxCKkHaYikCf_HZZQCbgApLpoyV2JA@mail.gmail.com>
 <20171124144917.GB1966@samekh>
 <20171124154317.copbe3u6y2q4mura@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171124154317.copbe3u6y2q4mura@dhcp22.suse.cz>
Message-Id: <20171124155458.GC1966@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, Mark Rutland <mark.rutland@arm.com>, scott.branden@broadcom.com, Will Deacon <will.deacon@arm.com>, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Rafael Wysocki <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Fri 24 Nov 2017, 16:43, Michal Hocko wrote:
> On Fri 24-11-17 14:49:17, Andrea Reale wrote:
> > Hi Rafael,
> > 
> > On Fri 24 Nov 2017, 15:39, Rafael J. Wysocki wrote:
> > > On Fri, Nov 24, 2017 at 11:22 AM, Andrea Reale <ar@linux.vnet.ibm.com> wrote:
> > > > Resending the patch adding linux-acpi in CC, as suggested by Rafael.
> > > > Everyone else: apologies for the noise.
> > > >
> > > > Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > > > introduced an assumption whereas when control
> > > > reaches remove_memory the corresponding memory has been already
> > > > offlined. In that case, the acpi_memhotplug was making sure that
> > > > the assumption held.
> > > > This assumption, however, is not necessarily true if offlining
> > > > and removal are not done by the same "controller" (for example,
> > > > when first offlining via sysfs).
> > > >
> > > > Removing this assumption for the generic remove_memory code
> > > > and moving it in the specific acpi_memhotplug code. This is
> > > > a dependency for the software-aided arm64 offlining and removal
> > > > process.
> > > >
> > > > Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> > > > Signed-off-by: Maciej Bielski <m.bielski@linux.vnet.ibm.com>
> > > > ---
> > > >  drivers/acpi/acpi_memhotplug.c |  2 +-
> > > >  include/linux/memory_hotplug.h |  9 ++++++---
> > > >  mm/memory_hotplug.c            | 13 +++++++++----
> > > >  3 files changed, 16 insertions(+), 8 deletions(-)
> > > >
> > > > diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> > > > index 6b0d3ef..b0126a0 100644
> > > > --- a/drivers/acpi/acpi_memhotplug.c
> > > > +++ b/drivers/acpi/acpi_memhotplug.c
> > > > @@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
> > > >                         nid = memory_add_physaddr_to_nid(info->start_addr);
> > > >
> > > >                 acpi_unbind_memory_blocks(info);
> > > > -               remove_memory(nid, info->start_addr, info->length);
> > > > +               BUG_ON(remove_memory(nid, info->start_addr, info->length));
> > > 
> > > Why does this have to be BUG_ON()?  Is it really necessary to kill the
> > > system here?
> > 
> > Actually, I hoped you would help me understand that: that BUG() call was introduced
> > by yourself in Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > in memory_hoptlug.c:remove_memory()). 
> > 
> > Just reading at that commit my understanding was that you were assuming
> > that acpi_memory_remove_memory() have already done the job of offlining
> > the target memory, so there would be a bug if that wasn't the case.
> > 
> > In my case, that assumption did not hold and I found that it might not
> > hold for other platforms that do not use ACPI. In fact, the purpose of
> > this patch is to move this assumption out of the generic hotplug code
> > and move it to ACPI code where it originated. 
> 
> remove_memory failure is basically impossible to handle AFAIR. The
> original code to BUG in remove_memory is ugly as hell and we do not want
> to spread that out of that function. Instead we really want to get rid
> of it.

Today, BUG() is called even in the simple case where remove fails
because the section we are removing is not offline. I cannot see any need to
BUG() in such a case: an error code seems more than sufficient to me.
This is why this patch removes the BUG() call when the "offline" check
fails from the generic code. 
It moves it back to the ACPI call, where the assumption
originated. Honestlly, I cannot tell if it makes sense to BUG() there:
I have nothing against removing it from ACPI hotplug too, but
I don't know enough to feel free to change the acpi semantics myself, so I
moved it there to keep the original behavior unchanged for x86 code.

In this arm64 hot-remove port, offline and remove are done in two separate
steps, and is conceivable that an user tries erroneusly to remove some
section that he forgot to offline first: in that case, with the patch,
remove will just report an erro without BUGing.

Is my reasoning flawed?

Cheers,
Andrea

> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
