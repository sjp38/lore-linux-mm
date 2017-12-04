Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD13C6B028F
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:42:42 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id t92so10242602wrc.13
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:42:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z1si1354681eda.372.2017.12.04.04.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 04:42:41 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4Cdt9u021985
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 07:42:40 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2en59rc68e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 07:42:39 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 12:42:37 -0000
Date: Mon, 4 Dec 2017 12:42:31 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/5] mm: memory_hotplug: memblock to track partially
 removed vmemmap mem
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <e17d447381b3f13d4d7d314916ca273b6f60d287.1511433386.git.ar@linux.vnet.ibm.com>
 <20171130145134.el3qq7pr3q4xqglz@dhcp22.suse.cz>
 <20171204114908.GC6373@samekh>
 <20171204123244.vfm6znonfqt6fien@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171204123244.vfm6znonfqt6fien@dhcp22.suse.cz>
Message-Id: <20171204124230.GA10599@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

On Mon  4 Dec 2017, 13:32, Michal Hocko wrote:
> On Mon 04-12-17 11:49:09, Andrea Reale wrote:
> > On Thu 30 Nov 2017, 15:51, Michal Hocko wrote:
> > > On Thu 23-11-17 11:14:38, Andrea Reale wrote:
> > > > When hot-removing memory we need to free vmemmap memory.
> > > > However, depending on the memory is being removed, it might
> > > > not be always possible to free a full vmemmap page / huge-page
> > > > because part of it might still be used.
> > > > 
> > > > Commit ae9aae9eda2d ("memory-hotplug: common APIs to support page tables
> > > > hot-remove") introduced a workaround for x86
> > > > hot-remove, by which partially unused areas are filled with
> > > > the 0xFD constant. Full pages are only removed when fully
> > > > filled by 0xFDs.
> > > > 
> > > > This commit introduces a MEMBLOCK_UNUSED_VMEMMAP memblock flag, with
> > > > the goal of using it in place of 0xFDs. For now, this will be used for
> > > > the arm64 port of memory hot remove, but the idea is to eventually use
> > > > the same mechanism for x86 as well.
> > > 
> > > Why cannot you use the same approach as x86 have? Have a look at the
> > > vmemmap_free at al.
> > > 
> > 
> > This arm64 hot-remove version (including vmemmap_free) is indeed an
> > almost 1-to-1 port of the x86 approach. 
> > 
> > If you look at the first version of the patchset we submitted a while 
> > ago (https://lkml.org/lkml/2017/4/11/540), we were initially using the
> > x86 approach of filling unsued page structs with 0xFDs. Commenting on
> > that, Mark suggested (and, indeed, I agree with him) that relying on a
> > magic constant for marking some portions of physical memory was quite
> > ugly. That is why we have used memblock for the purpose in this revised
> > patchset.
> > 
> > If you have a different view and any concrete suggestion on how to
> > improve this, it is definitely very well welcome. 
> 
> I would really prefer if those archictectues shared the code (and
> concept) as much as possible. It is really a PITA to wrap your head
> around each architectures for reasons which are not inherent to that
> specific architecture. If you find the way how x86 is implemented ugly,
> then all right, but making arm64 special just for the matter of taste is
> far from ideal IMHO.

The plan is indeed to use this memblock flag in x86 hot remove as well,
in place of the 0xFDs. The change is quite straightforward and we could
push it in a next patchset release. Our rationale was to first use it in
the new architecture and then, once proven stable, back port it to x86.

However, I am not in principle against of pushing it right now.

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
