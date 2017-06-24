Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0B926B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 09:16:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f92so29915609qtb.4
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 06:16:10 -0700 (PDT)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com. [209.85.220.176])
        by mx.google.com with ESMTPS id b128si6245025qkf.321.2017.06.24.06.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 06:16:10 -0700 (PDT)
Received: by mail-qk0-f176.google.com with SMTP id 16so53029888qkg.2
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 06:16:09 -0700 (PDT)
Message-ID: <1498310166.4796.4.camel@redhat.com>
Subject: Re: [PATCH v7 16/22] block: convert to errseq_t based writeback
 error tracking
From: Jeff Layton <jlayton@redhat.com>
Date: Sat, 24 Jun 2017 09:16:06 -0400
In-Reply-To: <20170624115946.GA22561@infradead.org>
References: <20170616193427.13955-1-jlayton@redhat.com>
	 <20170616193427.13955-17-jlayton@redhat.com>
	 <20170620123544.GC19781@infradead.org>
	 <1497980684.4555.16.camel@redhat.com>
	 <20170624115946.GA22561@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Sat, 2017-06-24 at 04:59 -0700, Christoph Hellwig wrote:
> On Tue, Jun 20, 2017 at 01:44:44PM -0400, Jeff Layton wrote:
> > In order to query for errors with errseq_t, you need a previously-
> > sampled point from which to check. When you call
> > filemap_write_and_wait_range though you don't have a struct file and so
> > no previously-sampled value.
> 
> So can we simply introduce variants of them that take a struct file?
> That would be:
> 
>  a) less churn
>  b) less code
>  c) less chance to get data integrity wrong

Yeah, I had that thought after I sent the reply to you earlier.

The main reason I didn't do that before was that I had myself convinced
that we needed to do the check_and_advance as late as possible in the
fsync process, after the metadata had been written.

Now that I think about it more, I think you're probably correct. As long
as we do the check and advance at some point after doing the
write_and_wait, we're fine here and shouldn't violate exactly once
semantics on the fsync return.
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
