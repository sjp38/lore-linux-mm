Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 540F96B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:24:43 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id uy5so12753685obc.11
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:24:43 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d3si6492826oew.17.2014.08.27.03.24.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 03:24:42 -0700 (PDT)
Date: Wed, 27 Aug 2014 13:24:39 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [next:master 2131/2422] kernel/sys.c:1888 prctl_set_mm_map()
 warn: maybe return -EFAULT instead of the bytes remaining?
Message-ID: <20140827102439.GO5100@mwanda>
References: <20140827095613.GN5100@mwanda>
 <20140827100909.GA8692@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827100909.GA8692@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: kbuild@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 27, 2014 at 02:09:09PM +0400, Cyrill Gorcunov wrote:

> Not really sure I'm follow. @error is error code either 0 (on success) or
> any other if some problem happened.


It's complaining about this:

kernel/sys.c
  1846          if (prctl_map.auxv_size) {
  1847                  up_read(&mm->mmap_sem);
  1848                  memset(user_auxv, 0, sizeof(user_auxv));
  1849                  error = copy_from_user(user_auxv,
  1850                                         (const void __user *)prctl_map.auxv,
  1851                                         prctl_map.auxv_size);
  1852                  down_read(&mm->mmap_sem);
  1853                  if (error)
  1854                          goto out;
  1855          }

It should say:

			if (error) {
				error = -EFAULT;
				goto out;
			}

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
