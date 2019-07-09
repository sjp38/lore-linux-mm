Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF834C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 09:19:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F6122073D
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 09:19:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F6122073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4F368E0040; Tue,  9 Jul 2019 05:19:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FE958E0032; Tue,  9 Jul 2019 05:19:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EEBB8E0040; Tue,  9 Jul 2019 05:19:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 437D88E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 05:19:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so13009679edm.21
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 02:19:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0wYnrWaTP5E68MFy3+epY3h54CJP1uaiKnVCaOqu6AU=;
        b=TDVZgAM5KXMPaWjboPkm9zk94IZxnu7m7Q/vztmoH7jJjnabpcEIsmEc1672myZScw
         Bc/B4sts2bsU137LtO/tfz5mo0VkM4HCf/A2ypN7L0HMX1mxRvtF+WbC++mzszignrWc
         uiAjZO+ELnXWPAAASVtlc6NMjeFFTdnRMfHe8mEdPEi2vpQ/vfH9yV4pc/y/rzl9DGaI
         jMBpk8ZuIVdcLCP73LLlisa7Rg2T+7/nqi8ZqWRqA/hlqLoKkz8snsFDaLRbq9bQp9wD
         F/4mrVlme1wtLdga+Yir6+aJlxDGIH3iZTFm2k/w7y1RKJwLHHti5eY41+Z1FUZ/JbB/
         gpUA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWKKfd/Q3SA4UvKwD71rGgycNywc9bDPBZCtKLj/Z507fFsmMNx
	Iu8a49MpDbgATBTG+HqbY/klHhiVx+/QBKiKlTHK4WRp2XF5n+ie0tbY3GO3s4Kg0PgfKGvvK72
	WmlpsfJD1cQl5/hg51IVIU3JmEzrGQ57bW4gk37GSkZVrB+sbSq0aKUgvTEAHDbk=
X-Received: by 2002:a50:b343:: with SMTP id r3mr24131487edd.16.1562663989673;
        Tue, 09 Jul 2019 02:19:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoVv2n/u5cS4fboboC0K63N/Gizn28AhAFYpX7TCFLVXNHSogvkUoZF+z4fHlmOWVLogs4
X-Received: by 2002:a50:b343:: with SMTP id r3mr24131420edd.16.1562663988417;
        Tue, 09 Jul 2019 02:19:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562663988; cv=none;
        d=google.com; s=arc-20160816;
        b=npxGj2av5UEFiQF72B54LIMuJrYZECMQcWv+eyZnu0TRnBz7B26S+CPyb/tmpYWN9u
         tX33FYVvaQzn5IP4c4GK0LzvZcEJIbu08fFnk8q8LBIyEUhfzTIoUoNYxYDnGgsFlNZr
         K4BQI1cTPRNoUHWrnJo5DoKCmScS9ie0unPLniHwloABI5IPm3sFODabl1ewAyNWfphQ
         gPAF+bWqizcsaAUHfGBw6vTPguSvBWZP5NPApxfZG6nK0AA2UtHLcjG3RlFUcaSi/FFz
         EuqyBjAG3ROqcjXlwXIbPCsFX6LS2LuAiSJzd5IfPCHbqJxPMfVIw5vGCmNckdAJbadm
         2Vuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0wYnrWaTP5E68MFy3+epY3h54CJP1uaiKnVCaOqu6AU=;
        b=AM4ZgPodKHCaARoKwItxg4GI5Ig/2NNsFgkynq9FgPLubGmMp/G4giUfI7zO6ZbgUz
         Om6UiX3qbOSN60tupZUyvunUIOeTVA/sqlfh5ryyfXEbfh3EHlqi0vy5AVCdV2pDCChb
         5T++Sezg9pD+AeB7ehbrsJuawtR9FTWo6oOss1qOc+qeH9oOUZ0pysLHj8sKT+M1z+l+
         OObuVCcs+pYpTIE2ZvszEMb7YG0WkKSlxxAPBN4+qdObId2M6WEsseksUOzb6I+ovLfP
         PY5O41ZLOrqRh59l02t8uG+/jzIIEUC8DGSrEz8ixikscK28f2D2BckfJZZEQkb/fcGd
         5SXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sa2si12432088ejb.65.2019.07.09.02.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 02:19:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 37AAFB127;
	Tue,  9 Jul 2019 09:19:47 +0000 (UTC)
Date: Tue, 9 Jul 2019 11:19:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
Message-ID: <20190709091945.GD26380@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
 <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
 <20190627140203.GB5303@dhcp22.suse.cz>
 <d9341eb3-08eb-3c2b-9786-00b8a4f59953@intel.com>
 <20190627145302.GC5303@dhcp22.suse.cz>
 <20190627235618.GC33052@google.com>
 <20190701073500.GA136163@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701073500.GA136163@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 16:35:00, Minchan Kim wrote:
> >From 39df9f94e6204b8893f3f3feb692745657392657 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 24 May 2019 13:47:54 +0900
> Subject: [PATCH v3 1/5] mm: introduce MADV_COLD
> 
> When a process expects no accesses to a certain memory range, it could
> give a hint to kernel that the pages can be reclaimed when memory pressure
> happens but data should be preserved for future use.  This could reduce
> workingset eviction so it ends up increasing performance.
> 
> This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> MADV_COLD can be used by a process to mark a memory range as not expected
> to be used in the near future. The hint can help kernel in deciding which
> pages to evict early during memory pressure.
> 
> It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> 
> 	active file page -> inactive file LRU
> 	active anon page -> inacdtive anon LRU
> 
> Unlike MADV_FREE, it doesn't move active anonymous pages to inactive
> file LRU's head because MADV_COLD is a little bit different symantic.
> MADV_FREE means it's okay to discard when the memory pressure because
> the content of the page is *garbage* so freeing such pages is almost zero
> overhead since we don't need to swap out and access afterward causes just
> minor fault. Thus, it would make sense to put those freeable pages in
> inactive file LRU to compete other used-once pages. It makes sense for
> implmentaion point of view, too because it's not swapbacked memory any
> longer until it would be re-dirtied. Even, it could give a bonus to make
> them be reclaimed on swapless system. However, MADV_COLD doesn't mean
> garbage so reclaiming them requires swap-out/in in the end so it's bigger
> cost. Since we have designed VM LRU aging based on cost-model, anonymous
> cold pages would be better to position inactive anon's LRU list, not file
> LRU. Furthermore, it would help to avoid unnecessary scanning if system
> doesn't have a swap device. Let's start simpler way without adding
> complexity at this moment. However, keep in mind, too that it's a caveat
> that workloads with a lot of pages cache are likely to ignore MADV_COLD
> on anonymous memory because we rarely age anonymous LRU lists.
> 
> * man-page material
> 
> MADV_COLD (since Linux x.x)
> 
> Pages in the specified regions will be treated as less-recently-accessed
> compared to pages in the system with similar access frequencies.
> In contrast to MADV_FREE, the contents of the region are preserved
> regardless of subsequent writes to pages.
> 
> MADV_COLD cannot be applied to locked pages, Huge TLB pages, or VM_PFNMAP
> pages.
> 
> * v2
>  * add up the warn with lots of page cache workload - mhocko
>  * add man page stuff - dave
> 
> * v1
>  * remove page_mapcount filter - hannes, mhocko
>  * remove idle page handling - joelaf
> 
> * RFCv2
>  * add more description - mhocko
> 
> * RFCv1
>  * renaming from MADV_COOL to MADV_COLD - hannes
> 
> * internal review
>  * use clear_page_youn in deactivate_page - joelaf
>  * Revise the description - surenb
>  * Renaming from MADV_WARM to MADV_COOL - surenb
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

OK, looks reasonable to me. THP part still gives me a head spin but it
is consistent with madv_free part so I will trust that all weird corner
cases are already caught there.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

