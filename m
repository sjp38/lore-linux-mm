Message-ID: <4509C4ED.9080508@cs.wisc.edu>
Date: Thu, 14 Sep 2006 16:09:01 -0500
From: Mike Christie <michaelc@cs.wisc.edu>
MIME-Version: 1.0
Subject: Re: [PATCH 20/20] iscsi: support for swapping over iSCSI.
References: <20060912143049.278065000@chello.nl>	 <20060912144905.201160000@chello.nl>  <45086F16.9030307@cs.wisc.edu>	 <1158214650.13665.27.camel@twins>  <4509ABE5.2080904@cs.wisc.edu>	 <1158266150.30737.92.camel@taijtu> <1158266816.30737.99.camel@taijtu>
In-Reply-To: <1158266816.30737.99.camel@taijtu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Thu, 2006-09-14 at 22:35 +0200, Peter Zijlstra wrote:
>> On Thu, 2006-09-14 at 14:22 -0500, Mike Christie wrote:
> 
>>>> I thought I found allocations in that path, lemme search...
>>>> found this:
>>>>
>>>> iscsi_tcp_data_recv()
>>>>   iscsi_data_rescv()
>>>>     iscsi_complete_pdu()
>>>>       __iscsi_complete_pdu()
>>>>         iscsi_recv_pdu()
>>>>           alloc_skb( GFP_ATOMIC);
>>>>
>>> You are right that is for the netlink interface. Could we move the
>>> PF_MEMALLOC setting and clearing to iscsi_recv_pdu and and add it to
>>> iscsi_conn_error in scsi_transport_iscsi.c so that iscsi_iser and
>>> qla4xxx will have it set when they need it. I will send a patch for this
>>> along with a way to have the netlink sock vmio set for all iscsi drivers
>>> that need it.
>> I already have such a patch, look at:
>> http://programming.kicks-ass.net/kernel-patches/vm_deadlock/current/iscsi_vmio.patch
>>
>> but what conditional do you want to use for PF_MEMALLOC, an
>> unconditional setting will be highly unpopular.
>>
>> Hmm, perhaps you could key it of sk_has_vmio(nls)...
> 
> On second thought, not such a good idea, that will still be too course.
> You only want to force feed stuff originating from
> sk_has_vmio(iscsi_tcp_conn->sock->sk) connections, not all
> connectections as soon as there is a swapper in the system.
> 

You can move the iscsi_session->swapper field to the iscsi_cls_session
and have iscsi_swapdev take a iscsi_cls_session and set that flag.
iscsi_recv_pdu and iscsi_conn_error and all the llds can then access
this bit.

> In order to preserve that information you need extra state, abusing this
> process flags is as good as propagating __GFP_EMERGENCY down the call
> chain with extra gfp_t arguments, perhaps even better, since it will
> make sure we catch all allocations.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
