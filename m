Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 778C56B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 16:54:37 -0400 (EDT)
Date: Fri, 27 Jul 2012 15:54:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value
 of move_pages() syscall
In-Reply-To: <1343411703-2720-4-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207271550190.25434@router.home>
References: <Yes> <1343411703-2720-1-git-send-email-js1304@gmail.com> <1343411703-2720-4-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>

On Sat, 28 Jul 2012, Joonsoo Kim wrote:

> move_pages() syscall may return success in case that
> do_move_page_to_node_array return positive value which means migration failed.

Nope. It only means that the migration for some pages has failed. This may
still be considered successful for the app if it moves 10000 pages and one
failed.

This patch would break the move_pages() syscall because an error code
return from do_move_pages_to_node_array() will cause the status byte for
each page move to not be updated anymore. Application will not be able to
tell anymore which pages were successfully moved and which are not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
