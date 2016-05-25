Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28D6A6B0270
	for <linux-mm@kvack.org>; Wed, 25 May 2016 17:56:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p81so47400626itd.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:56:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f13si6979270otd.242.2016.05.25.14.56.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 May 2016 14:56:53 -0700 (PDT)
Subject: Re: [PATCH v6 13/20] hung_task: Convert hungtaskd into kthread worker
 API
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
 <1460646879-617-14-git-send-email-pmladek@suse.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <47fb67eb-1756-7189-0245-f59c5a4c5f41@I-love.SAKURA.ne.jp>
Date: Thu, 26 May 2016 06:56:38 +0900
MIME-Version: 1.0
In-Reply-To: <1460646879-617-14-git-send-email-pmladek@suse.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-watchdog@vger.kernel.org

On 2016/04/15 0:14, Petr Mladek wrote:
> This patch converts hungtaskd() in kthread worker API because
> it modifies the priority.
> 
> This patch moves one iteration of the main cycle into a self-queuing
> delayed kthread work. It does not longer check if it was called
> earlier. Instead, the work is scheduled only when needed. This
> requires storing the time of the last check into a global
> variable.

Is it guaranteed that that work is fired when timeout expires? It is
common that tasks sleep in uninterruptible state due to waiting for
memory allocations. Unless a dedicated worker like vmstat_wq is used
for watchdog, I think it might fail to report such tasks due to all
workers being busy but the system is under OOM.

  vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
