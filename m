Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 510BE6200BF
	for <linux-mm@kvack.org>; Mon, 10 May 2010 02:12:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4A6CUuL029488
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 May 2010 15:12:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B082A45DE70
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:12:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52C1E45DE7C
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:12:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FA6BE0800B
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:12:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 685F91DB8041
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:12:26 +0900 (JST)
Date: Mon, 10 May 2010 15:08:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] cgroups: make cftype.unregister_event()
 void-returning
Message-Id: <20100510150815.3d2f7647.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1273363822-7796-1-git-send-email-kirill@shutemov.name>
References: <1273363822-7796-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun,  9 May 2010 03:10:22 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Since we unable to handle error returned by cftype.unregister_event()
> properly, let's make the callback void-returning.
> 
> mem_cgroup_unregister_event() has been rewritten to be "never fail"
> function. On mem_cgroup_usage_register_event() we save old buffer
> for thresholds array and reuse it in mem_cgroup_usage_unregister_event()
> to avoid allocation.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Hmm, just reusing buffer isn't enough ?
as
	tmp = memory->thresholds;
	reduce entries on tmp
And what happens when

	register
	register
	register	
	unregister  (use preallocated buffer)
	unregister  ????
	unregister

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
