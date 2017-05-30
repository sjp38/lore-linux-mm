Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id F19206B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 09:08:45 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g55so29633795qtc.8
        for <linux-mm@kvack.org>; Tue, 30 May 2017 06:08:45 -0700 (PDT)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com. [209.85.216.182])
        by mx.google.com with ESMTPS id s40si12358648qtg.293.2017.05.30.06.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 06:08:45 -0700 (PDT)
Received: by mail-qt0-f182.google.com with SMTP id c13so69327085qtc.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 06:08:44 -0700 (PDT)
Message-ID: <1496149722.2811.3.camel@redhat.com>
Subject: Re: [PATCH 0/2] record errors in mapping when writeback fails on DAX
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 30 May 2017 09:08:42 -0400
In-Reply-To: <20170530111046.8069-1-jlayton@redhat.com>
References: <20170530111046.8069-1-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neilb@suse.com>, willy@infradead.org, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2017-05-30 at 07:10 -0400, Jeff Layton wrote:
> This is part of the preparatory set of patches to pave the way for
> improved writeback error reporting. In order to do this correctly, we
> need to ensure that DAX marks the mapping with an error when writeback
> fails.
> 
> I sent the second patch in this series to Ross last week, but he pointed
> out that it makes fsync error out more than it should, since we don't
> currently clear errors in filemap_write_and_wait and
> filemap_write_and_wait_range.
> 
> In order to fix that, I think we need the first patch in this set. There
> is a some danger that this could end up causing error flags to be
> cleared earlier than they were before when write initiation fails in
> other filesystems.
> 
> Given how racy all of the AS_* flag handling is though, I'm inclined to
> just go ahead and merge both of these into linux-next and deal with any
> fallout as it arises.
> 
> Does that seem like a reasonable plan? If so, Andrew, would you be
> willing to take both of these in for linux-next, with an eye toward
> merging into v4.13?
> 
> Thanks in advance,
> 

There is an alternative here though...

In the series that I have that adds in the new writeback error reporting
infrastructure, I've added a fstype flag that indicates what flavor of
error reporting the filesystem does.

We could just have DAX check that flag and only mark the mapping for
error if it's set. That should make things work with the new scheme
while preserving the old as much as possible.

Now that I think about it, that's probably the safest avenue. Let's just
drop both of these patches, and I'll just roll a patch like that into
the later series.

Sorry for the noise,
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
