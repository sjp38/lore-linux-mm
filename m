Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 466AB828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 16:40:23 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id 6so312263279qgy.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 13:40:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g44si104425284qge.3.2016.01.10.13.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 13:40:22 -0800 (PST)
Date: Sun, 10 Jan 2016 23:40:17 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_balloon: fix race between migration and
 ballooning
Message-ID: <20160110233310-mutt-send-email-mst@redhat.com>
References: <1451259313-26353-1-git-send-email-minchan@kernel.org>
 <1451259313-26353-2-git-send-email-minchan@kernel.org>
 <20160101102756-mutt-send-email-mst@redhat.com>
 <20160104002747.GA31090@blaptop.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104002747.GA31090@blaptop.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rafael Aquini <aquini@redhat.com>, stable@vger.kernel.org

On Mon, Jan 04, 2016 at 09:27:47AM +0900, Minchan Kim wrote:
> > I think this will cause deadlocks.
> > 
> > pages_lock now nests within page lock, balloon_page_putback
> > nests them in the reverse order.
> 
> In balloon_page_dequeu, we used trylock so I don't think it's
> deadlock.

I went over this again and I don't see the issue anymore.
I think I was mistaken, so I dropped my patch and picked
up yours. Sorry about the noise.


> > 
> > Also, there's another issue there I think: after isolation page could
> > also get freed before we try to lock it.
> 
> If a page was isolated, the page shouldn't stay b_dev_info->pages
> list so balloon_page_dequeue cannot see the page.
> Am I missing something?

I mean without locks, as it is now. With either your or my patch in
place, it's fine.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
