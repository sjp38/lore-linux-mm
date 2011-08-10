Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8F72D6B0183
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 07:24:41 -0400 (EDT)
Received: by fxg9 with SMTP id 9so1156859fxg.14
        for <linux-mm@kvack.org>; Wed, 10 Aug 2011 04:24:38 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 1/2] fuse: delete dead .write_begin and .write_end aops
References: <1311626135-14279-1-git-send-email-jweiner@redhat.com>
	<20110725204942.GA12183@infradead.org>
	<87aabkeyfj.fsf@tucsk.pomaz.szeredi.hu>
	<20110810102604.GB6117@infradead.org>
Date: Wed, 10 Aug 2011 13:24:36 +0200
In-Reply-To: <20110810102604.GB6117@infradead.org> (Christoph Hellwig's
	message of "Wed, 10 Aug 2011 06:26:04 -0400")
Message-ID: <87sjp97bm3.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Johannes Weiner <jweiner@redhat.com>, fuse-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

> On Mon, Aug 08, 2011 at 05:05:20PM +0200, Miklos Szeredi wrote:
>> > The loop code still calls them uncondtionally.  This actually is a big
>> > as write_begin and write_end require filesystems specific locking,
>> > and might require code in the filesystem to e.g. update the ctime
>> > properly.  I'll let Miklos chime in if leaving them in was intentional,
>> > and if it was a comment is probably justified.
>> 
>> Loop checks for ->write_begin() and falls back to ->write if the former
>> isn't defined.
>> 
>> So I think the patch is fine.  I tested loop over fuse, and it still
>> works after the patch.
>
> It works, but it involves another data copy, which will slow down
> various workloads that people at least historically cared about.

AFAICS, normally there isn't an additional copy.  If ->write_begin is
defined the copy from the bio_vec to the filesystem page is done with
transfer_none() in the loop driver.

Otherwise the copy is done by ->write() itself on the kmapped bio.

If there's a crypto transfer function then a temporary page will be used
in the no write_begin case.  But I don't think there the additional copy
makes much difference or that anyone cares.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
