Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 267566B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 03:05:11 -0400 (EDT)
Received: by mail-ob0-f195.google.com with SMTP id eh20so1962363obb.2
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 00:05:10 -0700 (PDT)
Message-ID: <51EE2B16.3020605@gmail.com>
Date: Tue, 23 Jul 2013 15:04:54 +0800
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugepage: allow parallelization of the hugepage fault
 path
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net> <alpine.LNX.2.00.1307121729590.3899@eggly.anvils> <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net> <20130715072432.GA28053@voom.fritz.box> <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org> <1374090625.15271.2.camel@buesod1.americas.hpqcorp.net> <20130718090719.GB9761@lge.com>
In-Reply-To: <20130718090719.GB9761@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Andrew Morton <akpm@linux-foundation.org>, David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>

On 07/18/2013 05:07 PM, Joonsoo Kim wrote:
> On Wed, Jul 17, 2013 at 12:50:25PM -0700, Davidlohr Bueso wrote:
>
>> From: Davidlohr Bueso <davidlohr.bueso@hp.com>
>>
>> - Cleaned up and forward ported to Linus' latest.
>> - Cache aligned mutexes.
>> - Keep non SMP systems using a single mutex.
>>
>> It was found that this mutex can become quite contended
>> during the early phases of large databases which make use of huge pages - for instance
>> startup and initial runs. One clear example is a 1.5Gb Oracle database, where lockstat
>> reports that this mutex can be one of the top 5 most contended locks in the kernel during
>> the first few minutes:
>>
>>      	     hugetlb_instantiation_mutex:   10678     10678
>>               ---------------------------
>>               hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
>>               ---------------------------
>>               hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
>>
>> contentions:          10678
>> acquisitions:         99476
>> waittime-total: 76888911.01 us
> Hello,
> I have a question :)
>
> So, each contention takes 7.6 ms in your result.
> Do you map this area with VM_NORESERVE?
> If we map with VM_RESERVE, when page fault, we just dequeue a huge page from a queue and clear
> a page and then map it to a page table. So I guess, it shouldn't take so long.

I don't think there is clear page operation after dequeue huge page, 
actually it's even not done during hugetlb_reserve_pages, do you know 
why? There is just clear operation in hugetlb_no_page.

> I'm wondering why it takes so long.
>
> And do you use 16KB-size hugepage?
> If so, region handling could takes some times. If you access the area as random order,
> the number of region can be more than 90000. I guess, this can be one reason to too long
> waittime.
>
> Thanks.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
