Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65F386B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 09:42:48 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a189so52690226qkc.4
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 06:42:48 -0800 (PST)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id n17si6839739qki.57.2017.02.26.06.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 06:42:47 -0800 (PST)
Received: by mail-qk0-f180.google.com with SMTP id n127so65019366qkf.0
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 06:42:47 -0800 (PST)
Message-ID: <1488120164.2948.4.camel@redhat.com>
Subject: [LSF/MM TOPIC] do we really need PG_error at all?
From: Jeff Layton <jlayton@redhat.com>
Date: Sun, 26 Feb 2017 09:42:44 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>

Proposing this as a LSF/MM TOPIC, but it may turn out to be me just not
understanding the semantics here.

As I was looking into -ENOSPC handling in cephfs, I noticed that
PG_error is only ever tested in one place [1] __filemap_fdatawait_range,
which does this:

	if (TestClearPageError(page))
		ret = -EIO;

This error code will override any AS_* error that was set in the
mapping. Which makes me wonder...why don't we just set this error in the
mapping and not bother with a per-page flag? Could we potentially free
up a page flag by eliminating this?

The main argument I could see for keeping it is that removing it might
subtly change the behavior of sync_file_range if you have tasks syncing
different ranges in a file concurrently. I'm not sure if that would
break any guarantees though.

Even if we do need it, I think we might need some cleanup here anyway. A
lot of readpage operations end up setting that flag when they hit an
error. Isn't it wrong to return an error on fsync, just because we had a
read error somewhere in the file in a range that was never dirtied?

--
[1]: there is another place in f2fs, but it's more or less equivalent to
the call site in __filemap_fdatawait_range.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
