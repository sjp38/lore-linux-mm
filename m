Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73ABA6B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 09:49:30 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id l74so12994236qke.10
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 06:49:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i57si3701595qtf.226.2017.11.24.06.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 06:49:29 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAOEnE7G135227
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 09:49:28 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eejxqfbtd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 09:49:27 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Fri, 24 Nov 2017 14:49:25 -0000
Date: Fri, 24 Nov 2017 14:49:17 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
 <CAJZ5v0i7vOxwhgA1LWYDqxCKkHaYikCf_HZZQCbgApLpoyV2JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAJZ5v0i7vOxwhgA1LWYDqxCKkHaYikCf_HZZQCbgApLpoyV2JA@mail.gmail.com>
Message-Id: <20171124144917.GB1966@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, Mark Rutland <mark.rutland@arm.com>, scott.branden@broadcom.com, Will Deacon <will.deacon@arm.com>, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

Hi Rafael,

On Fri 24 Nov 2017, 15:39, Rafael J. Wysocki wrote:
> On Fri, Nov 24, 2017 at 11:22 AM, Andrea Reale <ar@linux.vnet.ibm.com> wrote:
> > Resending the patch adding linux-acpi in CC, as suggested by Rafael.
> > Everyone else: apologies for the noise.
> >
> > Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > introduced an assumption whereas when control
> > reaches remove_memory the corresponding memory has been already
> > offlined. In that case, the acpi_memhotplug was making sure that
> > the assumption held.
> > This assumption, however, is not necessarily true if offlining
> > and removal are not done by the same "controller" (for example,
> > when first offlining via sysfs).
> >
> > Removing this assumption for the generic remove_memory code
> > and moving it in the specific acpi_memhotplug code. This is
> > a dependency for the software-aided arm64 offlining and removal
> > process.
> >
> > Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> > Signed-off-by: Maciej Bielski <m.bielski@linux.vnet.ibm.com>
> > ---
> >  drivers/acpi/acpi_memhotplug.c |  2 +-
> >  include/linux/memory_hotplug.h |  9 ++++++---
> >  mm/memory_hotplug.c            | 13 +++++++++----
> >  3 files changed, 16 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> > index 6b0d3ef..b0126a0 100644
> > --- a/drivers/acpi/acpi_memhotplug.c
> > +++ b/drivers/acpi/acpi_memhotplug.c
> > @@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
> >                         nid = memory_add_physaddr_to_nid(info->start_addr);
> >
> >                 acpi_unbind_memory_blocks(info);
> > -               remove_memory(nid, info->start_addr, info->length);
> > +               BUG_ON(remove_memory(nid, info->start_addr, info->length));
> 
> Why does this have to be BUG_ON()?  Is it really necessary to kill the
> system here?

Actually, I hoped you would help me understand that: that BUG() call was introduced
by yourself in Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
in memory_hoptlug.c:remove_memory()). 

Just reading at that commit my understanding was that you were assuming
that acpi_memory_remove_memory() have already done the job of offlining
the target memory, so there would be a bug if that wasn't the case.

In my case, that assumption did not hold and I found that it might not
hold for other platforms that do not use ACPI. In fact, the purpose of
this patch is to move this assumption out of the generic hotplug code
and move it to ACPI code where it originated. 

Thanks,
Andrea

> If it is, please add a comment describing why continuing is not an option here.
> 
> >                 list_del(&info->list);
> >                 kfree(info);
> >         }
> 
> Thanks,
> Rafael
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
