Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68FDC6B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 15:16:25 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t23so351553ply.21
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 12:16:25 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id p88si482750pfj.124.2018.02.08.12.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 12:16:24 -0800 (PST)
Date: Thu, 08 Feb 2018 15:16:21 -0500 (EST)
Message-Id: <20180208.151621.581060088482890871.davem@davemloft.net>
Subject: Re: [PATCH] net: Whitelist the skbuff_head_cache "cb" field
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180208014438.GA12186@beast>
References: <20180208014438.GA12186@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ebiggers3@gmail.com, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 7 Feb 2018 17:44:38 -0800

> Most callers of put_cmsg() use a "sizeof(foo)" for the length argument.
> Within put_cmsg(), a copy_to_user() call is made with a dynamic size, as a
> result of the cmsg header calculations. This means that hardened usercopy
> will examine the copy, even though it was technically a fixed size and
> should be implicitly whitelisted. All the put_cmsg() calls being built
> from values in skbuff_head_cache are coming out of the protocol-defined
> "cb" field, so whitelist this field entirely instead of creating per-use
> bounce buffers, for which there are concerns about performance.
> 
> Original report was:
 ...
> Reported-by: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com
> Fixes: 6d07d1cd300f ("usercopy: Restrict non-usercopy caches to size 0")
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> I tried the inlining, it was awful. Splitting put_cmsg() was awful. So,
> instead, whitelist the "cb" field as the least bad option if bounce
> buffers are unacceptable. Dave, do you want to take this through net, or
> should I take it through the usercopy tree?

Thanks Kees, I'll take this through my 'net' tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
