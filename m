Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE2A96B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:14:16 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id x1so3060960lff.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:14:16 -0800 (PST)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id p3si3391164lfe.195.2017.01.11.04.14.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 04:14:15 -0800 (PST)
Received: by mail-lf0-x236.google.com with SMTP id k86so135548790lfi.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:14:15 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
From: Chris Vest <chris.vest@neotechnology.com>
In-Reply-To: <20170111050356.ldlx73n66zjdkh6i@thunk.org>
Date: Wed, 11 Jan 2017 13:14:13 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <A8FCA794-E868-4659-9EEA-D6A5B4AEF2AA@neotechnology.com>
References: <20170110160224.GC6179@noname.redhat.com>
 <20170111050356.ldlx73n66zjdkh6i@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Kevin Wolf <kwolf@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>


> On 11 Jan 2017, at 06.03, Theodore Ts'o <tytso@mit.edu> wrote:
>=20
> So an approach that might work is fsync() will keep the pages dirty
> --- but only while the file descriptor is open.  This could either be
> the default behavior, or something that has to be specifically
> requested via fcntl(2).  That way, as soon as the process exits (at
> which point it will be too late for it do anything to save the
> contents of the file) we also release the memory.  And if the process
> gets OOM killed, again, the right thing happens.  But if the process
> wants to take emergency measures to write the file somewhere else, it
> knows that the pages won't get lost until the file gets closed.

I think this sounds like a very reasonable default. Before reading this =
thread, it would have been my first guess as to how this worked. It =
gives the program the opportunity to retry the fsyncs, before aborting. =
It will also allow a database, for instance, to keep servicing reads =
until the issue resolves itself, or an administrator intervenes. A =
program cannot allow reads from the file if pages that has been written =
to can be evicted, and their changes lost, and then brought back with =
old data.

--
Chris Vest=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
