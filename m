Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48C856B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:18:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e129so78310546pfh.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:18:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 20si3427938pfo.372.2017.03.16.03.18.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 03:18:33 -0700 (PDT)
Subject: Re: [RFC PATCH] mm: retry writepages() on ENOMEM when doing an data
 integrity writeback
References: <20170309090449.GD15874@quack2.suse.cz>
 <20170315050743.5539-1-tytso@mit.edu> <20170315130305.GJ32620@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b48b3f89-9bd4-c78c-7238-c28bf9be5a70@I-love.SAKURA.ne.jp>
Date: Thu, 16 Mar 2017 19:18:19 +0900
MIME-Version: 1.0
In-Reply-To: <20170315130305.GJ32620@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Theodore Ts'o <tytso@mit.edu>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On 2017/03/15 22:03, Michal Hocko wrote:
> On Wed 15-03-17 01:07:43, Theodore Ts'o wrote:
>> Unfortunately, this can indeed cause livelocks, since inside the
>> writepages() call, the file system is holding various mutexes, and
>> these mutexes may prevent the OOM killer from killing its targetted
>> victim if it is also holding on to those mutexes.
> 
> The victim might be looping inside do_writepages now instead (especially
> when the memory reserves are depleted), though. On the other hand the
> recent OOM killer changes do not rely on the oom victim exiting anymore.

True only if CONFIG_MMU=y.

> We try to reap as much memory from its address space as possible
> which alone should help us to move on. Even if that is not sufficient we
> will move on to another victim. So unless everything is in this path and
> all the memory is sitting unreachable from the reapable address space we
> should be safe.

If the caller is doing sync() or umount() syscall, isn't it reasonable
to bail out if fatal_signal_pending() is true because it is caller's
responsibility to check whether sync() or umount() succeeded? Though,
I don't know whether writepages() can preserve data for later retry by
other callers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
