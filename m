Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21AC06B0007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 21:06:53 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q19-v6so10994167plr.22
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 18:06:53 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e90-v6si15617978pfb.185.2018.06.18.18.06.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 18:06:51 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v33 2/4] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_HINT
Date: Tue, 19 Jun 2018 01:06:48 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396AA10C@shsmsx102.ccr.corp.intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-3-git-send-email-wei.w.wang@intel.com>
 <20180615144000-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396A3D04@shsmsx102.ccr.corp.intel.com>
 <20180615171635-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396A5CB0@shsmsx102.ccr.corp.intel.com>
 <20180618051637-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180618051637-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Monday, June 18, 2018 10:29 AM, Michael S. Tsirkin wrote:
> On Sat, Jun 16, 2018 at 01:09:44AM +0000, Wang, Wei W wrote:
> > Not necessarily, I think. We have min(4m_page_blocks / 512, 1024) above=
,
> so the maximum memory that can be reported is 2TB. For larger guests, e.g=
.
> 4TB, the optimization can still offer 2TB free memory (better than no
> optimization).
>=20
> Maybe it's better, maybe it isn't. It certainly muddies the waters even m=
ore.
> I'd rather we had a better plan. From that POV I like what Matthew Wilcox
> suggested for this which is to steal the necessary # of entries off the l=
ist.

Actually what Matthew suggested doesn't make a difference here. That method=
 always steal the first free page blocks, and sure can be changed to take m=
ore. But all these can be achieved via kmalloc by the caller which is more =
prudent and makes the code more straightforward. I think we don't need to t=
ake that risk unless the MM folks strongly endorse that approach.

The max size of the kmalloc-ed memory is 4MB, which gives us the limitation=
 that the max free memory to report is 2TB. Back to the motivation of this =
work, the cloud guys want to use this optimization to accelerate their gues=
t live migration. 2TB guests are not common in today's clouds. When huge gu=
ests become common in the future, we can easily tweak this API to fill hint=
s into scattered buffer (e.g. several 4MB arrays passed to this API) instea=
d of one as in this version.

This limitation doesn't cause any issue from functionality perspective. For=
 the extreme case like a 100TB guest live migration which is theoretically =
possible today, this optimization helps skip 2TB of its free memory. This r=
esult is that it may reduce only 2% live migration time, but still better t=
han not skipping the 2TB (if not using the feature).

So, for the first release of this feature, I think it is better to have the=
 simpler and more straightforward solution as we have now, and clearly docu=
ment why it can report up to 2TB free memory.


=20
> If that doesn't fly, we can allocate out of the loop and just retry with =
more
> pages.
>=20
> > On the other hand, large guests being large mostly because the guests n=
eed
> to use large memory. In that case, they usually won't have that much free
> memory to report.
>=20
> And following this logic small guests don't have a lot of memory to repor=
t at
> all.
> Could you remind me why are we considering this optimization then?

If there is a 3TB guest, it is 3TB not 2TB mostly because it would need to =
use e.g. 2.5TB memory from time to time. In the worst case, it only has 0.5=
TB free memory to report, but reporting 0.5TB with this optimization is bet=
ter than no optimization. (and the current 2TB limitation isn't a limitatio=
n for the 3TB guest in this case)

Best,
Wei
