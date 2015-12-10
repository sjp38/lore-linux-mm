Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 43DBD82F6A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:59:36 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id ph11so4283894igc.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:59:36 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id q17si10198909igr.102.2015.12.09.18.59.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 18:59:35 -0800 (PST)
Date: Thu, 10 Dec 2015 11:59:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
Message-ID: <20151210025944.GB17967@js1304-P5Q-DELUXE>
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449242195-16374-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Steven Rostedt <rostedt@goodmis.org>

Ccing, Steven to ask trace-cmd problem.

On Fri, Dec 04, 2015 at 04:16:33PM +0100, Vlastimil Babka wrote:
> In mm we use several kinds of flags bitfields that are sometimes printed for
> debugging purposes, or exported to userspace via sysfs. To make them easier to
> interpret independently on kernel version and config, we want to dump also the
> symbolic flag names. So far this has been done with repeated calls to
> pr_cont(), which is unreliable on SMP, and not usable for e.g. sysfs export.
> 
> To get a more reliable and universal solution, this patch extends printk()
> format string for pointers to handle the page flags (%pgp), gfp_flags (%pgg)
> and vma flags (%pgv). Existing users of dump_flag_names() are converted and
> simplified.
> 
> It would be possible to pass flags by value instead of pointer, but the %p
> format string for pointers already has extensions for various kernel
> structures, so it's a good fit, and the extra indirection in a non-critical
> path is negligible.

I'd like to use %pgp in tracepoint output. It works well when I do
'cat /sys/kernel/debug/tracing/trace' but not works well when I do
'./trace-cmd report'. It prints following error log.

  [page_ref:page_ref_unfreeze] bad op token &
  [page_ref:page_ref_set] bad op token &
  [page_ref:page_ref_mod_unless] bad op token &
  [page_ref:page_ref_mod_and_test] bad op token &
  [page_ref:page_ref_mod_and_return] bad op token &
  [page_ref:page_ref_mod] bad op token &
  [page_ref:page_ref_freeze] bad op token &

Following is the format I used.

TP_printk("pfn=0x%lx flags=%pgp count=%d mapcount=%d mapping=%p mt=%d val=%d ret=%d",
                __entry->pfn, &__entry->flags, __entry->count,
                __entry->mapcount, __entry->mapping, __entry->mt,
                __entry->val, __entry->ret)

Could it be solved by 'trace-cmd' itself?
Or it's better to pass flags by value?
Or should I use something like show_gfp_flags()?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
