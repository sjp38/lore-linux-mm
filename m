Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id F38E26B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 04:50:35 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so8273955igd.14
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 01:50:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e16si408520igz.21.2014.11.27.01.50.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Nov 2014 01:50:35 -0800 (PST)
Date: Thu, 27 Nov 2014 01:50:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc patch] mm: protect set_page_dirty() from ongoing
 truncation
Message-Id: <20141127015054.6368af49.akpm@linux-foundation.org>
In-Reply-To: <20141127094006.GC30152@quack.suse.cz>
References: <1416944921-14164-1-git-send-email-hannes@cmpxchg.org>
	<20141126140006.d6f71f447b69cd4fadc42c26@linux-foundation.org>
	<20141127094006.GC30152@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 27 Nov 2014 10:40:06 +0100 Jan Kara <jack@suse.cz> wrote:

> > so we no longer require that the address_space be stabilized after
> > lock_page().  Of course something needs to protect the bdi and I'm not
> > sure what that is, but we're talking about umount and that quiesces and
> > evicts lots of things before proceeding, so surely there's something in
> > there which will save us ;)
>   In do_wp_page() the process doing the fault and ending in
> balance_dirty_pages() has to have the page mapped, thus it has to have the
> file open => no umount.

Actually, umount isn't enough to kill the backing_dev_info.  It's an
attribute of the device itself (for blockdevs it's a field in
request_queue) so I assume it will be stable until device hot-unplug,
losetup -d, rmmod, etc.  If the backing_dev can go away in the middle
of a pagefault against that device then we have bigger problems ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
