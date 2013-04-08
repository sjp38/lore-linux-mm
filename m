Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 13A246B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:17:00 -0400 (EDT)
Received: by mail-qe0-f46.google.com with SMTP id nd7so1251707qeb.5
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 12:16:59 -0700 (PDT)
Message-ID: <516317A9.7040208@gmail.com>
Date: Mon, 08 Apr 2013 15:16:57 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use on_each_cpu()
 to set percpu pageset fields.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com> <CAOtvUMdT0-oQMTsHAjFqL6K8vrLeCcXG2hX-sShxu6GGRBPxJw@mail.gmail.com>
In-Reply-To: <CAOtvUMdT0-oQMTsHAjFqL6K8vrLeCcXG2hX-sShxu6GGRBPxJw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kosaki.motohiro@gmail.com

(4/8/13 8:20 AM), Gilad Ben-Yossef wrote:
> On Fri, Apr 5, 2013 at 11:33 PM, Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
>> In free_hot_cold_page(), we rely on pcp->batch remaining stable.
>> Updating it without being on the cpu owning the percpu pageset
>> potentially destroys this stability.
>>
>> Change for_each_cpu() to on_each_cpu() to fix.
> 
> Are you referring to this? -
> 
> 1329         if (pcp->count >= pcp->high) {
> 1330                 free_pcppages_bulk(zone, pcp->batch, pcp);
> 1331                 pcp->count -= pcp->batch;
> 1332         }
> 
> I'm probably missing the obvious but won't it be simpler to do this in
>  free_hot_cold_page() -
> 
> 1329         if (pcp->count >= pcp->high) {
> 1330                  unsigned int batch = ACCESS_ONCE(pcp->batch);
> 1331                 free_pcppages_bulk(zone, batch, pcp);
> 1332                 pcp->count -= batch;
> 1333         }
> 
> Now the batch value used is stable and you don't have to IPI every CPU
> in the system just to change a config knob...

OK, right. Your approach is much better.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
