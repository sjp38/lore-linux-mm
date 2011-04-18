Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 670D3900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 20:26:26 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3I0QFVk012258
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 17:26:16 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by wpaz5.hot.corp.google.com with ESMTP id p3I0QD8w003087
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 17:26:14 -0700
Received: by pxi7 with SMTP id 7so2544076pxi.2
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 17:26:13 -0700 (PDT)
Date: Sun, 17 Apr 2011 17:26:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1104171649350.21405@sister.anvils>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

On Tue, 12 Apr 2011, KOSAKI Motohiro wrote:
> 
> Benjamin, Hugh, I hope to add your S-O-B to this one because you are original author. 
> Can I do?

Well, now you've fixed the mm/fremap.c omission, you're welcome to my
Acked-by: Hugh Dickins <hughd@google.com>

I happen not to shared Ben's aversion to unsigned long long, I just
don't really care one way or another on that; but I do get irritated by
obfuscatory types which we then have to cast or unfold all over the place,
I don't know if vm_flags_t would have been in that category or not.

You've made a few different choices than I did, okay: the only place
where it might be worth disagreeing with you, is on mm->def_flags:
I would rather make that an unsigned int than an unsigned long long,
to save 4 bytes on 64-bit (if it were moved) rather than waste 4 bytes
on 32-bit - in the unlikely event that someone adds a high VM_flag to
def_flags, I'd rather hope they would test its effect.  However,
it's every mm not every vma, so maybe not worth worrying about.

I am surprised that
#define VM_EXEC		0x00000004ULL
does not cause trouble for arch/arm/kernel/asm-offsets.c,
but you tried cross-building it which I never did.

Does your later addition of __nocast on vm_flags not make trouble
for the unsigned long casts in arch/arm/include/asm/cacheflush.h?
(And if it does not, then just what does __nocast do?)

Thanks for seeing this through,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
