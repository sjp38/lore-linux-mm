Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AF3B96B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:56:03 -0400 (EDT)
Message-ID: <4BD76B81.2070606@tauceti.net>
Date: Wed, 28 Apr 2010 00:56:01 +0200
From: Robert Wimmer <kernel@tauceti.net>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net> <20100419131718.GB16918@redhat.com> <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net> <20100421094249.GC30855@redhat.com> <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net> <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net> <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net> <20100425204916.GA12686@redhat.com> <1272284154.4252.34.camel@localhost.localdomain> <4BD5F6C5.8080605@tauceti.net> <1272315854.8984.125.camel@localhost.localdomain> <4BD61147.40709@tauceti.net> <1272324536.16814.45.camel@localhost.localdomain>
In-Reply-To: <1272324536.16814.45.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I've applied the patch against the kernel which I got
from "git clone ...." resulted in a kernel 2.6.34-rc5.

The stack trace after mounting NFS is here:
https://bugzilla.kernel.org/attachment.cgi?id=26166
/var/log/messages after soft lockup:
https://bugzilla.kernel.org/attachment.cgi?id=26167

I hope that there is any usefull information in there.

Thanks!
Robert

On 04/27/10 01:28, Trond Myklebust wrote:
> On Tue, 2010-04-27 at 00:18 +0200, Robert Wimmer wrote: 
>   
>>> Sure. In addition to what you did above, please do
>>>
>>> mount -t debugfs none /sys/kernel/debug
>>>
>>> and then cat the contents of the pseudofile at
>>>
>>> /sys/kernel/debug/tracing/stack_trace
>>>
>>> Please do this more or less immediately after you've finished mounting
>>> the NFSv4 client.
>>>   
>>>       
>> I've uploaded the stack trace. It was generated
>> directly after mounting. Here are the stacks:
>>
>> After mounting:
>> https://bugzilla.kernel.org/attachment.cgi?id=26153
>> After the soft lockup:
>> https://bugzilla.kernel.org/attachment.cgi?id=26154
>> The dmesg output of the soft lockup:
>> https://bugzilla.kernel.org/attachment.cgi?id=26155
>>
>>     
>>> Does your server have the 'crossmnt' or 'nohide' flags set, or does it
>>> use the 'refer' export option anywhere? If so, then we might have to
>>> test further, since those may trigger the NFSv4 submount feature.
>>>   
>>>       
>> The server has the following settings:
>> rw,nohide,insecure,async,no_subtree_check,no_root_squash
>>
>> Thanks!
>> Robert
>>
>>
>>     
> That second trace is more than 5.5K deep, more than half of which is
> socket overhead :-(((.
>
> The process stack does not appear to have overflowed, however that trace
> doesn't include any IRQ stack overhead.
>
> OK... So what happens if we get rid of half of that trace by forcing
> asynchronous tasks such as this to run entirely in rpciod instead of
> first trying to run in the process context?
>
> See the attachment...
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
