Date: Fri, 11 May 2007 09:17:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: change mmap_sem over to the scalable rw_mutex
Message-Id: <20070511091744.236e8409.akpm@linux-foundation.org>
In-Reply-To: <20070511132321.984615201@chello.nl>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.984615201@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007 15:15:43 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> -	down_write(&current->mm->mmap_sem);
> +	rw_mutex_write_lock(&current->mm->mmap_lock);

y'know, this is such an important lock and people have had such problems
with it and so many different schemes and ideas have popped up that I'm
kinda thinking that we should wrap it:

	write_lock_mm(struct mm_struct *mm);
	write_unlock_mm(struct mm_struct *mm);
	read_lock_mm(struct mm_struct *mm);
	read_unlock_mm(struct mm_struct *mm);

so that further experimentations become easier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
