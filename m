Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1361A6B025E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 11:10:59 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gw7so161629514pac.0
        for <linux-mm@kvack.org>; Fri, 06 May 2016 08:10:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id u4si18254111pfu.157.2016.05.06.08.10.57
        for <linux-mm@kvack.org>;
        Fri, 06 May 2016 08:10:58 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: mm: pages are not freed from lru_add_pvecs after process
 termination
Date: Fri, 6 May 2016 15:10:00 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
In-Reply-To: <20160505072122.GA4386@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Thu 05-05-16 09:21:00, Michal Hocko wrote:=20
> Or maybe the async nature of flushing turns
> out to be just impractical and unreliable and we will end up skipping
> THP (or all compound pages) for pcp LRU add cache. Let's see...

What if we simply skip lru_add pvecs for compound pages?
That way we still have compound pages on LRU's, but the problem goes
away.  It is not quite what this na=EFve patch does, but it works nice for =
me.

diff --git a/mm/swap.c b/mm/swap.c
index 03aacbc..c75d5e1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -392,7 +392,9 @@ static void __lru_cache_add(struct page *page)
        get_page(page);
        if (!pagevec_space(pvec))
                __pagevec_lru_add(pvec);
        pagevec_add(pvec, page);
+       if (PageCompound(page))
+               __pagevec_lru_add(pvec);
        put_cpu_var(lru_add_pvec);
 }

Do we have any tests that I could use to measure performance impact
of such changes before I start to tweak it up? Or maybe it doesn't make
sense at all ?

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
