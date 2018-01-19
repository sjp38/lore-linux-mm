Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2C06B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:33:49 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id p7so943806wre.18
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 02:33:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g71si705883wmg.94.2018.01.19.02.33.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 02:33:48 -0800 (PST)
Date: Fri, 19 Jan 2018 11:33:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180119103342.GS6584@dhcp22.suse.cz>
References: <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
 <20180118172213.GI6584@dhcp22.suse.cz>
 <20180119100259.rwq3evikkemtv7q5@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119100259.rwq3evikkemtv7q5@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Fri 19-01-18 13:02:59, Kirill A. Shutemov wrote:
> On Thu, Jan 18, 2018 at 06:22:13PM +0100, Michal Hocko wrote:
> > On Thu 18-01-18 18:40:26, Kirill A. Shutemov wrote:
> > [...]
> > > +	/*
> > > +	 * Make sure that pages are in the same section before doing pointer
> > > +	 * arithmetics.
> > > +	 */
> > > +	if (page_to_section(pvmw->page) != page_to_section(page))
> > > +		return false;
> > 
> > OK, THPs shouldn't cross memory sections AFAIK. My brain is meltdown
> > these days so this might be a completely stupid question. But why don't
> > you simply compare pfns? This would be just simpler, no?
> 
> In original code, we already had pvmw->page around and I thought it would
> be easier to get page for the pte intead of looking for pfn for both
> sides.
> 
> We these changes it's no longer the case.
> 
> Do you care enough to send a patch? :)

Well, memory sections are sparsemem concept IIRC. Unless I've missed
something page_to_section is quarded by SECTION_IN_PAGE_FLAGS and that
is conditional to CONFIG_SPARSEMEM. THP is a generic code so using it
there is wrong unless I miss some subtle detail here.

Comparing pfn should be generic enough.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
