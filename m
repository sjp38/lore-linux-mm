Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2DB6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:33:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so40715309pfx.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:33:58 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id q4si10937334pag.287.2016.07.28.00.33.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jul 2016 00:33:57 -0700 (PDT)
Message-ID: <5799B303.7020906@huawei.com>
Date: Thu, 28 Jul 2016 15:23:47 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: walk the zone in pageblock_nr_pages steps
References: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com> <7fcafdb1-86fa-9245-674b-db1ae53d1c77@suse.cz> <57971FDE.20507@huawei.com> <473964c8-23cd-cee7-b25c-6ef020547b9a@suse.cz> <57972DD3.3050909@huawei.com> <20160728065724.GB28136@js1304-P5Q-DELUXE>
In-Reply-To: <20160728065724.GB28136@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-mm@kvack.org

On 2016/7/28 14:57, Joonsoo Kim wrote:
> On Tue, Jul 26, 2016 at 05:30:59PM +0800, zhong jiang wrote:
>> On 2016/7/26 16:53, Vlastimil Babka wrote:
>>> On 07/26/2016 10:31 AM, zhong jiang wrote:
>>>> On 2016/7/26 14:24, Vlastimil Babka wrote:
>>>>> On 07/26/2016 05:08 AM, zhongjiang wrote:
>>>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>>>
>>>>>> when walking the zone, we can happens to the holes. we should
>>>>>> not align MAX_ORDER_NR_PAGES, so it can skip the normal memory.
> Do you have any system to trigger this problem?
>
> I'm not familiar with CONFIG_HOLES_IN_ZONE system, but, as Vlastimil saids,
> skip by pageblock size also has similar problem that skip the normal memory
> because hole's granularity would not be pageblock size.
>
> Anyway, if you want not to skip the normal memory, following code would work.
> I think that it is a better way since it doesn't depend on hole's granularity.
>
> Thanks.
  you maybe get me wrong. page type is showed with block size as the unit.  it is not skip the
  normal memory but we should align block. the following code will waste of time to skip the
  hole.  because it maybe need to realign to pageblock.
  I just want to express that align with pageblock will consistence with the following code. 
  and it maybe lead to skip the normal memory.
 
  Thanks
> --------->8-----------
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index e1a4690..4184db2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1276,6 +1276,11 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>          * not matter as the mixed block count will still be correct
>          */
>         for (; pfn < end_pfn; ) {
> +               if (!pfn_valid_within(pfn)) {
> +                       pfn++;
> +                       continue;
> +               }
> +
>                 if (!pfn_valid(pfn)) {
>                         pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
>                         continue;
>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
