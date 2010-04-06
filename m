Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E52D06B020E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 18:15:35 -0400 (EDT)
Subject: Re: Arch specific mmap attributes (Was: mprotect pgprot handling
 weirdness)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100406185246.7E63.A69D9226@jp.fujitsu.com>
References: <20100406151751.7E4E.A69D9226@jp.fujitsu.com>
	 <1270539044.13812.65.camel@pasglop>
	 <20100406185246.7E63.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Apr 2010 08:15:11 +1000
Message-ID: <1270592111.13812.88.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-04-06 at 19:26 +0900, KOSAKI Motohiro wrote:
> > Ok, I see. No biggie. The main deal remains how we want to do that
> > inside the kernel :-) I think the less horrible options here are
> > to either extend vm_flags to always be 64-bit, or add a separate
> > vm_map_attributes flag, and add the necessary bits and pieces to
> > prevent merge accross different attribute vma's.
> 
> vma->vm_flags already have VM_SAO. Why do we need more flags?
> At least, I dislike to add separate flags member into vma.
> It might introduce unnecessary messy into vma merge thing.

Well, we did shove SAO in there, and used up the very last vm_flag for
it a while back. Now I need another one, for little endian mappings. So
I'm stuck.

But the problem goes further I believe. Archs do nowadays have quite an
interesting set of MMU attributes that it would be useful to expose to
some extent.

Some powerpc's also provide storage keys for example and I think ARM
have something along those lines. There's interesting cachability
attributes too, on x86 as well. Being able to use such attributes to
request for example a relaxed ordering mapping on x86 might be useful.

I think it basically boils down to either extend vm_flags to always be
64-bit, which seems to be Nick preferred approach, or introduct a
vm_attributes with all the necessary changes to the merge code to take
it into account (not -that- hard tho, there's only half a page of
results in grep for these things :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
