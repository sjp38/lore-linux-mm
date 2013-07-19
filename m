Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DB60D6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 20:19:20 -0400 (EDT)
Message-ID: <1374193152.2076.8.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] hugepage: allow parallelization of the hugepage fault
 path
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Thu, 18 Jul 2013 17:19:12 -0700
In-Reply-To: <20130718090719.GB9761@lge.com>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
	 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
	 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
	 <20130715072432.GA28053@voom.fritz.box>
	 <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
	 <1374090625.15271.2.camel@buesod1.americas.hpqcorp.net>
	 <20130718090719.GB9761@lge.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>

On Thu, 2013-07-18 at 18:07 +0900, Joonsoo Kim wrote:
> On Wed, Jul 17, 2013 at 12:50:25PM -0700, Davidlohr Bueso wrote:
> 
> > From: Davidlohr Bueso <davidlohr.bueso@hp.com>
> > 
> > - Cleaned up and forward ported to Linus' latest.
> > - Cache aligned mutexes.
> > - Keep non SMP systems using a single mutex.
> > 
> > It was found that this mutex can become quite contended
> > during the early phases of large databases which make use of huge pages - for instance
> > startup and initial runs. One clear example is a 1.5Gb Oracle database, where lockstat
> > reports that this mutex can be one of the top 5 most contended locks in the kernel during
> > the first few minutes:
> > 
> >     	     hugetlb_instantiation_mutex:   10678     10678
> >              ---------------------------
> >              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
> >              ---------------------------
> >              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
> > 
> > contentions:          10678
> > acquisitions:         99476
> > waittime-total: 76888911.01 us
> 
> Hello,
> I have a question :)
> 
> So, each contention takes 7.6 ms in your result.

Well, that's the total wait time. I can see your concern, but no, things
aren't *that* bad. The average amount of time spent waiting for the lock
would be 76888911.01/10678 = 7200us

> Do you map this area with VM_NORESERVE?
> If we map with VM_RESERVE, when page fault, we just dequeue a huge page from a queue and clear
> a page and then map it to a page table. So I guess, it shouldn't take so long.
> I'm wondering why it takes so long.
> 

I cannot really say. This is proprietary software. AFAICT if Oracle is
anything like Posgres, than probably no.


> And do you use 16KB-size hugepage?

No, 2Mb pages.

> If so, region handling could takes some times. If you access the area as random order,
> the number of region can be more than 90000. I guess, this can be one reason to too long
> waittime.
> 
> Thanks.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
