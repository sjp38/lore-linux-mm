Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id BFCEB6B0038
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 04:49:58 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id q108so388152qgd.0
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 01:49:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si1481549qgk.40.2015.02.04.01.49.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 01:49:57 -0800 (PST)
Message-ID: <54D1EB3E.9050208@redhat.com>
Date: Wed, 04 Feb 2015 09:49:50 +0000
From: Steven Whitehouse <swhiteho@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] gfs2: use __vmalloc GFP_NOFS for fs-related allocations.
References: <1422849594-15677-1-git-send-email-green@linuxhacker.ru> <20150202053708.GG4251@dastard> <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru> <20150202081115.GI4251@dastard> <54CF51C5.5050801@redhat.com> <20150203223350.GP6282@dastard> <BD2045CE-45AD-4D79-8C8D-C854D112DCC5@linuxhacker.ru>
In-Reply-To: <BD2045CE-45AD-4D79-8C8D-C854D112DCC5@linuxhacker.ru>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Drokin <green@linuxhacker.ru>, Dave Chinner <david@fromorbit.com>
Cc: cluster-devel@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,

On 04/02/15 07:13, Oleg Drokin wrote:
> Hello!
>
> On Feb 3, 2015, at 5:33 PM, Dave Chinner wrote:
>>> I also wonder if vmalloc is still very slow? That was the case some
>>> time ago when I noticed a problem in directory access times in gfs2,
>>> which made us change to use kmalloc with a vmalloc fallback in the
>>> first place,
>> Another of the "myths" about vmalloc. The speed and scalability of
>> vmap/vmalloc is a long solved problem - Nick Piggin fixed the worst
>> of those problems 5-6 years ago - see the rewrite from 2008 that
>> started with commit db64fe0 ("mm: rewrite vmap layer")....
> This actually might be less true than one would hope. At least somewhat
> recent studies by LLNL (https://jira.hpdd.intel.com/browse/LU-4008)
> show that there's huge contention on vmlist_lock, so if you have vmalloc
> intense workloads, you get penalized heavily. Granted, this is rhel6 kernel,
> but that is still (albeit heavily modified) 2.6.32, which was released at
> the end of 2009, way after 2008.
> I see that vmlist_lock is gone now, but e.g. vmap_area_lock that is heavily
> used is still in place.
>
> So of course with that in place there's every incentive to not use vmalloc
> if at all possible. But if used, one would still hopes it would be at least
> safe to do even if somewhat slow.
>
> Bye,
>      Oleg

I was thinking back to this thread:
https://lkml.org/lkml/2010/4/12/207

More recent than 2008, and although it resulted in a patch that 
apparently fixed the problem, I don't think it was ever applied on the 
basis that it was too risky and kmalloc was the proper solution 
anyway.... I've not tested recently, so it may have been fixed in the 
mean time,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
