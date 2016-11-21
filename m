Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 193F1280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:19:19 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b123so54909904itb.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:19:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 68si13693814ioh.251.2016.11.21.04.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:19:18 -0800 (PST)
Date: Mon, 21 Nov 2016 07:19:11 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 01/18] mm/memory/hotplug: convert device parameter bool
 to set of flags
Message-ID: <20161121121911.GA2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-2-git-send-email-jglisse@redhat.com>
 <e4157b8e-ef9b-0539-bb2b-649152fbc7f2@gmail.com>
 <20161121045352.GA7872@redhat.com>
 <58329ACB.6030700@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <58329ACB.6030700@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, Nov 21, 2016 at 12:27:15PM +0530, Anshuman Khandual wrote:
> On 11/21/2016 10:23 AM, Jerome Glisse wrote:
> > On Mon, Nov 21, 2016 at 11:44:36AM +1100, Balbir Singh wrote:
> >>
> >>
> >> On 19/11/16 05:18, Jerome Glisse wrote:
> >>> Only usefull for arch where we support ZONE_DEVICE and where we want to
> >>> also support un-addressable device memory. We need struct page for such
> >>> un-addressable memory. But we should avoid populating the kernel linear
> >>> mapping for the physical address range because there is no real memory
> >>> or anything behind those physical address.
> >>>
> >>> Hence we need more flags than just knowing if it is device memory or not.
> >>>
> >>
> >>
> >> Isn't it better to add a wrapper to arch_add/remove_memory and do those
> >> checks inside and then call arch_add/remove_memory to reduce the churn.
> >> If you need selectively enable MEMORY_UNADDRESSABLE that can be done with
> >> _ARCH_HAS_FEATURE
> > 
> > The flag parameter can be use by other new features and thus i thought the
> > churn was fine. But i do not mind either way, whatever people like best.
> 
> Right, once we get the device memory classification right, these flags
> can be used in more places.
> 
> > 
> > [...]
> > 
> >>> -extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
> >>> +
> >>> +/*
> >>> + * For device memory we want more informations than just knowing it is device
> >> 				     information
> >>> + * memory. We want to know if we can migrate it (ie it is not storage memory
> >>> + * use by DAX). Is it addressable by the CPU ? Some device memory like GPU
> >>> + * memory can not be access by CPU but we still want struct page so that we
> >> 			accessed
> >>> + * can use it like regular memory.
> >>
> >> Can you please add some details on why -- migration needs them for example?
> > 
> > I am not sure what you mean ? DAX ie persistent memory device is intended to be
> > use for filesystem or persistent storage. Hence memory migration does not apply
> > to it (it would go against its purpose).
> 
> Why ? It can still be used for compaction, HW errors etc where we need to
> move between persistent storage areas. The source and destination can be
> persistent storage memory.

Well i don't think they intend to do migration for that, HW errors are hidden by
hardware itself so far. But yes if they care then they could use page migration.
So far it does not seems something any of the folks working on persistent memory
think useful.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
