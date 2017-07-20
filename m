Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 252216B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:21:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w126so2117638wme.10
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:21:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u107si1843465wrc.554.2017.07.20.02.21.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 02:21:28 -0700 (PDT)
Date: Thu, 20 Jul 2017 11:21:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/9] mm, page_alloc: remove stop_machine from
 build_all_zonelists
Message-ID: <20170720092124.GG9058@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-8-mhocko@kernel.org>
 <8d9d4eb5-eb7e-0422-0464-cdea9cb7e849@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8d9d4eb5-eb7e-0422-0464-cdea9cb7e849@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-07-17 09:24:58, Vlastimil Babka wrote:
> On 07/14/2017 10:00 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > build_all_zonelists has been (ab)using stop_machine to make sure that
> > zonelists do not change while somebody is looking at them. This is
> > is just a gross hack because a) it complicates the context from which
> > we can call build_all_zonelists (see 3f906ba23689 ("mm/memory-hotplug:
> > switch locking to a percpu rwsem")) and b) is is not really necessary
> > especially after "mm, page_alloc: simplify zonelist initialization".
> > 
> > Updates of the zonelists happen very seldom, basically only when a zone
> > becomes populated during memory online or when it loses all the memory
> > during offline. A racing iteration over zonelists could either miss a
> > zone or try to work on one zone twice. Both of these are something we
> > can live with occasionally because there will always be at least one
> > zone visible so we are not likely to fail allocation too easily for
> > example.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Some stress testing of this would still be worth, IMHO.

I have run the pathological online/offline of the single memblock in the
movable zone while stressing the same small node with some memory pressure.
Node 1, zone      DMA
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 943, 943, 943)
Node 1, zone    DMA32
  pages free     227310
        min      8294
        low      10367
        high     12440
        spanned  262112
        present  262112
        managed  241436
        protection: (0, 0, 0, 0)
Node 1, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 1024)
Node 1, zone  Movable
  pages free     32722
        min      85
        low      117
        high     149
        spanned  32768
        present  32768
        managed  32768
        protection: (0, 0, 0, 0)

root@test1:/sys/devices/system/node/node1# while true
do 
echo offline > memory34/state
echo online_movable > memory34/state
done

root@test1:/mnt/data/test/linux-3.7-rc5# numactl --preferred=1 make -j4

and it survived without any unexpected behavior. While this is not
really a great testing coverage it should exercise the allocation path
quite a lot.

I can add this to the changelog if you think it is worth it.
 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
