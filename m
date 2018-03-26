Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 853396B0010
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:10:40 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l67-v6so5986440oif.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:10:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m14-v6si5011458oth.466.2018.03.26.14.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:10:39 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
Date: Tue, 27 Mar 2018 06:10:09 +0900
MIME-Version: 1.0
In-Reply-To: <20180326192132.GE2236@uranus>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2018/03/27 4:21, Cyrill Gorcunov wrote:
> That said I think using read-lock here would be a bug.

If I understand correctly, the caller can't set both fields atomically, for
prctl() does not receive both fields at one call.

  prctl(PR_SET_MM, PR_SET_MM_ARG_START xor PR_SET_MM_ARG_END xor PR_SET_MM_ENV_START xor PR_SET_MM_ENV_END, new value, 0, 0);

Then, I wonder whether reading arg_start|end and env_start|end atomically makes
sense. Just retry reading if arg_start > env_end or env_start > env_end is fine?
