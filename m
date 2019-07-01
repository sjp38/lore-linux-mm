Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BB5EC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:26:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD86D2089C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:26:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="HbMdosaK";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BXvZF4Hv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD86D2089C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56F8E6B0006; Mon,  1 Jul 2019 05:26:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520FC8E0003; Mon,  1 Jul 2019 05:26:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C1E38E0002; Mon,  1 Jul 2019 05:26:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f208.google.com (mail-qt1-f208.google.com [209.85.160.208])
	by kanga.kvack.org (Postfix) with ESMTP id 17AC56B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:26:33 -0400 (EDT)
Received: by mail-qt1-f208.google.com with SMTP id z6so12877896qtj.7
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:26:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f4czRt2dBkv8pN065obux10iigs5H2P/jUH4YPctBX4=;
        b=P7YACrV+VTSFfxoEbNUuyB/isY+IjBB+RMUM7N2bPCO3bRs1t5AM6JlSbAwe32nuP/
         /JXKL5drQ4gRNDFEiWkTv4o73HXTBDp3wZa3kDNq4upvoZ3ORdoyexdq6n8GHa5hJ9Nf
         0CekmPbQoPnJoPxNo2WLtb2wbGplHYzPirEY/AudvYcqYZFaHj3m+YXEiRS6eFWL88Xk
         0KALq5/W0ywNzR5bz61nc8bwFq93w2LZsW7ICyd9kmP/6r1DVqMqcLXVz6+AUfqsAZrV
         j+1APCG4iRH9PH0b9AQtwcxAZy7RW29paILStqpmEzibm2P1mtrqkGE23KNhVFHNObQ0
         ZdHg==
X-Gm-Message-State: APjAAAWAncZ84p77btmP146wmgsS34RASqPr//VEpVs5A+Smp91hLTfn
	+POdBFthiIj3mr2OesmdA+u7y6EvfXKi1xieiLN4nbMITcOnIZ1sxQKixiGJF/+BkewZEjNMp/U
	dPD1cdMdGfnTIHJd/c2aHAgK1dKEsV2aL0xYNOCskoPbZ6OyQC38WSmzHZ2qsKPyDyw==
X-Received: by 2002:aed:23ac:: with SMTP id j41mr18797598qtc.200.1561973192792;
        Mon, 01 Jul 2019 02:26:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp19lexofSz8969GTG5k4jci0uubtwm/s5jyrOchJbEoaUV7WIlk/QaUxpaf7mNhcTebGE
X-Received: by 2002:aed:23ac:: with SMTP id j41mr18797560qtc.200.1561973192107;
        Mon, 01 Jul 2019 02:26:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561973192; cv=none;
        d=google.com; s=arc-20160816;
        b=reVsIT2W2l9ZCcKUwkqWuX658SJdbMZfxWcVdmWWvkYxQIoxDxzgy4vOB9qyW1k1e9
         K7gHPD0pkmfnrnkAodfHDz26zvEuAdQkC+ATmtMkTkdjPE9/ZcHL8dOjcKAgdalAKUNi
         m3MF7eSIcXmjPy/LqnhflON1GT4BFHa1ACnf9ngVJrdgLxPXkwtuqpTs/TXBTTS4pGiE
         oxtZ6k6m2w1f1CZu/hGdryhrqvqyoo/Jjdb9Na3Udn8C54dWYfFCNPHsd4fvcrdedpyg
         RrDKCx3Igv/Z8k6Ocy/sh9dxB5A31aOukVe0FAYxbOVhLBHYLTmW3ZfoDa98h6kP72Ng
         SBjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=f4czRt2dBkv8pN065obux10iigs5H2P/jUH4YPctBX4=;
        b=oTkuYwa6bYeQwxhD0tnlCyYNO5xdSxYfyppg3wr1RfyRbPj4H2NtyJngy/eHzNGT39
         g29xajfQKUnLjkoSmAEnetzD1G13QjWXC/esmh90KH14Zie2DtMQO7RjgIxQ7OjFRX9N
         KgGw5n6qF5zi5Ho5uOoob30lyvNe+UBdEYuKPZ7KNKMwSbMhF2P51x6ArcS0Eh5tOtK+
         UF0byxYoDQiGUAm3vbKuOiNp6uzSNQSxo7U2A6of7/Bb8lJa0Y7U8IYWlSP+q5YIEMEf
         SvOwnPpqkqPiN2P+x+ZcUoTX8PItaCNZgMmUSqbyma/NXN+NIzuPcwKuQSt3uSeXrBjD
         Zcvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=HbMdosaK;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=BXvZF4Hv;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id i31si7853309qvi.180.2019.07.01.02.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 02:26:32 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=HbMdosaK;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=BXvZF4Hv;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id 67F391926;
	Mon,  1 Jul 2019 05:26:31 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 01 Jul 2019 05:26:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=f4czRt2dBkv8pN065obux10iigs
	5H2P/jUH4YPctBX4=; b=HbMdosaKJFUEmlxfPpgvwRPfUZZUnDtXEJSulkXKgRS
	iq2GM3kPTqhnydLP/Hn1C1SM0wRFzxeqFQeuMY0cl17hHk0C4KQqSIu9e4hM9Nc/
	1zY63VrUibN3ZqIkqGDzcgcgMLBRU3ezQvgVh+OV6PHp6CvTgFqXjvc7F6h9sS3A
	s+psyVrnpX+4fRU1CEdKWo4NZTck9e93U1dpLG/+U2oVKS09doU0qqMw9okwRRRY
	6YSXvr9WPdOAwrycZTB5T9Y54XbrUOasHAvfBpe++hlNwRQei0ErkXozmdjG0kE2
	ANDFeR7mAs5D6Liz8gJdrSj/lANX4Bwz9Htdki1KOcg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=f4czRt
	2dBkv8pN065obux10iigs5H2P/jUH4YPctBX4=; b=BXvZF4HvskL2NSVGHZ0Fai
	pg5j0fHec3NoomL+fMN06PIxdn1g8X6AjhJoax5Q8jGxMrLCDpaWFSdepVlxV/Fa
	9/yN6jJcMkJj0lBvOjvjfC4uLa7pqMoW30cqqRdZ0DvBXam/RwuUx1dBvhW/r41o
	opZS+NBFQyPyxIGUTe2rnK4wsyA80nXXE+H4Xbn0O2Psfm9lqvwKecFMkqGpK0jn
	ZeJKqfLElbOxcX5t46Fa+N5zhyGvzKrySddU3sfs5RVCnn1VGp5RL40vMbqmOu0d
	uukhWVdWs501gAzAuRSPWubLEk80RDGAQCDuXScXf0on+ITTTdLmSFhquXCCFqUg
	==
X-ME-Sender: <xms:xNEZXZ2Ol1P8OXll-4lgGH7sAy1d0uFZSyHMJ-Es9JVAQyiHZbvw8w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrvdeigddugecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudelrdefuddrgeenucfrrghrrghmpehmrghilhhf
    rhhomhepmhgvsehtohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:xNEZXcFQV42vo-KmGldRMALNC7NGl2OO0b9N5E_bqmxd0JpnDAmVMQ>
    <xmx:xNEZXciLWpFKc4Ak5VIpYa2gAJwJGtzduq1hkcjeLPi1SRM0TX3zKA>
    <xmx:xNEZXVD8xLq-PNaGPYToblU5TA44fwD_xjDHmcubFMuYvWg0YhS7Og>
    <xmx:x9EZXReMZW3f4q3cfjMzqXuJlFpECY_7lk8QU65JRm-j6WdmfvGskw>
Received: from localhost (unknown [124.19.31.4])
	by mail.messagingengine.com (Postfix) with ESMTPA id 63C7F380074;
	Mon,  1 Jul 2019 05:26:27 -0400 (EDT)
Date: Mon, 1 Jul 2019 19:26:25 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Tobin C. Harding" <tobin@kernel.org>,
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
	linux-kernel@vger.kernel.org
Subject: Re: shrink_dentry_list() logics change (was Re: [RFC PATCH v3 14/15]
 dcache: Implement partial shrink via Slab Movable Objects)
Message-ID: <20190701092625.GA9703@ares>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
 <20190411210200.GH2217@ZenIV.linux.org.uk>
 <20190629040844.GS17978@ZenIV.linux.org.uk>
 <20190629043803.GT17978@ZenIV.linux.org.uk>
 <20190629190624.GU17978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190629190624.GU17978@ZenIV.linux.org.uk>
X-Mailer: Mutt 1.9.4 (2018-02-28)
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 29, 2019 at 08:06:24PM +0100, Al Viro wrote:
> On Sat, Jun 29, 2019 at 05:38:03AM +0100, Al Viro wrote:
> 
> > PS: the problem is not gone in the next iteration of the patchset in
> > question.  The patch I'm proposing (including dput_to_list() and _ONLY_
> > compile-tested) follows.  Comments?
> 
> FWIW, there's another unpleasantness in the whole thing.  Suppose we have
> picked a page full of dentries, all with refcount 0.  We decide to
> evict all of them.  As it turns out, they are from two filesystems.
> Filesystem 1 is NFS on a server, with currently downed hub on the way
> to it.  Filesystem 2 is local.  We attempt to evict an NFS dentry and
> get stuck - tons of dirty data with no way to flush them on server.
> In the meanwhile, admin tries to unmount the local filesystem.  And
> gets stuck as well, since umount can't do anything to its dentries
> that happen to sit in our shrink list.
> 
> I wonder if the root of problem here isn't in shrink_dcache_for_umount();
> all it really needs is to have everything on that fs with refcount 0
> dragged through __dentry_kill().  If something had been on a shrink
> list, __dentry_kill() will just leave behind a struct dentry completely
> devoid of any connection to superblock, other dentries, filesystem
> type, etc. - it's just a piece of memory that won't be freed until
> the owner of shrink list finally gets around to it.  Which can happen
> at any point - all they'll do to it is dentry_free(), and that doesn't
> need any fs-related data structures.
> 
> The logics in shrink_dcache_parent() is
> 	collect everything evictable into a shrink list
> 	if anything found - kick it out and repeat the scan
> 	otherwise, if something had been on other's shrink list
> 		repeat the scan
> 
> I wonder if after the "no evictable candidates, but something
> on other's shrink lists" we ought to do something along the
> lines of
> 	rcu_read_lock
> 	walk it, doing
> 		if dentry has zero refcount
> 			if it's not on a shrink list,
> 				move it to ours
> 			else
> 				store its address in 'victim'
> 				end the walk
> 	if no victim found
> 		rcu_read_unlock
> 	else
> 		lock victim for __dentry_kill
> 		rcu_read_unlock
> 		if it's still alive
> 			if it's not IS_ROOT
> 				if parent is not on shrink list
> 					decrement parent's refcount
> 					put it on our list
> 				else
> 					decrement parent's refcount
> 			__dentry_kill(victim)
> 		else
> 			unlock
> 	if our list is non-empty
> 		shrink_dentry_list on it
> in there...

Thanks for still thinking about this Al.  I don't have a lot of idea
about what to do with your comments until I can grok them fully but I
wanted to acknowledge having read them.

Thanks,
Tobin.

