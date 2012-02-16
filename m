Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 80C966B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 19:56:13 -0500 (EST)
Date: Thu, 16 Feb 2012 01:56:08 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Message-ID: <20120216005608.GC21685@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
 <20120215233537.GA20724@dev3310.snc6.facebook.com>
 <20120215234724.GA21685@thinkpad>
 <4F3C467B.1@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4F3C467B.1@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 15, 2012 at 03:57:47PM -0800, Arun Sharma wrote:
> 
> 
> On 2/15/12 3:47 PM, Andrea Righi wrote:
> >>index 74b6a97..b4e45e6 100644
> >>--- a/include/linux/fs.h
> >>+++ b/include/linux/fs.h
> >>@@ -9,7 +9,6 @@
> >>  #include<linux/limits.h>
> >>  #include<linux/ioctl.h>
> >>  #include<linux/blk_types.h>
> >>-#include<linux/kinterval.h>
> >>  #include<linux/types.h>
> >>
> >>  /*
> >>@@ -656,7 +655,7 @@ struct address_space {
> >>  	spinlock_t		private_lock;	/* for use by the address_space */
> >>  	struct list_head	private_list;	/* ditto */
> >>  	struct address_space	*assoc_mapping;	/* ditto */
> >>-	struct rb_root		nocache_tree;	/* noreuse cache range tree */
> >>+	void			*nocache_tree;	/* noreuse cache range tree */
> >>  	rwlock_t		nocache_lock;	/* protect the nocache_tree */
> >>  } __attribute__((aligned(sizeof(long))));
> >>  	/*
> >
> >mmh.. a forward declaration of rb_root in fs.h shouldn't be better than
> >this?
> >
> 
> Forward declaration works if the type was struct rb_root *. But the
> type in your patch was a struct and the compiler can't figure out
> its size.
> 
> include/linux/fs.h:659:17: error: field a??nocache_treea?? has incomplete type
> 
> Did you mean forward declaring struct rb_node instead of rb_root?
> 
> If we go down this path, a few more places need fixups (I ignored
> the compiler warnings about casting void * to struct rb_root *).
> 
>  -Arun

Oh sorry, you're right! nocache_tree is not a pointer inside
address_space, so the compiler must know the size.

mmh... move the definition of the rb_root struct in linux/types.h? or
simply use a rb_root pointer. The (void *) looks a bit scary and too bug
prone.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
