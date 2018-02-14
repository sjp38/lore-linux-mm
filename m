Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50CDC6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:48:11 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d67so19037072qkb.7
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:48:11 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d186si3543279qkg.484.2018.02.14.04.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 04:48:10 -0800 (PST)
Subject: Re: WARNING in kvmalloc_node
References: <001a1144c4ca5dc9d6056520c7b7@google.com>
 <20180214025533.GA28811@bombadil.infradead.org>
 <20180214084308.GX3443@dhcp22.suse.cz>
 <f3fda93e-b223-3c94-3213-43cad4346716@iogearbox.net>
 <24351362-a099-3317-2b96-8cdc6835eb1e@redhat.com>
 <20180214115119.GA3443@dhcp22.suse.cz>
 <62489a86-b578-b075-3ada-c2f5baf5b787@redhat.com>
 <dcbb4ead-2a76-310c-69dc-4f253e711fe9@iogearbox.net>
 <20180214132950.2d06e612@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <ce8cbaab-796b-2838-d1c4-c63243fb5f69@redhat.com>
Date: Wed, 14 Feb 2018 20:47:56 +0800
MIME-Version: 1.0
In-Reply-To: <20180214132950.2d06e612@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, Daniel Borkmann <daniel@iogearbox.net>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, syzbot <syzbot+1a240cdb1f4cc88819df@syzkaller.appspotmail.com>, akpm@linux-foundation.org, dhowells@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, rppt@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, viro@zeniv.linux.org.uk, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>



On 2018a1'02ae??14ae?JPY 20:29, Jesper Dangaard Brouer wrote:
> On Wed, 14 Feb 2018 13:17:18 +0100
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> On 02/14/2018 01:02 PM, Jason Wang wrote:
>>> On 2018a1'02ae??14ae?JPY 19:51, Michal Hocko wrote:
>>>> On Wed 14-02-18 19:47:30, Jason Wang wrote:
>>>>> On 2018a1'02ae??14ae?JPY 17:28, Daniel Borkmann wrote:
>>>>>> [ +Jason, +Jesper ]
>>>>>>
>>>>>> On 02/14/2018 09:43 AM, Michal Hocko wrote:
>>>>>>> On Tue 13-02-18 18:55:33, Matthew Wilcox wrote:
>>>>>>>> On Tue, Feb 13, 2018 at 03:59:01PM -0800, syzbot wrote:
>>>>>>> [...]
>>>>>>>>>  A A  kvmalloc include/linux/mm.h:541 [inline]
>>>>>>>>>  A A  kvmalloc_array include/linux/mm.h:557 [inline]
>>>>>>>>>  A A  __ptr_ring_init_queue_alloc include/linux/ptr_ring.h:474 [inline]
>>>>>>>>>  A A  ptr_ring_init include/linux/ptr_ring.h:492 [inline]
>>>>>>>>>  A A  __cpu_map_entry_alloc kernel/bpf/cpumap.c:359 [inline]
>>>>>>>>>  A A  cpu_map_update_elem+0x3c3/0x8e0 kernel/bpf/cpumap.c:490
>>>>>>>>>  A A  map_update_elem kernel/bpf/syscall.c:698 [inline]
>>>>>>>> Blame the BPF people, not the MM people ;-)
>>>>>> Heh, not really. ;-)
>>>>>>   
>>>>>>> Yes. kvmalloc (the vmalloc part) doesn't support GFP_ATOMIC semantic.
>>>>>> Agree, that doesn't work.
>>>>>>
>>>>>> Bug was added in commit 0bf7800f1799 ("ptr_ring: try vmalloc() when kmalloc() fails").
>>>>>>
>>>>>> Jason, please take a look at fixing this, thanks!
>>>>> It looks to me the only solution is to revert that commit.
>>>> Do you really need this to be GFP_ATOMIC? I can see some callers are
>>>> under RCU read lock but can we perhaps do the allocation outside of this
>>>> section?
>>> If I understand the code correctly, the code would be called by XDP program (usually run inside a bh) which makes it hard to do this.
>>>
>>> Rethink of this, we can probably test gfp and not call kvmalloc if GFP_ATOMIC is set in __ptr_ring_init_queue_alloc().
>> That would be one option indeed (probably useful in any case to make the API
>> more robust). Another one is to just not use GFP_ATOMIC in cpumap. Looking at
>> it, update can neither be called out of a BPF prog since prevented by verifier
>> nor under RCU reader side when updating this type of map from syscall path.
>> Jesper, any concrete reason we still need GFP_ATOMIC here?
> Allocations in cpumap (related to ptr_ring) should only be possible to
> be initiated through userspace via bpf-syscall.

I see verifier guarantees this.

>   Thus, there isn't any
> reason for GFP_ATOMIC here.
>

Want me to send a patch to remove GFP_ATOMIC here?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
