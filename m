Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DE4A06B0047
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:54:10 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 9so2007969qwj.44
        for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:55:00 -0700 (PDT)
Message-ID: <49D23CD1.9090208@codemonkey.ws>
Date: Tue, 31 Mar 2009 10:54:57 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random>
In-Reply-To: <20090331151845.GT9137@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Mar 31, 2009 at 10:09:24AM -0500, Anthony Liguori wrote:
>   
>> I don't think the registering of ram should be done via sysfs.  That would 
>> be a pretty bad interface IMHO.  But I do think the functionality that 
>> ksmctl provides along with the security issues I mentioned earlier really 
>> suggest that there ought to be a separate API for control vs. registration 
>> and that control API would make a lot of sense as a sysfs API.
>>
>> If you wanted to explore alternative APIs for registration, madvise() seems 
>> like the obvious candidate to me.
>>
>> madvise(start, size, MADV_SHARABLE) seems like a pretty obvious API to me.
>>     
>
> madvise to me would sound appropriate, only if ksm would be always-in,
> which is not the case as it won't even be built if it's configured to
> N.
>   

You can still disable ksm and simply return ENOSYS for the MADV_ flag.  
You could even keep it as a module if you liked by separating the 
madvise bits from the ksm bits.  The madvise() bits could just provide 
the tracking infrastructure for determine which vmas were currently 
marked as sharable.

You could then have ksm as loadable module that consumed that interface 
to then perform scanning.

> Besides madvise is sus covered syscall, and this is linux specific detail.
>   

A number of MADV_ flags are Linux specific (like MADV_DOFORK/MADV_DONTFORK).

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
