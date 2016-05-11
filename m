Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E13836B025F
	for <linux-mm@kvack.org>; Wed, 11 May 2016 03:38:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so34283335wme.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 00:38:16 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id d2si7639012wjl.68.2016.05.11.00.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 00:38:15 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so7696481wmn.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 00:38:15 -0700 (PDT)
Date: Wed, 11 May 2016 09:38:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160511073814.GD16677@dhcp22.suse.cz>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C3C4B@IRSMSX103.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023C3C4B@IRSMSX103.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Thu 05-05-16 17:25:07, Odzioba, Lukasz wrote:
> On Thu 05-05-16 09:21:00, Michal Hocko wrote: 
> > OK, it wasn't that tricky afterall. Maybe I have missed something but
> > the following should work. Or maybe the async nature of flushing turns
> > out to be just impractical and unreliable and we will end up skipping
> > THP (or all compound pages) for pcp LRU add cache. Let's see...
> 
> Initially this issue was found on RH's 3.10.x kernel, but now I am using 
> 4.6-rc6.
> 
> In overall it does help and under heavy load it is slightly better than the
> second patch. Unfortunately I am still able to hit 10-20% oom kills with it -
> (went down from 30-50%) partially due to earlier vmstat_update call
>  - it went up to 25-25% with this patch below:

This simply shows that this is not a viable option. So I guess we really
want to rather skip THP (compound pages) from LRU add pcp cache. Thanks
for your effort and testing!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
