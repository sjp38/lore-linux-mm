Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF5586B03A7
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 03:40:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 34so9327839wrb.20
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 00:40:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si5191310wrc.328.2017.04.07.00.40.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 00:40:03 -0700 (PDT)
Date: Fri, 7 Apr 2017 09:40:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/9] mm: support __GFP_REPEAT in kvmalloc_node for >32kB
Message-ID: <20170407074001.GB16413@dhcp22.suse.cz>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103032.2540-3-mhocko@kernel.org>
 <CALvZod5hBHjKfumAFmRoS9Wbg06+KTg33wSD=8Ksdrq=Vm1OgA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5hBHjKfumAFmRoS9Wbg06+KTg33wSD=8Ksdrq=Vm1OgA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu 06-04-17 17:45:23, Shakeel Butt wrote:
> On Mon, Mar 6, 2017 at 2:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > vhost code uses __GFP_REPEAT when allocating vhost_virtqueue resp.
> > vhost_vsock because it would really like to prefer kmalloc to the
> > vmalloc fallback - see 23cc5a991c7a ("vhost-net: extend device
> > allocation to vmalloc") for more context. Michael Tsirkin has also
> > noted:
> > "
> > __GFP_REPEAT overhead is during allocation time.  Using vmalloc means all
> > accesses are slowed down.  Allocation is not on data path, accesses are.
> > "
> >
> > The similar applies to other vhost_kvzalloc users.
> >
> > Let's teach kvmalloc_node to handle __GFP_REPEAT properly. There are two
> > things to be careful about. First we should prevent from the OOM killer
> > and so have to involve __GFP_NORETRY by default and secondly override
> > __GFP_REPEAT for !costly order requests as the __GFP_REPEAT is ignored
> > for !costly orders.
> >
> > Supporting __GFP_REPEAT like semantic for !costly request is possible
> > it would require changes in the page allocator. This is out of scope of
> > this patch.
> >
> > This patch shouldn't introduce any functional change.
> >
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  drivers/vhost/net.c   |  9 +++------
> >  drivers/vhost/vhost.c | 15 +++------------
> >  drivers/vhost/vsock.c |  9 +++------
> >  mm/util.c             | 20 ++++++++++++++++----
> >  4 files changed, 25 insertions(+), 28 deletions(-)
> >
> 
> There is a kzalloc/vzalloc call in
> drivers/vhost/scsi.c:vhost_scsi_open() which is not converted to
> kvzalloc(). Was that intentional?

No, an omission, I suspect. Feel free to send a follow up patch. I
suspect there will be more of those...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
