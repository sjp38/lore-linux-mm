Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 565B66B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 00:11:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i196so9197416pgd.2
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 21:11:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h19si3037065pgn.674.2017.10.21.21.11.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Oct 2017 21:11:22 -0700 (PDT)
Subject: Re: [PATCH v1 2/3] virtio-balloon: deflate up to oom_pages on OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
	<1508500466-21165-3-git-send-email-wei.w.wang@intel.com>
	<20171022062119-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171022062119-mutt-send-email-mst@kernel.org>
Message-Id: <201710221311.FFI17148.VStOJQLHOFFMOF@I-love.SAKURA.ne.jp>
Date: Sun, 22 Oct 2017 13:11:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, wei.w.wang@intel.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

Michael S. Tsirkin wrote:
> On Fri, Oct 20, 2017 at 07:54:25PM +0800, Wei Wang wrote:
> > The current implementation only deflates 256 pages even when a user
> > specifies more than that via the oom_pages module param. This patch
> > enables the deflating of up to oom_pages pages if there are enough
> > inflated pages.
> 
> This seems reasonable. Does this by itself help?

At least

> > -	num_freed_pages = leak_balloon(vb, oom_pages);
> > +
> > +	/* Don't deflate more than the number of inflated pages */
> > +	while (npages && atomic64_read(&vb->num_pages))
> > +		npages -= leak_balloon(vb, npages);

don't we need to abort if leak_balloon() returned 0 for some reason?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
