Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id D1EE26B00AC
	for <linux-mm@kvack.org>; Tue, 14 May 2013 08:42:26 -0400 (EDT)
Message-ID: <51923158.7040002@parallels.com>
Date: Tue, 14 May 2013 16:43:04 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 04/31] dcache: remove dentries from LRU before putting
 on dispose list
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <1368382432-25462-5-git-send-email-glommer@openvz.org> <20130514054640.GE29466@dastard>
In-Reply-To: <20130514054640.GE29466@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On 05/14/2013 09:46 AM, Dave Chinner wrote:
> [ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
> [ v7: (dchinner)
> - shrink list leaks dentries when inode/parent can't be locked in
>   dentry_kill().
> - fix the scope of the sb locking inside shrink_dcache_sb()
> - remove the readdition of dentry_lru_prune(). ]

Dave,

dentry_lru_prune was removed because it would only prune the dentry if
it was in the LRU list, and it has to be always pruned (61572bb1).

You don't reintroduce dentry_lru_prune here, so the two locations which
prune dentries read as follows:


        if (dentry->d_flags & DCACHE_OP_PRUNE)
                dentry->d_op->d_prune(dentry);

        dentry_lru_del(dentry);

I believe this is wrong. My old version would do:

+static void dentry_lru_prune(struct dentry *dentry)
+{
+	/*
+	 * inform the fs via d_prune that this dentry is about to be
+	 * unhashed and destroyed.
+	 */
+	if (dentry->d_flags & DCACHE_OP_PRUNE)
+		dentry->d_op->d_prune(dentry);
+
+	if (list_empty(&dentry->d_lru))
+		return;
+
+	if ((dentry->d_flags & DCACHE_SHRINK_LIST)) {
+		list_del_init(&dentry->d_lru);
+		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
+	} else {
+		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
+		__dentry_lru_del(dentry);
+		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
+	}
+}

Which is SHRINK_LIST aware. The code as it reads today after your patch
will only be correct if it is totally impossible for a dentry to be in
the shrink list before we reach both sites that call d_op->d_prune. They
are: dentry_kill and shrink_dcache_for_umount_subtree. So it seems to me
that we do really need to reintroduce dentry_lru_prune or just patch
both call sites with shrik-list aware code.

Comments ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
