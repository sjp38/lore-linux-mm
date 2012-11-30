Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 30 Nov 2012 00:00:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
Message-Id: <20121130000043.cf356676.akpm@linux-foundation.org>
In-Reply-To: <50B85C8C.2030702@jp.fujitsu.com>
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com>
	<20121129153930.477e9709.akpm@linux-foundation.org>
	<50B82B0D.8010206@cn.fujitsu.com>
	<20121129215749.acfd872a.akpm@linux-foundation.org>
	<50B85C8C.2030702@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, viro@zeniv.linux.org.uk, bcrl@kvack.org, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 30 Nov 2012 16:13:16 +0900 Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > What about futexes?
> >
> 
> IIUC, futex's key is now a pair of (mm,address) or (inode, pgoff).
> Then, get_user_page() in futex.c will release the page by put_page().
> 'struct page' is just touched by get_futex_key() to obtain page->mapping info.

Ah yes, that page is unpinned before syscall return.

	grep -rl get_user_pages .

Gad.

These should be audited.  The great majority will be simple and OK,
but drivers/media, drivers/infiniband and net/rds could be problematic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
