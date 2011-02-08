Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BA2908D003A
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 13:28:26 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p18ISElW004770
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:28:15 -0800
Received: from vxc38 (vxc38.prod.google.com [10.241.33.166])
	by wpaz9.hot.corp.google.com with ESMTP id p18IRHnv018591
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:28:13 -0800
Received: by vxc38 with SMTP id 38so2635738vxc.1
        for <linux-mm@kvack.org>; Tue, 08 Feb 2011 10:28:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297126056-14322-2-git-send-email-walken@google.com>
References: <1297126056-14322-1-git-send-email-walken@google.com>
	<1297126056-14322-2-git-send-email-walken@google.com>
Date: Tue, 8 Feb 2011 10:28:12 -0800
Message-ID: <AANLkTi=iYQCmKsE_xR4x0h-6BiVkpD3R2y6pKa1b9K0+@mail.gmail.com>
Subject: Re: [PATCH 1/2] mlock: fix race when munlocking pages in do_wp_page()
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Mon, Feb 7, 2011 at 4:47 PM, Michel Lespinasse <walken@google.com> wrote:
>
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

Acked-by: Hugh Dickins <hughd@google.com>

(but I have to say, do_wp_page() grows even ughlier!)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
