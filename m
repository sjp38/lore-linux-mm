Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 923D6C4321A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 04:38:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49AC5204FD
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 04:38:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49AC5204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6B836B0003; Sat, 29 Jun 2019 00:38:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1C358E0003; Sat, 29 Jun 2019 00:38:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABCB28E0002; Sat, 29 Jun 2019 00:38:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f79.google.com (mail-wr1-f79.google.com [209.85.221.79])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB176B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 00:38:25 -0400 (EDT)
Received: by mail-wr1-f79.google.com with SMTP id e8so3252406wrw.15
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 21:38:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=7X2W3Oissv5OiKS46GmHz0NE2MD/ntnmf9adwVaIXfc=;
        b=j3ULMkQILfffe+rKw6GzIshFPXn4KjLGo/ZOJd9hASLtcGJE0xIz7cVOUWSQJpcCw0
         c9X8U67MYhQUnbcs3W3UFi5/k8mycSis44mraQ+22sTLHlvUb9wrt6WWkhhODbFFVJyL
         xZtC5uwjlO15Xm9jMjU5CeobzZgDw9WtkCa3/4jG66jwoPCyxNaXpPD7GbVE1N37xAcb
         VJMjKHbq/gvixz0ePzHtjMRAM11AVDXPsO97XlWGXlMSzndVrpUg8ewnH4gfZVCrLc2N
         lHfz1d6mTsNY1+3rtU1dc1fMNf1pq+a6FEO5QIsdxh2N1jA4Eis0bsmnmhjYACJAs9qJ
         Uu4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAWjLoqkXT5hvZiBx1g9bmfFQxjNkECbYOSIxNWbBk4ymCMT2ToP
	COuwsGCCuHeA+hX8pI62OOAwOnHcGnXP3a7I7F9+hePSmjSeDBIFJaq/VLMV1uoVlxHB7ObxFbx
	2wo5a6uNFYLFFQd+es0zbPrsEdrJ5KzFuZ72rtf3vqKmX3lPJnYvf8cfdwO8aK/aAuA==
X-Received: by 2002:adf:e9c6:: with SMTP id l6mr10876107wrn.216.1561783104790;
        Fri, 28 Jun 2019 21:38:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuqsXwjdE5RHzBvXmtLc0GYbQcJXQjkY7J0347fW88DRfNpk2iRzMTB7FKZCKmwHgxgctT
X-Received: by 2002:adf:e9c6:: with SMTP id l6mr10876043wrn.216.1561783103907;
        Fri, 28 Jun 2019 21:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561783103; cv=none;
        d=google.com; s=arc-20160816;
        b=PP4Ur7e8dPjKPRzsoWS+kmCCLo2e3zgtuKaLSiLlE70MRDAuDHQjGkQQtnfo62yq3/
         +bkh0SpCMwciaOf0lx07H0ORCGSs+bjKLow6f3alkbyvpWo5f60JVpUYzU2/Q9em4iz5
         GtaWZLR6fgQwtb3NIz2JKjvAMcohZx9HkzdFC5ZvFEjelxV0uz5WWKMgVtB9RPibiqRV
         FYJDm6M5LLKukrG/fvfEZWTqOaiIqFA+Ufpom1tFu6fRxQNosLtwR40Rz0WK52Gn2mn6
         fwPFQQ78Q040TcvNFP/vPsgtggnvLis3bJVjDcWZagKLhi+kN6uTLVHP+4nHCYKeNS3r
         AkPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=7X2W3Oissv5OiKS46GmHz0NE2MD/ntnmf9adwVaIXfc=;
        b=bly71xsLv615z1W4BoaWwjqAJziBwsqB9USIlo2tO510oz1Llyp7vxZ4Xh8kxa2rr/
         GT3khsUFWNadGB+bidR+h3BWyUu60qLh26QJma7foOHo+W+43M1TyNNl27iI2VeZXcQL
         ABo8RcD6EOTt0IGxq1v1/wLa2e7Kx2CK2ibsXreuHzTNv0g2hCrgCWPBsNI5ke9aJ92/
         4J7FVNZBGGoddMDmRm7dVZdKFxiNBcOe20ItMYeoczLABavJ0Wbczp7Z9aKPRzZ+Rt1T
         lD70dLW4OUR9a2hEv/4Pw8HqGZ8dcOk+qa/N0kL22m73/96PG7IyVl0UFr4Mhl5r8l8t
         YjkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id m25si2724793wmi.43.2019.06.28.21.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 21:38:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hh57j-0003uX-CH; Sat, 29 Jun 2019 04:38:03 +0000
Date: Sat, 29 Jun 2019 05:38:03 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
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
Subject: shrink_dentry_list() logics change (was Re: [RFC PATCH v3 14/15]
 dcache: Implement partial shrink via Slab Movable Objects)
Message-ID: <20190629043803.GT17978@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
 <20190411210200.GH2217@ZenIV.linux.org.uk>
 <20190629040844.GS17978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190629040844.GS17978@ZenIV.linux.org.uk>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 29, 2019 at 05:08:44AM +0100, Al Viro wrote:
> > The reason we don't hit that problem with regular memory shrinker is
> > this:
> >                 unregister_shrinker(&s->s_shrink);
> >                 fs->kill_sb(s);
> > in deactivate_locked_super().  IOW, shrinker for this fs is gone
> > before we get around to shutdown.  And so are all normal sources
> > of dentry eviction for that fs.
> > 
> > Your earlier variants all suffer the same problem - picking a page
> > shared by dentries from several superblocks can run into trouble
> > if it overlaps with umount of one of those.

PS: the problem is not gone in the next iteration of the patchset in
question.  The patch I'm proposing (including dput_to_list() and _ONLY_
compile-tested) follows.  Comments?

diff --git a/fs/dcache.c b/fs/dcache.c
index 8136bda27a1f..dfe21a649c96 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -860,6 +860,32 @@ void dput(struct dentry *dentry)
 }
 EXPORT_SYMBOL(dput);
 
+static void __dput_to_list(struct dentry *dentry, struct list_head *list)
+__must_hold(&dentry->d_lock)
+{
+	if (dentry->d_flags & DCACHE_SHRINK_LIST) {
+		/* let the owner of the list it's on deal with it */
+		--dentry->d_lockref.count;
+	} else {
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+		if (!--dentry->d_lockref.count)
+			d_shrink_add(dentry, list);
+	}
+}
+
+void dput_to_list(struct dentry *dentry, struct list_head *list)
+{
+	rcu_read_lock();
+	if (likely(fast_dput(dentry))) {
+		rcu_read_unlock();
+		return;
+	}
+	rcu_read_unlock();
+	if (!retain_dentry(dentry))
+		__dput_to_list(dentry, list);
+	spin_unlock(&dentry->d_lock);
+}
 
 /* This must be called with d_lock held */
 static inline void __dget_dlock(struct dentry *dentry)
@@ -1088,18 +1114,9 @@ static void shrink_dentry_list(struct list_head *list)
 		rcu_read_unlock();
 		d_shrink_del(dentry);
 		parent = dentry->d_parent;
+		if (parent != dentry)
+			__dput_to_list(parent, list);
 		__dentry_kill(dentry);
-		if (parent == dentry)
-			continue;
-		/*
-		 * We need to prune ancestors too. This is necessary to prevent
-		 * quadratic behavior of shrink_dcache_parent(), but is also
-		 * expected to be beneficial in reducing dentry cache
-		 * fragmentation.
-		 */
-		dentry = parent;
-		while (dentry && !lockref_put_or_lock(&dentry->d_lockref))
-			dentry = dentry_kill(dentry);
 	}
 }
 

