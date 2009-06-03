Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB525F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:19:39 -0400 (EDT)
Date: Wed, 3 Jun 2009 10:21:23 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
Message-ID: <20090603172123.GG6701@oblivion.subreption.com>
References: <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <1244041914.12272.64.camel@localhost.localdomain> <alpine.DEB.1.10.0906031134410.13551@gentwo.org> <20090603162831.GF6701@oblivion.subreption.com> <4A26A689.1090300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A26A689.1090300@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Stephen Smalley <sds@tycho.nsa.gov>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 12:36 Wed 03 Jun     , Rik van Riel wrote:
> Larry H. wrote:
>
>> Christopher, crippling the system is truly not the way to fix this.
>> There are many legitimate users of private|fixed mappings at 0. In
>> addition, if you want to go ahead and break POSIX, at least make sure
>> your patch closes the loophole.
>
> I suspect there aren't many at all, and restricting them through
> SELinux may be enough to mitigate the risk.

It's still perfectly valid POSIX, but I'm definitely keen on using this
patch together with a convenient mmap_min_addr value. I'm just trying to
show how both things are orthogonal to each other, without additional
cost for us (as in people doing kernel/drivers development) and users.

>> If SELinux isn't present, that's not useful. If mmap_min_addr is
>> enabled, that still won't solve what my original, utterly simple patch
>> fixes.
>
> Would anybody paranoid run their system without SELinux?

Does everyone who is conscious about security must use SELinux? Is
SELinux the only acceptable solution? What about people who decide to
use AppArmor, or LIDS, or grsecurity?

That's not a valid point. People should stay safe without SELinux
whenever it is feasible, IMHO. I think everyone here will agree that
SELinux has a track of being disabled by users after installation
because they don't want to invest the necessary time on understanding
and learning the policy language or management tools.

>> The patch provides a no-impact, clean solution to prevent kmalloc(0)
>> situations from becoming a security hazard. Nothing else.
>
> True, the changes in your patch only affect a few code paths.

Only SLAB code itself is affected, users of kmalloc won't see a
functional difference. They just won't be as easily abused if a zero
length ends up passed to kmalloc and the pointer is used for something
later. There's an issue here that I must note: a wraparound can happen
and make the pointer land back somewhere near NULL.

It could be changed to point at the start of the fixmap.

It might be wise to see if expanding the fixmap on runtime can deter
this, although I had trouble using it within vm guests. This can be done
using reservetop boot option.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
