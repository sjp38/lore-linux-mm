Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C86576B0069
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:35:22 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id g13so81899571otd.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:35:22 -0800 (PST)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id y45si354718oty.217.2017.02.06.06.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:35:22 -0800 (PST)
Received: by mail-ot0-x241.google.com with SMTP id f9so10543238otd.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:35:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170206132410.GC10298@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org>
 <20170206124037.GA10298@dhcp22.suse.cz> <CAOaiJ-kf+1xO9R5u33-JADpNpHiyyfbq0CKY014E8L+ErKioDA@mail.gmail.com>
 <20170206132410.GC10298@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Mon, 6 Feb 2017 20:05:21 +0530
Message-ID: <CAOaiJ-ksqOr8T0KRN8eP-YmvCsXOwF6_z=gvQEtaC5mhMt7tvA@mail.gmail.com>
Subject: Re: [PATCH 2/2 RESEND] mm: vmpressure: fix sending wrong events on underflow
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Feb 6, 2017 at 6:54 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-02-17 18:39:03, vinayak menon wrote:
>> On Mon, Feb 6, 2017 at 6:10 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Mon 06-02-17 17:54:10, Vinayak Menon wrote:
>> > [...]
>> >> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> >> index 149fdf6..3281b34 100644
>> >> --- a/mm/vmpressure.c
>> >> +++ b/mm/vmpressure.c
>> >> @@ -112,8 +112,10 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>> >>                                                   unsigned long reclaimed)
>> >>  {
>> >>       unsigned long scale = scanned + reclaimed;
>> >> -     unsigned long pressure;
>> >> +     unsigned long pressure = 0;
>> >>
>> >> +     if (reclaimed >= scanned)
>> >> +             goto out;
>> >
>> > This deserves a comment IMHO. Besides that, why shouldn't we normalize
>> > the result already in vmpressure()? Please note that the tree == true
>> > path will aggregate both scanned and reclaimed and that already skews
>> > numbers.
>> Sure. Will add a comment.
>> IIUC, normalizing in vmpressure() means something like this which you
>> mentioned in one
>> of your previous emails right ?
>>
>> + if (reclaimed > scanned)
>> +          reclaimed = scanned;
>
> yes or scanned = reclaimed.
>
>> Considering a scan window of 512 pages and without above piece of
>> code, if the first scanning is of a THP page
>> Scan=1,Reclaimed=512
>> If the next 511 scans results in 0 reclaimed pages
>> total_scan=512,Reclaimed=512 => vmpressure 0
>
> I am not sure I understand. What do you mean by next scans? We do not
> modify counters outside of vmpressure? If you mean next iteration of
> shrink_node's loop then this changeshouldn't make a difference, no?
>
By scan I meant pages scanned by shrink_node_memcg/shrink_list which is passed
as nr_scanned to vmpressure.
The calculation of pressure for tree is done at the end of
vmpressure_win and it is that
calculation which underflows. With this patch we want only the
underflow to be avoided. But
if we make (reclaimed = scanned) in vmpressure(), we change the
vmpressure value even
when there is no underflow right ?
Rewriting the above e.g again.
First call to vmpressure with nr_scanned=1 and nr_reclaimed=512 (THP)
Second call to vmpressure with nr_scanned=511 and nr_reclaimed=0
In the second call vmpr->tree_scanned becomes equal to vmpressure_win
and the work
is scheduled and it will calculate the vmpressure as 0 because
tree_reclaimed = 512

Similarly, if scanned is made equal to reclaimed in vmpressure()
itself as you had suggested,
First call to vmpressure with nr_scanned=1 and nr_reclaimed=512 (THP)
And in vmpressure, we make nr_scanned=1 and nr_reclaimed=1
Second call to vmpressure with nr_scanned=511 and nr_reclaimed=0
In the second call vmpr->tree_scanned becomes equal to vmpressure_win
and the work
is scheduled and it will calculate the vmpressure as critical, because
tree_reclaimed = 1

So it makes a difference, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
