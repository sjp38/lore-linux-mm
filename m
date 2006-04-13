Date: Thu, 13 Apr 2006 16:24:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/2] mm: fix mm_struct reference counting bugs in
 mm/oom_kill.c
Message-Id: <20060413162432.41892d3a.akpm@osdl.org>
In-Reply-To: <200604131452.08292.dsp@llnl.gov>
References: <200604131452.08292.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

Dave Peterson <dsp@llnl.gov> wrote:
>
> The patch below fixes some mm_struct reference counting bugs in
> badness().

hm, OK, afaict the code _is_ racy.

But you're now calling mmput() inside read_lock(&tasklist_lock), and
mmput() can sleep in exit_aio() or in exit_mmap()->unmap_vmas().  So
sterner stuff will be needed.

I'll put a might_sleep() into mmput - it's a bit unexpected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
