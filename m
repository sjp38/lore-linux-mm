Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6CA526B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:56:14 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A0CBD82C3F3
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:03:03 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZJJvfXnlg9pz for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 13:03:03 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6908982C43F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:02:57 -0500 (EST)
Date: Fri, 6 Nov 2009 12:54:50 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
 instead
In-Reply-To: <20091106174439.GB819@basil.fritz.box>
Message-ID: <alpine.DEB.1.10.0911061249170.5187@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <87r5sc7kst.fsf@basil.nowhere.org> <alpine.DEB.1.10.0911051558220.7668@V090114053VZO-1> <20091106073946.GV31511@one.firstfloor.org>
 <alpine.DEB.1.10.0911061208370.5187@V090114053VZO-1> <20091106174439.GB819@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009, Andi Kleen wrote:

> On Fri, Nov 06, 2009 at 12:08:54PM -0500, Christoph Lameter wrote:
> > On Fri, 6 Nov 2009, Andi Kleen wrote:
> >
> > > Yes but all the major calls still take mmap_sem, which is not ranged.
> >
> > But exactly that issue is addressed by this patch!
>
> Major calls = mmap, brk, etc.

Those are rare. More frequently are for faults, get_user_pages and
the like operations that are frequent.

brk depends on process wide settings and has to be
serialized using a processor wide locks.

mmap and other address space local modification may be able to avoid
taking mmap write lock by taking the read lock and then locking the
ptls in the page struct relevant to the address space being modified.

This is also enabled by this patchset.

> Only for page faults, not for anything that takes it for write.
>
> Anyways the better reader lock is a step in the right direction, but
> I have my doubts it's a good idea to make write really slow here.

The bigger the system the larger the problems with mmap. This is one key
scaling issue important for the VM. We can work on that. I have a patch
here that restricts the per cpu checks to only those cpus on which the
process has at some times run before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
