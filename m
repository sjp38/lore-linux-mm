Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 201676B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 13:52:34 -0500 (EST)
Received: by eekc41 with SMTP id c41so17036088eek.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 10:52:32 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 01/11] mm: page_alloc: set_migratetype_isolate: drain PCP
 prior to isolating
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
 <CAOtvUMeAVgDwRNsDTcG07ChYnAuNgNJjQ+sKALJ79=Ezikos-A@mail.gmail.com>
 <op.v7ew5cvg3l0zgt@mpn-glaptop>
 <CAOtvUMfKDiLwxaH5FCS6wC=CgPiDz3ZAPbVv4b=Oxdx4ZpMCYw@mail.gmail.com>
Date: Sun, 01 Jan 2012 19:52:16 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7e5demq3l0zgt@mpn-glaptop>
In-Reply-To: <CAOtvUMfKDiLwxaH5FCS6wC=CgPiDz3ZAPbVv4b=Oxdx4ZpMCYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Sun, 01 Jan 2012 17:06:53 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:

> 2012/1/1 Michal Nazarewicz <mina86@mina86.com>:
>> Looks interesting, I'm not entirely sure why it does not end up a rac=
e
>> condition, but in case of __zone_drain_all_pages() we already hold

> If a page is in the PCP list when we check, you'll send the IPI and al=
l is well.
>
> If it isn't when we check and gets added later you could just the same=
 have
> situation where we send the IPI, try to do try an empty PCP list and t=
hen
> the page gets added. So we are not adding a race condition that is not=
 there
> already :-)

Right, makes sense.

>> zone->lock, so my fears are somehow gone..  I'll give it a try, and p=
repare
>> a patch for __zone_drain_all_pages().

> I plan to send V5 of the IPI noise patch after some testing. It has a =
new
> version of the drain_all_pages, with no allocation in the reclaim path=

> and no locking. You might want to wait till that one is out to base on=
 it.

This shouldn't be a problem for my case as set_migratetype_isolate() is =
hardly
ever called in reclaim path. :)

The change so far seems rather obvious:

  mm/page_alloc.c |   14 +++++++++++++-
  1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 424d36a..eaa686b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1181,7 +1181,19 @@ static void __zone_drain_local_pages(void *arg)
   */
  static void __zone_drain_all_pages(struct zone *zone)
  {
-	on_each_cpu(__zone_drain_local_pages, zone, 1);
+	struct per_cpu_pageset *pcp;
+	cpumask_var_t cpus;
+	int cpu;
+
+	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC | __GFP_NOWARN))) {
+		for_each_online_cpu(cpu)
+			if (per_cpu_ptr(zone->pageset, cpu)->pcp.count)
+				cpumask_set_cpu(cpu, cpus);
+		on_each_cpu_mask(cpus, __zone_drain_local_pages, zone, 1);
+		free_cpumask_var(cpus);
+	} else {
+		on_each_cpu(__zone_drain_local_pages, zone, 1);
+	}
  }

  #ifdef CONFIG_HIBERNATION

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
