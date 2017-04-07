Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84DBE6B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 20:45:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v4so54350820pgc.20
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 17:45:25 -0700 (PDT)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id u124si3173359pgb.168.2017.04.06.17.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 17:45:24 -0700 (PDT)
Received: by mail-pg0-x229.google.com with SMTP id g2so49539407pge.3
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 17:45:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170306103032.2540-3-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org> <20170306103032.2540-3-mhocko@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 6 Apr 2017 17:45:23 -0700
Message-ID: <CALvZod5hBHjKfumAFmRoS9Wbg06+KTg33wSD=8Ksdrq=Vm1OgA@mail.gmail.com>
Subject: Re: [PATCH 2/9] mm: support __GFP_REPEAT in kvmalloc_node for >32kB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Mar 6, 2017 at 2:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> vhost code uses __GFP_REPEAT when allocating vhost_virtqueue resp.
> vhost_vsock because it would really like to prefer kmalloc to the
> vmalloc fallback - see 23cc5a991c7a ("vhost-net: extend device
> allocation to vmalloc") for more context. Michael Tsirkin has also
> noted:
> "
> __GFP_REPEAT overhead is during allocation time.  Using vmalloc means all
> accesses are slowed down.  Allocation is not on data path, accesses are.
> "
>
> The similar applies to other vhost_kvzalloc users.
>
> Let's teach kvmalloc_node to handle __GFP_REPEAT properly. There are two
> things to be careful about. First we should prevent from the OOM killer
> and so have to involve __GFP_NORETRY by default and secondly override
> __GFP_REPEAT for !costly order requests as the __GFP_REPEAT is ignored
> for !costly orders.
>
> Supporting __GFP_REPEAT like semantic for !costly request is possible
> it would require changes in the page allocator. This is out of scope of
> this patch.
>
> This patch shouldn't introduce any functional change.
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/vhost/net.c   |  9 +++------
>  drivers/vhost/vhost.c | 15 +++------------
>  drivers/vhost/vsock.c |  9 +++------
>  mm/util.c             | 20 ++++++++++++++++----
>  4 files changed, 25 insertions(+), 28 deletions(-)
>

There is a kzalloc/vzalloc call in
drivers/vhost/scsi.c:vhost_scsi_open() which is not converted to
kvzalloc(). Was that intentional?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
