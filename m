Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 63B1A6B0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:41:29 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb23so4214702vcb.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 00:41:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121211002108.8d013a80.akpm@linux-foundation.org>
References: <1355213158-4955-1-git-send-email-lliubbo@gmail.com>
	<20121211002108.8d013a80.akpm@linux-foundation.org>
Date: Tue, 11 Dec 2012 16:41:28 +0800
Message-ID: <CAA_GA1cOh0vP=6_FbLCzakaROySUJHpR4604Bq6QjUOvttjXHw@mail.gmail.com>
Subject: Re: [PATCH] mm: memory_hotplug: fix build error
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: laijs@cn.fujitsu.com, wency@cn.fujitsu.com, jiang.liu@huawei.com, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org

On Tue, Dec 11, 2012 at 4:21 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 11 Dec 2012 16:05:58 +0800 Bob Liu <lliubbo@gmail.com> wrote:
>
>> Fix below build error(and comment):
>> mm/memory_hotplug.c:646:14: error: ___ZONE_HIGH___ undeclared (first use in this
>> function)
>> mm/memory_hotplug.c:646:14: note: each undeclared identifier is reported
>> only once for each function it appears in
>> make[1]: *** [mm/memory_hotplug.o] Error 1
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>>  mm/memory_hotplug.c |    6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index ea71d0d..9e97530 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -636,14 +636,14 @@ static void node_states_check_changes_online(unsigned long nr_pages,
>>  #ifdef CONFIG_HIGHMEM
>>       /*
>>        * If we have movable node, node_states[N_HIGH_MEMORY]
>> -      * contains nodes which have zones of 0...ZONE_HIGH,
>> -      * set zone_last to ZONE_HIGH.
>> +      * contains nodes which have zones of 0...ZONE_HIGHMEM,
>> +      * set zone_last to ZONE_HIGHMEM.
>>        *
>>        * If we don't have movable node, node_states[N_NORMAL_MEMORY]
>>        * contains nodes which have zones of 0...ZONE_MOVABLE,
>>        * set zone_last to ZONE_MOVABLE.
>>        */
>> -     zone_last = ZONE_HIGH;
>> +     zone_last = ZONE_HIGHMEM;
>>       if (N_MEMORY == N_HIGH_MEMORY)
>>               zone_last = ZONE_MOVABLE;
>
> Thanks - there are actually two sites.  You only caught one because
> CONFIG_HIGHMEM was missing its 'F'.
>

Hmm...You are right.
Sorry for not take more time on it.

>
> Guys, this isn't very good.  Obviously this code wasn't tested well :(
>
> I expect the combination of highmem and memory hotplug will never
> exist, but it should at least compile.
>

Agree.

>
>
> --- a/mm/memory_hotplug.c~hotplug-update-nodemasks-management-fix
> +++ a/mm/memory_hotplug.c
> @@ -620,14 +620,14 @@ static void node_states_check_changes_on
>  #ifdef CONFIG_HIGHMEM
>         /*
>          * If we have movable node, node_states[N_HIGH_MEMORY]
> -        * contains nodes which have zones of 0...ZONE_HIGH,
> -        * set zone_last to ZONE_HIGH.
> +        * contains nodes which have zones of 0...ZONE_HIGHMEM,
> +        * set zone_last to ZONE_HIGHMEM.
>          *
>          * If we don't have movable node, node_states[N_NORMAL_MEMORY]
>          * contains nodes which have zones of 0...ZONE_MOVABLE,
>          * set zone_last to ZONE_MOVABLE.
>          */
> -       zone_last = ZONE_HIGH;
> +       zone_last = ZONE_HIGHMEM;
>         if (N_MEMORY == N_HIGH_MEMORY)
>                 zone_last = ZONE_MOVABLE;
>
> @@ -1151,17 +1151,17 @@ static void node_states_check_changes_of
>         else
>                 arg->status_change_nid_normal = -1;
>
> -#ifdef CONIG_HIGHMEM
> +#ifdef CONFIG_HIGHMEM
>         /*
>          * If we have movable node, node_states[N_HIGH_MEMORY]
> -        * contains nodes which have zones of 0...ZONE_HIGH,
> -        * set zone_last to ZONE_HIGH.
> +        * contains nodes which have zones of 0...ZONE_HIGHMEM,
> +        * set zone_last to ZONE_HIGHMEM.
>          *
>          * If we don't have movable node, node_states[N_NORMAL_MEMORY]
>          * contains nodes which have zones of 0...ZONE_MOVABLE,
>          * set zone_last to ZONE_MOVABLE.
>          */
> -       zone_last = ZONE_HIGH;
> +       zone_last = ZONE_HIGHMEM;
>         if (N_MEMORY == N_HIGH_MEMORY)
>                 zone_last = ZONE_MOVABLE;
>
> _
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
