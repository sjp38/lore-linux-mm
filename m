Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4AFE8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:10:59 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b8so2394375pfe.10
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 11:10:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t184si19387809pfb.22.2019.01.23.11.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 Jan 2019 11:10:58 -0800 (PST)
Date: Wed, 23 Jan 2019 11:10:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
Message-ID: <20190123191046.GA15311@bombadil.infradead.org>
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Jan 23, 2019 at 10:48:58AM +0200, Amir Goldstein wrote:
> Hi,
> 
> In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
> up the subject of sharing pages between cloned files and the general vibe
> in room was that it could be done.
> 
> In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
> that Matthew Willcox was "working on that problem".

My solution is to move the DAX hacks into the page cache proper.  For a
reflinked file, the filesystem would create a canonical address_space
to own the pages, and this is what ->mapping and ->index would refer to.

Instances of that reflinked file would each have their own address_space,
just as they have their own inode.  The i_pages array would contain only
PFN entries (until the COWs start).

I'm currently at LCA; please excuse me for not participating more fully
right now.
