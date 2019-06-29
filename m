Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5627C4321A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 04:09:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78D81214AF
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 04:09:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78D81214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E56446B0003; Sat, 29 Jun 2019 00:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDF818E0003; Sat, 29 Jun 2019 00:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7F338E0002; Sat, 29 Jun 2019 00:09:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f80.google.com (mail-wm1-f80.google.com [209.85.128.80])
	by kanga.kvack.org (Postfix) with ESMTP id 769E06B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 00:09:26 -0400 (EDT)
Received: by mail-wm1-f80.google.com with SMTP id y127so1672552wmd.0
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 21:09:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=zFT8Eg9srX4yG/cxwlvQ5H0v6t3M3ZEOaMGsGYlfuaM=;
        b=nZ1Za1p7t6bGbYzzQhwirDcNkCnPl+xmilh7T9JepvSnDf7KyPiMbpQSyLbXFP8QkU
         M1P+g0wMy8+4Iu7scs1vpkXET0UcImxYPYSv/Lo/3jXXf2ojGtp8r7mpOobRZeUy2Nf3
         Y3JbbINfsrWyGavQbR/iz+lxO/m2TsHJXYuOTpSQuMVt9iONC9rnMpRzq7rWrA1r+AdV
         rm9d+Fkv4GF6hv4QBJKURa0lop3IxL9JpwolDBw/Bp8d96+p7Eyy8wJhxvMnItKpU1Vy
         EwYIU6HnYRj0RjFBayx3CSe7n+bbuVwbUTnJEGMtHMZ7wCtm03vs3CaB8zkkY0SGtF1w
         WClw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAWj69SiB2CIpThDh4NfhiA15J1LY24prfXyMnGVIopwlGpg2hyR
	WncKTU6Z3u/8mrjP+X7H1t8YPVGdJQT7DTxrqqvTstM/NRzQSw9H2xE7GEr3uk5TxEzn0rB1Zwx
	ReeGgih77k6lA0bYt0AsMNWTnb/rNOdUyFtBQT3cJUCJJEhOT0ZHOKEqsO2Kw1FIFQg==
X-Received: by 2002:a1c:a019:: with SMTP id j25mr9606671wme.95.1561781365864;
        Fri, 28 Jun 2019 21:09:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXXhrC334BY16E9rGaf/GtoVojWo5EtI9FNV1a6aK8tZKVS2NRb8pIcefp5LcyNrbTY4Vp
X-Received: by 2002:a1c:a019:: with SMTP id j25mr9606613wme.95.1561781364662;
        Fri, 28 Jun 2019 21:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561781364; cv=none;
        d=google.com; s=arc-20160816;
        b=eelpW4EMuq9TSTuCKSTb7EnYlWIOXULB9fMcbB6sU0koJ6RMR+LC5SF2OLDKX41qyY
         0R5T7UBR3A/CssF46xcQZd60wxuSLboALX+GLq4U1iRs1TbxjRkt2Md9sZ5T7Uo+Jkrs
         XYpPsMkMJavwgQ/Y7kLjx5MtuVPJ8v4CoXYJyMx3iOJNCqmq4VvK8eoLL2L8rWIx/ptJ
         jaAiDuok4N65f6b5dFroo4Wre484ZLXfVauT3t1Z1hixsbwS52XE8HNBZQaY/8OqfFp7
         ES7tunQV2yQp0GUi6bEeECeCI4x1e6V1P+rzxSHN7GMLjvz3OkQc08BdW8XK95fJz92b
         uRAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=zFT8Eg9srX4yG/cxwlvQ5H0v6t3M3ZEOaMGsGYlfuaM=;
        b=IoW+gIWJtApYOWteXEu2LBXNQ9ifZGzR+KStjxLWMy+WSrde300RYFgCAYSFCdaIpU
         u8eXh/8b+rK0EfeZT5zsoWBGSisodQQmvzQBD1YQUBya1upkRQCQEkvqQGWQ/T7o2DZo
         H0dfj582++UdP7bfmHRFYNEnBXWFPHPDmKrVkFVF1byLzAYWLeAtSHjOarFUt1HlbQGK
         9L6xZQ6QsoZFLzgovNEQJTJIC2m+JWcRISph1+HihsEEkhB75YyErqi2ErebMbDyNvpz
         UX8kkQ1+w2yHJf0sVsUxzY/sL0YdVFMLAMzm7NFR0xoiHGOX4v++iTiCBY62uX3nufwm
         3aEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id c17si3227084wrm.278.2019.06.28.21.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 21:09:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hh4fM-0003FG-Bu; Sat, 29 Jun 2019 04:08:44 +0000
Date: Sat, 29 Jun 2019 05:08:44 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab
 Movable Objects
Message-ID: <20190629040844.GS17978@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
 <20190411210200.GH2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411210200.GH2217@ZenIV.linux.org.uk>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:02:00PM +0100, Al Viro wrote:

> Aaaarrgghhh...  No, we can't.  Look: we get one candidate dentry in isolate
> phase.  We put it into shrink list.  umount(2) comes and calls
> shrink_dcache_for_umount(), which calls shrink_dcache_parent(root).
> In the meanwhile, shrink_dentry_list() is run and does __dentry_kill() on
> that one dentry.  Fine, it's gone - before shrink_dcache_parent() even
> sees it.  Now shrink_dentry_list() holds a reference to its parent and
> is about to drop it in
>                 dentry = parent;
>                 while (dentry && !lockref_put_or_lock(&dentry->d_lockref))
>                         dentry = dentry_kill(dentry);
> And dropped it will be, but... shrink_dcache_parent() has finished the
> scan, without finding *anything* with zero refcount - the thing that used
> to be on the shrink list was already gone before shrink_dcache_parent()
> has gotten there and the reference to parent was not dropped yet.  So
> shrink_dcache_for_umount() plows past shrink_dcache_parent(), walks the
> tree and complains loudly about "busy" dentries (that parent we hadn't
> finished dropping), and then we proceed with filesystem shutdown.
> In the meanwhile, dentry_kill() finally gets to killing dentry and
> triggers an unexpected late call of ->d_iput() on a filesystem that
> has already been far enough into shutdown - far enough to destroy the
> data structures needed for that sucker.
> 
> The reason we don't hit that problem with regular memory shrinker is
> this:
>                 unregister_shrinker(&s->s_shrink);
>                 fs->kill_sb(s);
> in deactivate_locked_super().  IOW, shrinker for this fs is gone
> before we get around to shutdown.  And so are all normal sources
> of dentry eviction for that fs.
> 
> Your earlier variants all suffer the same problem - picking a page
> shared by dentries from several superblocks can run into trouble
> if it overlaps with umount of one of those.

FWIW, I think I see a kinda-sorta sane solution.  Namely, add

static void __dput_to_list(struct dentry *dentry, struct list_head *list)
{
	if (dentry->d_flags & DCACHE_SHRINK_LIST) {
		/* let the owner of the list it's on deal with it */
		--dentry->d_lockref.count;
	} else {
		if (dentry->d_flags & DCACHE_LRU_LIST)
			d_lru_del(dentry);
		if (!--dentry->d_lockref.count)
			d_shrink_add(parent, list);
	}
}

and have
shrink_dentry_list() do this in the end of loop:
                d_shrink_del(dentry);
                parent = dentry->d_parent;
		/* both dentry and parent are locked at that point */
		if (parent != dentry) {
			/*
			 * We need to prune ancestors too. This is necessary to
			 * prevent quadratic behavior of shrink_dcache_parent(),
			 * but is also expected to be beneficial in reducing
			 * dentry cache fragmentation.
			 */
			__dput_to_list(parent, list);
		}
		__dentry_kill(dentry);
        }

instead of
                d_shrink_del(dentry);
                parent = dentry->d_parent;
                __dentry_kill(dentry);
                if (parent == dentry)
                        continue;
                /*
                 * We need to prune ancestors too. This is necessary to prevent
                 * quadratic behavior of shrink_dcache_parent(), but is also
                 * expected to be beneficial in reducing dentry cache
                 * fragmentation.
                 */
                dentry = parent;
                while (dentry && !lockref_put_or_lock(&dentry->d_lockref))
                        dentry = dentry_kill(dentry);
        }
we have there now.  Linus, do you see any problems with that change?  AFAICS,
that should avoid the problem described above.  Moreover, it seems to allow
a fun API addition:

void dput_to_list(struct dentry *dentry, struct list_head *list)
{
	rcu_read_lock();
	if (likely(fast_dput(dentry))) {
		rcu_read_unlock();
		return;
	}
	rcu_read_unlock();
	if (!retain_dentry(dentry))
		__dput_to_list(dentry, list);
	spin_unlock(&dentry->d_lock);
}

allowing to take an empty list, do a bunch of dput_to_list() (under spinlocks,
etc.), then, once we are in better locking conditions, shrink_dentry_list()
to take them all out.  I can see applications for that in e.g. fs/namespace.c -
quite a bit of kludges with ->mnt_ex_mountpoint would be killable that way,
and there would be a chance to transfer the contribution to ->d_count of
mountpoint from struct mount to struct mountpoint (i.e. make any number of
mounts on the same mountpoint dentry contribute only 1 to its ->d_count,
not the number of such mounts).

