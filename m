Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4EF16B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 09:38:44 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b15so5608060qkg.23
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 06:38:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z33si535158qtd.357.2017.10.13.06.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 06:38:44 -0700 (PDT)
Date: Fri, 13 Oct 2017 16:38:34 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v16 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
Message-ID: <20171013163503-mutt-send-email-mst@kernel.org>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-6-git-send-email-wei.w.wang@intel.com>
 <20171001060305-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73932025A@shsmsx102.ccr.corp.intel.com>
 <20171010180636-mutt-send-email-mst@kernel.org>
 <59DDB428.4020208@intel.com>
 <20171011161912-mutt-send-email-mst@kernel.org>
 <59DEE790.5040809@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59DEE790.5040809@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Thu, Oct 12, 2017 at 11:54:56AM +0800, Wei Wang wrote:
> > But I think flushing is very fragile. You will easily run into races
> > if one of the actors gets out of sync and keeps adding data.
> > I think adding an ID in the free vq stream is a more robust
> > approach.
> > 
> 
> Adding ID to the free vq would need the device to distinguish whether it
> receives an ID or a free page hint,

Not really.  It's pretty simple: a 64 bit buffer is an ID. A 4K and bigger one
is a page.


> so an extra protocol is needed for the two sides to talk. Currently, we
> directly assign the free page
> address to desc->addr. With ID support, we would need to first allocate
> buffer for the protocol header,
> and add the free page address to the header, then desc->addr = &header.


I do not think you should add ID on each page. What would be the point?
Add it each time you detect a new start command.

> How about putting the ID to the command path? This would avoid the above
> trouble.
> 
> For example, using the 32-bit config registers:
> first 16-bit: Command field
> send 16-bit: ID field
> 
> Then, the working flow would look like this:
> 
> 1) Host writes "Start, 1" to the Host2Guest register and notify;
> 
> 2) Guest reads Host2Guest register, and ACKs by writing "Start, 1" to
> Guest2Host register;
> 
> 3) Guest starts report free pages;
> 
> 4) Each time when the host receives a free page hint from the free_page_vq,
> it compares the ID fields of
> the Host2Guest and Guest2Host register. If matching, then filter out the
> free page from the migration dirty bitmap,
> otherwise, simply push back without doing the filtering.
> 
> 
> Best,
> Wei


All fine but config and vq ops are asynchronous. Host has no idea when
were entries added to vq. So the ID sent to host needs to be through vq.
And I would make it a 64 or at least 32 bit ID, not a 16 bit one,
to avoid wrap-around.
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
