Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 512226B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:29:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 91-v6so6468626lfu.20
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:29:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor2994442ljj.89.2018.03.26.14.29.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 14:29:46 -0700 (PDT)
Date: Tue, 27 Mar 2018 00:29:44 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180326212944.GF2236@uranus>
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
 <0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Matthew Wilcox <willy@infradead.org>, Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 27, 2018 at 06:10:09AM +0900, Tetsuo Handa wrote:
> On 2018/03/27 4:21, Cyrill Gorcunov wrote:
> > That said I think using read-lock here would be a bug.
> 
> If I understand correctly, the caller can't set both fields atomically, for
> prctl() does not receive both fields at one call.
> 
>   prctl(PR_SET_MM, PR_SET_MM_ARG_START xor PR_SET_MM_ARG_END xor PR_SET_MM_ENV_START xor PR_SET_MM_ENV_END, new value, 0, 0);
> 

True, but the key moment is that two/three/four system calls can
run simultaneously. And while previously they are ordered by "write",
with read lock they are completely unordered and this is really
worries me. To be fair I would prefer to drop this old per-field
interface completely. This per-field interface was rather an ugly
solution from my side.

> Then, I wonder whether reading arg_start|end and env_start|end atomically makes
> sense. Just retry reading if arg_start > env_end or env_start > env_end is fine?

Tetsuo, let me re-read this code tomorrow, maybe I miss something obvious.
