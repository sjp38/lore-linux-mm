Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 461066B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 07:58:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so5891404wmd.9
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 04:58:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f134si826502wmd.165.2017.10.13.04.58.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 04:58:37 -0700 (PDT)
Date: Fri, 13 Oct 2017 13:58:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
 <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
 <87infmz9xd.fsf@concordia.ellerman.id.au>
 <20171011065123.e7jvoftmtso3vcha@dhcp22.suse.cz>
 <d29b6788-da1b-23e9-090c-d43428deb97d@suse.cz>
 <87bmlbtgsp.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bmlbtgsp.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 13-10-17 22:42:46, Michael Ellerman wrote:
> Vlastimil Babka <vbabka@suse.cz> writes:
> > On 10/11/2017 08:51 AM, Michal Hocko wrote:
> >> On Wed 11-10-17 13:37:50, Michael Ellerman wrote:
> >>> Michal Hocko <mhocko@kernel.org> writes:
> >>>> On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
> >>>>> Michal Hocko <mhocko@kernel.org> writes:
> >>>>>> From: Michal Hocko <mhocko@suse.com>
> >>>>>>
> >>>>>> Memory offlining can fail just too eagerly under a heavy memory pressure.
> ...
> >>>>>
> >>>>> This breaks offline for me.
> >>>>>
> >>>>> Prior to this commit:
> >>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
> >>>>>   -bash: echo: write error: Device or resource busy
> >
> > Well, that means offline didn't actually work for that block even before
> > this patch, right? Is it even a movable_node block? I guess not?
> 
> Correct. It should fail.
> 
> >>>>> After:
> >>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
> >>>>>   -bash: echo: write error: Device or resource busy
> >>>>>   
> >>>>>   real	2m0.009s
> >>>>>   user	0m0.000s
> >>>>>   sys	1m25.035s
> >>>>>
> >>>>> There's no way that block can be removed, it contains the kernel text,
> >>>>> so it should instantly fail - which it used to.
> >
> > Ah, right. So your complain is really about that the failure is not
> > instant anymore for blocks that can't be offlined.
> 
> Yes. Previously it failed instantly, now it doesn't fail, and loops
> infinitely (once the 2 minute limit is removed).

Yeah it failed only because the migration code retried few times and we
bailed out which is wrong as well. I will send two patches as a reply to
this email.

> >> This is really strange! As you write in other email the page is
> >> reserved. That means that some of the earlier checks 
> >> 	if (zone_idx(zone) == ZONE_MOVABLE)
> >> 		return false;
> >> 	mt = get_pageblock_migratetype(page);
> >> 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> >
> > The MIGRATE_MOVABLE check is indeed bogus, because that doesn't
> > guarantee there are no unmovable pages in the block (CMA block OTOH
> > should be a guarantee).
> 
> OK I'll try that and get back to you.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
