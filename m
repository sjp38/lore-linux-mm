Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8544D6B00CC
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 10:07:04 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so2256644qcq.25
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 07:07:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k11si46724786qgk.28.2014.11.14.07.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Nov 2014 07:07:03 -0800 (PST)
Message-ID: <54661A8C.5050806@redhat.com>
Date: Fri, 14 Nov 2014 10:06:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: anon_vma accumulating for certain load still not addressed
References: <20141114130822.GC22857@dhcp22.suse.cz>
In-Reply-To: <20141114130822.GC22857@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Andrea Argangeli <andrea@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, LKML <linux-kernel@vger.kernel.org>

On 11/14/2014 08:08 AM, Michal Hocko wrote:
> Hi,
> back in 2012 [1] there was a discussion about a forking load which
> accumulates anon_vmas. There was a trivial test case which triggers this
> and can potentially deplete the memory by local user.
>
> We have a report for an older enterprise distribution where nsd is
> suffering from this issue most probably (I haven't debugged it throughly
> but accumulating anon_vma structs over time sounds like a good enough
> fit) and has to be restarted after some time to release the accumulated
> anon_vma objects.
>
> There was a patch which tried to work around the issue [2] but I do not
> see any follow ups nor any indication that the issue would be addressed
> in other way.
>
> The test program from [1] was running for around 39 mins on my laptop
> and here is the result:
>
> $ date +%s; grep anon_vma /proc/slabinfo
> 1415960225
> anon_vma           11664  11900    160   25    1 : tunables    0    0    0 : slabdata    476    476      0
>
> $ ./a # The reproducer
>
> $ date +%s; grep anon_vma /proc/slabinfo
> 1415962592
> anon_vma           34875  34875    160   25    1 : tunables    0    0    0 : slabdata   1395   1395      0
>
> $ killall a
> $ date +%s; grep anon_vma /proc/slabinfo
> 1415962607
> anon_vma           11277  12175    160   25    1 : tunables    0    0    0 : slabdata    487    487      0
>
> So we have accumulated 23211 objects over that time period before the
> offender was killed which released all of them.
>
> The proposed workaround is kind of ugly but do people have a better idea
> than reference counting? If not should we merge it?

I believe we should just merge that patch.

I have not seen any better ideas come by.

The comment should probably be fixed to reflect the
chain length of 5 though :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
