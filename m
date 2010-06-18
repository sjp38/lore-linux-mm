Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6C16B01C1
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 06:21:46 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1276797878-28893-1-git-send-email-jack@suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 18 Jun 2010 12:21:37 +0200
Message-ID: <1276856497.27822.1699.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> +               if (bdi_stat(bdi, BDI_WRITTEN) >=3D bdi->wb_written_head)
> +                       bdi_wakeup_writers(bdi);=20

For the paranoid amongst us you could make wb_written_head s64 and write
the above as:

  if (bdi_stat(bdi, BDI_WRITTEN) - bdi->wb_written_head > 0)

Which, if you assume both are monotonic and wb_written_head is always
within 2^63 of the actual bdi_stat() value, should give the same end
result and deal with wrap-around.

For when we manage to create a device that can write 2^64 pages in our
uptime :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
