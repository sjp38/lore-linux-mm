Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E0AE16B00D7
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:27:52 -0400 (EDT)
Date: Wed, 3 Jun 2009 12:27:32 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
Message-ID: <alpine.LFD.2.01.0906031222550.4880@localhost.localdomain>
References: <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com>
 <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <20090603182949.5328d411@lxorguk.ukuu.org.uk> <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain> <20090603180037.GB18561@oblivion.subreption.com> <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>
 <20090603183939.GC18561@oblivion.subreption.com> <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain> <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain> <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Christoph Lameter wrote:
>
> We could just move the check for mmap_min_addr out from
> CONFIG_SECURITY?

No.

The thing is, the security model wants to modify the rules on what's 
"secure" and what isn't. And your patch just hard-coded that 
capable(CAP_SYS_RAWIO) decision - but that's not what something like 
SElinux actually uses to decide whether it's ok or not.

So if you do it in generic code, you'd have to make it much more complex. 
One option would be to change the rule for what "security_file_mmap()" 
means, and make the return value says "yes, no, override". Where 
"override" would be "allow it for this process even if it's below the 
minimum mmap limit.

But the better option really is to just copy the cap_file_mmap() rule to 
the !SECURITY rule, and make !SECURITY really mean the same as "always do 
default security", the way it's documented.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
