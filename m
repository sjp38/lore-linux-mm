Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB7948E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:06:12 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id t3so1258988ybq.20
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:06:12 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id d11si3014134ybe.382.2019.01.23.09.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 Jan 2019 09:06:11 -0800 (PST)
Message-ID: <1548263167.2949.27.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 23 Jan 2019 09:06:07 -0800
In-Reply-To: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
References: 
	<CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>, lsf-pc@lists.linux-foundation.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, 2019-01-23 at 10:48 +0200, Amir Goldstein wrote:
> Hi,
> 
> In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong
> brought up the subject of sharing pages between cloned files and the
> general vibe in room was that it could be done.

This subject has been around for a while.  We talked about cache
sharing for containers in LSF/MM 2013, although it was as a discussion
within a session rather than a session about it.  At that time,
Parallels already had an out of tree implementation of a daemon that
forced this sharing and docker was complaining about the dual caching
problem of their graph drivers.

So, what we need in addition to reflink for container images is
something like ksm for containers which can force read only sharing of
pages that have the same content even though they're apparently from
different files.  This is because most cloud container systems run
multiple copies of the same container image even if the overlays don't
necessarily reflect the origin.  Essentially it's the same reason why
reflink doesn't solve the sharing problem entirely for VMs.

James
