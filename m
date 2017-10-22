Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43D396B0038
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 23:20:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 82so14920052oid.11
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 20:20:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 2si1408693oto.537.2017.10.21.20.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 20:19:58 -0700 (PDT)
Date: Sun, 22 Oct 2017 06:19:56 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1 0/3] Virtio-balloon Improvement
Message-ID: <20171022061307-mutt-send-email-mst@kernel.org>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Fri, Oct 20, 2017 at 07:54:23PM +0800, Wei Wang wrote:
> This patch series intends to summarize the recent contributions made by
> Michael S. Tsirkin, Tetsuo Handa, Michal Hocko etc. via reporting and
> discussing the related deadlock issues on the mailinglist. Please check
> each patch for details.
> 
> >From a high-level point of view, this patch series achieves:
> 1) eliminate the deadlock issue fundamentally caused by the inability
> to run leak_balloon and fill_balloon concurrently;

We need to think about this carefully. Is it an issue that
leak can now bypass fill? It seems that we can now
try to leak a page before fill was seen by host,
but I did not look into it deeply.

I really like my patch for this better at least for
current kernel. I agree we need to work more on 2+3.

> 2) enable OOM to release more than 256 inflated pages; and

Does just this help enough? How about my patch + 2?
Tetsuo, what do you think?

> 3) stop inflating when the guest is under severe memory pressure
> (i.e. OOM).

But when do we finally inflate?  Question is how does host know it needs
to resend an interrupt, and when should it do it?


> Here is an example of the benefit brought by this patch series:
> The guest sets virtio_balloon.oom_pages=100000. When the host requests
> to inflate 7.9G of an 8G idle guest, the guest can still run normally
> since OOM can guarantee at least 100000 pages (400MB) for the guest.
> Without the above patches, the guest will kill all the killable
> processes and fall into kernel panic finally.
> 
> Wei Wang (3):
>   virtio-balloon: replace the coarse-grained balloon_lock
>   virtio-balloon: deflate up to oom_pages on OOM
>   virtio-balloon: stop inflating when OOM occurs
> 
>  drivers/virtio/virtio_balloon.c | 149 ++++++++++++++++++++++++----------------
>  1 file changed, 91 insertions(+), 58 deletions(-)
> 
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
