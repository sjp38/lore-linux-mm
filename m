Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BACC76B0389
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:20:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c143so601097wmd.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:20:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 124si389915wmc.106.2017.03.14.09.20.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 09:20:08 -0700 (PDT)
Date: Tue, 14 Mar 2017 17:20:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface
Message-ID: <20170314162003.GD7772@dhcp22.suse.cz>
References: <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <75ee9d3f-7027-782a-9cde-5192396a4a8c@gmail.com>
 <20170313091907.GF31518@dhcp22.suse.cz>
 <99f14975-f89f-4484-6ae1-296b242d4bf9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99f14975-f89f-4484-6ae1-296b242d4bf9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Reza Arbab <arbab@linux.vnet.ibm.com>

On Tue 14-03-17 12:05:59, YASUAKI ISHIMATSU wrote:
> 
> 
> On 03/13/2017 05:19 AM, Michal Hocko wrote:
> >On Fri 10-03-17 12:39:27, Yasuaki Ishimatsu wrote:
> >>On 03/10/2017 08:58 AM, Michal Hocko wrote:
[...]
> >>># echo online_movable > /sys/devices/system/memory/memory34/state
> >>># grep . /sys/devices/system/memory/memory3?/valid_zones
> >>>/sys/devices/system/memory/memory32/valid_zones:Normal
> >>>/sys/devices/system/memory/memory33/valid_zones:Normal Movable
> >>>/sys/devices/system/memory/memory34/valid_zones:Movable Normal
> >>>
> >>
> >>I think there is no strong reason which kernel has the restriction.
> >>By setting the restrictions, it seems to have made management of
> >>these zone structs simple.
> >
> >Could you be more specific please? How could this make management any
> >easier when udev is basically racing with the physical hotplug and the
> >result is basically undefined?
> >
> 
> When changing zone from NORMAL(N) to MOVALBE(M), we must resize both zones,
> zone->zone_start_pfn and zone->spanned_pages. Currently there is the
> restriction.
> 
> So we just simply change:
>   zone(N)->spanned_pages -= nr_pages
>   zone(M)->zone_start_pfn -= nr_pages

Yes I understand how this made the implementation simpler. I was
questioning how this made user management any easier. Changing
valid zones which races with the hotplug consumer (e.g. udev) sounds
like a terrible idea to me.

Anyway, it seems that the initial assumption/restriction that all
pages have to start on the zone Normal is not really needed. I have a
preliminary patch which removes that and associates newly added pages
with a zone at the online time and it seems to be working reasonably
well. I have to iron out some corners before I post it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
