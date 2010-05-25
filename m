Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D262F6B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 21:36:08 -0400 (EDT)
From: "Guo, Chaohong" <chaohong.guo@intel.com>
Date: Tue, 25 May 2010 09:35:27 +0800
Subject: RE: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-ID: <CF2F38D4AE21BB4CB845318E4C5ECB671E790AF3@shsmsx501.ccr.corp.intel.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	 <20100520134359.fdfb397e.akpm@linux-foundation.org>
	 <20100521105512.0c2cf254.sfr@canb.auug.org.au>
	 <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
	 <4BF642BB.2020402@linux.intel.com>
	 <20100521173940.8f130205.kamezawa.hiroyu@jp.fujitsu.com>
	 <4BF64E79.4010401@linux.intel.com>
	 <1274448107.9131.87.camel@useless.americas.hpqcorp.net>
	 <CF2F38D4AE21BB4CB845318E4C5ECB671E790500@shsmsx501.ccr.corp.intel.com>
 <1274713162.13756.209.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1274713162.13756.209.camel@useless.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: minskey guo <chaohong_guo@linux.intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "prarit@redhat.com" <prarit@redhat.com>, "Kleen, Andi" <andi.kleen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, "stable@kernel.org" <stable@kernel.org>
List-ID: <linux-mm.kvack.org>



>>
>>  But currently, I don't
>> >think you can use the numa_mem_id()/cpu_to_mem() interfaces for your
>> >purpose.  I suppose you could change page_alloc.c to compile
>> >local_memory_node() #if defined(CONFIG_HAVE_MEMORYLESS_NODES) ||
>> >defined
>> >(CPU_HOTPLUG) and use that function to find the nearest memory.  It
>> >should return a valid node after zonelists have been rebuilt.
>> >
>> >Does that make sense?
>>
>> Yes, besides,  I need to find a place in hotplug path to call set_numa_m=
em()
>> just as you mentioned for ia64 platform.  Is my understanding right ?
>
>I don't think you can use any of the "numa_mem" functions on x86[_64]
>without doing a lot more work to expose memoryless nodes.  On x86_64,
>numa_mem_id() and cpu_to_mem() always return the same as numa_node_id()
>and cpu_to_node().  This is because x86_64 code hides memoryless nodes
>and reassigns all cpus to nodes with memory.  Are you planning on
>changing this such that memoryless nodes remain on-line with their cpus
>associated with them?  If so, go for it!   If not, then you don't need
>to [can't really, I think] use set_numa_mem()/cpu_to_mem() for your
>purposes.  That's why I suggested you arrange for local_memory_node() to
>be compiled for CPU_HOTPLUG and call that function directly to obtain a
>nearby node from which you can allocate memory during cpu hot plug.  Or,
>I could just completely misunderstand what you propose to do with these
>percpu variables.

Got it, thank you very much for detailed explanation.


-minskey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
