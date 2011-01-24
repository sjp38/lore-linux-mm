Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E0D546B00E7
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 19:14:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 26B1D3EE0B3
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:14:49 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ED7445DE4F
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:14:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E790F45DE51
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:14:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAD0F1DB803E
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:14:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A816F1DB8037
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:14:48 +0900 (JST)
Date: Mon, 24 Jan 2011 09:08:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix uninitialized variable use in
 mm/memcontrol.c::mem_cgroup_move_parent()
Message-Id: <20110124090844.e13e15af.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LNX.2.00.1101222044580.7746@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101222044580.7746@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Pavel Emelianov <xemul@openvz.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Sat, 22 Jan 2011 20:51:32 +0100 (CET)
Jesper Juhl <jj@chaosbits.net> wrote:

> In mm/memcontrol.c::mem_cgroup_move_parent() there's a path that jumps to 
> the 'put_back' label
>   	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, charge);
>   	if (ret || !parent)
>   		goto put_back;
>  where we'll 
>   	if (charge > PAGE_SIZE)
>   		compound_unlock_irqrestore(page, flags);
> but, we have not assigned anything to 'flags' at this point, nor have we 
> called 'compound_lock_irqsave()' (which is what sets 'flags').
> So, I believe the 'put_back' label should be moved below the call to 
> compound_unlock_irqrestore() as per this patch. 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Andrew, I'll move my new patces onto this. So, please pick this one 1st.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
