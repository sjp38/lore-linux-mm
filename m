Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E08026B00A8
	for <linux-mm@kvack.org>; Tue, 21 May 2013 20:33:52 -0400 (EDT)
Date: Tue, 21 May 2013 17:33:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 6/7] mm: Support address range reclaim
Message-Id: <20130521173332.637942da.akpm@linux-foundation.org>
In-Reply-To: <1368084089-24576-7-git-send-email-minchan@kernel.org>
References: <1368084089-24576-1-git-send-email-minchan@kernel.org>
	<1368084089-24576-7-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Namhyung Kim <namhyung@kernel.org>, Minkyung Kim <minkyung88@lge.com>

On Thu,  9 May 2013 16:21:28 +0900 Minchan Kim <minchan@kernel.org> wrote:

> This patch adds address range reclaim of a process.
> The requirement is following as,
> 
> Like webkit1, it uses a address space for handling multi tabs.
> IOW, it uses *one* process model so all tabs shares address space
> of the process. In such scenario, per-process reclaim is rather
> coarse-grained so this patch supports more fine-grained reclaim
> for being able to reclaim target address range of the process.
> For reclaim target range, you should use following format.
> 
> 	echo [addr] [size-byte] > /proc/pid/reclaim
> 
> The addr should be page-aligned.
> 
> So now reclaim konb's interface is following as.
> 
> echo file > /proc/pid/reclaim
> 	reclaim file-backed pages only
> 
> echo anon > /proc/pid/reclaim
> 	reclaim anonymous pages only
> 
> echo all > /proc/pid/reclaim
> 	reclaim all pages
> 
> echo 0x100000 8K > /proc/pid/reclaim
> 	reclaim pages in (0x100000 - 0x102000)

This might be going a bit far.  The application itself can be modified
to use fadvise/madvise/whatever to release unused pages and that's a
better interface.

Athough it's a bit of a pipe-dream, I do think we should encourage
userspace to go this path, rather than providing ways for hacky admin
tools to go poking around in /proc/pid/maps and whacking apps
externally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
