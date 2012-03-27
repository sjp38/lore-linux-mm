Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id D52936B0109
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 18:12:40 -0400 (EDT)
Date: Tue, 27 Mar 2012 15:12:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mmap.c: find_vma: remove if(mm) check
Message-Id: <20120327151238.302a5920.akpm@linux-foundation.org>
In-Reply-To: <1332805767-2013-1-git-send-email-consul.kautuk@gmail.com>
References: <1332805767-2013-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Mar 2012 19:49:27 -0400
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> find_vma is called from kernel code where it is absolutely
> sure that the mm_struct arg being passed to it is non-NULL.
> 
> Remove the if(mm) check.

It's odd that the if(mm) test exists - I wonder why it was originally
added.  My repo only goes back ten years, and it's there in 2.4.18.

Any code which calls find_vma() without an mm is surely pretty busted?


Still, I think I'd prefer to do

	if (WARN_ON_ONCE(!mm))
		return NULL;

then let that bake for a kernel release, just to find out if we have a
weird caller out there, such as a function which is called by both user
threads and by kernel threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
