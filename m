Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7FB16B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 23:58:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p17so15098265pfh.18
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 20:58:13 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f12si10752260plo.19.2017.12.04.20.58.10
        for <linux-mm@kvack.org>;
        Mon, 04 Dec 2017 20:58:11 -0800 (PST)
Subject: Re: possible deadlock in generic_file_write_iter (2)
References: <94eb2c0d010a4e7897055f70535b@google.com>
 <20171204083339.GF8365@quack2.suse.cz>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
Date: Tue, 5 Dec 2017 13:58:09 +0900
MIME-Version: 1.0
In-Reply-To: <20171204083339.GF8365@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, peterz@infradead.org, kernel-team@lge.com

On 12/4/2017 5:33 PM, Jan Kara wrote:
> Hello,
> 
> adding Peter and Byungchul to CC since the lockdep report just looks
> strange and cross-release seems to be involved. Guys, how did #5 get into
> the lock chain and what does put_ucounts() have to do with sb_writers
> there? Thanks!

Hello Jan,

In order to get full stack of #5, we have to pass a boot param,
"crossrelease_fullstack", to the kernel. Now that it only informs
put_ucounts() in the call trace, it's hard to find out what exactly
happened at that time, but I can tell #5 shows:

When acquire(sb_writers) in put_ucounts(), it was on the way to
complete((completion)&req.done) of wait_for_completion() in
devtmpfs_create_node().

If acquire(sb_writers) in put_ucounts() is stuck, then
wait_for_completion() in devtmpfs_create_node() would be also
stuck, since complete() being in the context of acquire(sb_writers)
cannot be called.

This is why cross-release added the lock chain.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
