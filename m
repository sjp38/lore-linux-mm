Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id F134C6B003D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:25:56 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro12so358294pbb.18
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 09:25:56 -0700 (PDT)
Date: Mon, 8 Apr 2013 20:42:41 -0400
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH v8 3/3] mm: reinititalise user and admin reserves if
 memory is added or removed
Message-ID: <20130409004241.GA4277@localhost.localdomain>
References: <20130408190738.GC2321@localhost.localdomain>
 <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Mon, Apr 08, 2013 at 01:37:12PM -0700, Andrew Morton wrote:
> On Mon, 8 Apr 2013 15:07:38 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:
> 
> > This patch alters the admin and user reserves of the previous patches 
> > in this series when memory is added or removed.
> > 
> > If memory is added and the reserves have been eliminated or increased above
> > the default max, then we'll trust the admin.
> > 
> > If memory is removed and there isn't enough free memory, then we
> > need to reset the reserves.
> > 
> > Otherwise keep the reserve set by the admin.
> > 
> > The reserve reset code is the same as the reserve initialization code.
> > 
> > Does this sound reasonable to other people? I figured that hot removal
> > with too large of memory in the reserves was the most important case 
> > to get right.
> 
> Seems reasonable to me.
> 
> I don't understand the magic numbers 1<<13 and 1<<17.  How could I? 
> Please add comments explaining how and why these were chosen.

The v9 patch I posted has this too, but here is a patch against 
yesterday's mmotm.

diff --git a/mm/mmap.c b/mm/mmap.c
index 099a16d..cee7e74 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3119,6 +3119,13 @@ module_init(init_admin_reserve)
 /*
  * Reinititalise user and admin reserves if memory is added or removed.
  *
+ * The default user reserve max is 128MB, and the default max for the
+ * admin reserve is 8MB. These are usually, but not always, enough to
+ * enable recovery from a memory hogging process using login/sshd, a shell,
+ * and tools like top. It may make sense to increase or even disable the
+ * reserve depending on the existence of swap or variations in the recovery
+ * tools. So, the admin may have changed them.
+ *
  * If memory is added and the reserves have been eliminated or increased above
  * the default max, then we'll trust the admin.
  *
@@ -3134,10 +3141,16 @@ static int reserve_mem_notifier(struct notifier_block *nb,
 
 	switch (action) {
 	case MEM_ONLINE:
+		/*
+		 * Default max is 128MB. Leave alone if modified by operator.
+ 		 */
 		tmp = sysctl_user_reserve_kbytes;
 		if (0 < tmp && tmp < (1UL << 17))
 			init_user_reserve();
 
+		/*
+		 * Default max is 8MB. Leave alone if modified by operator.
+ 		 */
 		tmp = sysctl_admin_reserve_kbytes;
 		if (0 < tmp && tmp < (1UL << 13))
 			init_admin_reserve();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
