Date: Fri, 13 Apr 2007 16:29:09 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch] generic rwsems
Message-Id: <20070413162909.c436a732.dada1@cosmosbay.com>
In-Reply-To: <30644.1176471112@redhat.com>
References: <20070413124303.GD966@wotan.suse.de>
	<20070413100416.GC31487@wotan.suse.de>
	<25821.1176466182@redhat.com>
	<30644.1176471112@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Apr 2007 14:31:52 +0100
David Howells <dhowells@redhat.com> wrote:


> Break the counter down like this:
> 
> 	0x00000000	- not locked; queue empty
> 	0x40000000	- locked by writer; queue empty
> 	0xc0000000	- locket by writer; queue occupied
> 	0x0nnnnnnn	- n readers; queue empty
> 	0x8nnnnnnn	- n readers; queue occupied

If space considerations are that important, we could then reserve one bit for the 'wait_lock spinlock'

0x20000000 : one cpu gained control of 'wait_list'

This would save 4 bytes on 32 bit platforms.

64 bit platforms could have a limit of 2^60 threads, instead of the way too small 2^28 one ;)

(we loose the debug version of spinlock of course)

Another possibility to save space would be to move wait_lock/wait_list outside of rw_semaphore, in a hashed global array.
This would save 12/16 bytes per rw_semaphore (inode structs are probably the most demanding)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
