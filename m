Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 10B9F6B00A6
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 08:20:46 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id u10so5670683lbi.17
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 05:20:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com>
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
	<1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com>
Date: Mon, 8 Apr 2013 15:20:44 +0300
Message-ID: <CAOtvUMdT0-oQMTsHAjFqL6K8vrLeCcXG2hX-sShxu6GGRBPxJw@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use
 on_each_cpu() to set percpu pageset fields.
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 5, 2013 at 11:33 PM, Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
> In free_hot_cold_page(), we rely on pcp->batch remaining stable.
> Updating it without being on the cpu owning the percpu pageset
> potentially destroys this stability.
>
> Change for_each_cpu() to on_each_cpu() to fix.

Are you referring to this? -

1329         if (pcp->count >= pcp->high) {
1330                 free_pcppages_bulk(zone, pcp->batch, pcp);
1331                 pcp->count -= pcp->batch;
1332         }

I'm probably missing the obvious but won't it be simpler to do this in
 free_hot_cold_page() -

1329         if (pcp->count >= pcp->high) {
1330                  unsigned int batch = ACCESS_ONCE(pcp->batch);
1331                 free_pcppages_bulk(zone, batch, pcp);
1332                 pcp->count -= batch;
1333         }

Now the batch value used is stable and you don't have to IPI every CPU
in the system just to change a config knob...

Thanks,
Gilad



--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a situation
where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
