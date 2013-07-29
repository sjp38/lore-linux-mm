Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id E6EDE6B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 12:45:44 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id q14so894377vbe.27
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 09:45:43 -0700 (PDT)
Message-ID: <51F69C59.10307@gmail.com>
Date: Mon, 29 Jul 2013 12:46:17 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Possible deadloop in direct reclaim?
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com> <CAA_GA1ciCDJeBqZv1gHNpQ2VVyDRAVF9_au+fo2dwVvLqnkygA@mail.gmail.com> <CAHGf_=oSiz8TKhrz9unxGSkxO10jveae9n+U8GPDoppe2jmYxw@mail.gmail.com> <CAA_GA1frSpEzKraDAuM2hMgwPcu76NfJEATAKBrDco25B-TRyA@mail.gmail.com>
In-Reply-To: <CAA_GA1frSpEzKraDAuM2hMgwPcu76NfJEATAKBrDco25B-TRyA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Lisa Du <cldu@marvell.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

(7/25/13 9:22 PM), Bob Liu wrote:
> Hi Kosaki,
>
> On Fri, Jul 26, 2013 at 2:14 AM, KOSAKI Motohiro
> <kosaki.motohiro@gmail.com> wrote:
>>> How about replace the checking in kswapd_shrink_zone()?
>>>
>>> @@ -2824,7 +2824,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>>>          /* Account for the number of pages attempted to reclaim */
>>>          *nr_attempted += sc->nr_to_reclaim;
>>>
>>> -       if (nr_slab == 0 && !zone_reclaimable(zone))
>>> +       if (sc->nr_reclaimed == 0 && !zone_reclaimable(zone))
>>>                  zone->all_unreclaimable = 1;
>>>
>>>          zone_clear_flag(zone, ZONE_WRITEBACK);
>>>
>>>
>>> I think the current check is wrong, reclaimed a slab doesn't mean
>>> reclaimed a page.
>>
>> The code is correct, at least, it works as intentional. page reclaim
>> status is checked by zone_reclaimable() and slab shrinking status is
>> checked by nr_slab.
>
> I'm afraid in some special cases, nr_slab = 1 or any small number
> which means we reclaimed some slab objects.
> Then we don't set zone->all_unreclaimeabled =1.
>
> But even though we reclaimed some slab objects, there may be no pages freed.
> Because one page may contain several objects.

Right. This is a limitation of current slab shrinker's implementation.
We are welcome you contribution this area.


> If we reclaimed some slab objects but without actual pages, we need to
> set zone->all_unreclaimeabled=1!
> So I think we should check sc->nr_reclaimed == 0 instead of nr_slab == 0.

sc->nr_reclaimed doesn't check how much pages freed from slab.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
