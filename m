Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 41D776B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 00:08:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so1456644585pgi.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 21:08:23 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id f1si50031699pfc.158.2017.01.04.21.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 21:08:22 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id i5so39460125pgh.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 21:08:22 -0800 (PST)
Date: Thu, 5 Jan 2017 15:08:10 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/2] nfs: no PG_private waiters remain, remove waker
Message-ID: <20170105150810.0b82a9ec@roar.ozlabs.ibm.com>
In-Reply-To: <0562F017-2963-41E0-BE5B-62A07EC444CD@primarydata.com>
References: <20170103182234.30141-1-npiggin@gmail.com>
	<20170103182234.30141-2-npiggin@gmail.com>
	<0562F017-2963-41E0-BE5B-62A07EC444CD@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>

On Wed, 4 Jan 2017 13:43:10 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> Hi Nick,
> 
> > On Jan 3, 2017, at 13:22, Nicholas Piggin <npiggin@gmail.com> wrote:
> > 
> > Since commit 4f52b6bb ("NFS: Don't call COMMIT in ->releasepage()"),
> > no tasks wait on PagePrivate, so the wake introduced in commit 95905446
> > ("NFS: avoid deadlocks with loop-back mounted NFS filesystems.") can
> > be removed.
> > 
> > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> > ---
> > fs/nfs/write.c | 2 --
> > 1 file changed, 2 deletions(-)
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index b00d53d13d47..006068526542 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -728,8 +728,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
> > 		if (likely(head->wb_page && !PageSwapCache(head->wb_page))) {
> > 			set_page_private(head->wb_page, 0);
> > 			ClearPagePrivate(head->wb_page);
> > -			smp_mb__after_atomic();
> > -			wake_up_page(head->wb_page, PG_private);
> > 			clear_bit(PG_MAPPED, &head->wb_flags);
> > 		}
> > 		nfsi->nrequests--;
> > -- 
> > 2.11.0
> >   
> 
> That looks fine to me. Do you want to push it through the linux-mm path or do you want me to take it?

Hi Trond,

Thanks. I don't see a problem with both patches going through your tree.
I think the patches to add this stuff went through your tree as well.
The removal of the export is really the only thing that makes patch 2
non-trivial, but considering it was added for NFS, I think it's safe to
remove.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
