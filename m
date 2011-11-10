Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B4106B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 22:06:50 -0500 (EST)
Date: Thu, 10 Nov 2011 04:06:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/5]thp: improve the error code path
Message-ID: <20111110030646.GT5075@redhat.com>
References: <1319511521.22361.135.camel@sli10-conroe>
 <20111025114406.GC10182@redhat.com>
 <1319593680.22361.145.camel@sli10-conroe>
 <1320643049.22361.204.camel@sli10-conroe>
 <20111110021853.GQ5075@redhat.com>
 <1320892395.22361.229.camel@sli10-conroe>
 <alpine.DEB.2.00.1111091828500.32414@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111091828500.32414@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, Nov 09, 2011 at 06:43:58PM -0800, David Rientjes wrote:
> You're right, but I agree that the #ifdef's just make the function error 
> handling much too complex.  Would you mind adding sysfs_*_out labels at 
> the end of the function to handle these errors instead?  And I think we 
> should be doing khugepaged_slab_init() and mm_slots_hash_init() before 
> initializing sysfs.
> 
> Something like
> 
> 	out:
> 		khugepaged_slab_free();
> 		mm_slots_hash_free();	<-- after you remove it from #if 0
> 		return err;
> 
> 	#ifdef CONFIG_SYSFS
> 	sysfs_khugepaged_out:
> 		sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
> 	sysfs_hugepage_out:
> 		sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
> 		...
> 		goto out;
> 	#endif

Before after won't matter much I guess... If you really want to clean
the code, I wonder what is exactly the point of those dummy functions
if we can't call those outside of #ifdefs. I mean a cleanup that adds
more #ifdefs when there are explicit dummy functions which I assume
are meant to be used outside of #ifdef CONFIG_SYSFS doesn't sound so
clean in the first place. I understand you need to refactor the code
above to call those outside of #ifdefs but hey if you're happy with
#ifdef I'm happy too :). It just looks fishy to read sysfs.h dummy
functions and #ifdefs. When I wrote the code I hardly could have
wondered about the sysfs #ifdefs but at this point it's only cleanups
I'm seeing so I actually noticed that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
