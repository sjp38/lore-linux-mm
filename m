Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6A56B026B
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 06:35:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e128so3983637wmg.1
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 03:35:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m59si1964062ede.46.2017.12.04.03.35.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 03:35:12 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4BZ72P145007
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 06:35:10 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2en2ta1q2q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:35:09 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 11:34:18 -0000
Date: Mon, 4 Dec 2017 11:34:12 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] Memory hotplug support for arm64 - complete
 patchset v2
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <20171123160258.xmw5lxnjfch2dxfw@dhcp22.suse.cz>
 <20171123173331.GA15535@samekh>
 <20171130145734.c62ggrx3r7335etc@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171130145734.c62ggrx3r7335etc@dhcp22.suse.cz>
Message-Id: <20171204113412.GB6373@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

Hi Michal,

On Thu 30 Nov 2017, 15:57, Michal Hocko wrote:
> On Thu 23-11-17 17:33:31, Andrea Reale wrote:
> > On Thu 23 Nov 2017, 17:02, Michal Hocko wrote:
> > 
> > Hi Michal,
> > 
> > > I will try to have a look but I do not expect to understand any of arm64
> > > specific changes so I will focus on the generic code but it would help a
> > > _lot_ if the cover letter provided some overview of what has been done
> > > from a higher level POV. What are the arch pieces and what is the
> > > generic code missing. A quick glance over patches suggests that
> > > changelogs for specific patches are modest as well. Could you give us
> > > more information please? Reviewing hundreds lines of code without
> > > context is a pain.
> > 
> > sorry for the lack of details. I will try to provide a better
> > overview in the following. Please, feel free to ask for more details
> > where needed.
> > 
> > Overall, the goal of the patchset is to implement arch_memory_add and
> > arch_memory_remove for arm64, to support the generic memory_hotplug
> > framework. 
> > 
> > Hot add
> > -------
> > Not so many surprises here. We implement the arch specific
> > arch_add_memory, which builds the kernel page tables via hotplug_paging()
> > and then calls arch specific add_pages(). We need the arch specific
> > add_pages() to implement a trick that makes the satus of pages being
> > added accepted by the asumptions made in the generic __add_pages. (See
> > code comments).
> 
> Actually I would like to see exactly this explained. The arch support of
> the hotplug should be basically only about arch_add_memory and add_pages
> resp. arch_remove_memory and __remove_pages. Nothing much more, really.
> The core hotplug code should take care of the rest. Ideally you
> shouldn't be really forced to touch the generic code. If yes than this
> should be called out explicitly.

For what concerns hot add, there are no changes to the core hotplug code
whatsoever; just arch_add_memory and add_pages.

For what concerns hot remove, there are two changes to generic code, as
described in the second part of https://lkml.org/lkml/2017/11/23/456.
The first is the removal of the BUG() call in arch_remove_memory and
moving it to ACPI code: I think we agree that calling BUG() from
arch_remove_memory is undesirable. I have to develop a better
understanding on how to get rid of it from ACPI as well.

The second are the memblock changes for vmemmap removal. 
I'll try to discuss this change in more details in a follow up email.

Thanks,
Andrea

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
