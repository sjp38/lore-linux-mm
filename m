Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 402AD6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:29:20 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so15087028pac.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:29:20 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id z69si25339452pfi.42.2015.11.24.00.29.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 00:29:19 -0800 (PST)
Date: Tue, 24 Nov 2015 17:29:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: hugepage compaction causes performance drop
Message-ID: <20151124082941.GA4136@js1304-P5Q-DELUXE>
References: <564DCEA6.3000802@suse.cz>
 <564EDFE5.5010709@intel.com>
 <564EE8FD.7090702@intel.com>
 <564EF0B6.10508@suse.cz>
 <20151123081601.GA29397@js1304-P5Q-DELUXE>
 <5652CF40.6040400@intel.com>
 <CAAmzW4M6oJukBLwucByK89071RukF4UEyt02A7ZjenpPr5rsdQ@mail.gmail.com>
 <5653DC2C.3090706@intel.com>
 <20151124045536.GA3112@js1304-P5Q-DELUXE>
 <5654116F.1030301@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5654116F.1030301@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, Nov 24, 2015 at 03:27:43PM +0800, Aaron Lu wrote:
> On 11/24/2015 12:55 PM, Joonsoo Kim wrote:
> > On Tue, Nov 24, 2015 at 11:40:28AM +0800, Aaron Lu wrote:
> >> BTW, I'm still learning how to do proper ftrace for this case and it may
> >> take a while.
> > 
> > You can do it simply with trace-cmd.
> > 
> > sudo trace-cmd record -e compaction &
> > run test program
> > fg
> > Ctrl + c
> > 
> > sudo trace-cmd report
> 
> Thanks for the tip, I just recorded it like this:
> trace-cmd record -e compaction ./usemem xxx
> 
> Due to the big size of trace.out(6MB after compress), I've uploaed it:
> https://drive.google.com/open?id=0B49uX3igf4K4UkJBOGt3cHhOU00
> 
> The pagetypeinfo, perf and proc-vmstat is also there.
> 

Thanks.

Okay. Output proves the theory. pagetypeinfo shows that there are
too many unmovable pageblocks. isolate_freepages() should skip these
so it's not easy to meet proper pageblock until need_resched(). Hence,
updating cached pfn doesn't happen. (You can see unchanged free_pfn
with 'grep compaction_begin tracepoint-output')

But, I don't think that updating cached pfn is enough to solve your problem.
More complex change would be needed, I guess.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
