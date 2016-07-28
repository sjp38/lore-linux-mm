Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E62C6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:49:53 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j124so48723765ith.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 22:49:53 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id j130si7888750oib.244.2016.07.27.22.49.51
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 22:49:52 -0700 (PDT)
Date: Thu, 28 Jul 2016 15:49:47 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160728054947.GL12670@dastard>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Jones <tonyj@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

[line wrap text at 72 columns, please] 

On Tue, Jul 26, 2016 at 09:40:57AM -0700, Tony Jones wrote:
> On 07/20/2016 07:54 AM, Michal Hocko wrote:
> >On Wed 20-07-16 20:11:09, Janani Ravichandran wrote:
> >>>On Jul 11, 2016, at 8:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >>>On Mon 11-07-16 10:12:51, Rik van Riel wrote:
> >>>>
> >>>>What mechanism do you have in mind for obtaining the name,
> >>>>Michal?
> >>>
> >>>Not sure whether tracing infrastructure allows printk like %ps.
> >>>If not then it doesn't sound too hard to add.
> >>
> >>It does allow %ps. Currently what is being printed is the
> >>function symbol of the callback using %pF. Ia??d like to know
> >>why %pF is used instead of %ps in this case.
> >
> >From a quick look into the code %pF should be doing the same
> >thing as %ps in the end. Some architectures just need some magic
> >to get a proper address of the function.
> >
> >>Michal, just to make sure I understand you correctly, do you
> >>mean that we could infer the names of the shrinkers by looking
> >>at the names of their callbacks?
> >
> >Yes, %ps can then be used for the name of the shrinker structure
> >(assuming it is available).
> 
> The "shrinker structure" (struct shrinker) isn't a good candidate
> (as it's often embedded as thus no symbol name can be resolved)
> but the callback seems to work fine in my testing.
> 
> I made an earlier suggestion to Janani that it was helpful to have
> the superblock shrinker name constructed to include the fstype.
> This level of specificity would be lost if just the callback is
> used.  I talked briefly to Michal and his view is that more
> specific tracepoints can be added for this case.   This is
> certainly an option as the super_cache_scan callback can access
> the superblock and thus the file_system_type via containing
> record.   It's just more work to later reconcile the output of two
> tracepoints.
> 
> I talked briefly to Mel and we both think being able to have this
> level (of fstype) specificity would be useful and it would be lost
> just using the callback.   Another option which would avoid the
> static overhead of the names would be to add a new shrinker_name()
> callback.  If NULL,  the caller can just perform the default, in
> this case lookup the symbol for the callback, if !NULL it would
> provide additional string information which the caller could use.
> The per-sb shrinker could implement it and return the fstype.
> It's obviously still a +1 word growth of the struct shrinker but
> it avoids the text overhead of the constructed names.
> 
> Opinions?

Seems you're all missing the obvious.

Add a tracepoint for a shrinker callback that includes a "name"
field, have the shrinker callback fill it out appropriately. e.g
in the superblock shrinker:


	trace_shrinker_callback(shrinker, shrink_control, sb->s_type->name);

And generic code that doesn't want to put a specific context name in
there can simply call:

	trace_shrinker_callback(shrinker, shrink_control, __func__);

And now you know exactly what shrinker is being run.

No need to add names to any structures, it's call site defined so is
flexible, and if you're not using tracepoints has no overhead.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
