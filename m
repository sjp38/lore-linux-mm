Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EBAC36B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 23:43:40 -0500 (EST)
Received: by yenm7 with SMTP id m7so1911052yen.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 20:43:37 -0800 (PST)
Date: Wed, 9 Nov 2011 20:43:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/5]thp: improve the error code path
In-Reply-To: <20111110030646.GT5075@redhat.com>
Message-ID: <alpine.DEB.2.00.1111092039110.27280@chino.kir.corp.google.com>
References: <1319511521.22361.135.camel@sli10-conroe> <20111025114406.GC10182@redhat.com> <1319593680.22361.145.camel@sli10-conroe> <1320643049.22361.204.camel@sli10-conroe> <20111110021853.GQ5075@redhat.com> <1320892395.22361.229.camel@sli10-conroe>
 <alpine.DEB.2.00.1111091828500.32414@chino.kir.corp.google.com> <20111110030646.GT5075@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 10 Nov 2011, Andrea Arcangeli wrote:

> Before after won't matter much I guess... If you really want to clean
> the code, I wonder what is exactly the point of those dummy functions
> if we can't call those outside of #ifdefs.

You can, you just need to declare the actuals that you pass to the dummy 
functions for CONFIG_SYSFS=n as well.  Or, convert the dummy functions to 
do

	#define sysfs_remove_group(kobj, grp) do {} while (0)

but good luck getting that passed Andrew :)

> I mean a cleanup that adds
> more #ifdefs when there are explicit dummy functions which I assume
> are meant to be used outside of #ifdef CONFIG_SYSFS doesn't sound so
> clean in the first place. I understand you need to refactor the code
> above to call those outside of #ifdefs but hey if you're happy with
> #ifdef I'm happy too :). It just looks fishy to read sysfs.h dummy
> functions and #ifdefs. When I wrote the code I hardly could have
> wondered about the sysfs #ifdefs but at this point it's only cleanups
> I'm seeing so I actually noticed that.
> 

The cleaniest solution would probably be to just extract all the calls 
that depend on CONFIG_SYSFS out of hugepage_init(), call it 
hugepage_sysfs_init(), and then return a failure code if it fails to setup 
then do the error handling there.  hugepage_sysfs_init() would be defined 
right after the attributes are defined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
