Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E26DC6B6DE6
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:09:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id k58so7917134eda.20
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:09:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b27sor2945844edn.5.2018.12.04.01.09.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 01:09:52 -0800 (PST)
Date: Tue, 4 Dec 2018 09:09:50 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181204090950.ql3zbnbjjbfnvhdg@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204065453.4rsyhtsk2aej4vim@master>
 <CAFgQCTvQBC11=4eGQ6T9vyB+KOznFCr4hjdg1wwD8GotSRWpDg@mail.gmail.com>
 <20181204083428.emgcaomg6vulknaq@master>
 <CAFgQCTtY28w=9LLgOMT5J-SfKqz-Cirv-bNvXQvjazn_Ev4F4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtY28w=9LLgOMT5J-SfKqz-Cirv-bNvXQvjazn_Ev4F4g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: richard.weiyang@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 04, 2018 at 04:52:52PM +0800, Pingfan Liu wrote:
>On Tue, Dec 4, 2018 at 4:34 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>>
>> On Tue, Dec 04, 2018 at 03:20:13PM +0800, Pingfan Liu wrote:
>> >On Tue, Dec 4, 2018 at 2:54 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>> >>
>> >> On Tue, Dec 04, 2018 at 11:05:57AM +0800, Pingfan Liu wrote:
>> >> >During my test on some AMD machine, with kexec -l nr_cpus=x option, the
>> >> >kernel failed to bootup, because some node's data struct can not be allocated,
>> >> >e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
>> >> >device->numa_node info is used as preferred_nid param for
>> >>
>> >> could we fix the preferred_nid before passed to
>> >> __alloc_pages_nodemask()?
>> >>
>> >Yes, we can doit too, but what is the gain?
>>
>> node_zonelist() is used some places. If we are sure where the problem
>> is, it is not necessary to spread to other places.
>>
>> >
>> >> BTW, I don't catch the function call flow to this point. Would you mind
>> >> giving me some hint?
>> >>
>> >You can track the code along slab_alloc() ->...->__alloc_pages_nodemask()
>>
>> slab_alloc() pass NUMA_NO_NODE down, so I am lost in where the
>> preferred_nid is assigned.
>>
>You can follow:
>[    5.773618]  new_slab+0xa9/0x570
>[    5.773618]  ___slab_alloc+0x375/0x540
>[    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
>where static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>

Well, thanks for your patience, but I still don't get it.

new_slab(node)
    allocate_slab(node)
       alloc_slab_page(node)
           if (node == NUMA_NO_NODE)
	       alloc_pages()
	   eles
	       __alloc_pages_node(node)

As you mentioned, this starts from slab_alloc() which pass NUMA_NO_NODE.
This means it goes to alloc_pages() and then alloc_pages_current() ->
__alloc_pages_nodemask(). Here we use policy_node() to get the
preferred_nid. 

I didn't catch the relathionship between policy_node() and
device->numa_node. Maybe I got wrong in some place. Would you minding
sharing more?

>Thanks,
>Pingfan

-- 
Wei Yang
Help you, Help me
