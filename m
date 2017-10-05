Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC736B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:36:39 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id l40so8752224uah.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:36:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w79si1864460oia.106.2017.10.05.03.36.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 03:36:37 -0700 (PDT)
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org> <20171004185906.GB2136@cmpxchg.org>
 <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
 <20171004231821.GA3610@cmpxchg.org>
 <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
Date: Thu, 5 Oct 2017 19:36:17 +0900
MIME-Version: 1.0
In-Reply-To: <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 2017/10/05 16:57, Michal Hocko wrote:
> On Wed 04-10-17 19:18:21, Johannes Weiner wrote:
>> On Wed, Oct 04, 2017 at 03:32:45PM -0700, Andrew Morton wrote:
> [...]
>>> You don't think they should be backported into -stables?
>>
>> Good point. For this one, it makes sense to CC stable, for 4.11 and
>> up. The second patch is more of a fortification against potential
>> future issues, and probably shouldn't go into stable.
> 
> I am not against. It is true that the memory reserves depletion fix was
> theoretical because I haven't seen any real life bug. I would argue that
> the more robust allocation failure behavior is a stable candidate as
> well, though, because the allocation can fail regardless of the vmalloc
> revert. It is less likely but still possible.
> 

I don't want this patch backported. If you want to backport,
"s/fatal_signal_pending/tsk_is_oom_victim/" is the safer way.

On 2017/10/04 17:33, Michal Hocko wrote:
> Now that we have cd04ae1e2dc8 ("mm, oom: do not rely on TIF_MEMDIE for
> memory reserves access") the risk of the memory depletion is much
> smaller so reverting the above commit should be acceptable. 

Are you aware that stable kernels do not have cd04ae1e2dc8 ?

We added fatal_signal_pending() check inside read()/write() loop
because one read()/write() request could consume 2GB of kernel memory.

What if there is a kernel module which uses vmalloc(1GB) from some
ioctl() for legitimate reason? You are going to allow such vmalloc()
calls to deplete memory reserves completely.

On 2017/10/05 8:21, Johannes Weiner wrote:
> Generally, we should leave it to the page allocator to handle memory
> reserves, not annotate random alloc_page() callsites.

I disagree. Interrupting the loop as soon as possible is preferable.

Since we don't have __GFP_KILLABLE, we had to do fatal_signal_pending()
check inside read()/write() loop. Since vmalloc() resembles read()/write()
in a sense that it can consume GB of memory, it is pointless to expect
the caller of vmalloc() to check tsk_is_oom_victim().

Again, checking tsk_is_oom_victim() inside vmalloc() loop is the better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
