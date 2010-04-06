Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 988756B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 02:25:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o366OwZZ010171
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Apr 2010 15:24:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAB9D45DE50
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:24:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A72CE45DE51
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:24:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 840E21DB8045
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:24:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F599E78005
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:24:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Arch specific mmap attributes (Was: mprotect pgprot handling weirdness)
In-Reply-To: <1270534061.13812.56.camel@pasglop>
References: <20100406143928.7E4B.A69D9226@jp.fujitsu.com> <1270534061.13812.56.camel@pasglop>
Message-Id: <20100406151751.7E4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  6 Apr 2010 15:24:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 2010-04-06 at 14:52 +0900, KOSAKI Motohiro wrote:
> 
> (Adding linux-arch)
> 
> > This check was introduced the following commit. yes now we don't
> > consider arch specific PROT_xx flags. but I don't think it is odd.
> > 
> > Yeah, I can imagine at least embedded people certenary need arch
> > specific PROT_xx flags and they hope to change it. but I don't 
> > think mprotect() fit for your usage. I mean mprotect() is widely 
> > used glibc internally. then, If mprotec can change which flags, 
> > glibc might turn off such flags implictly.
> > 
> > So, Why can't we proper new syscall? It has no regression risk. 
> 
> I don't care much personally whether we use mprotect() or a new syscall,
> but at this stage we already have PROT_SAO going that way for powerpc so
> that would be an ABI change.
> 
> However, the main issue isn't really there. The main issue is that right
> now, everything we do in mmap.c, mprotect.c, ... revolves around having
> everything translated into the single vm_flags field. VMA merging
> decisions, construction of vm_page_prot, etc... everything is there.
> 
> However, this is a 32-bit field on 32-bit archs, and we already use all
> possible bits in there. It's also a field entirely defined in generic
> code with no provision for arch specific bits.
> 
> The question here thus boils down to what direction do we want to go to
> if we want to untangle that and provide the ability to expose mapping
> "attributes" basically. In fact, I suspect even x86 might have good use
> of that to create things like relaxed ordering mappings no ?
> 
> This boils down, so far to a few facts/questions to be resolved:
> 
>  - Do we want to use the existing PROT_ argument to mmap, mprotect,... ?
> There's plenty of bit space, and we already have at least one example of
> an arch adding something to it (powerpc with PROT_SAO - aka Strong
> Access Ordering - aka Make It Look Like An x86 :-)
> 
>  - If not, while a separate syscall would be fine with me for setting
> attributes after the fact, it makes it harder to pass them via mmap, is
> that a big deal ? IE. Ie it means one -always- has to call it after mmap
> to change the attributes. That means for example that mmap will
> potentially create a VMA merged with another one, just to be re-split
> due to the attribute change. A bit gross...
> 
>  - Do we want to keep the current "Funnel everything into vm_flags"
> approach ? That leaves no option that I can see but to extend it into a
> u64 so it grows on 32-bit archs. 
> 
>  - If not, I see two approaches here: Either having a separate / new
> "attribute" field in the VMA or going straight for the vm_page_prot (ie.
> the pgprot). In both cases, things like vma_merge() need to grow a new
> argument since obviously we can't merge things with different
> attributes.
> 
>  - ... Unless we just replace VM_SAO with VM_CANT_MERGE and set that
> whenever a VMA has a non-0 attributes. Sad but simpler
> 
> Any other / better idea ?

I guess you haven't catch my intention. I didn't say we have to remove 
PROT_SAO and VM_SAO.
I mean mmap(PROT_SAO) is ok, it's only append new flag, not change exiting
flags meanings. I'm only against mprotect(PROT_NONE) turn off PROT_SAO
implicitely.

IOW I recommend we use three syscall
	mmap()		create new mappings
	mprotect()	change a protection of mapping (as a name)
	mattribute(): (or similar name)
			change an attribute of mapping (e.g. PROT_SAO or
			another arch specific flags)

I'm not against changing mm/protect.c for PROT_SAO.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
