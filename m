Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id AD1BE9003C7
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 02:16:24 -0400 (EDT)
Received: by qkch123 with SMTP id h123so5143888qkc.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 23:16:24 -0700 (PDT)
Received: from unicom146.biz-email.net (unicom146.biz-email.net. [210.51.26.146])
        by mx.google.com with ESMTPS id 41si5829452qgc.12.2015.08.19.23.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Aug 2015 23:16:23 -0700 (PDT)
Subject: Re: [PATCH] Memory hot added,The memory can not been added to movable
 zone
References: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
 <20150819165029.665b89d7ab3228185460172c@linux-foundation.org>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <55D57071.1080901@inspur.com>
Date: Thu, 20 Aug 2015 14:15:13 +0800
MIME-Version: 1.0
In-Reply-To: <20150819165029.665b89d7ab3228185460172c@linux-foundation.org>
Content-Type: multipart/alternative;
	boundary="------------010202060400050004020801"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

--------------010202060400050004020801
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit

Hi Andrew Morton:
First, thanks very much for your review, I will update codes according 
to  your suggestio

a?? 2015/8/20 7:50, Andrew Morton a??e??:
> On Wed, 19 Aug 2015 04:18:26 -0400 Changsheng Liu <liuchangsheng@inspur.com> wrote:
>
>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>
>> When memory hot added, the function should_add_memory_movable
>> always return 0,because the movable zone is empty,
>> so the memory that hot added will add to normal zone even if
>> we want to remove the memory.
>> So we change the function should_add_memory_movable,if the user
>> config CONFIG_MOVABLE_NODE it will return 1 when
>> movable zone is empty
> I cleaned this up a bit:
>
> : Subject: mm: memory hot-add: memory can not been added to movable zone
> :
> : When memory is hot added, should_add_memory_movable() always returns 0
> : because the movable zone is empty, so the memory that was hot added will
> : add to the normal zone even if we want to remove the memory.
> :
> : So we change should_add_memory_movable(): if the user config
> : CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.
>
> But I don't understand the "even if we want to remove the memory".
> This is hot-add, not hot-remove.  What do you mean here?
     After the system startup, we hot added one memory. After some time 
we wanted to hot remove the memroy that was hot added,
     but we could not offline some memory blocks successfully because 
the memory was added to normal zone defaultly and the value of the file 
     named removable under some memory blocks is 0.
     we checked the value of the file under some memory blocks as follows:
     "cat /sys/devices/system/memory/ memory***/removable"
     When memory being hot added we let the memory be added to movable 
zone,
     so we will be able to hot remove the memory that have been hot added
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1198,9 +1198,13 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>>   	pg_data_t *pgdat = NODE_DATA(nid);
>>   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>>   
>> -	if (zone_is_empty(movable_zone))
>> +	if (zone_is_empty(movable_zone)) {
>> +	#ifdef CONFIG_MOVABLE_NODE
>> +		return 1;
>> +	#else
>>   		return 0;
>> -
>> +	#endif
>> +	}
>>   	if (movable_zone->zone_start_pfn <= start_pfn)
>>   		return 1;
> Cleaner:
>
> --- a/mm/memory_hotplug.c~memory-hot-addedthe-memory-can-not-been-added-to-movable-zone-fix
> +++ a/mm/memory_hotplug.c
> @@ -1181,13 +1181,9 @@ static int should_add_memory_movable(int
>   	pg_data_t *pgdat = NODE_DATA(nid);
>   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>   
> -	if (zone_is_empty(movable_zone)) {
> -	#ifdef CONFIG_MOVABLE_NODE
> -		return 1;
> -	#else
> -		return 0;
> -	#endif
> -	}
> +	if (zone_is_empty(movable_zone))
> +		return IS_ENABLED(CONFIG_MOVABLE_NODE);
> +
>   	if (movable_zone->zone_start_pfn <= start_pfn)
>   		return 1;
>   
> _
>
> .
>


--------------010202060400050004020801
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    Hi Andrew Morton: <br>
    First, thanks very much for your review, I will update codes
    according toA  your suggestio<br>
    <br>
    <div class="moz-cite-prefix">a?? 2015/8/20 7:50, Andrew Morton a??e??:<br>
    </div>
    <blockquote
      cite="mid:20150819165029.665b89d7ab3228185460172c@linux-foundation.org"
      type="cite">
      <pre wrap="">On Wed, 19 Aug 2015 04:18:26 -0400 Changsheng Liu <a class="moz-txt-link-rfc2396E" href="mailto:liuchangsheng@inspur.com">&lt;liuchangsheng@inspur.com&gt;</a> wrote:

</pre>
      <blockquote type="cite">
        <pre wrap="">From: Changsheng Liu <a class="moz-txt-link-rfc2396E" href="mailto:liuchangcheng@inspur.com">&lt;liuchangcheng@inspur.com&gt;</a>

When memory hot added, the function should_add_memory_movable
always return 0,because the movable zone is empty,
so the memory that hot added will add to normal zone even if
we want to remove the memory.
So we change the function should_add_memory_movable,if the user
config CONFIG_MOVABLE_NODE it will return 1 when
movable zone is empty
</pre>
      </blockquote>
      <pre wrap="">
I cleaned this up a bit:

: Subject: mm: memory hot-add: memory can not been added to movable zone
: 
: When memory is hot added, should_add_memory_movable() always returns 0
: because the movable zone is empty, so the memory that was hot added will
: add to the normal zone even if we want to remove the memory.
: 
: So we change should_add_memory_movable(): if the user config
: CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.

But I don't understand the "even if we want to remove the memory". 
This is hot-add, not hot-remove.  What do you mean here?
</pre>
    </blockquote>
    A A A  After the system startup, we hot added one memory. After some
    time we wanted to hot remove the memroy that was hot added, <br>
    A A A  but we could not offline some memory blocks successfully because
    the memory was added to normal zone defaultly and the value of the
    file A A A  named removable under some memory blocks is 0. <br>
    A A A  we checked the value of the file under some memory blocks as
    follows: <br>
    A A A  "cat <i class="moz-txt-slash"><span class="moz-txt-tag">/</span>sys/devices/system/memory<span
        class="moz-txt-tag">/</span></i> memory***/removable" <br>
    A A A  When memory being hot added we let the memory be added to
    movable zone, <br>
    A A A  so we will be able to hot remove the memory that have been hot
    added
    <blockquote
      cite="mid:20150819165029.665b89d7ab3228185460172c@linux-foundation.org"
      type="cite">
      <pre wrap="">
</pre>
      <blockquote type="cite">
        <pre wrap="">--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1198,9 +1198,13 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat-&gt;node_zones + ZONE_MOVABLE;
 
-	if (zone_is_empty(movable_zone))
+	if (zone_is_empty(movable_zone)) {
+	#ifdef CONFIG_MOVABLE_NODE
+		return 1;
+	#else
 		return 0;
-
+	#endif
+	}
 	if (movable_zone-&gt;zone_start_pfn &lt;= start_pfn)
 		return 1;
</pre>
      </blockquote>
      <pre wrap="">
Cleaner:

--- a/mm/memory_hotplug.c~memory-hot-addedthe-memory-can-not-been-added-to-movable-zone-fix
+++ a/mm/memory_hotplug.c
@@ -1181,13 +1181,9 @@ static int should_add_memory_movable(int
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat-&gt;node_zones + ZONE_MOVABLE;
 
-	if (zone_is_empty(movable_zone)) {
-	#ifdef CONFIG_MOVABLE_NODE
-		return 1;
-	#else
-		return 0;
-	#endif
-	}
+	if (zone_is_empty(movable_zone))
+		return IS_ENABLED(CONFIG_MOVABLE_NODE);
+
 	if (movable_zone-&gt;zone_start_pfn &lt;= start_pfn)
 		return 1;
 
_

.

</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------010202060400050004020801--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
