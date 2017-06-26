Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA3D6B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:46:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 77so27259845wrb.11
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 22:46:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si11028845wrs.220.2017.06.25.22.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Jun 2017 22:46:27 -0700 (PDT)
Date: Mon, 26 Jun 2017 07:46:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20170626054623.GC31972@dhcp22.suse.cz>
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
 <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 26-06-17 08:28:07, Alkis Georgopoulos wrote:
> IGBPI?I1I? 23/06/2017 02:38 I 1/4 I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> >this means that the highmem is not dirtyable and so only 20% of the free
> >lowmem (+ page cache in that region) is considered and writers might
> >get throttled quite early (this might be a really low number when the
> >lowmem is congested already). Do you see the same problem when enabling
> >highmem_is_dirtyable = 1?
> >
> 
> Excellent advice! :)
> Indeed, setting highmem_is_dirtyable=1 completely eliminates the issue!
> 
> Is that something that should be =1 by default,

Unfortunatelly, this is not something that can be applied in general.
This can lead to a premature OOM killer invocations. E.g. a direct write
to the block device cannot use highmem, yet there won't be anything to
throttle those writes properly. Unfortunately, our documentation is
silent about this setting. I will post a patch later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
