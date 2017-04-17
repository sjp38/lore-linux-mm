Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6218B6B0390
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 01:47:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q25so81291625pfg.6
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 22:47:29 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id 6si9986603pfb.167.2017.04.16.22.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Apr 2017 22:47:28 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id z127so3678372pgb.1
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 22:47:28 -0700 (PDT)
Date: Mon, 17 Apr 2017 14:47:20 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: your mail
Message-ID: <20170417054718.GD1351@js1304-desktop>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170415121734.6692-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Sat, Apr 15, 2017 at 02:17:31PM +0200, Michal Hocko wrote:
> Hi,
> here I 3 more preparatory patches which I meant to send on Thursday but
> forgot... After more thinking about pfn walkers I have realized that
> the current code doesn't check offline holes in zones. From a quick
> review that doesn't seem to be a problem currently. Pfn walkers can race
> with memory offlining and with the original hotplug impementation those
> offline pages can change the zone but I wasn't able to find any serious
> problem other than small confusion. The new hotplug code, will not have
> any valid zone, though so those code paths should check PageReserved
> to rule offline holes. I hope I have addressed all of them in these 3
> patches. I would appreciate if Vlastimil and Jonsoo double check after
> me.

Hello, Michal.

s/Jonsoo/Joonsoo. :)

I'm not sure that it's a good idea to add PageResereved() check in pfn
walkers. First, this makes struct page validity check as two steps,
pfn_valid() and then PageResereved(). If we should not use struct page
in this case, it's better to pfn_valid() returns false rather than
adding a separate check. Anyway, we need to fix more places (all pfn
walker?) if we want to check validity by two steps.

The other problem I found is that your change will makes some
contiguous zones to be considered as non-contiguous. Memory allocated
by memblock API is also marked as PageResereved. If we consider this as
a hole, we will set such a zone as non-contiguous.

And, I guess that it's not enough to check PageResereved() in
pageblock_pfn_to_page() in order to skip these pages in compaction. If
holes are in the middle of the pageblock, pageblock_pfn_to_page()
cannot catch it and compaction will use struct page for this hole.

Therefore, I think that making pfn_valid() return false for not
onlined memory is a better solution for this problem. I don't know the
implementation detail for hotplug and I don't see your recent change
but we may defer memmap initialization until the zone is determined.
It will make pfn_valid() return false for un-initialized range.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
