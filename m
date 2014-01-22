Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A35056B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:40:58 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x12so116495wgg.1
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 01:40:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t13si6031723wju.91.2014.01.22.01.40.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 01:40:57 -0800 (PST)
Date: Wed, 22 Jan 2014 09:40:53 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] restore user defined min_free_kbytes when disabling thp
Message-ID: <20140122094053.GT4963@suse.de>
References: <20140121093859.GA7546@localhost.localdomain>
 <20140121102351.GD4963@suse.de>
 <20140122060506.GA2657@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140122060506.GA2657@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

On Wed, Jan 22, 2014 at 02:05:06PM +0800, Han Pingtian wrote:
> On Tue, Jan 21, 2014 at 10:23:51AM +0000, Mel Gorman wrote:
> > On Tue, Jan 21, 2014 at 05:38:59PM +0800, Han Pingtian wrote:
> > > The testcase 'thp04' of LTP will enable THP, do some testing, then
> > > disable it if it wasn't enabled. But this will leave a different value
> > > of min_free_kbytes if it has been set by admin. So I think it's better
> > > to restore the user defined value after disabling THP.
> > > 
> > 
> > Then have LTP record what min_free_kbytes was at the same time THP was
> > enabled by the test and restore both settings. It leaves a window where
> > an admin can set an alternative value during the test but that would also
> > invalidate the test in same cases and gets filed under "don't do that".
> > 
> 
> Because the value is changed in kernel, so it would be better to 
> restore it in kernel, right? :)  I have a v2 patch which will restore
> the value only if it isn't set again by user after THP's initialization.
> This v2 patch is dependent on the patch 'mm: show message when updating
> min_free_kbytes in thp' which has been added to -mm tree, can be found
> here:
> 

It still feels like the type of scenario that only shows up during tests
that modify kernel parameters as part of the test. I do not consider it
normal operation for THP to be enabled and disabled multiple types during
the lifetime of the system. If the system started with THP disabled, ran
for a long period of time then the benefit of having min_free_kbytes at
a higher value is already lost due to the system being potentially in a
fragmented state already.

I'm ok with the warning being displayed if min_free_kbytes is updated
but I'm not convinced that further trickery is necessary.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
