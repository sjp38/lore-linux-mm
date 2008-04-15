Date: Tue, 15 Apr 2008 13:10:48 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: s/PF_BORROWED_MM/PF_KTHREAD/ (was: kernel warning: tried to
	kill an mm-less task!)
Message-ID: <20080415171048.GA11441@c2.user-mode-linux.org>
References: <4803030D.3070906@cn.fujitsu.com> <48030F69.7040801@linux.vnet.ibm.com> <48031090.5050002@cn.fujitsu.com> <48042539.8050009@cn.fujitsu.com> <20080415061716.GA89@tv-sign.ru> <20080415101905.GB89@tv-sign.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415101905.GB89@tv-sign.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 15, 2008 at 02:19:05PM +0400, Oleg Nesterov wrote:
> First, include/asm-um/mmu_context.h:activate_mm() doesn't look right to me,
> use_mm() does switch_mm(), not activate_mm(), so I think we can do
> 
> 	--- include/asm-um/mmu_context.h	2008-02-17 23:40:08.000000000 +0300
> 	+++ -	2008-04-15 13:35:34.089295980 +0400
> 	@@ -29,7 +29,7 @@ static inline void activate_mm(struct mm
> 		 * host. Since they're very expensive, we want to avoid that as far as
> 		 * possible.
> 		 */
> 	-	if (old != new && (current->flags & PF_BORROWED_MM))
> 	+	if (old != new)
> 			__switch_mm(&new->context.id);
> 	 
> 		arch_dup_mmap(old, new);

I'm thinking I can just change this to call switch_mm, getting rid of
the old != new test too.

Plus, you can get rid of the comment in use_mm about UML needing
PF_BORROWED_MM.

I'll test this to make sure.

			Jeff

-- 
Work email - jdike at linux dot intel dot com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
