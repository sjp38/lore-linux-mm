Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA77E6B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 05:17:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l4so5563493wre.10
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 02:17:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i19si3552924eda.254.2017.12.01.02.17.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 02:17:38 -0800 (PST)
Date: Fri, 1 Dec 2017 11:17:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: stalled MM patches
Message-ID: <20171201101734.65tubivkejlduq34@dhcp22.suse.cz>
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
 <20171201083154.GA7108@gmail.com>
 <20171201084510.4cztiv2o752zoqmt@dhcp22.suse.cz>
 <20171201101147.t62ouec3ebnv7lz5@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201101147.t62ouec3ebnv7lz5@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alexandru Moise <00moses.alexander00@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org

On Fri 01-12-17 13:11:47, Kirill A. Shutemov wrote:
> On Fri, Dec 01, 2017 at 09:45:10AM +0100, Michal Hocko wrote:
> > On Fri 01-12-17 09:31:55, Alexandru Moise wrote:
> > [...]
> > > > Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level
> > > > 
> > > >   Hoping for Kirill review.  I wanted additional code comments (I
> > > >   think).  mhocko nacked it.
> > > 
> > > TBH I'd rather give up this one if mhocko feels that there's no point to it.
> > > Rather drop it than risk adding crap in the kernel :).
> > > 
> > > It is a bit weird though that currently we have the behavior that on some PPC platforms
> > > you can migrate 1G hugepages but on x86_64 you cannot.
> > 
> > I _think_ we can apply this patch in the end. But there is more work to
> > be done before we can do that. PPC is probably broken in that regard as
> > well, we just haven't noticed before this got merged. I find the
> > hwpoison based reasons for merging disputable at best but this is not
> > serious enough to call for a revert. I am currently working on patches
> > to make giga pages migratable for real and then we can apply your patch
> > on top.
> 
> One way we can approach it is to make architecture code to provide
> hugepage_migration_supported() with fallback to "return false;" in generic
> code. It will give us more control on what can be migrated.
> 
> And we can kill CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION.
> 
> Then we can include new page sizes into migration one-by-one with proper
> testing.

I do not think this is the biggest problem here. The page migration code
is basically generic for hugetlb pages. I seriously suspect anybody has
tested PGD pages migration on PPC. This is all hwpoison driven thing.

So, really, we should make giga pages migration work better first and
then play with hugepage_migration_supported. Arch specific treatment
might be needed but that is not the biggest problem we have.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
