Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B41526B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 05:19:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 67so95919524ite.6
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:19:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 126si6690528ity.6.2017.04.26.02.19.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 02:19:10 -0700 (PDT)
Date: Wed, 26 Apr 2017 11:19:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170426091906.GB12504@dhcp22.suse.cz>
References: <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
 <20170421043826.GC13966@js1304-desktop>
 <20170421071616.GC14154@dhcp22.suse.cz>
 <20170424014441.GA29305@js1304-desktop>
 <20170424075312.GA1739@dhcp22.suse.cz>
 <20170425025043.GA32583@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425025043.GA32583@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 25-04-17 11:50:45, Joonsoo Kim wrote:
> On Mon, Apr 24, 2017 at 09:53:12AM +0200, Michal Hocko wrote:
> > On Mon 24-04-17 10:44:43, Joonsoo Kim wrote:
> > > On Fri, Apr 21, 2017 at 09:16:16AM +0200, Michal Hocko wrote:
> > > > On Fri 21-04-17 13:38:28, Joonsoo Kim wrote:
> > > > > On Thu, Apr 20, 2017 at 09:28:20AM +0200, Michal Hocko wrote:
> > > > > > On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> > > > > > > On Mon, Apr 17, 2017 at 10:15:15AM +0200, Michal Hocko wrote:
> > > > > > [...]
> > > > > > > > Which pfn walkers you have in mind?
> > > > > > > 
> > > > > > > For example, kpagecount_read() in fs/proc/page.c. I searched it by
> > > > > > > using pfn_valid().
> > > > > > 
> > > > > > Yeah, I've checked that one and in fact this is a good example of the
> > > > > > case where you do not really care about holes. It just checks the page
> > > > > > count which is a valid information under any circumstances.
> > > > > 
> > > > > I don't think so. First, it checks the page *map* count. Is it still valid
> > > > > even if PageReserved() is set?
> > > > 
> > > > I do not know about any user which would manipulate page map count for
> > > > referenced pages. The core MM code doesn't.
> > > 
> > > That's weird that we can get *map* count without PageReserved() check,
> > > but we cannot get zone information.
> > > Zone information is more static information than map count.
> > 
> > As I've already pointed out the rework of the hotplug code is mainly
> > about postponing the zone initialization from the physical hot add to
> > the logical onlining. The zone is really not clear until that moment.
> >  
> > > It should be defined/documented in this time that what information in
> > > the struct page is valid even if PageReserved() is set. And then, we
> > > need to fix all the things based on this design decision.
> > 
> > Where would you suggest documenting this? We do have
> > Documentation/memory-hotplug.txt but it is not really specific about
> > struct page.
> 
> pfn_valid() in include/linux/mmzone.h looks proper place.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c412e6a3a1e9..443258fcac93 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1288,10 +1288,14 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
 /*
  * pfn_valid() is meant to be able to tell if a given PFN has valid memmap
- * associated with it or not. In FLATMEM, it is expected that holes always
- * have valid memmap as long as there is valid PFNs either side of the hole.
- * In SPARSEMEM, it is assumed that a valid section has a memmap for the
- * entire section.
+ * associated with it or not. This means that a struct page exists for this
+ * pfn. The caller cannot assume the page is fully initialized though.
+ * pfn_to_online_page() should be used to make sure the struct page is fully
+ * initialized.
+ *
+ * In FLATMEM, it is expected that holes always have valid memmap as long as
+ * there is valid PFNs either side of the hole. In SPARSEMEM, it is assumed
+ * that a valid section has a memmap for the entire section.
  *
  * However, an ARM, and maybe other embedded architectures in the future
  * free memmap backing holes to save memory on the assumption the memmap is

> > [...]
> > 
> > > > You are trying to change a semantic of something that has a well defined
> > > > meaning. I disagree that we should change it. It might sound like a
> > > > simpler thing to do because pfn walkers will have to be checked but what
> > > > you are proposing is conflating two different things together.
> > > 
> > > I don't think that *I* try to change the semantic of pfn_valid().
> > > It would be original semantic of pfn_valid().
> > > 
> > > "If pfn_valid() returns true, we can get proper struct page and the
> > > zone information,"
> > 
> > I do not see any guarantee about the zone information anywhere. In fact
> > this is not true with the original implementation as I've tried to
> > explain already. We do have new pages associated with a zone but that
> > association might change during the online phase. So you cannot really
> > rely on that information until the page is online. There is no real
> > change in that regards after my rework.
> 
> I know that what you did doesn't change thing much. What I try to say
> is that previous implementation related to pfn_valid() in hotplug is
> wrong. Please do not assume that hotplug implementation is correct and
> other pfn_valid() users are incorrect. There is no design document so
> I'm not sure which one is correct but assumption that pfn_valid() user
> can access whole the struct page information makes much sense to me.

Not really. E.g. ZONE_DEVICE pages are never online AFAIK. I believe we
still need pfn_valid to work for those pfns. Really, pfn_valid has a
different meaning than you would like it to have. Who knows how many
others like that are lurking there. I feel much more comfortable to go
and hunt already broken code and fix it rathert than break something
unexpectedly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
