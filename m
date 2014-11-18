Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 281DB6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:34:28 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so8390981ier.0
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:34:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rp3si578299igb.63.2014.11.18.15.34.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Nov 2014 15:34:27 -0800 (PST)
Date: Tue, 18 Nov 2014 15:34:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zsmalloc: correct fragile [kmap|kunmap]_atomic use
Message-Id: <20141118153424.70899732d4ed7933892b6055@linux-foundation.org>
In-Reply-To: <20141118232139.GA7393@bbox>
References: <1415927461-14220-1-git-send-email-minchan@kernel.org>
	<20141114150732.GA2402@cerebellum.variantweb.net>
	<20141118150138.668c81fda55c3ce39d7b2aac@linux-foundation.org>
	<20141118232139.GA7393@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Jerome Marchand <jmarchan@redhat.com>

On Wed, 19 Nov 2014 08:21:39 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Main reason I sent the patch is I got a subtle bug when I implement
> new feature of zsmalloc(ie, compaction) due to link's mishandling
> (ie, link was over page boundary by my fault).
> Although it was totally my mistake, it took time for a while
> to find a root cause because unpredictable kmapped address should
> be unmapped so it's almost random crash.

Fair enough.

That's pretty rude behaviour from kunmap_atomic().  Unfortunately it
just doesn't have anything with which to check the address - we'd need
to create a special per-cpu array[KM_TYPE_NR] just for the purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
