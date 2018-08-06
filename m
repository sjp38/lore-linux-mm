Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1CF6B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 18:59:31 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g12-v6so9384241plo.1
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 15:59:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bj4-v6si10400173plb.119.2018.08.06.15.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 15:59:29 -0700 (PDT)
Date: Mon, 6 Aug 2018 15:59:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: adjust max read count in
 generic_file_buffered_read()
Message-Id: <20180806155927.4740babd057df9d5078281b1@linux-foundation.org>
In-Reply-To: <20180806102203.hmobd26cujmlfcsw@quack2.suse.cz>
References: <20180719081726.3341-1-cgxu519@gmx.com>
	<20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
	<20180720161429.d63dccb9f66799dc0ff74dba@linux-foundation.org>
	<20180806102203.hmobd26cujmlfcsw@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Chengguang Xu <cgxu519@gmx.com>, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>

On Mon, 6 Aug 2018 12:22:03 +0200 Jan Kara <jack@suse.cz> wrote:

> On Fri 20-07-18 16:14:29, Andrew Morton wrote:
> > On Thu, 19 Jul 2018 10:58:12 +0200 Jan Kara <jack@suse.cz> wrote:
> > 
> > > On Thu 19-07-18 16:17:26, Chengguang Xu wrote:
> > > > When we try to truncate read count in generic_file_buffered_read(),
> > > > should deliver (sb->s_maxbytes - offset) as maximum count not
> > > > sb->s_maxbytes itself.
> > > > 
> > > > Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
> > > 
> > > Looks good to me. You can add:
> > > 
> > > Reviewed-by: Jan Kara <jack@suse.cz>
> > 
> > Yup.
> > 
> > What are the runtime effects of this bug?
> 
> Good question. I think ->readpage() could be called for index beyond
> maximum file size supported by the filesystem leading to weird filesystem
> behavior due to overflows in internal calculations.
> 

Sure.  But is it possible for userspace to trigger this behaviour? 
Possibly all callers have already sanitized the arguments by this stage
in which case the statement is arguably redundant.

I guess I'll put a cc:stable on it and send it in for 4.19-rc1, so we
get a bit more time to poke at it.  But we should have a better
understanding of the userspace impact.
