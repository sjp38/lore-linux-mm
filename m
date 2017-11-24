Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4786B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:34:20 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so19384241pfi.23
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:34:20 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id p1si13355832pld.51.2017.11.24.04.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 04:34:18 -0800 (PST)
Received: from epcas5p4.samsung.com (unknown [182.195.41.42])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20171124123416epoutp03c094c426e8e515b5e535b67c617ca1a0~6BarSnOnA1667816678epoutp03p
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 12:34:16 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH 1/1] stackdepot: interface to check entries and size
 of stackdepot.
Reply-To: v.narang@samsung.com
From: Vaneet Narang <v.narang@samsung.com>
In-Reply-To: <CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
Message-ID: <20171124115707epcms5p4fa19970a325e87f08eadb1b1dc6f0701@epcms5p4>
Date: Fri, 24 Nov 2017 11:57:07 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
	<20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
	<1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
	<20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3>
	<20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
	<CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Maninder Singh <maninder1.s@samsung.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jkosina@suse.cz" <jkosina@suse.cz>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

Hi Michal,


>> 5) To check number of entries in stackdepot to decide stackdepot hash size for different systems.
>>    For fewer entries hash table size can be reduced from 4MB.
>
> What are you going to do with that information. It is not like you can
> reduce the memory footprint or somehow optimize anything during the
> runtime.

On low memory system where page owner entries are in range of 3k ~ 4k, its
a waste to keep hash table size of 4MB. It can be modified to some 128KB to
save memory footprint of stackdepot. So stackdepot entry count is important.

> OK, so debugging a debugging facility... I do not think we want to
> introduce a lot of code for something like that.

We enabled stackdepot on our system and realised, in long run stack depot consumes
more runtime memory then it actually needs. we used shared patch to debug this issue. 
stack stores following two unique entries. Page allocation done in interrupt 
context will generate a unique stack trace. Consider following two entries.

Entry 1:
 __alloc_pages_nodemask+0xec/0x200
 page_frag_alloc+0x84/0x140
 __napi_alloc_skb+0x83/0xe0
 rtl8169_poll+0x1e5/0x670
 net_rx_action+0x122/0x380          
 __do_softirq+0xce/0x298            
 irq_exit+0xa3/0xb0
 -------------------
 do_IRQ+0x72/0xc0
 ret_from_intr+0x0/0x14
 rw_copy_check_uvector+0x8a/0x100
 import_iovec+0x27/0xc0
 copy_msghdr_from_user+0xc0/0x120
 ___sys_recvmsg+0x76/0x210
 __sys_recvmsg+0x39/0x70
 entry_SYSCALL_64_fastpath+0x13/

 Entry 2:
  __alloc_pages_nodemask+0xec/0x200
 page_frag_alloc+0x84/0x140
 __napi_alloc_skb+0x83/0xe0
 rtl8169_poll+0x1e5/0x670
 net_rx_action+0x122/0x380
 __do_softirq+0xce/0x298
 irq_exit+0xa3/0xb0    
 -------------------
 smp_apic_timer_interrupt+0x5b/0x110
 apic_timer_interrupt+0x89/0x90
 cpuidle_enter_state+0x95/0x2c0
 do_idle+0x163/0x1a0
 cpu_startup_entry+0x14/0x20
 secondary_startup_64+0xa5/0xb0

 Actual Allocation Path is
 __alloc_pages_nodemask+0xec/0x200
 page_frag_alloc+0x84/0x140
 __napi_alloc_skb+0x83/0xe0
 rtl8169_poll+0x1e5/0x670
 net_rx_action+0x122/0x380          
 __do_softirq+0xce/0x298            
 irq_exit+0xa3/0xb0

We have been getting similar kind of such entries and eventually
stackdepot reaches Max Cap. So we found this interface useful in debugging
stackdepot issue so shared in community.

Regards,
Vaneet Narang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
