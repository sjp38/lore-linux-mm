Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 108B96B0283
	for <linux-mm@kvack.org>; Mon, 25 May 2015 00:02:44 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so62402683pab.1
        for <linux-mm@kvack.org>; Sun, 24 May 2015 21:02:43 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id cf17si14312440pdb.113.2015.05.24.21.02.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 21:02:43 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so19519823pdb.1
        for <linux-mm@kvack.org>; Sun, 24 May 2015 21:02:43 -0700 (PDT)
Date: Mon, 25 May 2015 13:03:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150525040304.GA555@swordfish>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
 <20150522131447.GA14922@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522131447.GA14922@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Marcin Jabrzyk <m.jabrzyk@samsung.com>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

On (05/22/15 22:14), Minchan Kim wrote:
> > > >second, there is not much value in exposing zcomp internals,
> > > >especially when the result is just another line in dmesg output.
> > > 
> > > From the other hand, the only valid values that can be written are
> > > in 'comp_algorithm'.
> > > So when writing other one, returning -EINVAL seems to be reasonable.
> > > The user would get immediately information that he can't do that,
> > > now the information can be very deferred in time.
> > 
> > it's not.
> > the error message appears in syslog right before we return -EINVAL
> > back to user.
> 
> Although Marcin's description is rather misleading, I like the patch.
> Every admin doesn't watch dmesg output. Even people could change loglevel
> simply so KERN_INFO would be void in that case.

there is no -EUNSPPORTEDCOMPRESSIONALGORITHM errno that we can return
back to userspace and expect it [userspace] to magically transform it
into a meaningful error message; users must check syslog/dmesg. that's
the way it is.

# echo LZ4 > /sys/block/zram0/comp_algorithm
# -bash: echo: write error: Device or resource busy

- hm.... why?
- well, that's why:
dmesg
[  249.745335] zram: Can't change algorithm for initialized device


> Instant error propagation is more strighforward for user point of view
> rather than delaying with depending on another event.

I'd rather just add two lines of code, w/o making zcomp internals visible.

it seems that we are trying to solve a problem that does not really
exist. I think what we really need to do is to rewrite zram documentation
and to propose zramctl usage as a recommended way of managing zram devices.
zramctl does not do `typo' errors. if somebody wants to configure zram
manually, then he simply must check syslog. it's simple.

---

 drivers/block/zram/zcomp.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/block/zram/zcomp.c b/drivers/block/zram/zcomp.c
index a1a8b8e..d96da53 100644
--- a/drivers/block/zram/zcomp.c
+++ b/drivers/block/zram/zcomp.c
@@ -54,11 +54,16 @@ static struct zcomp_backend *backends[] = {
 static struct zcomp_backend *find_backend(const char *compress)
 {
 	int i = 0;
+
 	while (backends[i]) {
 		if (sysfs_streq(compress, backends[i]->name))
 			break;
 		i++;
 	}
+
+	if (!backends[i])
+		pr_err("Error: unknown compression algorithm: %s\n",
+				compress);
 	return backends[i];
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
