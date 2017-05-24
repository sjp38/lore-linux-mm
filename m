Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED886B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:40:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g143so36538149wme.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:40:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z9si22083770edb.89.2017.05.24.01.39.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 01:39:58 -0700 (PDT)
Date: Wed, 24 May 2017 10:39:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] memory hotplug regression
Message-ID: <20170524083956.GC14733@dhcp22.suse.cz>
References: <20170524082022.GC5427@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524082022.GC5427@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 24-05-17 10:20:22, Heiko Carstens wrote:
> Hello Michal,
> 
> I just re-tested linux-next with respect to your memory hotplug changes and
> actually (finally) figured out that your patch ("mm, memory_hotplug: do not
> associate hotadded memory to zones until online)" changes behaviour on
> s390:
> 
> before your patch memory blocks that were offline and located behind the
> last online memory block were added by default to ZONE_MOVABLE:
> 
> # cat /sys/devices/system/memory/memory16/valid_zones
> Movable Normal
> 
> With your patch this changes, so that they will be added to ZONE_NORMAL by
> default instead:
> 
> # cat /sys/devices/system/memory/memory16/valid_zones
> Normal Movable
> 
> Sorry, that I didn't realize this earlier!
>
> Having the ZONE_MOVABLE default was actually the only point why s390's
> arch_add_memory() was rather complex compared to other architectures.
> 
> We always had this behaviour, since we always wanted to be able to offline
> memory after it was brought online. Given that back then "online_movable"
> did not exist, the initial s390 memory hotplug support simply added all
> additional memory to ZONE_MOVABLE.
> 
> Keeping the default the same would be quite important.

Hmm, that is really unfortunate because I would _really_ like to get rid
of the previous semantic which was really awkward. The whole point of
the rework is to get rid of the nasty zone shifting.

Is it an option to use `online_movable' rather than `online' in your setup?
Btw. my long term plan is to remove the zone range constrains altogether
so you could online each memblock to the type you want. Would that be
sufficient for you in general?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
