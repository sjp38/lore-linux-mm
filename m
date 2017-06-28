Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED0C56B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:29:20 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id f9so16793814vke.4
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 00:29:20 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id i123si645435vke.264.2017.06.28.00.29.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 00:29:19 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id 191so3193224vko.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 00:29:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <855068c0-8361-9789-4208-36d43e8fd80d@suse.cz>
References: <20170626035822.50155-1-richard.weiyang@gmail.com> <855068c0-8361-9789-4208-36d43e8fd80d@suse.cz>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Wed, 28 Jun 2017 15:28:59 +0800
Message-ID: <CADZGycbxQq3TewS7VBDo9PzeY7nm1scYD=teFQaURKVEdoBGYA@mail.gmail.com>
Subject: Re: [PATCH] mm/memory_hotplug: just build zonelist for new added node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jun 28, 2017 at 3:06 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 06/26/2017 05:58 AM, Wei Yang wrote:
>> In commit (9adb62a5df9c0fbef7) "mm/hotplug: correctly setup fallback
>> zonelists when creating new pgdat" tries to build the correct zonelist for
>> a new added node, while it is not necessary to rebuild it for already exist
>> nodes.
>>
>> In build_zonelists(), it will iterate on nodes with memory. For a new added
>> node, it will have memory until node_states_set_node() is called in
>
>         it will not have memory
>

No memory at this point.

> right?
>
>> online_pages().
>>
>> This patch will avoid to rebuild the zonelists for already exist nodes.
>>
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
> Sounds correct, as far as the memory hotplug mess allows.
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Some style nitpicks below:
>
>> ---
>>  mm/page_alloc.c | 16 +++++++++-------
>>  1 file changed, 9 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 560eafe8234d..fc8181b44fd8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5200,15 +5200,17 @@ static int __build_all_zonelists(void *data)
>>       memset(node_load, 0, sizeof(node_load));
>>  #endif
>>
>> -     if (self && !node_online(self->node_id)) {
>> +     /* This node is hotadded and no memory preset yet.
>
> On multiline comments, the first line should be empty after "/*"
>

Thanks, I will pay attention next time.

> But I see Andrew already fixed that.
>
>> +      * So just build zonelists is fine, no need to touch other nodes.
>> +      */
>> +     if (self && !node_online(self->node_id))
>>               build_zonelists(self);
>> -     }
>> -
>> -     for_each_online_node(nid) {
>> -             pg_data_t *pgdat = NODE_DATA(nid);
>> +     else
>> +             for_each_online_node(nid) {
>> +                     pg_data_t *pgdat = NODE_DATA(nid);
>>
>> -             build_zonelists(pgdat);
>> -     }
>> +                     build_zonelists(pgdat);
>> +             }
>
> Personally I would use { } for the else block, and thus leave them also
> for the if block, not sure if this is recommended by the style guide though.
>

I am not quite sure about this. The checkpatch.py script doesn't complain.

Thanks for your comment again~

>>       /*
>>        * Initialize the boot_pagesets that are going to be used
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
