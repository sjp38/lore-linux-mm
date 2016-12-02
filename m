Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBB96B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 05:08:23 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so2145986wme.4
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:08:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b188si2250273wme.154.2016.12.02.02.08.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 02:08:22 -0800 (PST)
Date: Fri, 2 Dec 2016 11:08:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] dax: Call ->iomap_begin without entry lock during
 dax fault
Message-ID: <20161202100818.GA26086@quack2.suse.cz>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-6-git-send-email-jack@suse.cz>
 <20161201222447.GB13739@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201222447.GB13739@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu 01-12-16 15:24:47, Ross Zwisler wrote:
> On Thu, Nov 24, 2016 at 10:46:35AM +0100, Jan Kara wrote:
> > Currently ->iomap_begin() handler is called with entry lock held. If the
> > filesystem held any locks between ->iomap_begin() and ->iomap_end()
> > (such as ext4 which will want to hold transaction open), this would cause
> > lock inversion with the iomap_apply() from standard IO path which first
> > calls ->iomap_begin() and only then calls ->actor() callback which grabs
> > entry locks for DAX.
> 
> I don't see the dax_iomap_actor() grabbing any entry locks for DAX?  Is this
> an issue currently, or are you just trying to make the code consistent so we
> don't run into issues in the future?

So dax_iomap_actor() copies data from / to user provided buffer. That can
fault and if the buffer happens to be mmaped file on DAX filesystem, the
fault will end up grabbing entry locks. Sample evil test:

	fd = open("some_file", O_RDWR);
	buf = mmap(NULL, 65536, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	write(fd, buf, 4096);

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
