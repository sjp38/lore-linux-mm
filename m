Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 83C5B6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:30:45 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so1227396pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:30:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y15si29171808pbt.204.2015.08.24.13.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 13:30:44 -0700 (PDT)
Date: Mon, 24 Aug 2015 13:30:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/khugepaged: Allow to interrupt allocation sleep
 again
Message-Id: <20150824133043.23b66633b5c9c91bd6aae190@linux-foundation.org>
In-Reply-To: <1440429203-4039-1-git-send-email-pmladek@suse.com>
References: <1440429203-4039-1-git-send-email-pmladek@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>

On Mon, 24 Aug 2015 17:13:23 +0200 Petr Mladek <pmladek@suse.com> wrote:

> The commit 1dfb059b9438633b0546 ("thp: reduce khugepaged freezing
> latency") fixed khugepaged to do not block a system suspend. But
> the result is that it could not get interrupted before the given
> timeout because the condition for the wait event is "false".

What are the userspace-visible effects of this bug?

> This patch puts back the original approach but it uses
> freezable_schedule_timeout_interruptible() instead of
> schedule_timeout_interruptible(). It does the right thing.
> I am pretty sure that the freezable variant was not used in
> the original fix only because it was not available at that time.
> 
> The regression has been there for ages. It was not critical. It just
> did the allocation throttling a little bit more aggressively.
> 
> I found this problem when converting the kthread to kthread worker API
> and trying to understand the code.
> 
> ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
