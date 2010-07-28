Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CB9FA6B02A3
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:13:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S0Diw7017850
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 09:13:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE04145DE6F
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:13:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AC86945DE60
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:13:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80C541DB803A
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:13:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0C6F1DB8040
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:13:39 +0900 (JST)
Date: Wed, 28 Jul 2010 09:08:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-Id: <20100728090854.9b255f7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727122949.3bfbfd0a@bike.lwn.net>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727122949.3bfbfd0a@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 12:29:49 -0600
Jonathan Corbet <corbet@lwn.net> wrote:

> On Tue, 27 Jul 2010 16:53:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This virt-array allocates a virtally contiguous array via get_vm_area()
> > and allows object allocation per an element of array.
> 
> Quick question: this looks a lot like the "flexible array" mechanism
> which went in around a year ago, and which is documented in
> Documentation/flexible-arrays.txt.  I'm not sure we need two of
> these...  That said, it appears that there are still no users of
> flexible arrays.  If your virtually-indexed arrays provide something
> that flexible arrays don't, perhaps your implementation should replace
> flexible arrays?

Hmm. As Documentatin/flexible-arrays.txt says,

"The down sides are that the arrays cannot be indexed directly, individual object
 size cannot exceed the system page size, and putting data into a flexible array
 requires a copy operation. "

This virtually-indexed array is

 - the arrays can be indexed directly.
 - individual object size can be defined arbitrary.
 - puttind data into virt-array requires memory allocation via alloc_varray_item().

But, virtyally-indexed array has its own down side, too.

 - It uses vmalloc() area. This can be very limited in 32bit archs.
 - It cannot be used in !MMU archs.
 - It may consume much TLBs because vmalloc area tends not to be backed by hugepage.

Especially, I think !MMU case is much different. So, there are functional
difference. I implemented this to do quick direct access to objects by indexes.
Otherwise, flex-array may be able to provide more generic frameworks.

Then, I myself don't think virt-array is a replacemento for flex-array.

A discussion "flex-array should be dropped or not" is out of my scope, sorry.
I think you can ask to drop it just because it's almost dead without mentioning
virt-array.

Thanks,
-Kame
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
