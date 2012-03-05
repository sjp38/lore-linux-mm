Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id AF8EB6B00E7
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 15:04:29 -0500 (EST)
Date: Mon, 5 Mar 2012 12:04:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: OOM killer even when not overcommiting
Message-Id: <20120305120427.2d11d30e.akpm@linux-foundation.org>
In-Reply-To: <1330977506.1589.59.camel@lappy>
References: <1330977506.1589.59.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>

On Mon, 05 Mar 2012 21:58:26 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Hi all,

> I assumed that when setting overcommit_memory=2 and
> overcommit_ratio<100 that the OOM killer won't ever get invoked (since
> we're not overcommiting memory), but it looks like I'm mistaken since
> apparently a simple mmap from userspace will trigger the OOM killer if
> it requests more memory than available.
>
> Is it how it's supposed to work?  Why does it resort to OOM killing
> instead of just failing the allocation?
>
> Here is the dump I get when the OOM kicks in:
> 
> ...
>
> [ 3108.730350]  [<ffffffff81198e4a>] mlock_vma_pages_range+0x9a/0xa0
> [ 3108.734486]  [<ffffffff8119b75b>] mmap_region+0x28b/0x510
> ...

The vma is mlocked for some reason - presumably the app is using
mlockall() or mlock()?  So the kernel is trying to instantiate all the
pages at mmap() time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
