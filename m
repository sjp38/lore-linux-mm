Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE79E6B0038
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 00:19:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so69205260pgc.6
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 21:19:53 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u21si20745093pgi.398.2017.02.20.21.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 21:19:52 -0800 (PST)
Subject: Re: Query on per app memory cgroup
References: <b7ee0ad3-a580-b38a-1e90-035c77b181ea@codeaurora.org>
 <b11e01d9-7f67-5c91-c7da-e5a95996c0ec@codeaurora.org>
 <CAA_GA1eMYOPwm8iqn6QLVRvn7vFi3Ae6CbpkLU7iO=J+jE=Yiw@mail.gmail.com>
 <ed013bac-e3b9-feb1-c7ce-26c982bf04b7@codeaurora.org>
 <CAA_GA1cmDEqS7T+K0v0Qcd9ObYEU5X3wOWWNyntUj6ZdLcH-pA@mail.gmail.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <62f20b82-1221-31e1-46f4-17db98ea989a@codeaurora.org>
Date: Tue, 21 Feb 2017 10:49:46 +0530
MIME-Version: 1.0
In-Reply-To: <CAA_GA1cmDEqS7T+K0v0Qcd9ObYEU5X3wOWWNyntUj6ZdLcH-pA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, shashim@codeaurora.org


On 2/20/2017 5:59 PM, Bob Liu wrote:
> On Mon, Feb 20, 2017 at 1:22 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
>>
>> On 2/17/2017 6:47 PM, Bob Liu wrote:
>>> On Thu, Feb 9, 2017 at 7:16 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
>>>> Hi,
>>>>
>>>> We were trying to implement the per app memory cgroup that Johannes
>>>> suggested (https://lkml.org/lkml/2014/12/19/358) and later discussed during
>>>> Minchan's proposal of per process reclaim
>>>> (https://lkml.org/lkml/2016/6/13/570). The test was done on Android target
>>>> with 2GB of RAM and cgroupv1. The first test done was to just create per
>>>> app cgroups without modifying any cgroup controls. 2 kinds of tests were
>>>> done which gives similar kind of observation. One was to just open
>>>> applications in sequence and repeat this N times (20 apps, so around 20
>>>> memcgs max at a time). Another test was to create around 20 cgroups and
>>>> perform a make (not kernel, another less heavy source) in each of them.
>>>>
>>>> It is observed that because of the creation of memcgs per app, the per
>>>> memcg LRU size is so low and results in kswapd priority drop. This results
>>> How did you confirm that? Traced the get_scan_count() function?
>>> You may hack this function for more verification.
>> This was confirmed by adding some VM event counters in get_scan_count.
> Would you mind attach your modification?
> That would be helpful for people to make fix patches.

Sure. The entire set of debug changes is quite big with stuff not relevant for this issue.
Adding here only the relevant part related to priority drop. Let me know if this is not useful,
I can clean up the debug path and share it.
Note that the test is done on 4.4 kernel.
To get the number of pages chosen by get_scan_count for each LRU vm event was added
like this. Showing only a part of it.

+       if (current_is_kswapd()) {
+               switch (sc->priority) {
+                       case 0:
+                       count_vm_events(SCAN_ACTIVE_ANON0, nr[LRU_ACTIVE_ANON]);
+                       count_vm_events(SCAN_INACTIVE_ANON0, nr[LRU_INACTIVE_ANON]);
+                       count_vm_events(SCAN_ACTIVE_FILE0, nr[LRU_ACTIVE_FILE]);
+                       count_vm_events(SCAN_INACTIVE_FILE0, nr[LRU_INACTIVE_FILE]);
+                       break;
+                       case 1:
....

Similarly just after the shrink_list in shrink_lruvec

+     if ((lru == LRU_INACTIVE_ANON) && current_is_kswapd()) {
+     	count_vm_events(RECLAIM_INACTIVE_ANON, ret);
...

The results from above counters show the scanned and reclaimed at each priority and with
the per app memcg it can be seen that the scanned and reclaimed are less at lower priorities
(because of small LRU) and suddenly increases at higher priorities (because of scanning most
of the LRUs of all the memcgs).

A check like this was added in get_scan_count to get a comparative data on times we hit !scan
case.

+                       if (!scan && pass && force_scan) {
+                               count_vm_event(GSC_6);
                                scan = min(size, SWAP_CLUSTER_MAX);
+                       }
+
+                       if (!scan) {
+                               if (lru == 0)
+                                       count_vm_event(GSC_7_0);
+                               else if (lru == 1)
+                                       count_vm_event(GSC_7_1);
+                               else if (lru == 2)
+                                       count_vm_event(GSC_7_2);
+                               else if (lru == 3)
+                                       count_vm_event(GSC_7_3);
+                       }

And to get the actual scanned and reclaimed pages at each priority, events were added in shrink_zone
after the shrink_lruvec call

+if (current_is_kswapd()) {
+       switch (sc->priority) {
+               case 0:
+                       count_vm_events(KSWAPD_S_AT_0, sc->nr_scanned - nr_scanned);
+                       count_vm_events(KSWAPD_R_AT_0, sc->nr_reclaimed - nr_reclaimed);
+                       break;
+               case 1:
+                       count_vm_events(KSWAPD_S_AT_1, sc->nr_scanned - nr_scanned);
+                       count_vm_events(KSWAPD_R_AT_1, sc->nr_reclaimed - nr_reclaimed);
+                       break;
...

The below count was added to find the number of times kswapd_shrink_zone had run at different priorities.
+       switch (sc->priority) {
+               case 0:
+                       count_vm_event(KSWAPD_AT_0);
+                       break;
+               case 1:
...

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
