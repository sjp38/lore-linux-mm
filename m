Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8516B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 04:36:41 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so153051743pgd.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 01:36:41 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30051.outbound.protection.outlook.com. [40.107.3.51])
        by mx.google.com with ESMTPS id 67si28020334pgb.337.2016.12.08.01.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 01:36:40 -0800 (PST)
Date: Thu, 8 Dec 2016 17:36:24 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161208093623.GA4551@sha-win-210.asiapac.arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
 <20161205093100.GF30758@dhcp22.suse.cz>
 <20161206100358.GA4619@sha-win-210.asiapac.arm.com>
 <20161207150237.GC31797@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161207150237.GC31797@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will
 Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "vbabka@suze.cz" <vbabka@suze.cz>

On Wed, Dec 07, 2016 at 11:02:38PM +0800, Michal Hocko wrote:
> On Tue 06-12-16 18:03:59, Huang Shijie wrote:
> > On Mon, Dec 05, 2016 at 05:31:01PM +0800, Michal Hocko wrote:
> > > On Mon 05-12-16 17:17:07, Huang Shijie wrote:
> > > [...]
> > > >    The failure is caused by:
> > > >     1) kernel fails to allocate a gigantic page for the surplus case.
> > > >        And the gather_surplus_pages() will return NULL in the end.
> > > > 
> > > >     2) The condition checks for some functions are wrong:
> > > >         return_unused_surplus_pages()
> > > >         nr_overcommit_hugepages_store()
> > > >         hugetlb_overcommit_handler()
>add the  > > 
> > > OK, so how is this any different from gigantic (1G) hugetlb pages on
> > I think there is no different from gigantic (1G) hugetlb pages on
> > x86_64. Do anyone ever tested the 1G hugetlb pages in x86_64 with the "counter.sh"
> > before? 
> 
> I suspect nobody has because the gigantic page support is still somehow
> coarse and from a quick look into the code we only support pre-allocated
Yes, the x86_64 even does not support the gigantic page.
The default x86_64_defconfig does not enable the CONFIG_CMA.

I enabled the CONFIG_CMA, and did the test for gigantic page in x86_64.
(I appended "hugepagesz=1G hugepages=4" in the kernel cmdline.)
The result is got with my 16G x86_64 desktop:

   -------------------------------------------------
	counters.sh (1024M: 32):        FAIL mmap failed: Cannot allocate memory
	counters.sh (1024M: 64):        PASS
	********** TEST SUMMARY
	*                      1024M         
	*                      32-bit 64-bit 
	*     Total testcases:     1      1   
	*             Skipped:     0      0   
	*                PASS:     0      1   
	*                FAIL:     1      0   
	*    Killed by signal:     0      0   
	*   Bad configuration:     0      0   
	*       Expected FAIL:     0      0   
	*     Unexpected PASS:     0      0   
	*    Test not present:     0      0   
	* Strange test result:     0      0   
	**********
   -------------------------------------------------

The test passes for 64bit, but fails for 32bit (but I think it's okay,
since 1G hugetlb page is too large for the 32bit).				 

> giga pages. In other words surplus pages and their accounting is not
> supported at all.
Yes.

> 
> I haven't yet checked your patchset but I can tell you one thing.
Could you please review the patch set when you have time? Thanks a lot.

> Surplus and subpool pages code is tricky as hell. And it is not just a
Agree. 

Do we really need so many accountings? such as reserve/ovorcommit/surplus.

> matter of teaching the huge page allocation code to do the right thing.
> There are subtle details all over the place. E.g. we currently
> do not free giga pages AFAICS. In fact I believe that the giga pages are
Please correct me if I am wrong. :)

I think the free-giga-pages can work well.
Please see the code in update_and_free_page(). 

Could you please list all the subtle details you think the code is wrong?
I can check them one by one.


> kind of implanted to the existing code without any higher level
> consistency. This should change long term. But I am worried it is much
What's type of the "higher level consistency" we should care about?

Thanks
Huang Shijie
> more work.
> 
> Now I might be wrong because I might misremember things which might have
> been changed recently but please make sure you describe the current
> state and changes of giga pages when touching this area much better if
> you want to pursue this route...
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
