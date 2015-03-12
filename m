Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 64050829AD
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 15:30:45 -0400 (EDT)
Received: by pdbfp1 with SMTP id fp1so22475187pdb.7
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 12:30:45 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id m4si889144pdm.252.2015.03.12.12.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 12:30:44 -0700 (PDT)
Received: by pabrd3 with SMTP id rd3so22962357pab.5
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 12:30:44 -0700 (PDT)
Date: Thu, 12 Mar 2015 15:30:38 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4] Allow compaction of unevictable pages
Message-ID: <20150312193038.GB20841@dhcp22.suse.cz>
References: <1426173776-23471-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426173776-23471-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 12-03-15 11:22:56, Eric B Munson wrote:
> Currently, pages which are marked as unevictable are protected from
> compaction, but not from other types of migration.  The mlock
> desctription does not promise that all page faults will be avoided, only
> major ones so this protection is not necessary.  This extra protection
> can cause problems for applications that are using mlock to avoid
> swapping pages out, but require order > 0 allocations to continue to
> succeed in a fragmented environment.  This patch adds a sysctl entry
> that will be used to allow root to enable compaction of unevictable
> pages.

It would be appropriate to add a justification for the sysctl, because
it is not obvious from the above description. mlock preventing from the
swapout is not sufficient to justify it. It is the real time extension
mentioned by Peter in the previous version which makes it worth a new
user visible knob.

I would also argue that the knob should be enabled by default because
the real time extension requires an additional changes anyway (rt-kernel
at least) while general usage doesn't need such a strong requirement.

You also should provide a knob description to
Documentation/sysctl/vm.txt

> To illustrate this problem I wrote a quick test program that mmaps a
> large number of 1MB files filled with random data.  These maps are
> created locked and read only.  Then every other mmap is unmapped and I
> attempt to allocate huge pages to the static huge page pool.  When the
> compact_unevictable sysctl is 0, I cannot allocate hugepages after
> fragmenting memory.  When the value is set to 1, allocations succeed.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

After the above things are fixed
Acked-by: Michal Hocko <mhocko@suse.cz>

One minor suggestion below

> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 88ea2d6..cc1a678 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1313,6 +1313,13 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= &min_extfrag_threshold,
>  		.extra2		= &max_extfrag_threshold,
>  	},
> +	{
> +		.procname	= "compact_unevictable",
> +		.data		= &sysctl_compact_unevictable,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,

You can use .extra1 = &zero and .extra2 = &one to reduce the value
space.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
