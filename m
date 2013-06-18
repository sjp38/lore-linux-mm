Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7A4326B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 13:21:34 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bi5so4234291pad.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 10:21:33 -0700 (PDT)
Date: Tue, 18 Jun 2013 10:21:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130618172129.GH2767@htj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130618020357.GZ32663@mtj.dyndns.org>
 <51BFF464.809@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51BFF464.809@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hey, Tang.

On Tue, Jun 18, 2013 at 01:47:16PM +0800, Tang Chen wrote:
> [approach]
> Parse SRAT earlier before memblock starts to work, because there is a
> bit in SRAT specifying which memory is hotpluggable.
> 
> I'm not saying this is the best approach. I can also see that this
> patch-set touches a lot of boot code. But i think parsing SRAT earlier
> is reasonable because this is the only way for now to know which memory
> is hotpluggable from firmware.

Touching a lot of code is not a problem but it feels like it's trying
to boot strap itself while walking and achieves that by carefully
sequencing all operations which may allocate from memblock before NUMA
info is available without any way to enforce or verify that.

> >Can't you just move memblock arrays after NUMA init is complete?
> >That'd be a lot simpler and way more robust than the proposed changes,
> >no?
> 
> Sorry, I don't quite understand the approach you are suggesting. If we
> move memblock arrays, we need to update all the pointers pointing to
> the moved memory. How can we do this ?

So, there are two things involved here - memblock itself and consumers
of memblock, right?  I get that the latter shouldn't allocate memory
from memblock before NUMA info is entered into memblock, so please
reorder as necessary *and* make sure memblock complains if something
violates that.  Temporary memory areas which are return are fine.
Just complain if there are memory regions remaining which are
allocated before NUMA info is available after boot is complete.  No
need to make booting more painful than it currently is.

As for memblock itself, there's no need to walk carefully around it.
Just let it do its thing and implement
memblock_relocate_to_numa_node_0() or whatever after NUMA information
is available.  memblock already does relocate itself whenever it's
expanding the arrays anyway, so implementation should be trivial.

Maybe I'm missing something but having a working memory allocator as
soon as possible is *way* less painful than trying to bootstrap around
it.  Allow boot path to allocate memory areas from memblock as soon as
possible but just ensure that none of the ones which may violate the
hotplug requirements is remaining once boot is complete.  Temporaray
regions won't matter then and the few which need persistent areas can
either be reordered to happen after NUMA init or they can allocate a
new area and move to there after NUMA info is available.  Let's please
minimize this walking-and-trying-to-tie-shoestrings-at-the-same-time
thing.  It's painful and extremely fragile.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
