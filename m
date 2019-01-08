Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACA438E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 03:50:17 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f2so2808416qtg.14
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 00:50:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i41si7368964qtc.57.2019.01.08.00.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 00:50:16 -0800 (PST)
Date: Tue, 8 Jan 2019 16:50:02 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of
 bottom-up after parsing hotplug attr
Message-ID: <20190108085002.GA18718@MiWiFi-R3L-srv>
References: <1545966002-3075-2-git-send-email-kernelfans@gmail.com>
 <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx>
 <20190102101804.GD1990@MiWiFi-R3L-srv>
 <20190102170537.GA3591@rapoport-lnx>
 <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
 <20190104150929.GA32252@rapoport-lnx>
 <20190105034450.GE30750@MiWiFi-R3L-srv>
 <20190106062733.GA3728@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190106062733.GA3728@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, Pingfan Liu <kernelfans@gmail.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On 01/06/19 at 08:27am, Mike Rapoport wrote:
> I do not suggest to discard the bottom-up method, I merely suggest to allow
> it to use [0, kernel_start).

Sorry for late reply.

I misunderstood it, sorry.

> > This bottom-up way is taken on many ARCHes, it works well on system if
> > KASLR is not enabled. Below is the searching result in the current linux
> > kernel, we can see that all ARCHes have this mechanism, except of
> > arm/arm64. But now only arm64/mips/x86 have KASLR.
> > 
> > W/o KASLR, allocating memblock region above kernle end when hotplug info
> > is not parsed, looks very reasonable. Since kernel is usually put at
> > lower address, e.g on x86, it's 16M. My thought is that we need do
> > memblock allocation around kernel before hotplug info parsed. That is
> > for system w/o KASLR, we will keep the current bottom-up way; for system
> > with KASLR, we should allocate memblock region top-down just below
> > kernel start.
> 
> I completely agree. I was thinking about making
> memblock_find_in_range_node() to do something like
> 
> if (memblock_bottom_up()) {
> 	bottom_up_start = max(start, kernel_end);

In this way, if start < kernel_end, it will still succeed to find a
region in bottom-up way after kernel end.

I am still reading code. Just noticed Pingfan sent a RFC patchset to put
SRAT parsing earlier, not sure if he has tested it in numa system with
acpi. I doubt that really works.

Thanks
Baoquan

> 	ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> 					      size, align, nid, flags);



> 	if (ret)
> 		return ret;
> 
> 	bottom_up_start = max(start, 0);
> 	end = kernel_start;
> 
> 	ret = __memblock_find_range_top_down(bottom_up_start, end,
> 					     size, align, nid, flags);
> 	if (ret)
> 		return ret;
> }
