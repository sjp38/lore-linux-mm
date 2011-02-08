Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 11AB68D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 20:51:28 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AE1583EE0C0
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:51:21 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9318B45DE52
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:51:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F15C45DE4F
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:51:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6340AEF8002
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:51:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30814EF8006
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 10:51:21 +0900 (JST)
Date: Tue, 8 Feb 2011 10:45:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mlock: fix race when munlocking pages in
 do_wp_page()
Message-Id: <20110208104505.a737d179.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297126056-14322-2-git-send-email-walken@google.com>
References: <1297126056-14322-1-git-send-email-walken@google.com>
	<1297126056-14322-2-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Mon,  7 Feb 2011 16:47:35 -0800
Michel Lespinasse <walken@google.com> wrote:

> vmscan can lazily find pages that are mapped within VM_LOCKED vmas,
> and set the PageMlocked bit on these pages, transfering them onto the
> unevictable list. When do_wp_page() breaks COW within a VM_LOCKED vma,
> it may need to clear PageMlocked on the old page and set it on the
> new page instead.
> 
> This change fixes an issue where do_wp_page() was clearing PageMlocked on
> the old page while the pte was still pointing to it (as well as rmap).
> Therefore, we were not protected against vmscan immediately trasnfering
> the old page back onto the unevictable list. This could cause pages to
> get stranded there forever.
> 
> I propose to move the corresponding code to the end of do_wp_page(),
> after the pte (and rmap) have been pointed to the new page. Additionally,
> we can use munlock_vma_page() instead of clear_page_mlock(), so that
> the old page stays mlocked if there are still other VM_LOCKED vmas
> mapping it.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
