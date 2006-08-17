Message-ID: <44E4AF10.5030308@google.com>
Date: Thu, 17 Aug 2006 11:01:52 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
References: <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <20060809.165431.118952392.davem@davemloft.net> <1155189988.12225.100.camel@twins> <44DF888F.1010601@google.com> <20060814051323.GA1335@2ka.mipt.ru> <44E3F525.3060303@google.com> <20060817053636.GA30920@2ka.mipt.ru>
In-Reply-To: <20060817053636.GA30920@2ka.mipt.ru>
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov wrote:
>>>Just for clarification - it will be completely impossible to login using 
>>>openssh or some other priveledge separation protocol to the machine due
>>>to the nature of unix sockets. So you will be unable to manage your
>>>storage system just because it is in OOM - it is not what is expected
>>>from reliable system.
>>
>>The system is not OOM, it is in reclaim, a transient condition that will be
>>resolved in normal course by IO progress.  However you raise an excellent
>>point: if there is any remote management that we absolutely require to be
>>available while remote IO is interrupted - manual failover for example -
>>then we must supply a means of carrying out such remote administration, that
>>is guaranteed not to deadlock on a normal mode memory request.  This ends up
>>as a new network stack feature I think, and probably a theoretical one for
>>the time being since we don't actually know of any such mandatory login
>>that must be carried out while remote disk IO is suspended.
> 
> That is why you are not allowed to depend on main system's allocator
> problems. That is why network can have it's own allocator.

Please check your assumptions.  Do you understand how PF_MEMALLOC works,
and where it gets its reserve memory from?

>>>>But really, if you expect to run reliable block IO to Zanzibar over an ssh
>>>>tunnel through a firewall, then you might also consider taking up bungie
>>>>jumping with the cord tied to your neck.
>>>Just pure openssh for control connection (admin should be able to
>>>login).
>>
>>And the admin will be able to, but in the cluster stack itself we don't
>>bless such stupidity as emailing an admin to ask for a login in order to
>>break a tie over which node should take charge of DLM recovery.
> 
> No, you can't since openssh and any other priveledge separation
> mechanisms use adtional sockets to transfer data between it's parts,
> unix sockets require page sized allocation frequently which will endup
> with 8k allocation in slab.
> You will not be able to login using openssh.

*** The system is not OOM, it is in reclaim, a transient condition ***

Which Peter already told you!  Please, let's get our facts straight,
then we can look intelligently at whether your work is appropriate to
solve the block IO network starvation problem that Peter and I are
working on.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
